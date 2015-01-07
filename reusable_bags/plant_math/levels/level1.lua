--PLANT_MATH level 1
local plant_math_level = require "plant_math.src.plant_math_level"

local grid_w, grid_h = 4, 4
local total_num_block = grid_w * grid_h
local num_goals = 3

local l = plant_math_level()
local width, height = l:GetWorldViewSize()
local players = 1

l:Setting('num_players', players)
     :Setting('grid_columns', grid_w)
     :Setting('grid_rows', grid_h)
     :Setting('num_goals', num_goals)

local function setup()
    --l:SetNumPlayer(2)
    
    
    physics.setDrawMode("normal")

    local blocks = {
        1,2,3,4,5,
        
        }

end
return {l, setup}