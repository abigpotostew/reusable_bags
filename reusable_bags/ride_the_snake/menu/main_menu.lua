local composer = require 'composer'
local scene = composer.newScene()


local function create_button(x,y,w,h, view, name, level_file)
    local button = display.newGroup(view)
    
    local rect = display.newRect(x,y,w,h)
    rect:setFillColor(.6,0,.2)
    button:insert(rect)
    
    local label = display.newText({parent=button, text=name, font=native.systemFont, fontSize=14})
    label:setFillColor(1,1,1)
    
    button.touch = function(self,event)
        composer.gotoScene('opal.src.levelScene',{params={level=level_file}})
    end
    
    button:addEventListener('touch',self)
    
    return button
end

local function add_buttons(view, buttons)
    local grp = display.newGroup(view)
    
    local vw, vh = 800, 600
    
    local w, h = vw /2, vh/2/ (#buttons)
    
    for i=1, #buttons do
        local btn = buttons[i]
        create_button (vw/2, vh*0.25 + (i-1)*h, w, h-5, view, btn[1],btn[2])
    end
    
end

function scene:show ( event )
    if event.phase == 'will' then
        return
    end
    
    local sceneGroup = self.view
    
    local function btn(name, level_file)
        return {name,level_file}
    end
    
    --add_buttons (sceneGroup, {btn('Level 1',"clean_ocean.levels.level1" ), btn('Level 2',"clean_ocean.levels.level2" )})
    
    O:GoToLevelScene ('ride_the_snake.levels.level1')
end




scene:addEventListener( "show", scene )

return scene