--simple test program for the goto API
local robot = require("robot")
local component = require("component")
local gt = require("gt")
--Richtung f=2: north, z-

local home = {x=-496,y=63,z=-2087,f=2}
local pos01 = {x=-496,y=70,z=-2100,f=0}

gt.init()
--gt.setPos(home)

gt.goToPos(pos01)
gt.goToPos(home)




