-- generic obstacle

local DebugActor = require 'opal.src.debug.debug_actor'
local _ = require "opal.libs.underscore"

local Obstacle = DebugActor:extends({typeName="Obstacle"})

function Obstacle.Name()
    return "Obstacle"
end

local function create_body (snake, x,y, radius, filter)
    snake:createCircularSprite (radius, x,y, {fill_color={0.25,0.65,0.45}})
    snake:addPhysics ({mass=1.0, bodyType="kinematic", gravityScale=0, friction=0.4,bounce=0.4,filter=filter})
end

function Obstacle:init (level)
    self:super("init", nil, level, nil)
end

function Obstacle:SetSquareBody (group, x,y,w,h, filter)
    filter = filter or self.level:GetFilter(self:Name())
    self.group = group
    self:createRectangleSprite (w,h,x,y)
    self:addPhysics ({mass=1.0, bodyType="kinematic", gravityScale=0, friction=0.4,bounce=0.4,filter=filter}, filter )
end

return Obstacle