-- event turtle_inventory verwenden

--unterscheidung pure crystal <-> fluix? sodass beim fluix kein energie eingeschaltet wird

firstFreeSlot = 5
pollTime = 10 -- time to wait between two polls
working = false
waiting = false
timerCount = 0
done = false
heartbeat = 0


function suckAll()
	turtle.select(firstFreeSlot)
	while turtle.suckDown() do end	
end

function compare()
	for i = 1,firstFreeSlot-1 do
		if turtle.compareTo(i) then
			return true
		end
	end
	return false
end

function display()
	timeToWait = pollTime - timerCount
	term.clear()
	term.setCursorPos(1,1)
	if working then
		print("working: true")
	else
		print("working: false")
	end
	if waiting then
		print("wait " .. timeToWait .. " more Seconds!")
	else
		print("not sleeping")
	end
	
	if done then
		print("currently done! waiting for more work")
	end
	heartbeat = heartbeat + 1
	print(heartbeat)
end


function dropAll()
	working = false
	for i = 1,16 do
		itemCount = turtle.getItemCount(i)
		if i < firstFreeSlot then
			if itemCount > 1 then
				turtle.select(i)
				turtle.dropUp(itemCount - 1)
			end
		else
			if itemCount ~= 0 then
				turtle.select(i)
				if compare() then
					turtle.dropUp()
				else
					turtle.dropDown()
					working = true
				end
			end
		end
	end
end

function main()
while true do
display()
event , param1 = os.pullEvent() -- 
-- state machine ;-)
	if (event == "timer") and (param1 == waitingTimer) then
		if timerCount >= pollTime then
			waiting = false
			work = true
			done = false
			timerCount=0 --reset Timer
		else
			timerCount = timerCount + 1
			waitingTimer = os.startTimer(1)
		end
	end
	if (event == "turtle_inventory") and (not(waiting)) then
		work = true
		sleep(2) -- the item delivery is not instant..
	end

	if not waiting then
		if work then
			work = false
			suckAll()
			dropAll()
		end

		if working then
			done = false
			rs.setOutput("front",true)
			waiting = true
			waitingTimer = os.startTimer(1)
		else
			rs.setOutput("front",false)
			done = true
		end
	end
 end
 end


 suckAll()
 dropAll()

 main()



