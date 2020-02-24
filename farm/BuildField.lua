-- field pos: one block above first ground block, not above crop!!! (--> pos not different for different crops)

--*********************************************
--refill and drop functions + general functions
function dropInventory()
    for Slot =1, 16 do              -- clear slots
        turtle.select(Slot)        -- select next Slot
        turtle.dropDown()          -- just drop everthing in the slot
        sleep(0.5)
    end
end

function refillFuel()
    if turtle.getFuelLevel() < 5000 then
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
    peri = peripheral.wrap("right")                     -- sets ME interface on bottom as pheripheral
    sleep(1)
    for i=1,9 do                                        -- checks each slot of peripheral
        item = peri.getItemMeta(i)                      -- stores meta data in item variable
        if item ~= nil then
            if item.name == ItemName then                   -- if name of item in slot is desired seed name
                peri.pushItems("east",i,MaxItems,Slot)      -- push item in slot i up to turtle, max 64 items in slot 1
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

    goTo.goTo(storage)
    dropInventory()
    refillFuel()  
    for i = 1, 16 do                -- get cobblestone
        getItemFromPeripheral("minecraft:cobblestone",i,64)
    end

    goTo.forward()
    goTo.goTo(travelsPos)           -- go to travel pos
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
            while slot == false do                   -- wait for beeing refilled
                print("run out of cobblestone")
                sleep(10)
                slot=getSlot("minecraft:cobblestone")
            end
            turtle.select(slot)
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

    goTo.goTo(travelsPos)           -- go to travel pos

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

goTo.goTo(drop)
dropInventory()
goTo.forward()
goTo.goTo(storage)
refillFuel() 
for i = 1, 8 do                     -- get ItemLayerOne
    getItemFromPeripheral(ItemLayerOne,i,64)
end
for i = 9, 16 do                     -- get ItemLayerTwo
    getItemFromPeripheral(ItemLayerTwo,i,64)
end

goTo.forward()
goTo.goTo(travelsPos)                -- go to travel pos
goTo.goTo(field.pos)
goTo.down(1)
goTo.turnLeft()
goTo.turnLeft()                     -- turtle is facing backwards and at first block of ground

for i = 1, cols do
    for j=1,rows-1 do
        slot1=getSlot(ItemLayerOne)
        slot2=getSlot(ItemLayerTwo)
        while slot1 == false or slot2 == false do           -- wait for beeing refilled
            if slot1 == false then
                print("run out of "..ItemLayerOne)
            end
            if slot2 == false then
                print("run out of "..ItemLayerTwo)
            end
            sleep(10)
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

goTo.goTo(travelsPos)           -- go to travel pos

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

    goTo.goTo(storage)
    dropInventory()
    refillFuel()  
    for i = 1, 16 do                                 -- get Item, leave half of the slots empty
        getItemFromPeripheral(ItemName,i,64)
    end

    goTo.forward()
    goTo.goTo(travelsPos)                            -- go to travel pos
    goTo.goTo(field.pos)

    for j=1,cols do
        for i=1,rows do
            valid, data = turtle.inspectDown()
            if (valid and data.name ~= ItemName) or not valid then
                slot=getSlot(ItemName)
                while slot == false do                  -- wait for beeing refilled
                    print("run out of "..ItemName)
                    sleep(10)
                    slot=getSlot(ItemName)
                end
                turtle.select(slot)
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
    
    goTo.goTo(travelsPos)           -- go to travel pos

end

