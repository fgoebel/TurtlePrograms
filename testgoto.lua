--simple test program for the goto API
local robot = require("robot")
local component = require("component")
local gt = require("gt")

local home = {x=0,y=0,z=0,f=0}
local pos01 = {x=10,y=10,z=0,f=2}

gt.initialize()
gt.setPos(home)

gt.goToPos(pos1)
gt.goToPos(home)




