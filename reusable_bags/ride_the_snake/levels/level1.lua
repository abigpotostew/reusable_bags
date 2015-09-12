local snake_level = require "ride_the_snake.src.snake_level"
local Actor = require "opal.src.debug.debug_actor"

local l = snake_level()
local width, height = l:GetWorldViewSize()
local players = 1


l:Setting     ('num_players', players)


--Called last, just before the level actually apprears on screen
local function setup()
    
    local s = l:GetWorldGroup()
    
    --[[local rect = display.newRect(400,400, 40, 40)--buildRectangleSprite (s, 100,100, 100,100)
    
    s:insert( rect )
    
    physics.setDrawMode("debug")
    
    local scene = l:GetWorldGroup()
    local rect = display.newCircle (100,100, 100)
    --scene:insert (rect)
    local g = display.newGroup()
    g:insert (rect)
    --]]
end
return {l, setup}