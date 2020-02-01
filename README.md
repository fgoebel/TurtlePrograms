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
if fs.open("fields","r") then
    fs.delete("fields")
end
if fs.open("goTo.lua","r") then
    fs.delete("goTo.lua")
end
```
Delete files to ensure reload of updated versions


