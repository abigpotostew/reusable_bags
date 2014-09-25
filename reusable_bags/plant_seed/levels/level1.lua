local seed_level = require "plant_seed.src.level"

local l = seed_level()
local width, height = l:GetWorldViewSize()
local players = 2
if players == 2 then
    

    local ground_level = height*0.6
    local x, y, w, d = l:AddGroundHole(  width/4, ground_level,
        width/4, height-height*.6-50,
        50)
    l:AddDirt(x, y, w, d, 23)
    
    x,y,w,d = l:AddGroundHole(3*width/4, ground_level, 
        width/4, height-height*.6-50, 
        50)
    l:AddDirt(x, y, w, d, 23)
elseif players == 1 then
    local x, y, w, d = l:AddGroundHole(width/2, height*0.6, width/3, height-height*.6-50,50)
    l:AddDirt(x, y, w, d, 23)
end


return l