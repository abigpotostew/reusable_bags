-----------------------------------------------------------------------------------------
-- Cannon... it shoots groceries at your head!
----------------------------------------------------------------------------------------

local Util = require 'opal.src.utils.util'
local Vector2 = require 'opal.src.vector2'
local Actor = require "opal.src.actor"

local cannon_states = {
    SHOOTING_STATE  = "shooting_state",
    EMPTY_STATE     = "empty_state",
}

local Cannon = Actor:extends {states = cannon_states}

function Cannon:init (cannon_data, level)
    oAssert.type (cannon_data, "table", "Cannon(): Requires cannon data")
    
    self:super ("init", {typeName="cannon"}, level)
    
    local data = cannon_data
    assert(data.directionX and
           data.directionY and
           data.speed,
           "Cannon(): required directionX and directionY and speed when creating food cannon" )
       
    self.group = level:GetWorldGroup()
    
    self:createRectangleSprite(data.w or 15,data.h or 50, data.x or 0, data.y or 0)
    local direction = Vector2(data.directionX, data.directionY)
    self.velocity = direction * data.speed
    self.angular_velocity = data.angular_velocity or 0
    self.speed_variation = data.speed_variation or 0
    self.rotation_variation = data.rotation_variation or 0
       
end
    
return Cannon