-----------------------------------------------------------------------------------------
--
-- Reusable Bag game entry point!
-- By Stewart Bracken
--
-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

require("mobdebug").start()

math.randomseed(os.time())

local composer = require "composer"

-- Enable multitouch
system.activate("multitouch")

composer.gotoScene('src.levelScene', {params={level=require("levels.level1")}})