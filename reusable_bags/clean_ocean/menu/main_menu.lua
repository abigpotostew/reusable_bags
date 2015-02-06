local composer = require 'composer'
local scene = composer.newScene()

function scene:create ( event )

    local sceneGroup = self.view
   

                composer.gotoScene('opal.src.levelScene',{params={level="clean_ocean.levels.level1"}})

    
end


scene:addEventListener( "create", scene )

return scene