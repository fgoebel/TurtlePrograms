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
    if not fs.exists("StoragePos") then
        initialization = true
    else 
        local file = fs.open("StoragePos","r")
        local data = file.readAll()
        file.close()
        storage = textutils.unserialize(data)
        initialization = false
    end
    ManagerID, message = rednet.receive()               -- waits for a broadcast to receive ID of manager
    
    -- initialization store storage Position
    if initialization then
        rednet.send(ManagerID,"I am new","New")             -- send message to manager using protocol "New"
        ManagerID, StorageMessage = rednet.receive("New")   -- listening to messages on protocol "New"
        storage = textutils.unserialize(StorageMessage)
        store("StoragePos",storage)
    end
end

-- General Farming Programm
function main()
local FirstInQueue = false
local BackHome = false
local Waiting = true

while true do

    if (Waiting and not FirstInQueue) then                      -- State: Waiting in Queue
        print("waiting in queue")
        valid, block = turtle.inspectDown()                     -- Check for first position, based on block below (oak-stairs on first Position)
        if valid then
            if block.name == "minecraft:oak_stairs" then        -- on first Position
                FirstInQueue = true                             -- change FirstInQueue state
            elseif not turtle.detect() then                     -- check if someone is in front
                goTo.forward()                                  -- go forward
            end
        end
    
    elseif (Waiting and FirstInQueue) then                      -- State: Waiting and First in Queue
        print("waiting for field")
        rednet.send(ManagerID,"I am first","Queue")             -- send message to manager using protocol "Queue"
        ID, message = rednet.receive("Queue",2)                 -- listening to messages on protocol "Queue"
        if message ~= nil then
            if textutils.unserialize(message) ~= nil then       -- message was field
                rednet.send(ID,"got it", "Field")               -- send message to manager using protocol "Field"
                field = textutils.unserialize(message)
                Waiting = false                                 -- change state of Waiting and First in Queue
                FirstInQueue = false
            end
        end

    elseif BackHome then                                        -- State: Back home
        rednet.send(ManagerID,"I am back","BackHome")           -- send message to manager to announce returning using protocol "BackHome"
        ID, message, protocol = rednet.receive("BackHome",2)    -- listening to messages on protocol "BackHome"
        if message == "go to queue" then                        -- is send to queue
            ToQueue()
            BackHome = false
            Waiting = true
        elseif message ~= nil then
            if textutils.unserialize(message) ~= nil then       -- message was field
                rednet.send(ID,"got it","Field")                -- send message to manager using protocol "Field"
                field = textutils.unserialize(message)
                Waiting = false                                 -- change state of Waiting and First in Queue
                BackHome = false
            end
        end

    elseif not Waiting and not BackHome then                    -- State: not waiting, harvesting
        print("Start farming on: ".. field.name)
        goTo.goTo(storage)
        farming.start(field,storage)                            -- go working
        BackHome = true                                         -- change BackHomeState
    end
end
end

rednet.open("left")
goTo.getPos()
initialization()
main()