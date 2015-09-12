local DebugActor = require 'opal.src.debug.debug_actor'
local _ = require "opal.libs.underscore"

local Snake = DebugActor:extends({typeName="Snake"})

local max_tail_length = 100
local head_radius = 25

function Snake.Name()
    return "Snake"
end

local function create_body (snake, x,y, radius, filter)
    snake:createCircularSprite (radius, x,y, {fill_color={0.25,0.65,0.45}})
    snake:addPhysics ({mass=1.0, bodyType="dynamic", gravityScale=0, friction=0.4,bounce=0.4,filter=filter})
end

function Snake:init (level, group, x, y)
    self:super("init", nil, level, group)
    create_body (self, x,y, head_radius, level:GetFilter(self:Name()))
    
    --tail things
    self.prev_positions = {} --prev y posiitons, FIFO, idx 1 is closest to snake head
    for i=1,max_tail_length do
        table.insert(self.prev_positions, self:y())
    end
    self.prev_pos_idx = 1

end

function Snake:RedrawTail (height_positions, x_step)
    if self.tail then
        self.tail.removeSelf()
        self.tail = nil
    end
    local positions = {} --tmp line vertices array
    local head_offset = head_radius
    local x = self:x() - head_offset
    x_step = x_step or 1 --could be modulated by speed of snake
    for i=1, #self.prev_positions do
        table.insert (positions, x)
        table.insert (positions, self.prev_positions[i])
        x = x - x_step
    end
    
    --build and color tail line object
    local tail = display.newLine (self.sprite, unpack(positions) )
    tail:setStrokeColor(1,1,0)
    tail.strokeWidth = 5
    
    self.tail = tail
end

function Snake:enterFrame (event)
    
    --Update tail
    table.insert (self.prev_positions, 1, self:y())
    if #self.prev_position > max_tail_length then
        table.remove (self.prev_positions)
    end
    --self.prev_pos_idx = (self.prev_pos_idx+1) % (max_tail_length)
    
    self:RedrawTail (self.prev_positions, 1.0)
    
end



function Snake:StartEvents()
    --TODO: probably need a custom event for enter frame only for when game is not paused
    self:AddEventListener (self.sprite, "enterFrame", self)
end

return Snake