--PLANT_MATH level 1
local plant_math_level = require "plant_math.src.plant_math_level"

local grid_w, grid_h = 4, 4
local total_num_block = grid_w * grid_h
local num_goals = 3

local l = plant_math_level()
local width, height = l:GetWorldViewSize()
local players = 1
local number_selections = {
        1,2,3
    }
local operators = l:GetOperatorTypes()

l:Setting     ('num_players', players)
     :Setting ('grid_columns', grid_w)
     :Setting ('grid_rows', grid_h)
     :Setting ('num_goals', num_goals)
     :Setting ('number_selections', number_selections)
     :Setting ('operator_selections', {operators.ADD, operators.SUB})
     :Setting ('solution_timer', 10000)

--Called last, just before the level actually apprears on screen
local function setup()
    --l:SetNumPlayer(2)
    
    
    physics.setDrawMode("normal")

    

end
return {l, setup}