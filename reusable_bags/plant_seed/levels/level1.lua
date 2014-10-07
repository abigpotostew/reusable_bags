local seed_level = require "plant_seed.src.level"

local l = seed_level()
local width, height = l:GetWorldViewSize()
local players = 2

local function setup()
if players == 2 then
    

    local ground_level = height*0.6
    local x, y, w, d = l:AddGroundHole(  width/4, ground_level,
        width/4, height-height*.6-50,
        50)
    l:AddDirt(x, y, w, d, 23)
    
    local ground ={w=x-w/2,h=d+50}
    l:AddGround (x-w/2-ground.w/2, y, ground.w, ground.h)
    
    local middle_grd_w = width/2-w
    
    l:AddGround (3*width/4-middle_grd_w, y, middle_grd_w, ground.h)
    
    l:AddGround (3*width/4+w/2+ground.w/2, y, ground.w, ground.h)
    
    x,y,w,d = l:AddGroundHole(3*width/4, ground_level, 
        width/4, height-height*.6-50, 
        50)
    l:AddDirt(x, y, w, d, 23)
    
    
    
elseif players == 1 then
    local x, y, w, d = l:AddGroundHole(width/2, height*0.6, width/3, height-height*.6-50,50)
    l:AddDirt(x, y, w, d, 23)
    
    local ground_w = width/3
    local ground_h = d+50
    l:AddGround (width/3-ground_w/2, y, ground_w, ground_h)
    l:AddGround (2*width/3+ground_w/2, y, ground_w, ground_h)
end

end
return {l, setup}