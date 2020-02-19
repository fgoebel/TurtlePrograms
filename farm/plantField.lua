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
    local turnRight = field.turnRight
  
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
                for n=1,16 do
                    getItemFromPeripheral("minecraft:sugar_cane",n,64)
                end
                goTo.goTo(ReturnPosition)
                slot=getSlot("minecraft:sugar_cane")
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
            goTo.turnLeft()
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

--*********************************************
-- plant cactus field
function cactusField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.turnRight
    
    dropInventory()
    refillFuel()
        
    for i=1,16 do
        getItemFromPeripheral("minecraft:cactus",i,64)
    end
    turnRight = field.turnRight
    goTo.goTo(field.pos)
    goTo.up()

    for j = 1,cols do
        for i = 1,rows/2 do
            slot=getSlot("minecraft:cactus")
            if slot == false then                   -- refill if no cactus is left
                print("run out of cactus")
                ReturnPosition = goTo.returnPos()
                for n=1,16 do
                    getItemFromPeripheral("minecraft:cactus",n,64)
                end
                goTo.goTo(ReturnPosition)
                slot=getSlot("minecraft:cactus")
            else
                turtle.select(slot)
            end
        end
        turtle.placeDown()
        goTo.forward(2)            
        if turnRight then                           -- move to next row
            goTo.turnRight()
            goTo.forward()
            goTo.turnRight()
            turnRight = false
        else 
            goTo.turnLeft()
            goTo.forward()
            goTo.turnLeft()
            turnRight=true
        end
    end

    dropInventory()

end

--*********************************************
-- build enderlilly field
function enderlillyField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.turnRight
    
    dropInventory()
    refillFuel()

    for i=1,16 do
        getItemFromPeripheral("extrautils2:enderlilly",i,64)
    end
    turnRight = field.turnRight
    goTo.goTo(field.pos)
    goTo.up()

    for j = 1,cols do
        for i = 1,rows do
            slot=getSlot("extrautils2:enderlilly")
            if slot == false then                   -- refill if no cactus is left
                print("run out of enderlilly")
                ReturnPosition = goTo.returnPos()
                for n=1,16 do
                    getItemFromPeripheral("extrautils2:enderlilly",n,64)
                end
                goTo.goTo(ReturnPosition)
                slot=getSlot("extrautils2:enderlilly")
            else
                turtle.select(slot)
            end
            turtle.placeDown()
            goTo.forward()            
            if turnRight then                       -- move to next row
                goTo.turnRight()
                goTo.forward()
                goTo.turnRight()
                turnRight = false
            else 
                goTo.turnLeft()
                goTo.forward()
                goTo.turnLeft()
                turnRight=true
            end
        end
    end

    dropInventory()
end

--*********************************************
-- build egeneral field
function generalField(field)
    local cols = field.cols
    local rows = field.rows
    local turnRight = field.turnRight

    seed = determineSeed(field.crop)
    
    dropInventory()
    refillFuel()

    turnRight = field.turnRight
    for i=1,16 do
        getItemFromPeripheral(seed,i,64)
    end
    goTo.goTo(field.pos)
    goTo.up()

    for j=1,cols do
        for i=1,rows do
            valid, data = turtle.inspectDown()
            if valid and data.name ~= "minecraft:water" then
                slot=getSlot(seed)
                if slot == false then                   -- refill if no water is left
                    print("run out of seed")
                    ReturnPosition = goTo.returnPos()
                    dropInventory()
                    for n=1,16 do
                        getItemFromPeripheral(seed,n,64)
                    end
                    goTo.goTo(ReturnPosition)
                    slot=getSlot(seed)
                else
                    turtle.select(slot)
                end
                turtle.digDown()
                turtle.placeDown()
            end
            goTo.forward()
        end
    end

    dropInventory()
end

--*********************************************
-- select planting function
function planting(field,storagePos)
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