-- Using Wireless Mining Turtle
-- Turtle is send by computer using Manage.lua
-- depends on FarmingNew and goTo API

--*********************************************
-- load APIs
if not fs.exists("goTo.lua") then
	r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/goTo.lua")
    f = fs.open("goTo.lua", "w")
    f.write(r.readAll())
    f.close()
    r.close()
end
os.loadAPI("goTo.lua") 

if not fs.exists("farming.lua") then
	r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/farm/FarmingNew.lua")
    f = fs.open("farming.lua", "w")
    f.write(r.readAll())
    f.close()
    r.close()
end
os.loadAPI("farming.lua") 

--*********************************************
--function to display heartbeat
function heartbeat()
    -- term.clear()
    currentFuelLevel = turtle.getFuelLevel()
	if waiting then
		print("current Status: waiting for input")
	else
		print("current Status: Working")
	end

    print("fuelLevel: " .. currentFuelLevel)
end

--*********************************************
-- Store values
function store(sName, stuff)
	local handle = fs.open(sName, "w")
	handle.write(textutils.serialize(stuff))
	handle.close()
end

function ToQueue()
local EndofQueue = false
    goTo.up()
    goTo.turnLeft()
    goTo.forward()
    goTo.turnRight()
    while not EndofQueue do
        if turtle.inspect() then
            goTo.turnLeft()
            goTo.forward()
            goTo.turnRight()
        else
            EndofQueue = true
        end
    end
    goTo.forward()
    goTo.turnRight()
end

--*********************************************
-- Initialization
function initialization()
local initialization = false
if not fs.exists("StoragePos") then
    initialization = true
else 
    local file = fs.open("StoragePos","r")
    local data = file.readAll()
    file.close()
    storage = textutils.unserialize(data)
end

    while initialization do         -- initialization store storage and queue Position
        ID, message = rednet.receive()
        if message == "New?" then
            rednet.send(ID,"I am new")
            ID, StorageMessage = rednet.receive()
            storage = textutils.unserialize(StorageMessage)
            store("StoragePos",storage)
            initialization = false  -- change initialization state
        end
    end

end

-- General Farming Programm
function main()
local FirstInQueue = false
local BackHome = false
local Waiting = true

while true do

    if (Waiting and not FirstInQueue) then      -- State: Waiting in Queue
        print("waiting in queue")
        valid, block = turtle.inspectDown()     -- Check for first position, based on block below (oak-stairs on first Position)
        if valid then
            if block.name == "minecraft:oak_stairs" then -- on first Position
                FirstInQueue = true                      -- change FirstInQueue state
            elseif not turtle.detect() then              -- check if someone is in front
                goTo.forward()                           -- go forward
            end
        end
    
    elseif (Waiting and FirstInQueue) then       -- State: Waiting and First in Queue
        print("waiting for field")
        ID, message = rednet.receive(2)
        if message == "in queue?" then           -- answer to "in queue?" call
            rednet.send(ID,"yes, in queue")
        elseif message ~= nil then
            if textutils.unserialize(message) ~= nil then -- message was field
                field = textutils.unserialize(message)
                Waiting = false                      -- change state of Waiting and First in Queue
                FirstInQueue = false
            end
        end

    elseif BackHome then                         -- State: Back home
        ID, message = rednet.receive(10)
        print("Message after return: "..message)
        if message == "coming home?" then        -- answer to "coming home?" call
            rednet.send(ID,"yes, back home")
        elseif message == "go to queue" then     -- is send to queue
            ToQueue()
        elseif message ~= nil then
            if textutils.unserialize(message) ~= nil then -- message was field
                field = textutils.unserialize(message)
                Waiting = false                      -- change state of Waiting and First in Queue
                BackHome = false
            end
        end

    elseif not Waiting and not BackHome then     -- State: not waiting, harvesting
        print("Start farming on: ".. field.name)
        goTo.goTo(storage)
        farming.start(field,storage)             -- go working
        BackHome = true                          -- change BackHomeState
    end
end
end

rednet.open("left")
goTo.getPos()
initialization()
main()