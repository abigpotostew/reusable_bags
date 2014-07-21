-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )
require("mobdebug").start()

math.randomseed(os.time())

require("src.my_lcs_test")

local composer = require "composer"
local Util = require "src.util"

Util.EnableDebugPhysicsShake(true)

-- Enable multitouch
system.activate("multitouch")


composer.gotoScene('src.levelScene', {params={level=require("levels.level1")}})