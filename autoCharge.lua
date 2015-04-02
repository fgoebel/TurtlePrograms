function fillSlot(slot)
	oldCount = turtle.getItemCount(slot)
	for i = 1,16 do
		if i ~= slot then
			currenCount = turtle.getItemCount(i)
			if currentCount ~= 0 then
			turtle.select(i)
				if turtle.compareTo(slot) then
					turtle.transferTo(slot)
				end
			end
			
		end
	end
	turtle.select(1)
end

function drop()
	for i = 2,16 do
		turtle.select(1)
		itemCount = turtle.getItemCount(i)
		if itemCount ~= 0 then
			if not turtle.compareTo(i) then
				turtle.select(i)
				turtle.dropUp()
			end
		end
	end
end

work = false

turtle.suck()
while true do
	event, param = os.pullEvent()
	if event == "turtle_inventory" then	
		while turtle.getItemCount(1) > 1 do
			turtle.select(1)
			turtle.drop()
			while not turtle.suck() do
				sleep(1)
			end
			drop()
			if turtle.getItemCount(1) < 3 then
				fillSlot(1)
			end
		end	
	end
end
