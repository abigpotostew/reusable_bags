local debug_level = require "src.debug.debug_level"
local levelDefaults = require "levels.defaults"

local l = debug_level:init()
levelDefaults(l)

local spawner = l:CreateSpawner(15,150, 1, 0, 10000)

l:TimelineSpawnFood {wait=1,x=175,y=200, foodName="apple", spawner_id=spawner}
--l:TimelineWait {wait=1}
l:TimelineSpawnFood {wait=1,x=425,y=200, foodName="apple", spawner_id=spawner}
--l:TimelineWait {wait=1}
l:TimelineSpawnFood {wait=1,x=675,y=200, foodName="apple", spawner_id=spawner}

for i=1, 20 do
    --l:TimelineSpawnFood {wait=0, x=100+(i%10)*75, y=400+150*(i%2), foodName="pizza"}
end

return l