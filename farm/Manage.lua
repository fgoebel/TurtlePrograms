-- Using Wireless Modem on right side of Computer
-- Sends Turtle to farming

--*********************************************
-- defintion of variables
local time = 0
local NextField
local minTime
local LastTime = os.time()*1000*0.05 --Time in real-Life seconds
local Time = 0

local storage = {
    x=122,
    y=63,
    z=-261,
    f=3
}

-- load json API from github if it does not exist yet
if not fs.exists("json.lua") then
	r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/json.lua")
    f = fs.open("json.lua", "w")
    f.write(r.readAll())
    f.close()
    r.close()
end
os.loadAPI("json.lua") 

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

--*********************************************
-- Store fields
function store(sName, stuff)
	local handle = fs.open(sName, "w")
	handle.write(textutils.serialize(stuff))
	handle.close()
end

-- determine Time
function checkTime()
    local TimeTable = http.get("http://worldtimeapi.org/api/timezone/Europe/Berlin").readAll()
    Time = json.decode(TimeTable).unixtime
    return Time
end

--*********************************************
-- Main Managing function
function main()
local Turtlestate = false
local Queuestate = false
local Fieldstate = false

while true do
    Time = checkTime()                                                      -- Update Time
    rednet.broadcast("just a broadcast")                                    -- Broadcast message to find new turtles
    ID, message, protocol = rednet.receive(2)                               -- check for messages

    -- Processing Message:
    -- Protocol = "Queue" --> Trutle is waiting on first position
    if protocol == "Queue" then
        print("found someone on queue")
        QueueID = ID
        Queuestate = true       

    -- Protocol = BackHome --> Turtle came back home and waits for input
    elseif protocol == "BackHome" then
        ReturnerID = ID
        Turtlestate = true        

    -- Protocol = "Field" --> Turtle received field and starts harvesting
    elseif protocol == "Field" then 
        Fieldstate = false                                                  -- Change Fieldstate and Queuestate
        Queuestate = false                                                  
        fields[FieldIndex].lastHarvested = Time                             -- update field harvesting time
        store("fields", fields)
        sleep(10)
    
    -- Protocol = "New" --> New Turtle needs input
    elseif protocol == "New" then
        print("found new turtle")
        NewID = ID
        storagePos = textutils.serialize(storage)
        rednet.send(NewID,storagePos,"New")                                 -- send storage position using protocol "New"
    end
    
    -- Update Fieldstate
    -- Fieldstate: false-->no field available/turtle was send, true-->field available
    if Fieldstate == false then
        print("waiting for fields")                                 
        minTime = 0                                                         -- check for new field
        FieldIndex = 0
        for k,field in ipairs(fields) do
            if ((field.lastHarvested + field.interval - Time <= minTime) and field.active == true) then   
                minTime = field.lastHarvested + field.interval - Time       -- select field based on lowest value
                FieldIndex = k                                              -- if new field available: store field index
            end
        end
        if FieldIndex ~= 0 then                                             -- if new field available: change state
            Fieldstate = true
            print("new field to harvest: "..fields[FieldIndex].name)
        end
    end

    -- Send Turtle
    -- Turtlestate: false-->Noone back from field, true-->Someone returned and is now waiting for input
        if Turtlestate==true then                                              -- Turtle returned from field
        if (Queuestate == false and Fieldstate == true) then                -- Noone is in queue and field is available
            NextField = textutils.serialize(fields[FieldIndex])             -- serialize field table
            rednet.send(ReturnerID,NextField,"BackHome")                    -- send field to turtle using protocol "BackHome"
            print(fields[FieldIndex].name)
        else                                                                -- either no field or someone in queue
            rednet.send(ReturnerID,"go to queue","BackHome")                -- initialize sending to queue using protocol "BackHome"
        end
        Turtlestate = false                                                 -- Change Turtlestate

    elseif (Fieldstate == true and Queuestate == true) then                 -- Field needs to be harvested and someone is available in queue
        print("try to send field") 
        NextField = textutils.serialize(fields[FieldIndex])                 -- serialize field table
        rednet.send(QueueID,NextField,"Queue")                              -- send field to turtle using protocol "Queue"
        print(fields[FieldIndex].name)
    end
    
    -- check for new fields (Overwriting not possible!!!)

end
end

rednet.open("right")
main()