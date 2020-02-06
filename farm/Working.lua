-- Using Wireless Mining Turtle
-- depends on FarmingNew and goTo API

--*********************************************
-- defintion of variables
local harvestingInterval = 600        -- time between two harvesting cycles 
local timerCount = 0                  -- counts how often timer was started
local waiting = false                 -- initially no waiting

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
    timeToWait = harvestingInterval - timerCount
    currentFuelLevel = turtle.getFuelLevel()
	if waiting then
		print("current Status: waiting " .. timeToWait .. " Seconds!")
	else
		print("current Status: Working")
	end

    print("fuelLevel: " .. currentFuelLevel)
	print("press x to exit Program and d to start manually!")
end

--*********************************************
-- General Farming Programm
function main()
    heartbeat()                                                 -- print heartbeat
    while true do
        if not waiting then                                     -- if waiting is not active
            for k,field in ipairs(fields) do                    -- for each field
                print(field.name)           
                    if field.active then                        -- if field is active
                        crop = field.crop
                        print("Start farming")
                        if (crop == "cactus") then
                            print("cactus")
                            sleep(2)
                            --farming.cactusField(field)
                        elseif (crop == "sugar") then
                            print("cactus")
                            sleep(2)
                            --farming.sugarField(field)
                        elseif (crop == "enderlilly") then
                            print("cactus")
                            sleep(2)
                            --farming.enderlillyField(field)
                        else                                    --just everything else (wheat, beetroot, carrot, potato)
                            print("cactus")
                            sleep(2)
                            farming.generalField(field)                                      
                        end
                    
                        print("finished farming")

                        farming.up(5)                           -- go up to avoid crashes
                    end
                heartbeat()                                     -- print heartbeat
            end
            waiting = true
            waitingTimer = os.startTimer(1)                     -- starts time on 1 second
                                     
        end

        event , bottom = os.pullEvent()                         -- waits for event 

	    if (event == "timer") and (bottom == waitingTimer) then -- waiting timer "rings"
		    if timerCount >= harvestingInterval then
			    waiting = false                                 -- stop waiting
			    timerCount = 0                                  -- reset Timer
		    else
			    timerCount = timerCount + 1                     -- increase timer count by one
                waitingTimer = os.startTimer(1)                 -- start new timer
		    end
	    elseif (event == "key") and (bottom == keys.x ) then    -- buttom x was pressed
		    return                                              -- stop everything, leave program
	    elseif (event == "key") and (bottom == keys.d) then     -- bottom d was pressed
		    timerCount = harvestingInterval                     -- start harvesting manually
        end
        heartbeat()                                             -- print heartbeat
    end

end

goTo.getPos()
main()