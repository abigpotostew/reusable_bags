local snake_level = require "ride_the_snake.src.snake_level"
local Actor = require "opal.src.debug.debug_actor"
local Obstacle = require "ride_the_snake.src.obstacle"
local Vector = require 'opal.src.vector2'

local l = snake_level()
local width, height = l:GetWorldViewSize()
local players = 1


l:Setting     ('num_players', players)


--Called last, just before the level actually apprears on screen
local function setup()
    
    local scene = l:GetWorldGroup()
    
    --[[local rect = display.newRect(400,400, 40, 40)--buildRectangleSprite (s, 100,100, 100,100)
    
    s:insert( rect )
    
    physics.setDrawMode("debug")
    
    local scene = l:GetWorldGroup()
    local rect = display.newCircle (100,100, 100)
    --scene:insert (rect)
    local g = display.newGroup()
    g:insert (rect)
    --]]
    local ww, wh = l:GetWorldViewSize()
    
    do --boilerplate create obstacle
        local o = Obstacle (l)
        local size = 200
        local x, y = ww+size, math.random()*(wh+size*2)
        o:SetSquareBody(scene, x,y, size,size)
        l:InsertActor (o)
        
        local vel, mag = Vector (ww/2 - x, wh/2 - y):Normalized()
        
        o:SetLinearVelocity ((vel * (97 + oMath.Binom() * 30)):Get())
        --o:SetAngularVelocity (17)
        
    end
end
return {l, setup}