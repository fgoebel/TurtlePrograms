-- load APIs
if not os.loadAPI("goTo") then
	shell.run("openp/github get fgoebel/TurtlePrograms/cct-clique27/goTo.lua goTo")
	if not os.loadAPI("goTo") then
	error("goTo API not present!!! ;-(")
	end
end

-- Define specific positions
local home = {x=121,y=64,z=-263,f=0}
local storage = {x=122,y=63,z=-261,f=2}

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

function getSeedSlot()
    SeedsSlot = 1
    state = 1
    while state == 1 do
        if goTo.select(SeedSlot) ~= 0                          -- if slot not empty
            SlotDetails = goTo.getItemDetails(slotSeeds)       -- get item details
            if SlotDetails.name == "minecraft:wheat_seeds"  -- if it is a seed
                state = 0                                   -- leave function
            end
        end
        SeedSlot = SeedSlot +1                              -- inspect next Slot
    end
    return SeedsSlot                                        -- return slot number
end

function havestAndPlant()
    SeedSlot = getSeedSlot()                    -- determine current Slot for seeds
    valid, data = goTo.inspectDown()               -- get state of block

    if valid then                               -- there is a block below
        if data.metadata == 7                   --block is fully grown
            goTo.digDown()                         -- harvest
            goTo.suckDown()                        -- suck in
            goTo.digDown()                         -- till field
            if goTo.getItemCount(SeedSlot) == 0    -- if SeedSlot is empty, get new slot
                SeedSlot = getSeedSlot()
            end
            goTo.select(SeedSlot)                  --select SeedSlot
            goTo.placeDown()                       --place Seed
        end
    end
end

function dropInventory()
    Slot = 1
    SeedSlot = getSeedSlot()    -- determine first SeedSlot
    while Slot <= 16 do
        goTo.select(Slot)          -- select next Slot
        if Slot ~= SeedSlot     -- if it is not the first SeedSlot
            goTo.dropDown()        -- just drop everthing in the slot
        end
        Slot = Slot +1
    end
    if SeedSlot == 1            -- if the SeedSlot is not slot 1
        goTo.select(SeedSlot)
        goTo.transferTo(1)         -- transfer Seeds to slot 1
    end
end

function refillFuel()
    if goTo.getFuelLevel()/goTo.getFuelLimit() < 1 do    -- get current Fuellevel (percentage) and compare to Limit
        goTo.select(16)                                -- select last slot
        goTo.suckDown()                                -- suckDown for fuel
        goTo.refuel()                                  -- refuel
    end
end

-- General Farming Programm
function farming(rows,cols,turnRight)
    -- got to first Block of field

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
    -- go to storage system, after field is finished

    dropInventory()                 -- drop wheat and seed (except for 1 stacks)
    refillFuel()                    -- refuel if fuel level below Max

    -- go home
end