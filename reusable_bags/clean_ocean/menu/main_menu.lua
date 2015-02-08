local composer = require 'composer'
local scene = composer.newScene()

function scene:show ( event )
    if event.phase == 'will' then
        return
    end
    local sceneGroup = self.view
    composer.gotoScene('opal.src.levelScene',{params={level="clean_ocean.levels.level1"}})

end


scene:addEventListener( "show", scene )

return scene