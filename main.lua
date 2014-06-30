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
debugTexturesSheetInfo = require("images.debug_image_sheet")
debugTexturesImageSheet = graphics.newImageSheet( "images/debug_image_sheet.png", debugTexturesSheetInfo:getSheet() )
--end debug stuff


-- load menu screen
--storyboard.gotoScene( "src.level" )
local Level = require "src.level"
local level_debug = Level:init()

--storyboard.gotoScene('src.level',{params={level_debug}})
level_debug:createScene()
level_debug:enterScene()