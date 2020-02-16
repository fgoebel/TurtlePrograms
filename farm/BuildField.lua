-- field pos: one block above first ground block, not above crop!!! (--> pos not different for different crops)

--*********************************************
--refill and drop functions + general functions
function dropInventory()
    goTo.goTo(storage)             -- go to storage system, after field is finished
    for Slot =1, 16 do              -- clear slots
        turtle.select(Slot)        -- select next Slot
        turtle.dropDown()          -- just drop everthing in the slot
    end
end

function refillFuel()
    if turtle.getFuelLevel() < 5000 then
        goTo.goTo(storage)              -- go to storage system
        while turtle.getFuelLevel()/turtle.getFuelLimit() < 1 do    -- get current Fuellevel (percentage) and compare to Limit
            turtle.select(16)                                       -- select last slot
            getItemFromPeripheral("minecraft:coal",16,16)           -- get 16 coal in slot 16
            turtle.refuel()                                         -- refuel
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

function getAndReturn(ItemName,Slot,MaxItems,NumSlots,Return)
    ReturnPosition = goTo.returnPos()
    for i=1,NumSlots do
        getItemFromPeripheral(ItemName,Slot,MaxItems)
    end
    goTo.goTo(ReturnPosition)
    end
--*********************************************
-- build Frame
function buildFrame()
    for i = 1, 16 do                -- get cobblestone
        getItemFromPeripheral("minecraft:cobblestone",i,64)
    end
    
    goTo.goTo(field.pos)

    if turnRight then               -- go to first pos of frame (one block left, one down)
        goTo.turnLeft()
        goTo.forward()
        goTo.turnLeft()             -- for facing backwards
    else                            -- go to first pos of frame (one block left, one down)
        goTo.turnRight()
        goTo.forward()
        goTo.turnRight()            -- for facing backwards
    end
    goTo.down(1)

    local side = 1
    local blocks = rows

    while side <= 4 do
        for i=1,blocks do
            slot=getSlot("minecraft:cobblestone")
            if slot == false then                   -- refill if no dirt is left
                print("run out of stone")
                ReturnPosition = goTo.returnPos()
                for i=1,NumSlots do
                    getItemFromPeripheral(ItemName,Slot,MaxItems)
                end
                goTo.goTo(ReturnPosition)
                slot=getSlot("minecraft:cobblestone")
            else
                turtle.select(slot)
            end
            turtle.placeDown()
            goTo.back()
            turtle.place()
        end                         -- turtle is now above last block of current side/ first block of next side of frame

        if turnRight then
            goTo.turnRight()
        else
            goTo.turnLeft()
        end

        side = side + 1
        if side == 2 or side == 4 then
            blocks = cols+1
        else
            blocks = rows + 1
        end
    end
    
    turtle.placeDown()              -- do last blocks of frame
    goTo.up()
    turtle.placeDown()

    dropInventory()

end

--*********************************************
-- build ground
function buildGround()

for i = 1, 16 do                -- get dirt
    getItemFromPeripheral("minecraft:dirt",i,64)
end
goTo.goTo(field.pos)
goTo.down(1)
goTo.turnLeft()
goTo.turnLeft()                     -- turtle is facing backwards and at first block of ground

for i = 1, cols do
    for j=1,rows-1 do
        slot=getSlot("minecraft:dirt")
        if slot == false then                   -- refill if no dirt is left
            print("run out of dirt")
            ReturnPosition = goTo.returnPos()
            for i=1,NumSlots do
                getItemFromPeripheral(ItemName,Slot,MaxItems)
            end
            goTo.goTo(ReturnPosition)
            slot=getSlot("minecraft:dirt")
        else
            turtle.select(slot)
        end
        turtle.placeDown()
        goTo.back()
        turtle.place()
    end
    turtle.placeDown()
    if i ~= cols then
        if turnRight then
            goTo.turnRight()
            goTo.back()
            turtle.place()
            goTo.turnRight()
            turnRight = false
        else
            goTo.turnLeft()
            goTo.back()
            turtle.place()
            goTo.turnLeft()
            turnRight = ture 
        end
    else
        goTo.up()
        turtle.placeDown()
    end

    dropInventory()

