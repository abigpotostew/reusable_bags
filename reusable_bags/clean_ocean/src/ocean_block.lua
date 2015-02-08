local OceanBlock
do
    local Block = require 'clean_ocean.src.touch_block'
    OceanBlock = Block:extends()
end

function OceanBlock:init (level, gridw, gridh)
    self:super("init", level, gridw, gridh, 'OceanBlock')

    
end


return OceanBlock