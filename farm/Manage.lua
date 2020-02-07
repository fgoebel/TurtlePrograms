-- Using Wireless Modem on right side of Computer
-- Sends Turtle to farming

--*********************************************
-- defintion of variables
local time = 0
local NextField
local minTime
local LastTime = os.time()*1000*0.05 --Time in real-Life seconds
local RunTime = 0

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
    RunTime = RunTime + TimePassed
    return RunTime
end
--*********************************************
-- Main Managing function
store("fields", fields)
function main()
local TurtleAvailable = false

    while true do
        if TurtleAvailable then        -- State: trutle available
            --Check if any field needs to be harvested
            minTime = 0
            NextField = "none"
            for k,field in ipairs(fields) do
                if ((field.lastHarvested + field.interval - RunTime <= minTime) and field.active == true) then   
                    minTime = field.lastHarvested + field.interval - RunTime      -- select field based on lowest value
                    key, NextField = k, field.name
                end
            end
            print("Field: " .. NextField .. ", minTime:" .. minTime)

            if NextField == "none" then             -- Sub-State: no field to harvest
                rednet.send(ID,"NoField")
                print("currently no field available")
                sleep(5)
            else                                    -- Sub-State: field to harvest
                rednet.send(ID,NextField)           -- send fieldName to available turtle
                fields[key].lastHarvested = RunTime -- store new values in fields
                store("fields", fields)
                TurtleAvailable = false             -- change State
                sleep(20)                           -- to avoid turtle crashes if multiple are available
            end
        
        end
        
        if not TurtleAvailable then         -- State: No turtle available
            rednet.broadcast("available?")  -- send broadcast massage to check for available turtles
            print("waiting for turtles")
            ID, message = rednet.receive(5) -- receive messages for 5s, then ask again
            print(message)
            if message == "yes" then        -- if message was yes, change state
                TurtleAvailable = true
            end
        end

        RunTime = checkTime()               -- get current Run Time of Programm
    end
end

rednet.open("right")
main()