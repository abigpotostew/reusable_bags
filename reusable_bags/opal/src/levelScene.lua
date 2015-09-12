-- Wrapper composer scene for Level

local composer = require( "composer" )
local scene = composer.newScene()

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------

-- "scene:create()"
function scene:create ( event )

    local sceneGroup = self.view
   
    oAssert (event.params and event.params.level, "LevelScene requires a level.")
   
    local l = require(event.params.level)
    local level, setup = l[1], l[2]
    self.level = level
    self.level_setup = setup
    level:create (event, sceneGroup)
end

-- "scene:show()"
function scene:show ( event )

   local sceneGroup = self.view
   
   self.level:show (event, sceneGroup)
   if event.phase == 'did' then
       self.level_setup()
    end
end

-- "scene:hide()"
function scene:hide ( event )

   local sceneGroup = self.view
   
   self.level:hide ( event, sceneGroup )
end

-- "scene:destroy()"
function scene:destroy( event )

   local sceneGroup = self.view

   self.level:DestroyLevel ( event, sceneGroup )
   
   sceneGroup.removeSelf()
   
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