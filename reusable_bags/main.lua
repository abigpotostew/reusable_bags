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
Time = require "opal.src.utils.time"
Runtime:addEventListener("enterFrame", Time)

Log = require "opal.src.utils.log"
Log:SetLogLevel (Log.DEBUG)

oAssert = require "opal.src.utils.oAssert"

-- Put GLOBAL table in _G
require "opal.src.globals"

local composer = require "composer"

-- Enable multitouch
--system.activate("multitouch")

composer.gotoScene('opal.src.levelScene', {params={level=require("reusable_bags.levels.level1")}})