local component = require("component")
local computer = require("computer")
local gt = require("gt") -- goto API ;-D
local rs = component.redstone

-- das hier  muss ich m al noch auslagern!! auch in so eine datei!!
	--progamm um diese Datei zu manipulieren!!
	-- gui hihi
	--
local home = {x=405,y=69,z=-1083,f=2}
local home1 = {x=405,y=69,z=-1085,f=0}
local dropPos = {x=405,y=69,z=-1083,f=3}



function load(name)
	local file = io.open(name,"r")
	local data = file:read("*a")
	file:close()
	return serialize.unserialize(data)
end

local fields = load("fields")

local pollTime = 600 --sekunden zwischen den Nachgucken
local timerCount = 0
local heartbeat = 0
local doWork = true
local waiting = false
--local currentFuelLevel = 0 
local lastFuelLevel = computer.energy()
local maxEnergyLevel = computer.maxEnergy()

local chargeTo = 95 -- Percentage which should be charged to
local usedEnergy = 0
--local refuelCount = 0
local lastUsedSlot = 2 -- darüber wird gelehrt
local currentPlant = 1
-- so ists einfacher im code
local cactus = 0
local seeds = 1
local enderlily = 2
local ItemReserve = 0 -- 0: slot wird bis auf einen geleert
local inventorySize = robot.inventorySize()


--if not os.loadAPI("goTo") then
--    shell.run("openp/github get Blast0r/TurtlePrograms/master/goTo.lua goTo")
--    if not os.loadAPI("goTo") then
--    error("goTo API not present!!! ;-(")
--    end
--end

function turn()
    left()
    left()
end
function left()
    gt.turnLeft()
end
function right()
    gt.turnRight()
end
function forward(steps)
    if steps == nil then
        steps = 1
    end
    i=0
    while i < steps do
        if gt.forward() then
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
        if gt.back() then
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
        if gt.up() then
            i=i+1
        else
            os.sleep(0.5)
        end
    end
end
function down(steps)
    if steps == nil then
        steps = 1
    end
i=0
    while i < steps do
        if gt.down() then
            i=i+1
        else
            os.sleep(0.5)
        end
    end
end
function digDown()
	robot.swingDown()
end
function place()
	if robot.placeDown() then
		return true
	else
		return false
	end
end

function isMature() -- gibts glaub ich nicht
success, data = robot.inspectDown()
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

--Math helping functions
function round(num,numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) /mult
end

-- Charging 
function rson()
  rs.setOutput(sides.left,15)
end 

function rsoff()
  rs.setOutput(sides.left,0)
end

function updateEnergy()
  currentEnergy = pc.energy()
  chargeState = round(((currentEnergy / maxEnergy) * 100),2)
end

function refuel()
	charge()
end

function charge()--aufladeprogram, aber wir mappen das einfach durch refuel()
	updateEnergy()
	print(chargeState)
	if chargeState <= chargeTo then
	  rson()
	  -- save currently stored energy
	  while not checkEnergyLevel(chargeTo) do
		os.sleep(1)
		print(chargeState)
	  end
	  rsoff()
	end
	-- calculate Charged energy, and add up
end


function checkEnergyLevel(level) --PERCENTAGE!!
	updateEnergy()
	if chargeState() >= level then
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
    --currentFuelLevel = turtle.getFuelLevel()
	updateEnergy()
	term.clear()
	term.setCursor(1,1)
	print("+Status Screen - EnderFarming+")
	if waiting then
		print("current Status: waiting " .. timeToWait .. " Seconds!")
	else
		print("current Status: Working")
	end
	
	heartbeat = heartbeat + 1
	--print("Event HeartBeat: " .. heartbeat)
    print("EnergyLevel: " .. currentEnergy)
	print("chargeState: " .. chargeState)
    print("used Energy: " .. usedEnergy) 
    --print("Number of Refuels: " .. refuelCount)
	print("press x to exit Programm!")
end
function selectCrop(plant)
	if plant == 0 then
		return
	end
	currentPlant = plant
	robot.select(plant)
	if robot.count(plant) == 1 then 
		fillSlot(plant)
	end
    if robot.count(plant) > 1 then
        return true
    else
        return false
    end
end

function combineStacks()
    for i = 1, inventorySize do
        robot.select(i)
        itemCount = robot.count(i)
        if itemCount == 0 then --müsste man nen anderen Stack hierher holen...
            
        elseif itemCount < 64 then
            --fillSlot(i) die funktion ist blöd, da sie von vorne anfängt ...
            
            for k = i + 1, inventorySize do
                robot.select(k)
                if robot.compareTo(i) then
                    robot.transferTo(i, 64 - robot.count(i))
                end
            end
        end
    end
end
function drop()
for i = 1,inventorySize do
	if i < lastUsedSlot + 1 then
	--auffüllen
		fillSlot(i)
	else
		robot.select(i)
		robot.drop()
	end
end
robot.select(1)
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
	for i=lastUsedSlot + 1,inventorySize do
		robot.select(fsSlot)
		if robot.compareTo(i) then
			robot.select(i)
			robot.transferTo(fsSlot, 64 - robot.count(fsSlot))
		end
		if robot.count(fsSlot) == 64 then 
			robot.select(fsSlot)
			return true
		end
	end
	robot.select(fsSlot)
	return false
end
function getEmptySlot()
    for i = lastUsedSlot + 1, inventorySize do
        if robot.count(i) == 0 then
            --robot.select(i)
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
if not checkEnergyLevel(chargeTo) then
    --left()
    charge()
    --right()
end
up(5)
-- verschiednee Fields usw hier einsetzen..
-- Wheat, oneField(rows,cols,turnRight)


for k,v in ipairs(fields) do
print(v.name)
	if v.active then
	goTo.goTo(v.pos)
	if v.type == 0 then 
		--cactusField(v.rows,v.cols,v.right)
		-- just go back ;-D
	else
		print("only cactus allowed for the moment")
--		selectCrop(v.type)
--		oneField(v.rows,v.cols,v.right)
	end
	up(5)
	end
end

--ab ach hause
    gt.goToPos(home1) -- home, richtung Interface
	--gt.goToPos(dropPos)
	--drop()
	--gt.goToPos(home)

--nochmal überdenken:
updateEnergy()
usedEnergy = usedEnergy + (lastEnergyLevel - currentEnergy)
lastEnergyLevel = currentEnergy
end


gt.init()
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
 
--main()


