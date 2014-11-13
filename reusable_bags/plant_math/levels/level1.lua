--PLANT_MATH level 1
local plant_math_level = require "plant_math.src.plant_math_level"

local l = plant_math_level()
local width, height = l:GetWorldViewSize()
local players = 1

local function setup()
    l:SetNumPlayer(2)

end
return {l, setup}