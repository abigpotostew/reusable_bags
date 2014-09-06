local debug_level = require "src.debug.debug_level"
local levelDefaults = require "levels.defaults"
local WindTurbine = require "actors.windTurbine"

local l = debug_level()
levelDefaults(l)


local spawner = l:CreateSpawner({x=600, y=250, directionX=0, directionY=1, speed=40, angular_velocity=20})

l:SetBagCount ( 3 ) --required

local plastic_bag1 = l:SpawnBag("plastic", 100, 350)
local paper_bag1 = l:SpawnBag("paper", 350, 350)
local canvas_bag1 = l:SpawnBag("canvas", 600, 350)

l:TimelineSpawnFood {wait=1,x=175,y=200, foodName="apple", spawner_id=spawner}
l:TimelineWait {wait=5}
l:TimelineSpawnFood {wait=5,x=425,y=200, foodName="apple", spawner_id=spawner}
l:TimelineWait {wait=1}
--l:TimelineSpawnFood {wait=1,x=675,y=200, foodName="apple", spawner_id=spawner}

--l:InsertActor( WindTurbine(340, 200, {}, l) )

return l