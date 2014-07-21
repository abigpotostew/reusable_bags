local debug_level = require "src.debug.debug_level"
local levelDefaults = require "levels.defaults"

local l = debug_level()
levelDefaults(l)

local spawner = l:CreateSpawner(15,150, 1, 0, 10000)

local plastic_bag1 = l:SpawnBag("plastic", 100, 350)
local paper_bag1 = l:SpawnBag("paper", 350, 350)
local canvas_bag1 = l:SpawnBag("canvas", 600, 350)

l:TimelineSpawnFood {wait=1,x=175,y=200, foodName="apple", spawner_id=spawner}
--l:TimelineWait {wait=1}
l:TimelineSpawnFood {wait=1,x=425,y=200, foodName="apple", spawner_id=spawner}
--l:TimelineWait {wait=1}
l:TimelineSpawnFood {wait=1,x=675,y=200, foodName="apple", spawner_id=spawner}


return l