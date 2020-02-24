
-- Using Wireless Mining Turtle
-- depends on goTo API

--*********************************************
-- Define options
local BoneMealOpt = false                   -- Using Bone Meal is optional

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

--*********************************************
-- Basic functions for movement, just for shorter usage
function turn()
    goTo.turnLeft()
    goTo.turnLeft()
end
function left()
    goTo.turnLeft()
end
function right()
    goTo.turnRight()
end
function forward(steps)
    goTo.forward(steps)
end
function back(steps)
    goTo.back(steps)
end
function up(steps)
    goTo.up(steps)
end
function down(steps)
    goTo.down(steps)
end

--*********************************************
--Functions for harvesting Wheat, Beetroot, Carrots and Potatos
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

function getBoneMeal()                                  -- does not work with getItemFromPeripheral, since displayName must be checked
    peri = peripheral.wrap("bottom")                    -- sets ME interface on bottom as pheripheral
    for i=1,9 do                                        -- checks each slot of peripheral
        item = peri.getItemMeta(i)                      -- stores meta data in item variable
        if item.displayName == "Bone Meal" then         -- if name of item in slot is desired seed name
            peri.pushItems("up",i,64,2)                 -- push item in slot i up to turtle, max 64 items in slot 2
            return 2                                    -- returns slot number for Bone Meal if it was available
        end
    end
    return false                                        
end

function havestAndPlant(crop)
    if SeedSlot == false then
        print("no seeds")
        return
    end

    valid, data = turtle.inspectDown()                  -- get state of block

    if valid then                                       -- there is a block below
        if BoneMealOpt then
            if ((data.metadata < 7 and crop ~= "beetroot") or (data.metadata < 3)) then  -- block is not fully grown
                turtle.select(BoneSlot)                                                         -- select BoneMeal slot
                while ((data.metadata < 7 and crop ~= "beetroot") or (data.metadata < 3)) do
                    turtle.placeDown()                                                          -- place Bone Meal until it is grown
                    valid, data = turtle.inspectDown()                                          -- inspect again
                end
            end
        end

        if ((data.metadata == 7) or (data.metadata == 3 and crop == "beetroot")) then  --block is fully grown
            turtle.digDown()                            -- harvest
            sleep(0.5)
            turtle.suckDown()                           -- suck in
        end

    end
    if turtle.inspectDown() == false then               -- tilling and planting only needed if there is nothing below or crop was destroyed
        if turtle.getItemCount(SeedSlot) == 0 then      -- if SeedSlot is empty, get new slot
            SeedSlot = getSlot(SeedName)
            while slot == false do                  -- wait for beeing refilled
                print("run out of "..SeedName)
                sleep(10)
                SeedSlot=getSlot(SeedName)
            end
        end
        turtle.select(SeedSlot)                     --select SeedSlot
        turtle.placeDown()                          --place Seed
    end
end

function generalField(field)
local cols = field.cols
local rows = field.rows
local turnRight = field.right
SeedName = determineSeed(field.crop)

dropInventory(storage)              -- drop everything
refillFuel(storage)                 -- refuel if fuel level below 5000
SeedSlot = getItemFromPeripheral(SeedName,1,64) -- get 64 Seeds, returns false, if no seeds were available
if BoneMealOpt then
    BoneSlot = getBoneMeal()        -- get Bone Meal, returns false, if no Bone meal was available
end
field.pos.y = field.pos.y + 1       -- correct harvesting height based on crop
goTo.goTo(field.pos)                -- got to first Block of field

    for j = 1,cols do               --start harvesting
        for i=1,rows-1 do
            havestAndPlant(field.crop)        -- harvest and plant on current block
            forward(1)              -- move one block forward
        end                         
        havestAndPlant(field.crop)  -- on last block of col only harvest and plant
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
        empty = determineEmptySlots()
        while empty < 2 do              -- wait for beeing unfilled
            print("please clear inventory")
            sleep(10)
            empty = determineEmptySlots()
        end
    end

end

--*********************************************
--cactus fiels
function cactusField(field)
local cols = field.cols
local rows = field.rows
local turnRight = field.right

refillFuel(storage)                             -- refuel if fuel level below 5000

field.pos.y = field.pos.y + 3                   -- correct harvesting height based on crop
goTo.goTo(field.pos)                            -- got to first Block of field

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
        empty = determineEmptySlots()
        while empty < 2 do               -- wait for beeing unfilled
            print("please clear inventory")
            sleep(10)
            empty = determineEmptySlots()
        end
    end

end

--*********************************************
--sugar field
function sugarField(field)
local cols = field.cols
local rows = field.rows
local turnRight = field.right

local skip = 1                              -- equals 1 if water must be skipped in next turn, else equals 0
local currentCol = 1                        -- variable for currentCol

refillFuel(storage)                         -- refuel if fuel level below 5000

