-- Wrapper composer scene for Level

local composer = require( "composer" )
local scene = composer.newScene()

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------

-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view
   
    assert(event.params and event.params.level, "LevelScene requires a level.")
   
    self.level = event.params.level
    
    self.level:create( event, sceneGroup )
end

-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   
   self.level:show(event)
   
end

-- "scene:hide()"
function scene:hide( event )

   local sceneGroup = self.view
   
   self.level:hide( event )
end

-- "scene:destroy()"
function scene:destroy( event )

   local sceneGroup = self.view

   self.level:destroy( event )
   
   self.level = nil
   
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene