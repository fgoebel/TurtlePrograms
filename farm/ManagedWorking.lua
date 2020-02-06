-- Using Wireless Mining Turtle
-- Turtle is send by computer using Manage.lua
-- depends on FarmingNew and goTo API

--*********************************************
-- defintion of variables
local waiting = true                 -- initially no waiting
local waitingPos = {x=122,y=63,z=-260,f=0}

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
--function to display heartbeat
function heartbeat()
    term.clear()
    currentFuelLevel = turtle.getFuelLevel()
	if waiting then
		print("current Status: waiting for input")
	else
		print("current Status: Working")
	end

    print("fuelLevel: " .. currentFuelLevel)
	print("press x to exit Program and d to start manually!")
end

--*********************************************
-- General Farming Programm
function main()
    while true do
        heartbeat()                                             -- print heartbeat
        ID, message = rednet.receive()                          -- waits for message 
        print(message)
        if message == "available?" then
            rednet.send(ID,"yes")                               -- answer to available call
        elseif message ~= "NoField" then
            waiting = false                                     -- stop waiting
            fieldName = message
        end

        if not waiting then                                     -- if waiting is not active
            for k,field in ipairs(fields) do                    -- for each field
                if field.name == fieldName then                 -- if field is known
                    print(field.name) 
                    print("Start farming")
                    if (field.crop == "cactus") then
                        farming.cactusField(field)
                    elseif (field.crop == "sugar") then
                        farming.sugarField(field)
                    elseif (field.crop == "enderlilly") then
                        farming.enderlillyField(field)
                    else                                    --just everything else (wheat, beetroot, carrot, potato)
                        farming.generalField(field)                                      
                    end
                
                    print("finished farming")

                    farming.up(5)                           -- go up to avoid crashes
                end

            end
            waiting = true
            goTo.goTo(waitingPos)     
            print("going waiting")                                   
        end
    end

end

rednet.open("left")
goTo.getPos()
main()