

local Actor = require 'opal.src.actor'
local _ = require "opal.libs.underscore"

local OceanBlock = Actor:extends()



local function CancelTouch(event)
    local sprite = event.target
    if sprite.has_focus then
        display.getCurrentStage():setFocus( nil )
        sprite.has_focus = false
    end
end

--delegate touch event to 'block_touch'
local function touch (event)
    local block = event.target.owner
    if event.phase == "began" then
        display.getCurrentStage():setFocus( event.target )
        event.target.has_focus = true
        block:BeginTouch(event)
        block:DispatchEvent(event.target, "block_touch",
            {block = block, phase = event.phase})
        
    elseif event.phase == "moved" then
elseif event.phase == "ended" then
        display.getCurrentStage():setFocus( nil )
        event.target.has_focus = false
        block:EndTouch(event)
        --TODO:revamp touch to trigger event on touch release
    end 
    return true
end


function OceanBlock:init (level, gridw, gridh)
    self:super("init", {typeName="OceanBlock"}, level)
    
    self.sprite = display.newRect(0,0,gridw,gridh)
    self.draw_data={block_data={fill_color={0.5,0.25,0.33
}}}
    self.sprite:setFillColor(unpack(self.draw_data.block_data.fill_color))
    self.sprite.owner = self
    
    self:AddEvent("block_touch")
    self:AddEventListener(self.sprite, "touch", touch)
    
end


function OceanBlock:BeginTouch(event)
    if not self.sprite or (not self.draw_data and not self.draw_data.block) then return end
    
    local c = { unpack (self.draw_data.block_data.fill_color) }
    self.draw_data.block_data.select_color = c
    
    -- c[1..3]*=1.3
    c = _.map(c, function(i) return i*1.3 end)
    
    self.sprite:setFillColor (unpack (c))
end

function OceanBlock:EndTouch(event)
    self.sprite:setFillColor (unpack (self.draw_data.block_data.fill_color))
end


return OceanBlock