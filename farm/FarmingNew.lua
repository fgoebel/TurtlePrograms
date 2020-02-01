
-- Using harvesting, wireless turtle
-- by using turtle.digDown for harvesting, more than one block was harvested. This is handled by using placeDown instead, which also resulted
-- in the crop "still be planted" (equal to right klicking on it).

--*********************************************
-- Define specific positions
local home = {x=121,y=66,z=-263,f=0}
local storage = {x=122,y=63,z=-261,f=2}

-- defintion of variables
local harvestingInterval = 600        -- time between two harvesting cycles 
local timerCount = 0                  -- counts how often timer was started
local waiting = false                 -- initially no waiting

--*********************************************
-- load APIs
if not fs.open("goTo.lua","r") then
	r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/goTo.lua")
    f = fs.open("goTo.lua", "w")
    f.write(r.readAll())
    f.close()
    r.close()
    os.loadAPI("goTo.lua") 

elseif not os.loadAPI("goTo.lua") then
    error("goTo API not present!!! ;-(")
end

-- Load field file
if not fs.open("fields","w") then
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
-- Basic functions for movement
function turn()
    left()
    left()
end
function left()
    goTo.turnLeft()
end
function right()
    goTo.turnRight()
end
function forward(steps)
    if steps == nil then
        steps = 1
    end
    i=0
    while i < steps do
        if goTo.forward() then
            i=i+1
        else
            sleep(0.5)
        end
    end
end
function back(steps)
    if steps == nil then
        steps = 1
    end
    i=0
    while i < steps do
        if goTo.back() then
            i=i+1
        else
            sleep(0.5)
        end
    end
end
function up(steps)
    if steps == nil then
        steps = 1
    end
    i=0
    while i < steps do
        if goTo.up() then
            i=i+1
        else
            sleep(0.5)
        end
    end
end
function down(steps)
    if steps == nil then
        steps = 1
    end
    i=0
    while i < steps do
        if goTo.down() then
            i=i+1
        else
            sleep(0.5)
        end
    end
end

--*********************************************
--Functions for harvesting Wheat, Beetroot, Carrots and Potatos
function getSlot(ItemName)
    for i=1,16 do
        if turtle.getItemCount(i) ~= 0 then             -- if slot not empty
            Detail = turtle.getItemDetail(i)            -- get item details
            if Detail.name == ItemName then             -- if it is the item
                return i                                -- leave function
            end
        end                                                         
    end
    return false                                        -- return slot number
end

function determineSeed(crop)
    if (crop == "wheat") then
        seed = "minecraft:wheat_seeds"
    elseif crop == "beetroot" then
        seed = "minecraft:beetroot_seeds"
    elseif crop == "carrot" then
        seed = "minecraft:carrot"
    elseif crop == "potato" then
        seed = "minecraft:potato"
    end
    return seed
end

function getSeeds()
    peri = peripheral.wrap("bottom")                    -- sets ME interface on bottom as pheripheral
    for i=1,9 do                                        -- checks each slot of peripheral
        item = peri.getItemMeta(i)                      -- stores meta data in item variable
        if item.name == seed                            -- if name of item in slot is desired seed name
            peri.pushItem("up",i,64,1)                  -- push item in slot i up to turtle, max 64 items in slot 1
            return
        end
    end
end

function havestAndPlant()
    SeedSlot = getSlot(SeedName)                        -- determine current Slot for seeds, returns false if Seed not in inventory
    if SeedSlot == false
        print("no seeds left")
        -- hier könnte man dann Position speichern un neue Seeds holen
        return
    end
    valid, data = turtle.inspectDown()                  -- get state of block
    turtle.select(1)

    if valid then                                       -- there is a block below
        if ((data.metadata == 7) or (data.metadata == 3 and crop == "beetroot")) then  --block is fully grown
            turtle.placeDown()                          -- harvest (see comment at top of the document)
            turtle.suckDown()                           -- suck in
            if turtle.inspectDown() == false then       -- tilling and planting only needed if crop was destroyed
                turtle.digDown()                        -- till field
                if turtle.getItemCount(SeedSlot) == 0 then  -- if SeedSlot is empty, get new slot
                    SeedSlot = getSlot(SeedName)
                    if SeedSlot == false
                    print("no seeds left")
                    -- hier könnte man dann Position speichern un neue Seeds holen
                        return
                    end
                end
                turtle.select(SeedSlot)                     --select SeedSlot
                turtle.placeDown()                          --place Seed
            end
        end
    end
end

function generalField(cols,rows,turnRight)
    for j = 1,cols do               --start harvesting
        for i=1,rows-1 do
            havestAndPlant()        -- harvest and plant on current block
            forward(1)              -- move one block forward
        end                         
        havestAndPlant()            -- on last block of col only harvest and plant
        if j ~= cols then           -- if it is not the last col
            if turnRight then       -- turn right if last turn was left
                right()
                forward(1)
                right()
                turnRight= false
            else                    -- turn left if last turn was left
                left()
                forward(1)
                left()
                turnRight=true
            end
        end
    end
