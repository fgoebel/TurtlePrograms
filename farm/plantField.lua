-- field pos: one block above first ground block, not above crop!!! (--> pos not different for different crops)

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
        goTo.goTo(position)                                         -- go to storage system
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

--*********************************************
-- plant sugar field
function sugarField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right
  
    dropInventory(storage)
    refillFuel(storage)
    for i = 1, 16 do                -- get sugar cane
        getItemFromPeripheral("minecraft:reeds",i,64)
    end

    goTo.goTo(travelsPos)                             -- go to travel pos
    goTo.goTo(field.pos)
    goTo.up(1)
    turnRight = field.right
    local skip = 1

    j=1
    while j <= cols do
        for i=1,rows-1 do
            slot=getSlot("minecraft:reeds")
            while slot == false do                  -- wait for beeing refilled
                print("run out of sugar_cane")
                sleep(10)
                slot=getSlot("minecraft:reeds")
            end
            turtle.select(slot)
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
            goTo.turnLeft()
            turnRight = true 
        end
        j = j + 1 + skip
        if skip == 1 then
            skip = 0
        else
            skip = 1
        end

    end

    goTo.goTo(travelsPos)
    dropInventory(drop)

end

--*********************************************
-- plant cactus field
function cactusField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right
    
    dropInventory(storage)
    refillFuel(storage)
        
    for i=1,16 do
        getItemFromPeripheral("minecraft:cactus",i,64)
    end

    turnRight = field.right
    goTo.goTo(travelsPos)                             -- go to travel pos
    goTo.goTo(field.pos)
    goTo.up()

    for j = 1,cols do
        i = 1
        while i < rows do
            slot=getSlot("minecraft:cactus")
            while slot == false do                  -- wait for beeing refilled
                print("run out of cactus")
                sleep(10)
                slot=getSlot("minecraft:cactus")
            end
            turtle.select(slot)
            turtle.placeDown()
            goTo.forward(2)
            i = i + 2
        end

        if turnRight then                           -- move to next row
            goTo.turnRight()
            goTo.forward()
            goTo.turnRight()
            goTo.forward()
            turnRight = false
        else 
            goTo.turnLeft()
            goTo.forward()
            goTo.turnLeft()
            goTo.forward()
            turnRight=true
        end
    end

    goTo.goTo(travelsPos)
    dropInventory(drop)

end

--*********************************************
-- build enderlilly field
function enderlillyField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right
    
    dropInventory(storage)
    refillFuel(storage)

    for i=1,16 do
        getItemFromPeripheral("extrautils2:enderlilly",i,64)
    end

    turnRight = field.right
    goTo.goTo(travelsPos)                             -- go to travel pos
    goTo.goTo(field.pos)
    goTo.up()

    for j = 1,cols do
        for i = 1,rows do
            slot=getSlot("extrautils2:enderlilly")
            while slot == false do                  -- wait for beeing refilled
                print("run out of enderlilly")
                sleep(10)
                slot=getSlot("extrautils2:enderlilly")
            end
            turtle.select(slot)
            turtle.placeDown()
            goTo.forward()
        end         

        if turnRight then                           -- move to next row
            goTo.turnRight()
            goTo.forward()
            goTo.turnRight()
            goTo.forward()
            turnRight = false
        else 
            goTo.turnLeft()
            goTo.forward()
            goTo.turnLeft()
            goTo.forward()
            turnRight=true
        end
    end

    goTo.goTo(travelsPos)
    dropInventory(drop)

end

--*********************************************
-- build egeneral field
function generalField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.right

    seed = determineSeed(field.crop)
    
    dropInventory(storage)
    refillFuel(storage)

    turnRight = field.right
    for i=1,16 do
        getItemFromPeripheral(seed,i,64)
    end

    goTo.goTo(travelsPos)                             -- go to travel pos
    goTo.goTo(field.pos)
    goTo.up()

    -- till first
    for j = 1,cols do
        for i= 1,rows-1 do
            turtle.digDown()
            goTo.forward()
        end
        turtle.digDown()
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
    end

    -- go back to start
    turnRight = field.right
    goTo.goTo(field.pos)
    goTo.up()
    turtle.digDown()
    
    -- plant seeds
    for j=1,cols do
        for i=1,rows-1 do
            slot=getSlot(seed)
            while slot == false do                  -- wait for beeing refilled
                print("run out of "..seed)
                sleep(10)
                slot=getSlot(seed)
            end
            turtle.select(slot)
            turtle.placeDown()
            goTo.forward()
        end
        turtle.select(slot)
        turtle.placeDown()

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
    end

    goTo.goTo(travelsPos)
    dropInventory(drop)

end

--*********************************************
-- select planting function
function planting(field,storagePos,dropPos)
    storage = storagePos
    drop = dropPos
    travelsPos = field.pos
    travelsPos.y = travelsPos.y + 3
    travelsPos.x = travelsPos.x - 5
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