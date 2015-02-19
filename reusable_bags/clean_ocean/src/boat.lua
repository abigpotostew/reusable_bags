

local Actor = require 'opal.src.actor'
local _ = require "opal.libs.underscore"

local BoatDirection = require 'clean_ocean.src.boat_direction'

local Boat = Actor:extends()

function Boat:init (level, radius)
    self:super("init", {typeName="Boat"}, level)
    radius = radius or 25
    self.sprite = display.newCircle(0,0,radius)
    self.sprite:setFillColor(0.25,0.65,0.45)
    self.sprite.owner = self
    
    self.direction = BoatDirection.NONE
end

function Boat:Direction()
    return self.direction
end

function Boat:SetDirection(d)
    self.direction = d
end

function Boat:CleanTrashAction(trash_block)
    local event = {phase='began', boat=self, block=trash_block}
    self:DispatchEvent (self.sprite, 'action_clean_trash', event)
    
end

return Boat