end

--*********************************************
--cactus fiels
function cactusField(cols,rows,turnRight)
top = true                                      -- variable for indicating if turtle is in top of col
currentCol = 1                                  -- variable for currentCol
    while true do
        for i = 1, rows do                      --harvest one col
            turtle.digDown()
            forward(1)
        end                                     -- position now: one block behind last row

        if ((currentCol == cols) and (not top)) then    -- if current col is last col and not top
            return                                      -- finished field -- > exit loop
        end

        if ((currentCol == 1) and top) or ((currentCol == cols-1) and (not(top))) then    
            -- if first col and top or second last and not top: height stays the same, but next col
            if turnRight then                   
                right()
                forward(1)
                right()
            else
                left()
                forward(1)
                left()
            end
            currentCol = currentCol + 1         -- determine new col
        else
            if top then
                -- if top of current col: next is one col back and one down                         
                if turnRight then
                    right()
                    forward(1)
                    right()
                else
                    left()
                    forward(1)
                    left()
                end
                down(1)
                currentCol = currentCol - 1     -- determine new col
                top = false                     -- reset top variable
            else                                
                -- currently not in top of col: next is two col forward and one up (top of new col)
                up(1)
                if turnRight then
                    right()
                    forward(2)
                    right()
                else
                    left()
                    forward(2)
                    left()
                end
                currentCol = currentCol + 2     -- determine new col
                top = true                      -- reset top variable
            end
        end
    end
end

--*********************************************
--sugar field
function sugarField(cols,rows,turnRight)
local skip = 1                              -- equals 1 if water must be skipped in next turn, else equals 0
local currentCol = 1                        -- variable for currentCol

    while currentCol < cols do              -- do for each col
        turtle.digDown()                    -- first block must be removed, to go down()
        down()                              -- go one block down
        for i=1,rows do                     -- start with col
            turtle.digDown()
            turtle.dig()
            forward(1)
        end
        up()                                -- finished col, go one up

        if turnRight then                   -- go to next col
            right()
            forward(1+skip)                 -- next col depends on skipping active or not
            right()
            turnRight = false
        else
            left()
            forward(1+skip)
            left()
            turnRight = true
        end
        forward()                           -- go one forward --> now in top of next col
        currentCol =currentCol + skip       -- determine current col (might be next or second next one, depending on skip)
        skip = math.abs((skip-1))           -- invert skipping variable, returns 1 if skip was 0 and 0 if skip was 1
    end

end


--*********************************************
--overall farming function
function farming(field)
    refillFuel()                    -- refuel if fuel level below 5000
    dropInventory()                 -- drop wheat and seed (except for 1 stacks)
    
    cols = field.cols
    rows = field.rows
    turnRight = field.right
    crop = field.crop

    print("Start farming")
    if (crop == "cactus") then
        goTo.goTo(field.pos)            -- got to first Block of field
        cactusField(cols,rows,turnRight)
    elseif (crop == "sugar") then
        goTo.goTo(field.pos)            -- got to first Block of field
        sugarField(cols,rows,turnRight)
    else                                --just everything else (wheat, beetroot, carrot, potato)
        SeedName = determineSeed(crop)
        getSeeds()                      -- get Seeds
        goTo.goTo(field.pos)            -- got to first Block of field
        generalField(cols,rows,turnRight)                                      
    end

    print("finished farming")
end

--*********************************************
--refill and drop functions
function dropInventory()
    goTo.goTo(storage)             -- go to storage system, after field is finished
    for Slot =1, 16 do             -- there must be something at least in one slot to use put!
        turtle.select(Slot)        -- select next Slot
        turtle.dropDown()          -- just drop everthing in the slot
    end
end

function refillFuel()
    if turtle.getFuelLevel() < 5000 then
        goTo.goTo(storage)              -- go to storage system
        while turtle.getFuelLevel()/turtle.getFuelLimit() < 1 do    -- get current Fuellevel (percentage) and compare to Limit
            turtle.select(16)                                       -- select last slot
            if turtle.getItemCount(16) == 0 then
                turtle.suckDown()                                   -- suckDown for fuel
            end
            turtle.refuel()                                         -- refuel
        end
    end
end

--*********************************************
--function to display heartbeat
function heartbeat()
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
                        farming(field)                          -- farm field
                    end
                    up(5)                                       -- go up to avoid crashes
                heartbeat()                                     -- print heartbeat
            end
            waiting = true
            goTo.goTo(home)                                         -- go home
            waitingTimer = os.startTimer(1)                         -- starts time on 1 second
                                     
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