# TurtlePrograms
collection of useful little Turtle Programs for the minecraft Mod "ComputerCraft"

## Harvesting Turtles
By using turtle.digDown for harvesting, more than one block was harvested. 
This was initially handled by using placeDown instead, which resulted in the crop "still be planted" (equal to right klicking on it).
However, this did not work for sugar at all, while a lot of crops are left for the remaining plants. 
Hence, better use mining turtles!

## Applied Energistics
for equipping the turtle, an ME interface of Applied Energistics is used as peripheral including coal, wheat seeds, beetroot seeds, potato, carrot and a dirt block.

## Program to update files
### Unmanaged farming
add a programm to turtle like "update.lua" by following these steps:
``` 
r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/update.lua")
f = fs.open("update.lua", "w")
f.write(r.readAll())
f.close()
r.close()
```
This code will automatically update files, if new commit is availabel

### Managed farming
Farming is managed by a computer and different turtles can be used, which are send by the computer. Important: when using multiple turtles, waiting position must be changed.

For Trutles:
``` 
r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/farm/updateManaged.lua")
f = fs.open("update.lua", "w")
f.write(r.readAll())
f.close()
r.close()
```
For Computer/Manager:
``` 
r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/farm/updateManage.lua")
f = fs.open("update.lua", "w")
f.write(r.readAll())
f.close()
r.close()
```
For Input Computer:
``` 
r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/farm/updateInput.lua")
f = fs.open("update.lua", "w")
f.write(r.readAll())
f.close()
r.close()
```
For Planting turtles:
``` 
r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/farm/updatePlanting.lua")
f = fs.open("update.lua", "w")
f.write(r.readAll())
f.close()
r.close()
```
