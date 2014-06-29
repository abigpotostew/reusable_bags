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

--print FPS info
local prevTime = system.getTimer()
local fps = display.newText( "30", 30, 47, nil, 24 )
fps:setTextColor( 255 )
fps.prevTime = prevTime

local function enterFrame( event )
 local curTime = event.time
 local dt = curTime - prevTime
 prevTime = curTime
 if ( (curTime - fps.prevTime ) > 100 ) then
     -- limit how often fps updates
     fps.text = string.format( '%.2f', 1000 / dt )
     --print(string.format("<%8.02f, %8.02f>", grid.group.x ,grid.group.y))
 end
end
Runtime:addEventListener( "enterFrame", enterFrame )
--end print FPS info
