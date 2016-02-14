local home = {x=405,y=69,z=-1083,f=2}
local home1 = {x=405,y=69,z=-1085,f=0}
local dropPos = {x=405,y=69,z=-1083,f=3}


function load(name)
	local file = fs.open(name,"r")
	local data = file.readAll()
	file.close()
	return textutils.unserialize(data)
end

local fields = load("fields")

local pollTime = 600 --sekunden zwischen den Nachgucken
local timerCount = 0
local heartbeat = 0
local doWork = true
local waiting = false
local currentFuelLevel = 0 
local lastFuelLevel = turtle.getFuelLevel()
local usedFuel = 0
local refuelCount = 0
local lastUsedSlot = 2 -- darüber wird gelehrt
local currentPlant = 1
-- so ists einfacher im code
local seeds = 1
local enderlily = 2
local ItemReserve = 0 -- 0: slot wird bis auf einen geleert


if not os.loadAPI("goTo") then
	shell.run("openp/github get Blast0r/TurtlePrograms/master/goTo.lua goTo")
	if not os.loadAPI("goTo") then
	error("goTo API not present!!! ;-(")
	end
end
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
function digDown()
	turtle.digDown()
end
function place()
	if turtle.placeDown() then
		return true
	else
		return false
	end
end
function isMature()
success, data = turtle.inspectDown()
	if success then
		--da ist ein block
		if data.metadata == 7 then
			return 1
			-- es ist der richtige ;-)
		else
			--print("not mature!")
			return 2
		end
	else -- succes = false
		-- da ist kein block!
		--print("there is no block")
		return 0
		
	end
end
function refuel(toLevel)
	turtle.select(16)
	if turtle.getItemCount(16) ~= 0 then 
		turtle.drop()
	end
	while turtle.getFuelLevel() < toLevel do
		turtle.suck()
		if turtle.refuel() then
           refuelCount = refuelCount + 1-- haben wir wohl ein Bucket verbraucht.
        end
		turtle.drop()
	end
	turtle.select(1)
	lastFuelLevel = turtle.getFuelLevel()
end
function checkFuelLevel(level)
    if turtle.getFuelLevel() >= level then
        return true
    else
        return false
    end
end

function harvest()
	mature = isMature()
	if (mature == 1) then
		print("is mature")
		digDown()
		if selectCrop(currentPlant) then
			if not place() then
				print("place failed")
				if currentPlant~=enderlily then
					digDown()
				end
				place()
				print("second place")
			end
		end
	elseif mature == 0 then
		print("there is no block")
	-- da ist kein block
		if selectCrop(currentPlant) then
			if not place() then
				if currentPlant~=enderlily then
					digDown()
				end
				place()
			end
		end
	end
end
function display()
    timeToWait = pollTime - timerCount
    currentFuelLevel = turtle.getFuelLevel()
	term.clear()
	term.setCursorPos(1,1)
	print("+Status Screen - EnderFarming+")
	if waiting then
		print("current Status: waiting " .. timeToWait .. " Seconds!")
	else
		print("current Status: Working")
	end
	
	heartbeat = heartbeat + 1
	--print("Event HeartBeat: " .. heartbeat)
    print("fuelLevel: " .. currentFuelLevel)
    print("used Fuel: " .. usedFuel) 
    print("Number of Refuels: " .. refuelCount)
	print("press x to exit Programm!")
end
function selectCrop(plant)
	if plant == 0 then
		return
	end
	currentPlant = plant
	turtle.select(plant)
	if turtle.getItemCount(plant) == 1 then 
		fillSlot(plant)
	end
    if turtle.getItemCount(plant) > 1 then
        return true
    else
        return false
    end
end

function combineStacks()
    for i = 1, 16 do
        turtle.select(i)
        itemCount = turtle.getItemCount(i)
        if itemCount == 0 then --müsste man nen anderen Stack hierher holen...
            
        elseif itemCount < 64 then
            --fillSlot(i) die funktion ist blöd, da sie von vorne anfängt ...
            
            for k = i + 1, 16 do
                turtle.select(k)
                if turtle.compareTo(i) then
                    turtle.transferTo(i, 64 - turtle.getItemCount(i))
                end
            end
        end
    end
end
function drop()
for i = 1,16 do
	if i < lastUsedSlot + 1 then
	--auffüllen
		fillSlot(i)
	else
		turtle.select(i)
		turtle.drop()
	end
