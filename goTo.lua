-- simple goto API with persistence... maybe gets corrupt if the server shuts down/crashes during move!

-- originaly written by Keefkalif

local x = 0
local y = 70
local z = 0
local f = 0
local url = "http://turtle.fgdo.de/Communicator.aspx"
local fFromXZ = {}
local id = os.computerID() 

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





function store(sName, stuff)
        local filePath = fs.combine("/.persistance", sName)
        if stuff == nil then
                return fs.delete(filePath)
        end
        local handle = fs.open(sName, "w")
        handle.write(textutils.serialize(stuff))
        handle.close()
end
 
function pull(sName)
        local handle = fs.open(sName, "r")
        local stuff = handle.readAll()
        handle.close()
        return textutils.unserialize(stuff)
end

function exists(sName)
	if not fs.exists(sName) then
		return false
	end
	return true
end

function syncF()
	if f == -1 then
		f = 3
	elseif f == 4 then
		f = 0
	end
	store("f",f)
end

 function turnLeft()
	turtle.turnLeft()
	f = f -1
	syncF()
end

 function turnRight()
	turtle.turnRight()
	f = f + 1
	syncF()
end

 function forward()
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
	x = x + xDirFromF[f]
	z = z + zDirFromF[f]
	store("x",x)
	store("z",z)
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

	y = y - 1
	store("y",y)
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

	y = y + 1
	store("y",y)
	return true
end

function turnToDir(toF)
	local spinCount = math.abs(f-toF);
	local spin = ((toF > f and spinCount < 3) or (f > toF and spinCount > 2)) and turnRight or turnLeft;
	spinCount = (spinCount > 2) and 4-spinCount or spinCount;
	for i=1,spinCount do
		spin();
	end
end

function xForward()
	if not turtle.forward() then
			up()
	else
		x = x + xDirFromF[f]
		z = z + zDirFromF[f]
		store("x",x)
		store("z",z)
	end
	return true
end

 function mForward()
	turtle.digUp()
	turtle.digDown()
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

	x = x + xDirFromF[f]
	z = z + zDirFromF[f]
	store("x",x)
	store("z",z)
	if turtle.getItemCount(16) > 0 then
		dropOff()
	end
	return true
end

function goTo( toX,toY,toZ, toF)
	print("Position: X:"..  x .. " Y:".. y .. " Z:".. z .. " F:".. f)
	print("Going to: X:"..  toX .. " Y:".. toY .. " Z:".. toZ .. " F:".. toF)
	while y < toY do
		up()
		print("Position: X:"..  x .. " Y:".. y .. " Z:".. z .. " F:".. f)
		print("Going to: X:"..  toX .. " Y:".. toY .. " Z:".. toZ .. " F:".. toF)
	end

	if x > toX then
		turnToDir(1)
		while x > toX do
			xForward()
			print("Position: X:"..  x .. " Y:".. y .. " Z:".. z .. " F:".. f)
			print("Going to: X:"..  toX .. " Y:".. toY .. " Z:".. toZ .. " F:".. toF)
		end
	elseif x < toX then
		turnToDir(3)
		while x < toX do
			xForward()
			print("Position: X:"..  x .. " Y:".. y .. " Z:".. z .. " F:".. f)
			print("Going to: X:"..  toX .. " Y:".. toY .. " Z:".. toZ .. " F:".. toF)
		end
	end
	
	if z > toZ then
		turnToDir(2)
		while z > toZ do
			xForward()
			print("Position: X:"..  x .. " Y:".. y .. " Z:".. z .. " F:".. f)
			print("Going to: X:"..  toX .. " Y:".. toY .. " Z:".. toZ .. " F:".. toF)
		end
	elseif z < toZ then
		turnToDir(0)
		while z < toZ do
			xForward()
			print("Position: X:"..  x .. " Y:".. y .. " Z:".. z .. " F:".. f)
			print("Going to: X:"..  toX .. " Y:".. toY .. " Z:".. toZ .. " F:".. toF)
		end	
	end

	while y > toY do
		down()
	end
	
	turnToDir(toF)
end


function initialize()
	if exists("x") then
		x = pull("x")
	else
		x=345
	end
	if exists("y") then
		y = pull("y")
	else
		y=88
	end
	if exists("z") then
		z = pull("z")
	else
		z=-31
	end
	if exists("f") then
		f = pull("f")
	else
		f=2
	end
	--möchte man hier nicht auch speichern?
end
