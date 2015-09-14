local composer = require 'composer'
local scene = composer.newScene()
local _ = require "opal.libs.underscore"


local function create_button(x,y,w,h, view, name, level_file)
    local button = display.newGroup(view)
    button.x, button.y = x, y
    
    local rect = display.newRect(0,0,w,h)
    rect:setFillColor(.6,0,.2)
    button:insert(rect)
    
    local label = display.newText({parent=button, text=name, font=native.systemFont, fontSize=14})
    label:setFillColor(1,1,1)
    
    button.touch = function(self,event)
        if event.phase == 'ended' then
            O:GoToLevelScene(level_file, {debug_draw=O:Option("debug_draw")})
        end 
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
        buttons[i] = create_button (vw/2, vh*0.25 + (i-1)*h, w, h-5, view, btn[1],btn[2])
    end
    return buttons
end

function scene:show ( event )
    if event.phase == 'will' then
        return
    end
    
    local sceneGroup = self.view
    
    local function btn(name, level_file)
        return {name,level_file}
    end
    
    self.buttons = add_buttons (sceneGroup, {btn('SNAAAKE 1',"ride_the_snake.levels.level1" )})
    
    O:GoToLevelScene ('ride_the_snake.levels.level1')
end

function scene:hide (event)
    if event.phase=='did' then
        _.each (self.buttons, function(b) b:removeSelf(); end)
        self.buttons = nil
        self.view:removeSelf()
        self.view=nil
    end
end


scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
--scene:addEventListener( "destroy", scene )

return scene