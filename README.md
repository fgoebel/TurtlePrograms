# TurtlePrograms
collection of useful little Turtle Programs for the minecraft Mod "ComputerCraft"

## Program to update files
add a programm to turtle like "update.lua" with the following code:
``` 
r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/farm/FarmingNew.lua")
f = fs.open("goTo.lua", "w")
f.write(r.readAll())
f.close()
r.close()
if fs.exists("fields" then
    fs.delete("fields")
end
if fs.exists("goTo.lua") then
    fs.delete("goTo.lua")
end
```
Delete files to ensure reload of updated versions

## Harvesting Turtles
By using turtle.digDown for harvesting, more than one block was harvested. 
This was initially handled by using placeDown instead, which resulted in the crop "still be planted" (equal to right klicking on it).
However, this did not work for sugar at all, while a lot of crops are left for the remaining plants. 
Hence, better use mining turtles!


