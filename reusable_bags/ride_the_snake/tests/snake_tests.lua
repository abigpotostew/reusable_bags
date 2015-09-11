local u = require 'opal.src.test.unit'('snake_test')
local _ = require 'opal.libs.underscore'
local Vector2 = require 'opal.src.vector2'


local SnakeLevel = require "ride_the_snake.src.snake_level"
local Snake = require "ride_the_snake.src.snake"

function u:SetUp()
end

function u:TearDown()
end

local function default_setup()
    local level = SnakeLevel()
    return level
end

u:Test ("SnakeName", function(self)
    local l = default_setup()
    local snake = Snake (l, l:GetWorldGroup(), 0,0)
    l:InsertActor(snake)
    
    local expected_name = "Snake"
    local actual_name = snake:Name()
    
    self:ASSERT_EQ(expected_name, actual_name)
    l:DestroyLevel()
end)

return u