local Actor = require 'opal.src.actor'
local _ = require "opal.libs.underscore"

local Snake = Actor:extends({typeName="Snake"})

local function create_body(snake, radius, filter)
    snake:createCircularSprite (radius,0,0,{fill_color={0.25,0.65,0.45}})
    snake:addPhysics ({mass=1.0, bodyType="dynamic", gravityScale=0, friction=0.4,bounce=0.4,filter=filter})
end

function Snake:init (level, group, x, y)
    self:super("init", nil, level, group)
    local radius = 25
    create_body (self, radius, level:GetFilter(self:Name()))
end

return Snake