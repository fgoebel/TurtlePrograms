-- Using Wireless Mining Turtle
-- Turtle is send by computer using Manage.lua
-- depends on FarmingNew and goTo API

--*********************************************
-- defintion of variables
local waiting = true                 -- initially waiting
local waitingPos = {x=124,y=63,z=-260,f=0}
--local waitingPos = {x=123,y=63,z=-259,f=0}
--local waitingPos = {x=122,y=63,z=-258,f=0}

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
                    field = textutils.unserialize(message)
                end
            end
            
        end

        if not waiting then                                     -- State: got order, working now
            farming.start(field)
            waiting = true
            farming.dropInventory()
            goTo.goTo(waitingPos)                                     
        end

        heartbeat()
    end
end

rednet.open("left")
goTo.getPos()
main()
