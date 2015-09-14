local DebugActor = require 'opal.src.debug.debug_actor'
local _ = require "opal.libs.underscore"

local Snake = DebugActor:extends({typeName="Snake"})

local max_tail_length = 50 --unused
local max_tail_count = 10
local head_radius = 25

function Snake.Name()
    return "Snake"
end

local function create_body (snake, x,y, radius, filter)
    snake:createCircularSprite (radius, x,y, {fill_color={0.25,0.65,0.45}})
    snake:addPhysics ({mass=1.0, bodyType="kinematic", gravityScale=0, friction=0.4,bounce=0.4,filter=filter})
end

function Snake:init (level, group, x, y)
    self:super("init", nil, level, group)
    create_body (self, x,y, head_radius, level:GetFilter(self:Name()))
    
    --create group for snake and tail display objects
    local snake_group = display.newGroup()
    snake_group:insert (self.sprite)
    --snake_group.x, snake_group.y = x, y
    
    self.snake_head = self.sprite
    self.sprite = snake_group
    self.tail = nil -- tail spawns in RedrawTail()
    
    --tail things
    self.prev_positions = {} --prev y posiitons, FIFO, idx 1 is closest to snake head
    for i=1,max_tail_length do
        table.insert(self.prev_positions, self.snake_head.y)
    end
    self.prev_pos_idx = 1

end

function Snake:RedrawTail (height_positions, x_step)
    if self.tail then
        self.tail:removeSelf()
        self.tail = nil
    end
    --TODO could be optimized to not recreate a table each frame
    local positions = {} --tmp line vertices array
    local head_offset = head_radius
    local x = self.snake_head.x - head_offset
    x_step = x_step or 1 --could be modulated by speed of snake
    for i=1, #self.prev_positions do
        table.insert (positions, x)
        table.insert (positions, self.prev_positions[i])
        x = x - x_step
    end
    
    --Need a group for the snake, and the tail
    --build and color tail line object
    local tail = display.newLine ( unpack(positions) )
    tail:setStrokeColor (1,0,1)
    tail.strokeWidth = 1
    self.sprite:insert (tail)
    
    self.tail = tail
end


function Snake:enterFrame (event)
    
    --Update tail
    table.insert (self.prev_positions, 1, self.snake_head.y)
    if #self.prev_positions > max_tail_count then
        table.remove (self.prev_positions)
    end
    --self.prev_pos_idx = (self.prev_pos_idx+1) % (max_tail_length)
    
    self:RedrawTail (self.prev_positions, 1.0)
    
     --stop snake from moving after finger stops dragging
    self.snake_head:setLinearVelocity (0,0)
end

--screen coordinates
function Snake:SetTouchPosition (x,y)
    local vel_x = (x - self.snake_head.x) * display.fps
    local vel_y = (y - self.snake_head.y) * display.fps
    self.snake_head:setLinearVelocity(vel_x, vel_y)
end

function Snake:StartEvents()
    --TODO: probably need a custom event for enter frame only for when game is not paused
    --self:AddEventListener (self.sprite, "enterFrame", enterFrame)
    Runtime:addEventListener("enterFrame", self)
    self:AddEventListener (self.snake_head, 'collision', self)
    --self.snake_head:addEventListener ('collision', onCollide)
end

function Snake:collision (event)
    local snake_head = event.target
    local other = event.other 
    local other_owner = other.owner
    local other_type = other_owner:Type()
    if event.phase == "began"  then
        print( self.myName .. ": collision began with " .. event.other.myName )

    elseif event.phase == "ended" then
        print( self.myName .. ": collision ended with " .. event.other.myName )
    end
end

return Snake