--*********************************************
-- add light
function addLight(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right

    goTo.goTo(drop)
    dropInventory()
    goTo.forward()
    goTo.goTo(storage)
    refillFuel()   
    getItemFromPeripheral("minecraft:torch",1,64)
    getItemFromPeripheral("minecraft:planks",2,64)

    goTo.forward()
    goTo.goTo(travelsPos)                            -- go to travel pos
    goTo.goTo(field.pos)
    goTo.up(5)
    if turnRight then                               -- go to first light col
        goTo.turnRight()
        goTo.forward(4)
        goTo.turnLeft()
    else
        goTo.turnLeft()
        goTo.forward(4)
        goTo.turnRight()
    end

    j = 5
    while j <= cols-4 do
        i = 1
        while i <= rows-4 do
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
            i = i + 5
        end
        goTo.forward(4)
        if j < cols - 4 then 
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
        j = j + 5
    end

    goTo.goTo(travelsPos)           -- go to travel pos
end


--*********************************************
-- build sugar field
function sugarField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right
    local waterCols = cols/3                                -- determine number of water cols

    -- build frame and ground if aero field
    if field.aero then
        buildFrame(field)
        buildGround(field)
    else
        changeGround(field)
    end

-- build water cols
    goTo.goTo(drop)
    dropInventory()
    goTo.forward()
    goTo.goTo(storage)
    refuel()
    for i = 1, 3 do                                     -- get water buckets
        getItemFromPeripheral("minecraft:water_bucket",i,1)
        sleep(1)
    end

    goTo.forward()
    goTo.goTo(travelsPos)                               -- go to travel pos
    goTo.goTo(field.pos)                                -- go to first water block
    turnRight = field.right                             -- reset turnRight
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
            while slot == false do                  -- wait for beeing refilled
                print("run out of water_bucket")
                sleep(10)
                slot=getSlot("minecraft:water_bucket")
            end
            turtle.select(slot)
            turtle.placeDown()
            goTo.forward()
        end
        goTo.back(1)

        for i=4,rows do
            goTo.back(1)
            slot=getSlot("minecraft:bucket")    -- select empty bucket
            while slot == false do                  -- wait for beeing refilled
                print("run out of bucket")
                sleep(10)
                slot=getSlot("minecraft:bucket")
            end
            turtle.select(slot)
            turtle.placeDown()                  -- refill bucket
            goTo.forward(2)
            turtle.digDown()                          
            turtle.placeDown()                  -- place water
        end
        goTo.back(1)                            -- go back 1 block, were water is available
        for n=1,3 do                            -- refill water
            slot=getSlot("minecraft:bucket")    -- get empty bucket
            if slot ~= false then               -- if empty bucket is available
                turtle.select(slot)
                turtle.placeDown()              -- get water   
            else
                slot=getSlot("minecraft:water_bucket")
                while slot == false do                  -- wait for beeing refilled
                    print("run out of water_bucket")
                    sleep(10)
                    slot=getSlot("minecraft:water_bucket")
                end
            end
            sleep(1)
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
    goTo.goTo(travelsPos)

    -- build light
    addLight(field)

end

--*********************************************
-- build cactus field
function cactusField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right
    
    -- build frame and ground if aero field
    if field.aero then
        buildFrame(field)
        buildGround(field,"minecraft:dirt", "minecraft:sand")
    else
        changeGround(field,"minecraft:sand")
    end

    -- build light
    addLight(field)

end

--*********************************************
-- build enderlilly field
function enderlillyField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right

    -- build frame and ground if aero field
    if field.aero then
        buildFrame(field)
        buildGround(field,"minecraft:dirt", "minecraft:end_stone")
    else
        changeGround(field,"minecraft:end_stone")
    end

    -- build light
    addLight(field)
    
end

--*********************************************
-- build egeneral field
function generalField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right

    -- build frame and ground if aero field
    if field.aero then
        buildFrame(field)
        buildGround(field)
    else
        changeGround(field)
    end

    -- Build water blocks
    turnRight = field.right
    goTo.goTo(drop)
    dropInventory()
    goTo.forward()
    goTo.goTo(storage)
    refillFuel()
    for i=1,15 do                                   -- leave one slot empty for dirt
        getItemFromPeripheral("minecraft:water_bucket",i,1)
    end

    goTo.forward()
    goTo.goTo(travelsPos)                           -- go to travel pos
    goTo.goTo(field.pos)
    if turnRight then                               -- go to first water col
        goTo.turnRight()
        goTo.forward(4)
        goTo.turnLeft()
    else
        goTo.turnLeft()
        goTo.forward(4)
        goTo.turnRight()
    end
    goTo.back()

    j=5
    while j <= cols-4 do
        i=1
        while i <= rows-4 do
            goTo.forward(5)
            slot=getSlot("minecraft:water_bucket")
            while slot == false do                  -- wait for beeing refilled
                print("run out of water_bucket")
                sleep(10)
                slot=getSlot("minecraft:water_bucket")
            end
            turtle.select(slot)
            turtle.digDown()
            turtle.placeDown()
            i = i + 5
        end
        goTo.forward(4)
        if j < cols - 4 then
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
        j = j + 5
    end
    goTo.goTo(travelsPos)

    -- build light
    addLight(field)

end

--*********************************************
-- select building function
function building(field,storagePos,dropPos)
    storage = storagePos
    drop = dropPos
    travelsPos = {}
    travelsPos.f = field.pos.f
    travelsPos.z = field.pos.z
    travelsPos.y = field.pos.y + 3
    travelsPos.x = field.pos.x - 5

    while turtle.detect == true do          -- check if someone is in front before moving to storage
        sleep(5)
    end

    if field.crop == "sugar" then
        sugarField(field)
    elseif field.crop == "cactus" then
        cactusField(field)
    elseif field.crop == "enderlilly" then
        enderlillyField(field)
    else
        generalField(field)
    end

    goTo.goTo(drop) 
    dropInventory()
end