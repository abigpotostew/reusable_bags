local u = require 'opal.src.test.unit'('clean_ocean_test')
local _ = require 'opal.libs.underscore'
local Vector2 = require 'opal.src.vector2'

--local dirt_types = require "clean_ocean.src.dirt_types"
local BoatDirection = require "clean_ocean.src.boat_direction"

local CleanOceanLevel = require "clean_ocean.src.clean_ocean_level"

function u:SetUp()
    --physics.start()
end

function u:TearDown()
    --physics.stop()
end

local function default_setup()
    local level = CleanOceanLevel()
    return level
end

u:Test ("BoatDirection", function(self)
    local dirs = {up=BoatDirection.UP,
        down=BoatDirection.DOWN, left=BoatDirection.LEFT, right=BoatDirection.RIGHT}
    _.each(_.keys(dirs), function (k) 
            self:ASSERT_TRUE (dirs[k], 
                tostring(k).." is not a correct direction") 
        end)
end)

--u:Test ("ALLBoatDirection", function(self)
--    local U,D,L,R,N = BoatDirection:AllDirections()
--    local dirs = {U,D,L,R,N}
--    _.each(_.keys(dirs), function (k) 
--            self:ASSERT_TRUE (dirs[k], 
--                tostring(k).." is not a correct direction") 
--        end)
--end)

u:Test ( "Next Block, No Previous", function(self)
    
    --local level_mock, b_group, num_a, num_b = default_setup (val_a, val_b, nil, false)
    local level_mock = default_setup()
    level_mock:Setting ('grid_columns', 4)
        :Setting ('grid_rows', 4)
    level_mock:show({phase='did'})
    local U,D,L,R,N = BoatDirection:AllDirections()
    level_mock:SetOceanVectors({{R,D},
                                {U,L}})
    
    local right = level_mock:DetermineNextBlock(R, Vector2(1,1), nil)
    self:ASSERT_TRUE (right==Vector2(1,2), "incorrectly determining direction")
    
    local down = level_mock:DetermineNextBlock(D, right, nil)
    self:ASSERT_TRUE (right==Vector2(1,2), "incorrectly determining direction")
    
    local left = level_mock:DetermineNextBlock(L, down, nil)
    self:ASSERT_TRUE (right==Vector2(2,2), "incorrectly determining direction")
    
    local up = level_mock:DetermineNextBlock(U, left, nil)
    self:ASSERT_TRUE (right==Vector2(2,1), "incorrectly determining direction")
    
    
    
    level_mock:DestroyLevel()
    level_mock = nil
end)

return u