end
turtle.select(1)
end
function goDrop()
--function welche nachh hause Fährt, abläd und weiter macht..
	oldPos = goTo.getPos()
	up(4)
	goTo.goTo(home1) -- home, 
	goTo.goTo(dropPos)
	drop()
	goTo.goTo(home1)
	forward(3)
	up(5)--erst Raus gehen! dann goto
	goTo.goTo(oldPos)
end
function fillSlot(fsSlot)
	for i=lastUsedSlot + 1,16 do
		turtle.select(fsSlot)
		if turtle.compareTo(i) then
			turtle.select(i)
			turtle.transferTo(fsSlot, 64 - turtle.getItemCount(fsSlot))
		end
		if turtle.getItemCount(fsSlot) == 64 then 
			turtle.select(fsSlot)
			return true
		end
	end
	turtle.select(fsSlot)
	return false
end
function getEmptySlot()
    for i = lastUsedSlot + 1, 16 do
        if turtle.getItemCount(i) == 0 then
            --turtle.select(i)
            return i
        end
    end
    return false
end

function cactusField(rows,cols,turnRight)
--wo starte ich denn? und wo gehe ich hin?
-- also Breite/Reihen zu Startpunkt einordnen.
breite= cols
reihen = rows
topRow = true
j=1
working = true


	--for j = 1, reihen do
	while working do
		for i = 1, breite do
			digDown()
			if i ~= breite then
				forward(1)
			end
		end
		if ((j == reihen) and (not topRow)) then
			break
		end
		if ((j == 1) and topRow) or ((j == reihen-1) and (not(topRow))) then
			if turnRight then -- auf gleicher höhe eine Reihe weiter
				right()
				forward(1)
				right()
			else
				left()
				forward(1)
				left()
			end
			j = j + 1
		else
			if topRow then -- eine Reihe wieder zurück und einen Tiefer.
				if turnRight then
					right()
					forward(1)
					right()
					down(1)
				else
					left()
					forward(1)
					left()
					down(1)
				end
				j = j - 1
				topRow = false
			else -- jetzt sind wir also eine höhe Tiefer und müssen zwei vor gehen
				if turnRight then
					up(1)
					right()
					forward(2)
					right()
				else
					up(1)
					left()
					forward(2)
					left()
				end
				j = j + 2
				topRow = true
			end
		end
	end
end
function oneField(rows,cols,turnRight) --cols nach vorn
	for j = 1,rows do
		for i=1,cols-1 do
			harvest()
			forward(1)
		end
		harvest()
		if j ~= rows then
			if turnRight then
				right()
				forward(1)
				right()
				turnRight= false
			--rechtsherum
			else
			--linksherum
				left()
				forward(1)
				left()
				turnRight=true
			end
		end
	end
end



function work()
if not checkFuelLevel(5000) then
    left()
    refuel(10000)
    right()
end
forward(2)
up(5)
-- verschiednee Fields usw hier einsetzen..
-- Wheat, oneField(rows,cols,turnRight)


for k,v in ipairs(fields) do
print(v.name)
	if v.active then
	goTo.goTo(v.pos)
	if v.type == 0 then 
		cactusField(v.rows,v.cols,v.right)
	else
		selectCrop(v.type)
		oneField(v.rows,v.cols,v.right)
	end
	up(5)
	end
end

--ab ach hause
    goTo.goTo(home1) -- home, richtung Interface
	goTo.goTo(dropPos)
	drop()
	goTo.goTo(home)


usedFuel = usedFuel + (lastFuelLevel - turtle.getFuelLevel())
lastFuelLevel = turtle.getFuelLevel()
end


goTo.initialize()
function main()
while true do
display()
event , param1 = os.pullEvent() -- 
-- state machine ;-)
	if (event == "timer") and (param1 == waitingTimer) then
		if timerCount >= pollTime then
			waiting = false
			doWork = true
			timerCount=0 --reset Timer
		else
			timerCount = timerCount + 1
			waitingTimer = os.startTimer(1)
		end
	elseif (event == "key") and (param1 == keys.x ) then
		return
	elseif (event == "key") and (param1 == keys.d) then
		timerCount = pollTime -- was zum start des programs führen sollte..
	end

	if not waiting then
		if doWork then
            display()
			doWork = false
            work() -- also ab aufs Feld
			waiting = true
			waitingTimer = os.startTimer(1)
		end
	end
 end
 end
 
main()


