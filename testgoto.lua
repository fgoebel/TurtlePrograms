--simple test program for the goto API
local robot = require("robot")
local component = require("component")
local goTo = require("goTo")

local home = {x=0,y=0,z=0,f=0}
local pos01 = {x=10,y=10,z=0,f=2}

goTo.initialize()
goTo.setPos(home)

goTo.goto(pos1)
goTo.goto(home)



