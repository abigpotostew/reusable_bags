local Vector2 = require 'opal.src.vector2'
local OceanBlock
local BoatDirection = require 'clean_ocean.src.boat_direction'
do
    local Block = require 'clean_ocean.src.touch_block'
    OceanBlock = Block:extends()
end

function OceanBlock:init (level, block_w, block_h)
    self:super("init", level, block_w, block_h, 'OceanBlock')

    self.grid_position = Vector2()
    self.direction = Vector2()
    self.object_type = nil
    self.action = nil
end

--in future when there are more block types, instead assign blocks commands
--that are evaulated when requested, and do actions to boat or whatever.
function OceanBlock:Direction()
    return self.direction
end

function OceanBlock:SetDirection(dir)
    self.direction = dir
    if dir ~= BoatDirection.NONE then
        local gw, gh = self.block_sprite.contentWidth, self.block_sprite.contentHeight
        local arrow = display.newPolygon (self.sprite, 0,0, 
            {gw*.45,0, 
            -gw*.45, gh*.1,
            -gw*.45, -gh*.1})
        local rotation = dir:Angle()*180/math.pi - 180
        arrow:rotate (rotation)
        self.arrow = arrow
    end
    return dir
end

function OceanBlock:HasAction()
    return (self.action and true) or false
end

function OceanBlock:SetAction(action)
    self.action = action
end

function OceanBlock:DoAction(level, boat)
    oLog.Debug ( string.format ("Doing action %s for %s",
                                tostring(self.action), self:describe()))
    self.action(self, level, boat)
end

return OceanBlock