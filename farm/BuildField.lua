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
    peri = peripheral.wrap("right")                    -- sets ME interface on bottom as pheripheral
    for i=1,9 do                                        -- checks each slot of peripheral
        item = peri.getItemMeta(i)                      -- stores meta data in item variable
        if item ~= nil then
            if item.name == ItemName then                   -- if name of item in slot is desired seed name
                peri.pushItems("left",i,MaxItems,Slot)        -- push item in slot i up to turtle, max 64 items in slot 1
                return Slot                                 -- returns slot number for seeds if it was available
            end
        end
    end
    return false                                      
end

--*********************************************
-- build Frame
function buildFrame(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right

    dropInventory()
    refillFuel()
    for i = 1, 16 do                -- get cobblestone
        getItemFromPeripheral("minecraft:cobblestone",i,64)
    end
    
    goTo.goTo(field.pos)

    if turnRight then               -- go to first pos of frame (one block left)
        goTo.turnLeft()
        goTo.forward()
        goTo.turnRight()         
    else                            -- go to first pos of frame (one block right)
        goTo.turnRight()
        goTo.forward()
        goTo.turnLeft()
    end

    local side = 1
    local blocks = rows

    while side <= 4 do
        for i=1,blocks do
            slot=getSlot("minecraft:cobblestone")
            if slot == false then                   -- refill if no dirt is left
                print("run out of stone")
                ReturnPosition = goTo.returnPos()
                for n=1,16 do
                    getItemFromPeripheral("minecraft:cobblestone",n,64)
                end
                goTo.goTo(ReturnPosition)
                slot=getSlot("minecraft:cobblestone")
            else
                turtle.select(slot)
            end
            turtle.placeDown()
            goTo.forward()
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

    dropInventory()

end

--*********************************************
-- build ground
function buildGround(field, ItemLayerOne, ItemLayerTwo)
local cols = field.cols
local rows = field.rows
local turnRight = field.right

if ItemLayerOne == nil then
    ItemLayerOne = "minecraft:dirt"
end
if ItemLayerTwo == nil then
    ItemLayerTwo = "minecraft:dirt"
end

dropInventory()
refillFuel()
for i = 1, 8 do                     -- get ItemLayerOne
    getItemFromPeripheral(ItemLayerOne,i,64)
end
for i = 9, 16 do                     -- get ItemLayerTwo
    getItemFromPeripheral(ItemLayerTwo,i,64)
end
goTo.goTo(field.pos)
goTo.down(1)
goTo.turnLeft()
goTo.turnLeft()                     -- turtle is facing backwards and at first block of ground

for i = 1, cols do
    for j=1,rows-1 do
        slot1=getSlot(ItemLayerOne)
        slot2=getSlot(itemLayerTwo)
        if slot1 == false or slot2 == false then                   -- refill
            print("run out of Items")
            ReturnPosition = goTo.returnPos()
            dropInventory()
            for n=1,8 do
                getItemFromPeripheral(ItemLayerOne,n,64)
            end
            for n=9,16 do
                getItemFromPeripheral(ItemLayerTwo,n,64)
            end
            goTo.goTo(ReturnPosition)
            slot1=getSlot(ItemLayerOne)
            slot2=getSlot(ItemLayerTwo)
        end
        turtle.select(slot1)
        turtle.placeDown()
        goTo.back()
        turtle.select(slot2)
        turtle.place()
    end
    turtle.select(slot1)
    turtle.placeDown()
    if i ~= cols then
        if turnRight then
            goTo.turnRight()
            goTo.back()
            turtle.select(slot2)
            turtle.place()
            goTo.turnRight()
            turnRight = false
        else
            goTo.turnLeft()
            goTo.back()
            turtle.select(slot2)
            turtle.place()
            goTo.turnLeft()
            turnRight = true 
        end
    else
        goTo.up()
        turtle.select(slot2)
        turtle.placeDown()
    end

end
dropInventory()

end

--*********************************************
-- change ground
function changeGround(field, ItemName)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right

    if ItemName == nil then
        ItemName = "minecraft:dirt"
    end

    dropInventory()
    refillFuel()
    for i = 1, 8 do                                 -- get Item, leave half of the slots empty
        getItemFromPeripheral(ItemName,i,64)
    end
    goTo.goTo(field.pos)

    for j=1,cols do
        for i=1,rows do
            valid, data = turtle.inspectDown()
            if (valid and data.name ~= ItemName) or not valid then
                exchange = true
            end
            
            if exchange then
                slot=getSlot(ItemName)
                if slot == false then                   -- refill if no sugar is left
                    print("run out of"..ItemName)
                    ReturnPosition = goTo.returnPos()
                    for n=1,8 do
                        getItemFromPeripheral(ItemName,n,64)
                    end
                    goTo.goTo(ReturnPosition)
                    slot=getSlot(ItemName)
                else
                    turtle.select(slot)
                end
                turtle.digDown()
                turtle.placeDown()
            end
            goTo.forward()
        end

        if turnRight then
            goTo.turnRight()
            goTo.forward()
            goTo.turnRight()
            turnRight = false
        else
            goTo.turnLeft()
            goTo.forward()
            goTo.turnLeft()
            turnRight = true
        end
        goTo.forward()
    end
    
    dropInventory()   
end

--*********************************************
-- add light
function addLight(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right

    dropInventory()
    refillFuel()
    getItemFromPeripheral("minecraft:torch",1,64)
    getItemFromPeripheral("minecraft:planks",1,64)

    local lightCols = math.floor((cols-1)/9)        -- returns number of necessary watercols
    local lightRows = math.floor((rows-1)/9)
    goTo.goTo(field.pos)
    goTo.up(5)
    if turnRight then                               -- go to first light col
        goTo.turnLeft()
        goTo.forward(4)
        goTo.turnRight()
    else
        goTo.turnRight()
        goTo.forward(4)
        goTo.turnLeft()
    end
    goTo.back()

    for j = 1, lightCols do
        goTo.forward()
        for i = 1, lightRows do
            goTo.forward(4)
            turtle.select(2)
            turtle.placeDown()
            turtle.select(1)

            goTo.turnRight()                -- first light
            goTo.forward()
            turtle.placeDown()
            goTo.turnRight()
            for i = 1,3 do                 -- remaining three lights
                goTo.forward()
                goTo.turnRight()
                goTo.forward()
                turtle.placeDown()
            end
            goTo.turnLeft()
        end
        goTo.forward(4)
        if turnRight then
            goTo.turnRight()
            goTo.forward(5)
            goTo.turnRight()
            turnRight = false
        else
            goTo.turnLeft()
            goTo.forward(5)
            goTo.turnLeft()
            turnRight = true
        end
    end

end


--*********************************************
-- build sugar field
function sugarField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right
    local waterCols = cols/3                                -- determine number of water cols

    dropInventory()
    refillFuel()
    
-- build frame and ground if aero field
    if field.aero then
        buildFrame(field)
        buildGround(field)
    else
        changeGround(field)
    end

-- build water cols
    for i = 1, 3 do                                     -- get water buckets
        getItemFromPeripheral("minecraft:water_bucket",i,1)
    end
    goTo.goTo(field.pos)                                -- go to first water block
    turnRight = field.right                         -- reset turnRight
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
                for n=1,3 do                            -- refill water
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
        for n=1,3 do                            -- refill water
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
    
    -- build light
    addLight(field)

    dropInventory()

end

--*********************************************
-- build cactus field
function cactusField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right
    
    dropInventory()
    refillFuel()
        
    -- build frame and ground if aero field
    if field.aero then
        buildFrame(field)
        buildGround(field,"minecraft:dirt", "minecraft:sand")
    else
        changeGround(field,"minecraft:sand")
    end

    -- build light
    addLight(field)
    
    dropInventory()

end

--*********************************************
-- build enderlilly field
function enderlillyField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right
    
    dropInventory()
    refillFuel()

    -- build frame and ground if aero field
    if field.aero then
        buildFrame(field)
        buildGround(field,"minecraft:dirt", "minecraft:end_stone")
    else
        changeGround(field,"minecraft:end_stone")
    end

    -- build light
    addLight(field)
    
    dropInventory()
end

--*********************************************
-- build egeneral field
function generalField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right
    
    dropInventory()
    refillFuel()

    -- build frame and ground if aero field
    if field.aero then
        buildFrame(field)
        buildGround(field)
    else
        changeGround(field)
    end

    -- Build water blocks
    turnRight = field.right
    local waterCols = math.floor((cols-1)/9)        -- returns number of necessary watercols
    local waterRows = math.floor((rows-1)/9)
    for i=1,15 do                                   -- leave one slot empty for dirt
        getItemFromPeripheral("minecraft:water_bucket",i,1)
    end
    goTo.goTo(field.pos)
    if turnRight then                               -- go to first water col
        goTo.turnLeft()
        goTo.forward(4)
        goTo.turnRight()
    else
        goTo.turnRight()
        goTo.forward(4)
        goTo.turnLeft()
    end
    goTo.back()

    for j = 1, waterCols do
        for i = 1, waterRows do
            goTo.forward(5)
            slot=getSlot("minecraft:water_bucket")
            if slot == false then                   -- refill if no water is left
                print("run out of water")
                ReturnPosition = goTo.returnPos()
                dropInventory()
                for n=1,15 do
                    getItemFromPeripheral("minecraft:water_bucket",n,1)
                end
                goTo.goTo(ReturnPosition)
                slot=getSlot("minecraft:water_bucket")
            else
                turtle.select(slot)
            end
            turtle.digDown()
            turtle.placeDown()
        end
        goTo.forward(4)
        if turnRight then
            goTo.turnRight()
            goTo.forward(5)
            goTo.turnRight()
            turnRight = false
        else
            goTo.turnLeft()
            goTo.forward(5)
            goTo.turnLeft()
            turnRight = true
        end
    end

    -- build light
    addLight(field)
    
    dropInventory()
end

--*********************************************
-- select building function
function building(field,storagePos)
    storage = storagePos
    if field.crop == "sugar" then
        sugarField(field)
    elseif field.crop == "cactus" then
        cactusField(field)
    elseif field.crop == "enderlilly" then
        enderlillyField(field)
    else
        generalField(field)
    end

end