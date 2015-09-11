local Actor = require 'opal.src.actor'
local _ = require "opal.libs.underscore"

local SubActor = Actor:extends()

function SubActor:init (level, radius)
    self:super("init", {typeName="SubActor"}, level)
    radius = radius or 25
    self.sprite = display.newCircle(0,0,radius)
    self.sprite:setFillColor(0.25,0.65,0.45)
    self.sprite.owner = self
    
end

return SubActor