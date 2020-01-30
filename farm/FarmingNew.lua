
-- Using harvesting, wireless turtle
-- by using turtle.digDown for harvesting, more than one block was harvested. This is handled by using placeDown instead, which also resulted
-- in the crop "still be planted" (equal to right klicking on it).

--*********************************************
-- load APIs
if not os.loadAPI("goTo.lua") then
	r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/goTo.lua")
    f = fs.open("goTo.lua", "w")
    f.write(r.readAll())
    f.close()
    r.close()

	if not os.loadAPI("goTo.lua") then
	    error("goTo API not present!!! ;-(")
	end
end

-- Define specific positions
local home = {x=121,y=66,z=-263,f=0}
local storage = {x=122,y=63,z=-261,f=2}
local field = {x=130, y=64, z=-267,f=0}

-- Load field file - change later
-- function load(name)
-- 	local file = fs.open(name,"r")
-- 	local data = file.readAll()
-- 	file.close()
-- 	return textutils.unserialize(data)
-- end

-- local fields = load("fields")

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
--Functions for harvesting Wheat
function getSlot(ItemName)
    i = 0
    while true do
        i = i + 1                                       -- inspect next Slot
        if turtle.getItemCount(i) ~= 0 then             -- if slot not empty
            Detail = turtle.getItemDetail(i)            -- get item details
            if Detail.name == ItemName then             -- if it is the item
                return i                                -- leave function
            end
        end                                                         
    end
    return false                                        -- return slot number
end

function havestAndPlant()
    SeedName = "minecraft:wheat_seeds"
    SeedSlot = getSlot(SeedName)                        -- determine current Slot for seeds
    valid, data = turtle.inspectDown()                  -- get state of block

    if valid then                                       -- there is a block below
        if data.metadata == 7 then                      --block is fully grown
            turtle.placeDown()                          -- harvest (see comment at top of the document)
            turtle.suckDown()                           -- suck in
            if turtle.inspectDown() == false then       -- tilling and planting only needed if crop was destroyed
                turtle.digDown()                        -- till field
                sleep(0.5)
                if turtle.getItemCount(SeedSlot) == 0 then  -- if SeedSlot is empty, get new slot
                    SeedSlot = getSlot(SeedName)
                end
                turtle.select(SeedSlot)                     --select SeedSlot
                turtle.placeDown()                          --place Seed
            end
        end
    end
end

--*********************************************
--refill and drop functions
function dropInventory()
    Slot = 1
    SeedSlot = getSlot("minecraft:wheat_seeds")        -- determine first SeedSlot
    while Slot <= 16 do
        turtle.select(Slot)         -- select next Slot
        if Slot ~= SeedSlot then    -- if it is not the first SeedSlot
            turtle.dropDown()       -- just drop everthing in the slot
        end
        Slot = Slot +1
    end
    if SeedSlot == 1 then           -- if the SeedSlot is not slot 1
        turtle.select(SeedSlot)
        turtle.transferTo(1)        -- transfer Seeds to slot 1
    end
end

function refillFuel()
    while turtle.getFuelLevel()/turtle.getFuelLimit() < 1 do    -- get current Fuellevel (percentage) and compare to Limit
        turtle.select(16)                                       -- select last slot
        if turtle.getItemCount(16) == 0 then
            turtle.suckDown()                                   -- suckDown for fuel
        end
        turtle.refuel()                                         -- refuel
    end
end

--*********************************************
-- General Farming Programm
function farming(rows,cols,turnRight)
    goTo.goTo(storage)              -- go to storage system
    refillFuel()                    -- refuel if fuel level below Max
    
    goTo.goTo(field)                -- got to first Block of field

    print("Start farming")
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
    print("finished farming")

    goTo.goTo(storage)             -- go to storage system, after field is finished
    dropInventory()                 -- drop wheat and seed (except for 1 stacks)
    goTo.goTo(home)                 -- go home
end

function main()
    farming(24,9,1)
end

goTo.getPos()
main()