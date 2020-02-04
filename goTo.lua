-- simple goto API with persistence... maybe gets corrupt if the server shuts down/crashes during move!

-- originaly written by Keefkalif
-- updated by r-goebel 2020.01.28

local id = os.computerID() 
local currentPosition = {
    x = 0,
    y = 0,
    z = 0,
    f = 0
}

--Variable to determine Direction F based on change in X and Z
local fFromXZ = {}
fFromXZ[0]={}
fFromXZ[1]={}
fFromXZ[-1]={}
fFromXZ[0][1] = 2   -- Moved to positive Z Direction --> south
fFromXZ[0][-1] = 0  -- Moved to negative Z Direction --> north
fFromXZ[1][0] = 1   -- Moved to positive X Direction --> east
fFromXZ[-1][0] = 3  -- Moved to negative X Direction --> west

-- Variable to determine new x-Coordinate based on Direction F
local xDirFromF = {}
xDirFromF[0]=0      -- Direction north
xDirFromF[1]=1		-- Direction east
xDirFromF[2]=0		-- Direction south
xDirFromF[3]=-1		-- Direction west

-- Variable to determine new z-Coordinate based on Direction F
local zDirFromF = {}
zDirFromF[0]=-1     -- Direction north
zDirFromF[1]=0		-- Direction east
zDirFromF[2]=1		-- Direction south
zDirFromF[3]=0      -- Direction west

--*********************************************
-- Initialization of Position:
-- determine current Position
function getPos()
	local x,y,z = gps.locate()
	print(x,y,z)
	currentPosition.x = x
	currentPosition.y = y
	currentPosition.z = z
	currentPosition.f = getDirection()
	store("currentPosition",currentPosition)
	print(currentPosition.f)
	sleep(10)
end

-- determine current Direction
function getDirection()
    while not turtle.forward() do  -- turn if moving foward was not possible and try again
        turtle.turnLeft()
    end
	x,y,z = gps.locate()           -- get new Position
	turtle.back()                  -- move back
	f = fFromXZ[x-currentPosition.x][z-currentPosition.z] --determine Direction based on Position difference
	return f
end

-- sync Direction if it is out of bounds
function syncF()
	if currentPosition.f == -1 then
		currentPosition.f = 3
	elseif currentPosition.f == 4 then
		currentPosition.f = 0
	end
	store("currentPosition",currentPosition)
end

--*********************************************
-- Move Turtle:
-- Turn Left
function turnLeft()
	turtle.turnLeft()
	currentPosition.f = currentPosition.f -1
	syncF()
end

--Turn Right
function turnRight()
	turtle.turnRight()
	currentPosition.f = currentPosition.f + 1
	syncF()
end

--Move forward
function forward()
	if not turtle.forward() then
		up()
	else
		currentPosition.x = currentPosition.x + xDirFromF[currentPosition.f]
		currentPosition.z = currentPosition.z + zDirFromF[currentPosition.f]
		store("currentPosition",currentPosition)
	end
	return true
end

--Force to move forward
function forwardForce()
	while not turtle.forward() do
		if turtle.detect() then
			if turtle.dig() then
			else
				return false
			end
		elseif turtle.attack() then
		else
			sleep( 0.5 )
		end
	end
	currentPosition.x = currentPosition.x + xDirFromF[currentPosition.f]
	currentPosition.z = currentPosition.z + zDirFromF[currentPosition.f]
	store("currentPosition",currentPosition)
	return true
end

--Move back
function back()
	if not turtle.back() then
		up()
    else
	    currentPosition.x = currentPosition.x - xDirFromF[currentPosition.f]
	    currentPosition.z = currentPosition.z - zDirFromF[currentPosition.f]
	    store("currentPosition",currentPosition)
    end
	return true
end

--Move down
function down()
	if not turtle.down() then
        return false
    end
	currentPosition.y = currentPosition.y - 1
	store("currentPosition",currentPosition)
	return true
end

--Force to move down
function downForce()
	while not turtle.down() do
		if turtle.detectDown() then
			if turtle.digDown() then
			else
				return false
			end
		elseif turtle.attackDown() then
		else
			sleep( 0.5 )
		end
	end

	currentPosition.y = currentPosition.y - 1
	store("currentPosition",currentPosition)
	return true
end

--Move up
function up()
	if not turtle.up() then
        return false
    end
	currentPosition.y = currentPosition.y + 1
	store("currentPosition",currentPosition)
	return true
end

--Force to move up
function upForce()
	while not turtle.up() do
		if turtle.detectUp() then
			if turtle.digUp() then
			else
				return false
			end
		elseif turtle.attackUp() then
		else
			sleep( 0.5 )
		end
	end

	currentPosition.y = currentPosition.y + 1
	store("currentPosition",currentPosition)
	return true
end

--Turn to specific direction
function turnToDir(toF)
	local spinCount = math.abs(currentPosition.f-toF);
	local spin = ((toF > currentPosition.f and spinCount < 3) or (currentPosition.f > toF and spinCount > 2)) and turnRight or turnLeft;
	spinCount = (spinCount > 2) and 4-spinCount or spinCount;
	for i=1,spinCount do
		spin();
	end
	currentPosition.f=toF
	store("currentPosition",currentPosition)
end

--go to Positon
function goTo(Position)
    -- first move up
    while currentPosition.y < Position.y do
		up()
	end
    -- go to new x
	if currentPosition.x > Position.x then      -- go to south
		turnToDir(2)
		while currentPosition.x > Position.x do
			forward()
		end
	elseif currentPosition.x < Position.x then  -- go to north
		turnToDir(0)
		while currentPosition.x < Position.x do
			forward()
		end
	end
	-- go to new z
	if currentPosition.z > Position.z then      -- go to west
		turnToDir(3)
		while currentPosition.z > Position.z do
			forward()
		end
	elseif currentPosition.z < Position.z then  -- go to east
		turnToDir(1)
		while currentPosition.z < Position.z do
			forward()
		end	
	end
    -- go down
	while currentPosition.y > Position.y do
		down()
	end
	
	turnToDir(Position.f)
end

--Storing values
function store(sName, stuff)
	if stuff == nil then
			return fs.delete(sName)
	end
	local handle = fs.open(sName, "w")
	handle.write(textutils.serialize(stuff))
	handle.close()
end

-- Read variable from File
function pull(sName)
	local handle = fs.open(sName, "r")
	local stuff = handle.readAll()
	handle.close()
	return textutils.unserialize(stuff)
end

function returnPos()
	getPos()				-- to ensure correct position is returned
	return currentPosition
end

--function setPos(Position)
--    currentPosition.x = Position.x
--    currentPosition.y = Position.y
--    currentPosition.z = Position.z
--    currentPosition.f = Position.f
--    storePosition(Position)
--end

--function storePosition(Position)
--    store("x",Position.x)
--	store("y",Position.y)
--	store("z",Position.z)
--	store("f",Position.f)h.
--end

--function exists(sName)
--	if not fs.exists(sName) then
--		return false
--	end
--	return true
--end