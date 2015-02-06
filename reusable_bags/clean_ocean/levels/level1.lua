--PLANT_MATH level 1
local clean_ocean_level = require "clean_ocean.src.clean_ocean_level"

local grid_w, grid_h = 4, 4
local total_num_block = grid_w * grid_h
local num_goals = 3

local l = clean_ocean_level()
local width, height = l:GetWorldViewSize()
local players = 1

l:Setting     ('num_players', players)
     :Setting ('grid_columns', grid_w)
     :Setting ('grid_rows', grid_h)
     :Setting ('num_goals', num_goals)
     :Setting ('solution_timer', 10000)

--Called last, just before the level actually apprears on screen
local function setup()
    
    
    physics.setDrawMode("normal")

    

end
return {l, setup}