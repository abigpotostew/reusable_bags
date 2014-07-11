local level = require "src.level"
local levelDefaults = require "levels.defaults"

local l = level:init()
levelDefaults(l)

l:TimelineSpawnFood {wait=2,x=175,y=200, foodName="apple"}
--l:TimelineWait {wait=1}
l:TimelineSpawnFood {wait=2,x=425,y=200, foodName="apple"}
--l:TimelineWait {wait=1}
l:TimelineSpawnFood {wait=2,x=675,y=200, foodName="apple"}

return l