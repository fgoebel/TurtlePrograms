-- Using Wireless Modem on right side of Computer
-- Sends Turtle to farming

--*********************************************
-- defintion of variables
local time = 0
local NextField
local minTime

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
    field.lastHarvested = -1    -- set initial value for lastHarvested
end

--*********************************************
-- Store fields
function store(sName, stuff)
	local handle = fs.open(sName, "w")
	handle.write(textutils.serialize(stuff))
	handle.close()
end


--*********************************************
-- Main Managing function

function main()
    while true do
        rednet.broadcast("available?")  -- send broadcast massage to check for available turtles
        ID, message = rednet.receive(5) -- receive messages for 5s
        time = time + 5                 -- set time 5s higher
        if message == "yes" then        -- if message was received
            minTime = 1
            NextField = "none"
            for k,field in ipairs(fields) do 
                if field.lastHarvested + field.interval - time < minTime then   
                    minTime = field.lastHarvested + field.interval - time       -- select field based on smallest value
                    key, NextField = k, field
                end
            end
            
            if NextField ~= "none" then          -- if any field to harvest was found
                rednet.send(ID,NextField)        -- send fieldName to available turtle
                print(NextField)
                fields[key].lastHarvested = time -- store new values in fields
                store("fields", fields)
            else
                rednet.send(ID,"NoField")
                print(NextField)
            end
        end
    end
end

rednet.open("right")
main()