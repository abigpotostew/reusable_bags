local Vector2 = require 'opal.src.vector2'
local OceanBlock
do
    local Block = require 'clean_ocean.src.touch_block'
    OceanBlock = Block:extends()
end

function OceanBlock:init (level, gridw, gridh)
    self:super("init", level, gridw, gridh, 'OceanBlock')

    self.grid_position = Vector2()
    self.direction = Vector2()
end

--in future when there are more block types, instead assign blocks commands
--that are evaulated when requested, and do actions to boat or whatever.
function OceanBlock:Direction()
    return self.direction
end


return OceanBlock