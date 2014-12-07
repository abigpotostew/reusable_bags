--PLANT_MATH level 1
local plant_math_level = require "plant_math.src.plant_math_level"

local l = plant_math_level(4,4)
local width, height = l:GetWorldViewSize()
local players = 1

local function setup()
    l:SetNumPlayer(2)
    physics.setDrawMode("normal")

    local blocks = {
        1,2,3,4,5,
        
        
        }

end
return {l, setup}