-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )
require("mobdebug").start()

math.randomseed(os.time())

local composer = require "composer"
local Util = require "src.util"

Util.EnableDebugPhysicsShake(true)

-- Enable multitouch
system.activate("multitouch")

composer.gotoScene('src.level')