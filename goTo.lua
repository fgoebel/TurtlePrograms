-- simple goto API with persistence... maybe gets corrupt if the server shuts down/crashes during move!
-- originaly written by Keefkalif
local robot = require("robot")
local gt = {} -- table with functions...





local currentPosition = {
    x = 0,
    y = 70,
    z = 0,
    f = 0
}

local fFromXZ = {}
--local id = os.computerID() 

fFromXZ[0]={}
fFromXZ[1]={}
fFromXZ[-1]={}
fFromXZ[0][1] = 0
fFromXZ[0][-1] = 2
fFromXZ[1][0] = 3
fFromXZ[-1][0] = 1
		
local xDirFromF = {}
xDirFromF[0]=0
xDirFromF[1]=-1		
xDirFromF[2]=0		
xDirFromF[3]=1		


local zDirFromF = {}
zDirFromF[0]=1
zDirFromF[1]=0		
zDirFromF[2]=-1		
zDirFromF[3]=0

function gt.store(sName, stuff)
        local filePath = filesystem.concat("/.persistance", sName)
        if stuff == nil then
                return filesystem.delete(filePath)
        end
        local handle = filesystem.open(sName, "w")
        handle.write(textutils.serialize(stuff))
        handle.close()
end
 
function gt.pull(sName)
        local handle = filesystem.open(sName, "r")
        local stuff = handle.readAll()
        handle.close()
        return textutils.unserialize(stuff)
end

function gt.exists(sName)
	if not filesystem.exists(sName) then
		return false
	end
	return true
end

function syncF()
	if currentPosition.f == -1 then
		currentPosition.f = 3
	elseif currentPosition.f == 4 then
		currentPosition.f = 0
	end
	store("f",currentPosition.f)
end

 function gt.turnLeft()
	if robot.turnLeft() then
		currentPosition.f = currentPosition.f -1
		syncF()
	end
end

 function gt.turnRight()
	if robot.turnRight() then
		currentPosition.f = currentPosition.f + 1
		syncF()
	end
end

 function gt.forward()
	while not robot.forward() do
		if robot.detect() then
			if robot.swing() then
			else
				return false
			end
		elseif robot.swing() then --ursprünglich attack
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

function gt.back()
	if not robot.back() then
		return false
	end
	currentPosition.x = currentPosition.x - xDirFromF[currentPosition.f]
	currentPosition.z = currentPosition.z - zDirFromF[currentPosition.f]
	store("x",currentPosition.x)
	store("z",currentPosition.z)
	return true
end

 function gt.down()
	while not robot.down() do
		if robot.detectDown() then
			if robot.swingDown() then --ursprünglich digDown
			else
				return false
			end
		elseif robot.swingDown() then --ursprünglich attackDown
		else
			sleep( 0.5 )
		end
	end

	currentPosition.y = currentPosition.y - 1
	store("y",currentPosition.y)
	return true
end

 function gt.up()
	while not robot.up() do
		if robot.detectUp() then
			if robot.swingUp() then
			else
				return false
			end
		elseif robot.swingUp() then
		else
			sleep( 0.5 )
		end
	end

	currentPosition.y = currentPosition.y + 1
	store("y",currentPosition.y)
	return true
end

function gt.turnToDir(toF)
	local spinCount = math.abs(currentPosition.f-toF);
	local spin = ((toF > currentPosition.f and spinCount < 3) or (currentPosition.f > toF and spinCount > 2)) and turnRight or turnLeft;
	spinCount = (spinCount > 2) and 4-spinCount or spinCount;
	for i=1,spinCount do
		spin();
	end
end

function gt.xForward()
	if not robot.forward() then
			up()
	else
		currentPosition.x = currentPosition.x + xDirFromF[currentPosition.f]
		currentPosition.z = currentPosition.z + zDirFromF[currentPosition.f]
		store("x",currentPosition.x)
		store("z",currentPosition.z)
	end
	return true
end

function gt.goTo( Position)
	while currentPosition.y < Position.y do
		up()
	end

	if currentPosition.x > Position.x then
		turnToDir(1)
		while currentPosition.x > Position.x do
			xForward()
		end
	elseif currentPosition.x < Position.x then
		turnToDir(3)
		while currentPosition.x < Position.x do
			xForward()
		end
	end
	
	if currentPosition.z > Position.z then
		turnToDir(2)
		while currentPosition.z > Position.z do
			xForward()
		end
	elseif currentPosition.z < Position.z then
		turnToDir(0)
		while currentPosition.z < Position.z do
			xForward()
		end	
	end

	while currentPosition.y > Position.y do
		down()
	end
	
	turnToDir(Position.f)
end

function gt.getPos()
	return {x=currentPosition.x,y=currentPosition.y,z=currentPosition.z,f=currentPosition.f}
end

function gt.setPos(Position)
    currentPosition.x = Position.x
    currentPosition.y = Position.y
    currentPosition.z = Position.z
    currentPosition.f = Position.f
    storePosition(Position)
end

function gt.storePosition(Position)
    store("x",Position.x)
	store("y",Position.y)
	store("z",Position.z)
	store("f",Position.f)
end


function gt.initialize()
	if exists("x") then
		currentPosition.x = pull("x")
	end
	if exists("y") then
		currentPosition.y = pull("y")
	end
	if exists("z") then
		currentPosition.z = pull("z")
	end
	if exists("f") then
		currentPosition.f = pull("f")
	end
end

return gt