local u = require 'opal.src.test.unit'('clean_ocean_test')
local _ = require 'opal.libs.underscore'
local Vector2 = require 'opal.src.vector2'

--local dirt_types = require "clean_ocean.src.dirt_types"
local BoatDirection = require "clean_ocean.src.boat_direction"
local OceanBlock = require "clean_ocean.src.ocean_block"

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
            --k is not a valid direction
            self:ASSERT_TRUE (dirs[k]) 
        end)
end)

u:Test ("ALLBoatDirection", function(self)
    local dirs = BoatDirection.AllDirections()
    _.each(_.keys(dirs), function (k) 
            self:ASSERT_TRUE (dirs[k]) 
        end)
end)

u:Test ("ValidDirection", function(self)
    local valid_dirs = BoatDirection.AllDirections()
    valid_dirs.NONE = nil
    local invalid_dirs = {1, "lame", {}, {x=1, tumblr='hub'}, function()end}
        
    _.each(_.keys(valid_dirs), function(dk)
            self:ASSERT_TRUE ( BoatDirection.ValidDirection(valid_dirs[dk]) )
    end)

    _.each(_.keys(invalid_dirs), function(idk)
            self:ASSERT_FALSE ( BoatDirection.ValidDirection(valid_dirs[idk]) )
    end)
end)
    

u:Test ( "Next Block, No Previous", function(self)
    
    --local level_mock, b_group, num_a, num_b = default_setup (val_a, val_b, nil, false)
    local level_mock = default_setup()
    level_mock:Setting ('grid_columns', 4)
        :Setting ('grid_rows', 4)
    level_mock:show({phase='did'})
    local AD = BoatDirection:AllDirections()
    local U,D,L,R,N = AD.UP, AD.DOWN, AD.LEFT, AD.RIGHT, AD.NONE
    level_mock:SetOceanVectors({{R,D},
                                {U,L}})
    
    local start = Vector2(1,1)
    
    local right = level_mock:DetermineNextGridPosition(R, start, nil)
    self:ASSERT_TRUE (right==Vector2(2,1), "incorrectly determining direction")
    
    local down = level_mock:DetermineNextGridPosition(D, right, nil)
    self:ASSERT_TRUE (down==Vector2(2,2), "incorrectly determining direction")
    
    local left = level_mock:DetermineNextGridPosition(L, down, nil)
    self:ASSERT_TRUE (left==Vector2(1,2), "incorrectly determining direction")
    
    local up = level_mock:DetermineNextGridPosition(U, left, nil)
    self:ASSERT_TRUE (up==start, "incorrectly determining direction")
    
    
    
    level_mock:DestroyLevel()
    level_mock = nil
end)

u:Test ("Ocean_Block_Do_Action", function(self)
    local level_mock = default_setup()
    local block = OceanBlock(level_mock, 10, 10)
    self:ASSERT_FALSE (block:HasAction())
    
    block:removeSelf()
    block=nil
    level_mock:DestroyLevel()
    level_mock = nil
end)--

return u