field.pos.y = field.pos.y + 3               -- correct harvesting height based on crop
goTo.goTo(field.pos)                        -- got to first Block of field

    while currentCol <= cols do             -- do for each col
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
        currentCol = currentCol + 1+ skip   -- determine current col (might be next or second next one, depending on skip)
        skip = math.abs((skip-1))           -- invert skipping variable, returns 1 if skip was 0 and 0 if skip was 1

        empty = determineEmptySlots()
        while empty < 2 do               -- wait for beeing unfilled
            print("please clear inventory")
            sleep(10)
            empty = determineEmptySlots()
        end
    end

end

--*********************************************
--ender lilly field
function enderlillyField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right

    refillFuel(storage)                             -- refuel if fuel level below 5000

    field.pos.y = field.pos.y + 1                   -- correct harvesting height based on crop
    goTo.goTo(field.pos)                            -- got to first Block of field
    
        for j = 1,cols do                           --start harvesting
            for i=1,rows-1 do
                valid, data = turtle.inspectDown()  -- get state of block
                if data.metadata == 7 then          -- if block is mature
                    turtle.digDown()                -- dig Down to harvest
                    sleep(0.5)
                    lillySlot = getSlot("extrautils2:enderlilly")
                    if lillySlot ~= false then
                        turtle.select(lillySlot)
                        turtle.placeDown()
                    end
                end
                forward(1)                          -- move one block forward
            end                         
            turtle.digDown()                -- dig Down to harvest
            sleep(0.5)
            lillySlot = getSlot("extrautils2:enderlilly")
            if lillySlot ~= false then
                turtle.select(lillySlot)
                turtle.placeDown()
            end   
            if j ~= cols then                       -- if it is not the last col
                if turnRight then                   -- turn right if last turn was left
                    right()
                    forward(1)
                    right()
                    turnRight= false
                else                                -- turn left if last turn was left
                    left()
                    forward(1)
                    left()
                    turnRight=true
                end
            end
            empty = determineEmptySlots()
            while empty < 2 do               -- wait for beeing unfilled
                print("please clear inventory")
                sleep(10)
                empty = determineEmptySlots()
            end
        end

end

--*********************************************
--refill and drop functions + general functions
function dropInventory(position)
    goTo.goTo(position)             -- go to storage system, after field is finished
    for Slot =1, 16 do              -- clear slots
        turtle.select(Slot)        -- select next Slot
        turtle.dropDown()          -- just drop everthing in the slot
        sleep(0.5)
    end
end

function refillFuel(position)
    if turtle.getFuelLevel() < 5000 then
        goTo.goTo(position)              -- go to storage system
        while turtle.getFuelLevel()/turtle.getFuelLimit() < 1 do    -- get current Fuellevel (percentage) and compare to Limit
            turtle.select(16)                                       -- select last slot
            getItemFromPeripheral("minecraft:lava_bucket",16,1)     -- get lava in slot 16
            turtle.refuel()                                         -- refuel
            turtle.dropDown()
        end
    end
end

function getSlot(ItemName)
    for i=1,16 do
        if turtle.getItemCount(i) ~= 0 then             -- if slot not empty
            Detail = turtle.getItemDetail(i)            -- get item details
            if Detail.name == ItemName then             -- if it is the item
                return i                                -- sets current clot to return variable
            end
        end                                                         
    end
    return false
end

function getItemFromPeripheral(ItemName,Slot,MaxItems)
    goTo.goTo(storage)  
    peri = peripheral.wrap("bottom")                    -- sets ME interface on bottom as pheripheral
    for i=1,9 do                                        -- checks each slot of peripheral
        item = peri.getItemMeta(i)                      -- stores meta data in item variable
        if item ~= nil then
            if item.name == ItemName then                   -- if name of item in slot is desired seed name
                peri.pushItems("up",i,MaxItems,Slot)        -- push item in slot i up to turtle, max 64 items in slot 1
                return Slot                                 -- returns slot number for seeds if it was available
            end
        end
    end
    return false                                      
end

function determineEmptySlots()
    local empty = 0
    for i=1,16 do
        if turtle.getItemCount(i) == 0 then
            empty = empty + 1
        end
    end
return empty
end

function start(field, storagePos, dropPos)
    storage = storagePos
    drop = dropPos
    travelsPos = field.pos
    travelsPos.y = travelsPos.y + 3
    travelsPos.x = travelsPos.x - 5
    print("Start farming")
    if (field.crop == "cactus") then
        cactusField(field)
    elseif (field.crop == "sugar") then
        sugarField(field)
    elseif (field.crop == "enderlilly") then
        enderlillyField(field)
    else                                    --just everything else (wheat, beetroot, carrot, potato)
        generalField(field)                                      
    end

    print("finished farming")
    goTo.goTo(travelsPos)

    dropInventory(drop)

end
