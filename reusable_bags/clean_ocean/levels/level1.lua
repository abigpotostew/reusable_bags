--PLANT_MATH level 1
local clean_ocean_level = require "clean_ocean.src.clean_ocean_level"

local BoatDirection = require 'clean_ocean.src.boat_direction'

local grid_w, grid_h = 8, 8
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

    local U, D, L, R, _ = BoatDirection.UP, BoatDirection.DOWN,
                          BoatDirection.LEFT, BoatDirection.RIGHT,
                          BoatDirection.NONE
    
    local ocean = {
    --[[{D,R,D,_,_,_,D,D},
    {R,U,_,_,_,D,_,_},
    {_,_,L,_,D,_,_,_},
    {_,_,_,R,_,_,_,_},
    {_,_,_,U,L,_,_,_},
    {_,_,U,_,_,L,_,_},
    {_,U,_,_,_,_,L,_},
    {_,_,_,_,_,_,_,L} --]]
    {R,_,_,_,_,_,D,D},
    {_,R,_,_,_,D,_,_},
    {_,_,R,_,D,_,_,_},
    {_,_,_,R,D,_,_,_},
    {_,_,_,U,L,_,_,_},
    {_,_,U,_,_,L,_,_},
    {_,U,_,_,_,_,L,_},
    {U,_,_,_,_,_,_,L} 
        }
    l:SetOceanVectors(ocean)

end
return {l, setup}