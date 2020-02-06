-- Using Wireless Mining Turtle
-- Turtle is send by computer using Manage.lua
-- depends on FarmingNew and goTo API

--*********************************************
-- defintion of variables
local waiting = true                 -- initially waiting
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
-- General Farming Programm
function main()

    while true do
        if waiting then                         -- State: Waiting for order
            ID, message = rednet.receive(5)    -- wait for message from Manager
            print(message)
            if message == "available?" then     -- answer to available call
                rednet.send(ID,"yes")
            else
                if message ~= "NoField" then    -- start farming
                    waiting = false
                    fieldName = message
                end
            end
            
        end

        if not waiting then                                     -- State: got order, working now
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
        end

        heartbeat()
    end
end

rednet.open("left")
goTo.getPos()
main()
