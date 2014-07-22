-----------------------------------------------------------------------------------------
--
-- Reusable Bag game entry point!
-- By Stewart Bracken
--
-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

require("mobdebug").start()

-- Time stuff, these only need to be called once:
math.randomseed(os.time())
Time = require "src.utils.time"
Runtime:addEventListener("enterFrame", Time)

local composer = require "composer"

-- Enable multitouch
system.activate("multitouch")

composer.gotoScene('src.levelScene', {params={level=require("levels.level1")}})