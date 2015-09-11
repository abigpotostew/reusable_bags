local DebugActor = require 'opal.src.actor'
local _ = require "opal.libs.underscore"

local Snake = DebugActor:extends({typeName="Snake"})

local max_tail_length = 100

function Snake.Name()
    return "Snake"
end

local function create_body (snake, x,y, radius, filter)
    snake:createCircularSprite (radius, x,y, {fill_color={0.25,0.65,0.45}})
    snake:addPhysics ({mass=1.0, bodyType="dynamic", gravityScale=0, friction=0.4,bounce=0.4,filter=filter})
end

function Snake:init (level, group, x, y)
    self:super("init", nil, level, group)
    local radius = 25
    create_body (self, x,y, radius, level:GetFilter(self:Name()))
    
    --tail things
    self.prev_positions = {} --prev y posiitons
    for i=1,max_tail_length do
        table.insert(self.prev_positions, self.y())
    self.prev_pos_idx = 1
    self.tail = display.newLine(
end

function Snake:enterFrame (event)
    
    --Update tail
    table.insert (self.prev_positions, 1, self:y())
    if #self.prev_position > max_tail_length then
        table.remove (self.prev_positions)
    end
    self.prev_pos_idx = (self.prev_pos_idx+1) % (max_tail_length)
    
    
    
end



function Snake:StartEvents()
    --TODO: probably need a custom event for enter frame only for when game is not paused
    self:AddEventListener(self.sprite, "enterFrame", self)
end

return Snake