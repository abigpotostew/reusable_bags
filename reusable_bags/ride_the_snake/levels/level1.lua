local snake_level = require "ride_the_snake.src.snake_level"


local l = snake_level()
local width, height = l:GetWorldViewSize()
local players = 1

l:Setting     ('num_players', players)
     --:Setting ('grid_columns', grid_w)
     --:Setting ('grid_rows', grid_h)
     --:Setting ('num_goals', num_goals)
     --:Setting ('solution_timer', 10000)

--Called last, just before the level actually apprears on screen
local function setup()
    
    
    physics.setDrawMode("debug")
    
end
return {l, setup}