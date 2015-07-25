local snake_level = require "ride_the_snake.src.snake_level"
local Actor = require "opal.src.debug.debug_actor"

local l = snake_level()
local width, height = l:GetWorldViewSize()
local players = 1


l:Setting     ('num_players', players)



local function buildRectangleSprite (group,w,h,x,y, sprite_data)
    assert(group,"DebugActor:buildRectangleSprite(): Please initialize group before creating a sprite rectangle")
    sprite_data = sprite_data or {}
    x, y = x or 0, y or 0
    local fill_color = sprite_data.fill_color or {1,0,1} --hot pink!
    local stroke_color = sprite_data.stroke_color or {1,0,1} --hot pink!
    local anchorX = sprite_data.anchorX or sprite_data.typeInfo and sprite_data.anchorX or 0.5
    local anchorY = sprite_data.anchorY or sprite_data.typeInfo and sprite_data.typeInfo.anchorY or 0.5

    local sprite = display.newRect(group, x, y, w, h)
    sprite:setFillColor(unpack(fill_color))
    sprite:setStrokeColor (unpack (stroke_color))    
    sprite.anchorX, sprite.anchorY = anchorX, anchorY
    if sprite_data.stroke_width then sprite.strokeWidth = sprite_data.stroke_width end
    return sprite
end



--Called last, just before the level actually apprears on screen
local function setup()
    
    local s = l:GetWorldGroup()
    
    local rect = display.newRect(400,400, 40, 40)--buildRectangleSprite (s, 100,100, 100,100)
    
    s:insert( rect )
    
    physics.setDrawMode("debug")
    
end
return {l, setup}