end

end

--*********************************************
-- build sugar field
function sugarField(field)
local cols = field.cols
local rows = field.rows
local turnRight = field.turnRight
local waterCols = cols/3                                -- determine number of water cols

refillFuel()
dropInventory()
    
-- build frame and ground if aero field
    if field.aero then
        buildFrame()
        turnRight = field.turnRight
        buildGround()
    end

-- build water cols
    for i = 1, 3 do                                     -- get water buckets
        getItemFromPeripheral("minecraft:water_bucket",i,1)
    end
    goTo.goTo(field.pos)                                -- go to first water block
    turnRight = field.turnRight                         -- reset turnRight
    if turnRight then
        goTo.turnRight()
        goTo.forward()
        goTo.turnLeft()
    else
        goTo.turnLeft()
        goTo.forward()
        goTo.turnRight()
    end

    for j=1,waterCols do                                -- build water cols
        for i=1,3 do
            turtle.digDown()
            slot=getSlot("minecraft:water_bucket")
            turtle.select(slot)
            turtle.placeDown()
            goTo.forward()
        end

        for i=4,rows do
            turtle.digDown()                            -- remove dirt
            slot=getSlot("minecraft:water_bucket")      -- select water bucket
            if not slot then                            -- no water in inventory
                goTo.back(2)                            -- go back 2 blocks, were water is available
                for j=1,3 do                            -- refill water
                    slot=getSlot("minecraft:bucket")    -- get empty bucket
                    turtle.select(slot)
                    turtle.placeDown()                  -- get water   
                end
                slot=getSlot("minecraft:water_bucket")  -- select water bucket
                goTo.forward(2)
            end           
            turtle.select(slot)
            turtle.placeDown()
            goTo.forward()
        end
        goTo.back(1)                            -- go back 1 blocks, were water is available
        for j=1,3 do                            -- refill water
            slot=getSlot("minecraft:bucket")    -- get empty bucket
            turtle.select(slot)
            turtle.placeDown()                  -- get water   
        end
        goTo.forward()

        if turnRight then                 -- go to next row of water
            goTo.turnRight()
            goTo.forward(3)
            goTo.turnRight()
            turnRight=false
        else 
            goTo.turnLeft()
            goTo.forward(3)
            goTo.turnLeft()
            turnRight=true
        end

    end
    
-- plant sugar on field
    dropInventory()
    refillFuel()
    for i = 1, 16 do                -- get sugar cane
        getItemFromPeripheral("minecraft:sugar_cane",i,64)
    end
    goTo.goTo(field.pos)
    goTo.up(1)
    turnRight = field.turnRight
    local skip = 1

    for j=1,cols do
        for i=1,rows-1 do
            slot=getSlot("minecraft:sugar_cane")
            if slot == false then                   -- refill if no sugar is left
                print("run out ofsugar cane")
                ReturnPosition = goTo.returnPos()
                for i=1,NumSlots do
                    getItemFromPeripheral(ItemName,Slot,MaxItems)
                end
                goTo.goTo(ReturnPosition)
                slot=getSlot("minecraft:dirt")
            else
                turtle.select(slot)
            end
            turtle.placeDown()
            goTo.forward()
        end
        turtle.placeDown()
        if turnRight then
            goTo.turnRight()
            goTo.forward(1+skip)
            goTo.turnRight()
            turnRight = false
        else
            goTo.turnLeft()
            goTo.forward(1+skip)
            goToturnLeft()
            turnRight = true 
        end
        if skip == 1 then
            skip = 0
        else
            skip = 1
        end

    end

    dropInventory()

end
