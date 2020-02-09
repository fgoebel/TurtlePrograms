-- Using Wireless Modem on right side of Computer
-- Sends Turtle to farming

--*********************************************
-- defintion of variables
local time = 0
local NextField
local minTime
local LastTime = os.time()*1000*0.05 --Time in real-Life seconds
local Time = 0

local storagePos = textutils.serialize({x=122,y=63,z=-261,f=3})

-- Load field file
if not fs.exists("fields") then
    r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/farm/fields")
    f = fs.open("fields", "w")
    f.write(r.readAll())
    f.close()
    r.close()
end

local file = fs.open("fields","r")
local data = file.readAll()
file.close()
fields = textutils.unserialize(data)

for k,field in ipairs(fields) do 
    field.lastHarvested = -1*field.interval    -- set initial value for lastHarvested
end

--*********************************************
-- Store fields
function store(sName, stuff)
	local handle = fs.open(sName, "w")
	handle.write(textutils.serialize(stuff))
	handle.close()
end

-- determine RunTime
function checkTime()
    local CurrentTime = os.time()*1000*0.05       --Time in real-Life seconds
    if CurrentTime > LastTime then
        TimePassed = CurrentTime - LastTime
    else 
        TimePassed = CurrentTime + (24*1000*0.05-LastTime)
    end
    LastTime = CurrentTime
    Time = Time + TimePassed
    return Time
end
--*********************************************
-- Main Managing function
store("fields", fields)

function main()
local Turtlestate = false
local Queuestate = false
local Fieldstate = false

while true do
    -- Turtlestate: false-->Noone back from field, true-->Someone returned and is now waiting for input
    if Turtlestate == false then
        rednet.broadcast("coming home?")                        -- check for new returnees
        ID, message = rednet.receive(2)
        if message == "yes, back home" then                     -- if someone returned: store ID, change state
            ReturnerID = ID
            Turtlestate = true
        end
    end

    -- Queuestate: false--> Noone is waiting in queue, true--> Someone is waiting
    if Queuestate == false then
        print("waiting for turtles")
        rednet.broadcast("in queue?")                           -- check for someone in queue
        ID, message = rednet.receive(2)
        if message == "yes, in queue" then                      -- if someone is in queue: store ID, change state
            QueueID = ID
            Queuestate = true
        end        
    end

    -- Fieldstate: false-->kein Feld verfügbar, true-->Feld verfügbar
    if Fieldstate == false then
        print("waiting for fields")                                 
        minTime = 0                                             -- check for new field
        NextField = "none"
        for k,field in ipairs(fields) do
            if ((field.lastHarvested + field.interval - Time <= minTime) and field.active == true) then   
                minTime = field.lastHarvested + field.interval - Time      -- select field based on lowest value
                FieldIndex = k                                             -- if new field available: store field index
            end
        end
        if Nextfield ~= "none" then                             -- if new field available: change state
            Fieldstate = true
            print("new field to harvest")
        end
    end
  
    -- Actions:
    if Turtlestate==true then                                   -- Turtle returned from field
        if (Queuestate == false and Fieldstate == true) then    -- Noone is in queue and field is available
            NextField = textutils.serialize(fields[FieldIndex]) -- serialize field table
            rednet.send(ReturnerID,NextField)                   -- send field to turtle
            fields[FieldIndex].lastHarvested = Time             -- update field harvesting time
            store("fields", fields)
            Fieldstate = false                                  -- Change Fieldstate and Queuestate
            Queuestate = true   
            print(fields[FieldIndex].name)
        else                                                    -- either no field or someone in queue
            rednet.send(ReturnerID,"go to queue")               -- initialize sending to queue
        end
        Turtlestate = false                                     -- Change Turtlestate

    elseif (Fieldstate == true and Queuestate == true) then     -- Field needs to be harvested and someone is available in queue 
        NextField = textutils.serialize(fields[FieldIndex])     -- serialize field table
        rednet.send(QueueID,NextField)                          -- send field to turtle
        fields[FieldIndex].lastHarvested = Time                 -- update field harvesting time
        store("fields", fields)
        Fieldstate = false                                      -- Change Fieldstate and Queuestate
        Queuestate = false  
    end

    rednet.broadcast("New?")
    NewID, message = rednet.receive(2)
    if message == "I am new" then
        print("found new turtle")
        rednet.send(NewID,storagePos)                           -- send storage position
    end
   

    -- check for new fields (Overwriting not possible!!!)

    Time = checkTime()                                          -- Update Time
end
end

rednet.open("right")
main()