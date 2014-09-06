local bag_level = require "reusable_bags.src.level"
local levelDefaults = require "reusable_bags.levels.defaults"
--local WindTurbine = require "actors.windTurbine"

local bag_types  = require("reusable_bags.actors.bagTypes").GetBagTypes()

local l = bag_level()
levelDefaults(l)

local width, height = l:GetWorldViewSize()
local num_bags = #bag_types

l:SetBagCount ( num_bags ) --required

local layout_border = width/4
for i, bag_name in ipairs (bag_types) do
    local x = layout_border + ((width-layout_border)/#bag_types)*(i-1)
    local y = height-140
    l:SpawnBag (bag_name, x, y)
    
    local cannon = l:SpawnCannon {x = x, y = 250, directionX=0, directionY=1, speed = 80, angular_velocity = 55, speed_variation=40, rotation_variation=35}
end

l:TimelineSpawnFood {wait=1,x=175,y=200, foodName="apple", cannon=l:GetActor ("cannon",1)}
l:TimelineWait {wait=5}
l:TimelineSpawnFood {wait=5,x=425,y=200, foodName="apple", cannon=l:GetActor ("cannon",2)}
l:TimelineWait {wait=1}
--l:TimelineSpawnFood {wait=1,x=675,y=200, foodName="apple", spawner_id=spawner}

--l:InsertActor( WindTurbine(340, 200, {}, l) )

return l