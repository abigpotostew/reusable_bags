-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )
require("mobdebug").start()

local composer = require "composer"
local Util = require "src.util"

Util.EnableDebugPhysicsShake(true)

--debug stuff
debugTexturesSheetInfo = require("images.debug_image_sheet")
debugTexturesImageSheet = graphics.newImageSheet( "images/debug_image_sheet.png", debugTexturesSheetInfo:getSheet() )
--end debug stuff

-- Enable multitouch
system.activate("multitouch")

composer.gotoScene('src.level')