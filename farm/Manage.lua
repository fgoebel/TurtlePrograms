-- Using Wireless Modem on right side of Computer
-- Sends Turtle to farming

--*********************************************
-- defintion of variables
local time = 0
local NextField
local minTime
local LastCheck = 0
local LastCheckBuild = 0
local LastCheckPlant = 0
local Time = 0

local storage = {
    x=122,
    y=63,
    z=-261,
    f=3
}

local queue = {
    x=123,
    y=63,
    z=-259,
    f=3
}

local plantingqueue = {
    x=123,
    y=63,
    z=-257,
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
    local TimeTable = http.get("http://worldtimeapi.org/api/timezone/Europe/Berlin")
    if TimeTable ~= nil then
        TimeTable = TimeTable.readAll()
        Time = json.decode(TimeTable).unixtime
    end
    return Time
end

-- Process user input
function processInput(message,ID,protocol)
    
    -- message == "send fields" --> send list of fields
    if message == "send fields" then
        local FieldsStr = textutils.serialize(fields)       -- serialize fields table
        rednet.send(ID,FieldsStr,"Input") 

    -- message == table --> received field, add to list or update if field is known
    elseif message ~= nil then
        if textutils.unserialize(message) ~= nil then       -- message was field
            rednet.send(ID,"got it", "Input")               -- send message to manager using protocol "Input"
            fieldInput = textutils.unserialize(message)

            if protocol == "Input" then
                fieldIndex = 0
                for k,field in ipairs(fields) do                -- check if field is known
                    if field.name == fieldInput.name then
                        fieldIndex = k
                    end
                    numFields = k
                end
                if fieldIndex ~= 0 then
                    fields[fieldIndex] = fieldInput             -- update field
                    store("fields", fields)
                else
                    fields[numFields+1] =  fieldInput           -- append field
                    store("fields", fields)
                end
            elseif protocol == "InputMulti" then
                fields = fieldInput
                store("fields", field)
            end    
        end
    end

end

--*********************************************
-- Main Managing function

function main()
local Queuestate = false
local Fieldstate = false
local BuildState = false
local Plantingstate = false
local Plantingqueuestate = false

while true do
    Time = checkTime()                                                      -- Update Time
    rednet.broadcast("just a broadcast","Init")                             -- Broadcast message to find new turtles using protocol "Init"
    ID, message, protocol = rednet.receive(2)                               -- check for messages

    -- Processing Message:
    -- Protocol = "Queue" --> Trutle is waiting on first position
    if protocol == "Queue" then
        print("found someone on queue")
        QueueID = ID
        Queuestate = true

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
        rednet.send(NewID,storagePos,"New")                             -- send storage position using protocol "New"
        if message == "I am new planting" then
            plantingqueuePos = textutils.serialize(plantingqueue)
            rednet.send(NewID,plantingqueuePos,"New")                -- send queue position using protocol "New"
        else
            queuePos = textutils.serialize(queue)
            rednet.send(NewID,queuePos,"New")                           -- send queue position using protocol "New"
        end

    -- Protocol = "Plant" --> turtle finished building, next step is planting of field
    elseif protocol == "FinishedBuilding" then
        toPlantName = message
        for k,field in ipairs(fields) do
            if field.name == toPlantName then   
                field.toplant = true                                       -- store field, which needs to be planted
            end
        end
        store("fields", fields)

    --Protocol = "Input" --> User input on fields
    elseif protocol == "Input" or protocol == "InputMulti" then
        print("User input on fields")
        processInput(message,ID,protocol)

    -- Protocol = "PlantQueue" --> Trutle is waiting on first position in Plantqueue
    elseif protocol == "PlantQueue" then
        PlantQueueID = ID
        Plantingqueuestate = true
    
    -- Protocol = "FinishedPlanting" --> turtle finished planting, next step is activating field
    elseif protocol == "FinishedPlanting" then
        toPlantName = message
        for k,field in ipairs(fields) do
            if field.name == toPlantName then   
                field.toplant = false
                field.active = true                                       -- store field, which is now active
                field.lastHarvested = Time
            end
        end
        store("fields", fields)

    end
    
    -- Update Fieldstate
    -- Fieldstate: false-->no field available/turtle was send, true-->field available
    if (Fieldstate == false and LastCheck+5<Time) then
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
        else 
            LastCheck = Time                                                -- check for field next time in five seconds
        end
    end

    -- Update BuildState
    -- BuildState: false --> no new field to build, true --> new field to build
    if (BuildState == false and LastCheckBuild+5<Time) then
        print("checking on new fields to build")
        toBuildIndex = 0
        for k,field in ipairs(fields) do
            if field.tobuild == true then   
                toBuildIndex = k                                       -- store field, which needs to be builded
            end
        end
        if toBuildIndex ~= 0 then
            BuildState = true
        else 
            LastCheckBuild = Time 
        end 
    end

    -- Update Plantingstate
    -- Plantingstate: false --> no new field to plant, true --> new field to plant
    if (Plantingstate == false) then
        print("checking on new fields to plant")
        toPlantIndex = 0
        for k,field in ipairs(fields) do
            if field.toplant == true then   
                toPlantIndex = k                                       -- store field, which needs to be builded
            end
        end
        if toPlantIndex ~= 0 then
            Plantingstate = true
        else 
            LastCheckPlant = Time 
        end 
    end

    -- Send Turtle
    -- Turtlestate: false-->Noone back from field, true-->Someone returned and is now waiting for input
    if (Fieldstate == true and Queuestate == true) then                 -- Field needs to be harvested and someone is available in queue
        print("try to send field") 
        NextField = textutils.serialize(fields[FieldIndex])                 -- serialize field table
        rednet.send(QueueID,NextField,"Queue")                              -- send field to turtle using protocol "Queue"
        print(fields[FieldIndex].name)
        ID, message, protocol = rednet.receive(2)                       -- check for messages
        -- Protocol = "Field" --> Turtle received field and starts harvesting
        if protocol == "Field" then 
            Fieldstate = false                                                  -- Change Fieldstate and Queuestate
            Queuestate = false                                                  
            fields[FieldIndex].lastHarvested = Time                             -- update field harvesting time
            store("fields", fields)
            sleep(10)
        end
    
    elseif (Fieldstate == false and Queuestate == true and BuildState == true) then -- send turtles to build new fields
        BuildingField = textutils.serialize(fields[toBuildIndex])               -- serialize field table
        rednet.send(QueueID,BuildingField,"Build")                              -- send field to turtle using protocol "Build"
        ID, message, protocol = rednet.receive(2)                               -- check for messages
        -- Protocol = "Build" --> Turtle received field and starts building
        if protocol == "Field" then 
            BuildState = false                                                  -- Change BuildState
            fields[toBuildIndex].tobuild = false
            store("fields", fields)
        end
    end

    if Plantingstate == true and Plantingqueuestate == true then                -- send harvesting turtle to plant field
        PlantingField = textutils.serialize(fields[toPlantIndex])               -- serialize field table
        rednet.send(PlantQueueID,PlantingField,"PlantQueue")
        ID, message, protocol = rednet.receive(2)
        -- Protocol = "Planting" --> turtle received field and starts planting
        if protocol == "Planting" then
            Plantingstate = false
            fields[toPlantIndex].toplant = false
            store("fields", fields)
        end
    end

end
end

rednet.open("right")
main()