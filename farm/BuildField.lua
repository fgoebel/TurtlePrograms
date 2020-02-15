-- field pos: one block above first ground block, not above crop!!! (--> pos not different for different crops)

--*********************************************
-- build Frame
function buildFrame()
    for i = 1, 16 do                -- get cobblestone
        getItemFromPeripheral("minecraft:cobblestone",i,64)
    end
    
    goTo.goTo(field.pos)

    if turnRight then         -- go to first pos of frame (one block left, one down)
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
            if slot == false then
                print("run out of stone")
                break
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

    goTo.goTo(storage)
    dropInventory()

end

--*********************************************
-- build ground
function buildGround()
goTo.goTo(storage)
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
        if slot == false then
            print("run out of dirt")
            break
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

    goTo.goTo(storage)
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

goTo.goTo(storage)
refillFuel()
dropInventory()
    
-- build frame and ground if aero field
    if field.aero then
        buildFrame()
        turnRight = field.turnRight
        buildGround()
    end

-- build water cols
    goTo.goTo(storage)
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
    goTo.goTo(storage)
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
            if slot == false then
                print("run out ofsugar cane")
                break
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

    goTo.goTo(storage)
    dropInventory()

end
