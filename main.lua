-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )
require("mobdebug").start()

-- include the Corona "storyboard" module
local storyboard = require "storyboard"


--debug stuff
debugTexturesSheetInfo = require("data.debug-textures")
debugTexturesImageSheet = graphics.newImageSheet( "data/debug-textures.png", debugTexturesSheetInfo:getSheet() )
--end debug stuff


-- load menu screen
storyboard.gotoScene( "src.menu" )

