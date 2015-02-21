--generic touchable block

local Actor = require 'opal.src.actor'
local _ = require "opal.libs.underscore"

local TouchBlock = Actor:extends()



local function CancelTouch(event)
    local sprite = event.target
    if sprite.has_focus then
        display.getCurrentStage():setFocus( nil )
        sprite.has_focus = false
    end
end

--assumes center anchor point
function TouchBlock:Colliding (x, y)
    local sx, sy = 0,0--self.sprite:localToContent (0,0)
    local bounds = self.sprite.contentBounds
    local top, bottom, right, left = bounds.yMin + sy, bounds.yMax + sy, bounds.xMax + sx, bounds.xMin + sx
    return not (x > right or x < left or y < top or y > bottom)
end

--delegate touch event to 'block_touch'
local function touch (event)
    local block = event.target.owner
    if event.phase == "began" then
        display.getCurrentStage():setFocus( event.target )
        event.target.has_focus = true
        block:BeginTouch(event)
        block:DispatchEvent(event.target, "block_touch",
            {block = block, phase = event.phase, target = event.target})
        
    elseif event.phase == "moved" then
    elseif event.phase == "ended" then
        display.getCurrentStage():setFocus( nil )
        event.target.has_focus = false
        block:EndTouch(event)
        --TODO:revamp touch to trigger event on touch release
        -- if the block is the original block touched and is also released on top, call event
        local block_x, block_y = block.sprite:localToContent (0,0)
        oLog.Debug(string.format ("Release Mouse [ %d, %d ], Block [ %d, %d ]", event.x, event.y, block_x, block_y))
        if block:Colliding(event.x, event.y) then
            block:DispatchEvent(event.target, "block_touch_release",
            {block = block, phase = event.phase, target = event.target})
        end
    end
    return true
end


function TouchBlock:init ( level, gridw, gridh, typeName)
    self:super("init", {typeName=(typeName or "TouchBlock")}, level)
    
    self.draw_data={block_data={fill_color={0.5,0.25,0.33},fill_colors={}  }}
    self.sprite = display.newGroup ()
    local block = display.newRect(0,0,gridw,gridh)
    block:setFillColor(unpack(self.draw_data.block_data.fill_color))
    self.sprite:insert(block)
    self.block_sprite = block
    
    self.sprite.owner = self
    
    self:AddEvent("block_touch")
    self:AddEventListener(self.sprite, "touch", touch)
    
end

function TouchBlock:SetBlockColor(r,g,b)
    local c = {r,g,b}
    self.draw_data.block_data.fill_color = c
    self.block_sprite:setFillColor(r,g,b)
end


function TouchBlock:BeginTouch(event)
    if not self.sprite or (not self.draw_data and not self.draw_data.block) then return end
    
    local c = { unpack (self.draw_data.block_data.fill_color) }
    self.draw_data.block_data.select_color = c
    
    -- c[1..3]*=1.3
    c = _.map(c, function(i) return i*1.3 end)
    
    self.block_sprite:setFillColor (unpack (c))
end

function TouchBlock:EndTouch(event)
    self.block_sprite:setFillColor (unpack (self.draw_data.block_data.fill_color))
end


return TouchBlock