local bag_level = require "reusable_bags.src.level"
local levelDefaults = require "reusable_bags.levels.defaults"
--local WindTurbine = require "actors.windTurbine"

local bag_types  = require("reusable_bags.actors.bagTypes").GetBagTypes()
local food_types = {"apple", "orange", "burrito", "pizza"}

local l = bag_level()
levelDefaults(l)

local width, height = l:GetWorldViewSize()
local num_bags = #bag_types

l:SpawnBags ( num_bags ) --required

for i=1,10 do
    --l:TimelineSpawnFood {wait=0.5,x=175,y=200, foodName=food_types[i%#food_types+1], cannon=l:GetActor ("cannon", i%num_bags+1)}
end

l:TimelineSpawnFood {wait=0.5,x=175,y=200, foodName=food_types[math.random(#food_types)], cannon=l:GetActor ("cannon", 1)}
l:TimelineSpawnFood {wait=3,x=175,y=200, foodName=food_types[math.random(#food_types)], cannon=l:GetActor ("cannon", 2)}
l:TimelineSpawnFood {wait=3,x=175,y=200, foodName=food_types[math.random(#food_types)], cannon=l:GetActor ("cannon", 3)}
l:TimelineSpawnFood {wait=3,x=175,y=200, foodName=food_types[math.random(#food_types)], cannon=l:GetActor ("cannon", 1)}
    l:TimelineSpawnFood {wait=0,x=175,y=200, foodName=food_types[math.random(#food_types)], cannon=l:GetActor ("cannon", 3)}


--l:TimelineSpawnFood {wait=1,x=175,y=200, foodName="apple", cannon=l:GetActor ("cannon",1)}
--l:TimelineWait {wait=5}
--l:TimelineSpawnFood {wait=5,x=425,y=200, foodName="apple", cannon=l:GetActor ("cannon",2)}
--l:TimelineWait {wait=1}
--l:TimelineSpawnFood {wait=1,x=675,y=200, foodName="apple", spawner_id=spawner}

--l:InsertActor( WindTurbine(340, 200, {}, l) )

return l