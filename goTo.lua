-- simple goto API with persistence... maybe gets corrupt if the server shuts down/crashes during move!

-- originaly written by Keefkalif
-- updated by r-goebel 2020.01.28

local fFromXZ = {}
local id = os.computerID() 

fFromXZ[0]={}
fFromXZ[1]={}
fFromXZ[-1]={}
fFromXZ[0][1] = 0
fFromXZ[0][-1] = 2
fFromXZ[1][0] = 3
fFromXZ[-1][0] = 1

-- Variable to determine new x-Coordinate based on Direction F
local xDirFromF = {}
xDirFromF[0]=1      -- Direction north
xDirFromF[1]=0		-- Direction east
xDirFromF[2]=-1		-- Direction south
xDirFromF[3]=0		-- Direction west

-- Variable to determine new z-Coordinate based on Direction F
local zDirFromF = {}
zDirFromF[0]=0      -- Direction north
zDirFromF[1]=1		-- Direction east
zDirFromF[2]=0		-- Direction south
zDirFromF[3]=-1     -- Direction west

--*********************************************
-- Initialization of Position:
-- determine current Position
function getPos()
    local x,y,z = gps.locate()
    store("x",currentPosition.x)
    store("y",currentPosition.y)
    store("z",currentPosition.z)
    f=getDirection(currentPosition)
    store("f",currentPosition.f)
    return currentPosition
end

-- determine current Direction
function getDirection()
    local State = 1
    while State == 1 do
        forward()
        x,y,z = gps.locate()
        back()
        State = 0
        if x-currentPosition.x > 0 then         -- new x is greater --> moved to north
            f = 0
        elseif x-currentPosition.x < 0 then     -- new x is smaller --> moved to south
            f = 2    
        elseif z-currentPosition.z > 0 then     -- new z is greater --> moved to east
            f = 1
        elseif z-currentPosition.z < 0 then     -- new z is smaller --> moved to west
            f = 3
        else                                    -- turtle did not move, turn around and try again
            t.left()
            State = 1
        end
    end
    return f
end

-- sync Direction if it is out of bounds
function syncF()
	if currentPosition.f == -1 then
		currentPosition.f = 3
	elseif currentPosition.f == 4 then
		currentPosition.f = 0
	end
	store("f",currentPosition.f)
end

--*********************************************
-- Move Turtle:
-- Turn Left
function turnLeft()
	turtle.turnLeft()
	currentPosition.f = currentPosition.f -1
	syncF()
end

function turnRight()
	turtle.turnRight()
	currentPosition.f = currentPosition.f + 1
	syncF()
end

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
	store("x",currentPosition.x)
	store("z",currentPosition.z)
	return true
end

function back()
	if not turtle.back() then
		return false
	end
	currentPosition.x = currentPosition.x - xDirFromF[currentPosition.f]
	currentPosition.z = currentPosition.z - zDirFromF[currentPosition.f]
	store("x",currentPosition.x)
	store("z",currentPosition.z)
	return true
end

 function down()
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
	store("y",currentPosition.y)
	return true
end

 function up()
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
	store("y",currentPosition.y)
	return true
end

function turnToDir(toF)
	local spinCount = math.abs(currentPosition.f-toF);
	local spin = ((toF > currentPosition.f and spinCount < 3) or (currentPosition.f > toF and spinCount > 2)) and turnRight or turnLeft;
	spinCount = (spinCount > 2) and 4-spinCount or spinCount;
	for i=1,spinCount do
		spin();
	end
end

function forward()
	if not turtle.forward() then
			up()
	else
		currentPosition.x = currentPosition.x + xDirFromF[currentPosition.f]
		currentPosition.z = currentPosition.z + zDirFromF[currentPosition.f]
		store("x",currentPosition.x)
		store("z",currentPosition.z)
	end
	return true
end

function goTo( Position)
	while currentPosition.y < Position.y do
		up()
	end

	if currentPosition.x > Position.x then
		turnToDir(1)
		while currentPosition.x > Position.x do
			forward()
		end
	elseif currentPosition.x < Position.x then
		turnToDir(3)
		while currentPosition.x < Position.x do
			forward()
		end
	end
	
	if currentPosition.z > Position.z then
		turnToDir(2)
		while currentPosition.z > Position.z do
			forward()
		end
	elseif currentPosition.z < Position.z then
		turnToDir(0)
		while currentPosition.z < Position.z do
			forward()
		end	
	end

	while currentPosition.y > Position.y do
		down()
	end
	
	turnToDir(Position.f)
end

--function getPos()
--	return {x=currentPosition.x,y=currentPosition.y,z=currentPosition.z,f=currentPosition.f}
--end

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
--	store("f",Position.f)
--end


--function initialize()
--	if exists("x") then
--		currentPosition.x = pull("x")
--	end
--	if exists("y") then
--		currentPosition.y = pull("y")
--	end
--	if exists("z") then
--		currentPosition.z = pull("z")
--	end
--	if exists("f") then
--		currentPosition.f = pull("f")
--	end
--end

--function store(sName, stuff)
--        local filePath = fs.combine("/.persistance", sName)
--        if stuff == nil then
--                return fs.delete(filePath)
--        end
--        local handle = fs.open(sName, "w")
--        handle.write(textutils.serialize(stuff))
--        handle.close()
--end
 
--function pull(sName)
--        local handle = fs.open(sName, "r")
--        local stuff = handle.readAll()
--        handle.close()
--        return textutils.unserialize(stuff)
--end

--function exists(sName)
--	if not fs.exists(sName) then
--		return false
--	end
--	return true
--end