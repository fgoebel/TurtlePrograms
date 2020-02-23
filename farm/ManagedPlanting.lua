-- Using Wireless harvesting Turtle
-- Turtle is send by computer using Manage.lua
-- depends on plantField and goTo API

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

if not fs.exists("planting.lua") then
	r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/farm/plantField.lua")
    f = fs.open("planting.lua", "w")
    f.write(r.readAll())
    f.close()
    r.close()
end
os.loadAPI("planting.lua") 

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
    goTo.goTo(queue)
    while not EndofQueue do
        if turtle.inspect() then
            goTo.up()
        else
            EndofQueue = true
        end
    end
    goTo.forward()
end

--*********************************************
-- Initialization
function initialization()
    if not fs.exists("StoragePos") or not fs.exists("QueuePos") then
        initialization = true
    else 
        local file = fs.open("StoragePos","r")
        local data = file.readAll()
        file.close()
        storage = textutils.unserialize(data)
        local file = fs.open("QueuePos","r")
        local data = file.readAll()
        file.close()
        queue = textutils.unserialize(data)
        initialization = false
    end
    ManagerID, message = rednet.receive("Init")              -- waits for a broadcast to receive ID of manager

    -- initialization store storage Position
    if initialization then
        rednet.send(ManagerID,"I am new planting","New")  -- send message to manager using protocol "New"
        ManagerID, StorageMessage = rednet.receive("New")   -- listening to messages on protocol "New"
        ManagerID, QueueMessage = rednet.receive("New")     -- listening to messages on protocol "New"
        storage = textutils.unserialize(StorageMessage)
        store("StoragePos",storage)
        queue = textutils.unserialize(QueueMessage)
        store("QueuePos",queue)
    end
end

-- General planting Programm
function main()
    local FirstInQueue = false
    local Waiting = true
    
    while true do
    
        if (Waiting and not FirstInQueue) then                      -- State: Waiting in Queue
            sleep(5)
            print("waiting in queue")
            valid, block = turtle.inspectDown()                      -- Check for first position, based on block below (cobble on first Position)
            if valid then
                if block.name == "minecraft:cobblestone" then
                    FirstInQueue = true
                end
            else
                goTo.down()
            end
        
        elseif (Waiting and FirstInQueue) then                      -- State: Waiting and First in Queue
            print("waiting for field")
            rednet.send(ManagerID,"I am first","PlantQueue")        -- send message to manager using protocol "Queue"
            ID, message = rednet.receive("PlantQueue",2)            -- listening to messages on protocol "Queue"
            print(message)
                if message ~= nil then
                    if textutils.unserialize(message) ~= nil then   -- message was field
                        rednet.send(ID,"got it", "Planting")        -- send message to manager using protocol "Field"
                        field = textutils.unserialize(message)
                        Waiting = false                             -- change state of Waiting and First in Queue
                        FirstInQueue = false
                    end
                else 
                    sleep(5)
                end
    
        elseif not Waiting then                                     -- State: not waiting, harvesting
            print("Start planting on: ".. field.name)
            goTo.goTo(queue)                                     -- just to avoid crashes
            goTo.goTo(storage)
            planting.planting(field,storage)                        -- go working
            rednet.send(ManagerID,"back", "FinishedPlanting")
            goTo.back()
  
            ToQueue()                                               -- go to queue
            Waiting = true
        end
    end
end

rednet.open("left")
goTo.getPos()
initialization()
main()