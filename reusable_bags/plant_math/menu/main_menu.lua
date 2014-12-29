local composer = require 'composer'
local scene = composer.newScene()

function scene:create ( event )

    local sceneGroup = self.view
   

    local button = display.newCircle(100,100,100)
    sceneGroup:insert(button)
    button:addEventListener('touch',function(event)
            if event.phase=='ended' then
                composer.gotoScene('opal.src.levelScene',{params={level="plant_math.levels.level1"}})
            
        end
    end)
    
end


scene:addEventListener( "create", scene )

return scene