local Unit = require "opal.src.test.unit"
local _ = require 'opal.libs.underscore'
local Level = require 'opal.src.level'
local Actor = require 'opal.src.Actor'

local u = Unit("level.lua Test Suite")

u:Test("Destroy level", function(self)
    local level_mock = Level()
    local actors = {Actor({}, level_mock, level_mock:GetWorldGroup())}
    actors[1]:createRectangleSprite(10,10,0,0)
    _.each(actors, function(a) level_mock:InsertActor(a) end)
    self:ASSERT_TRUE(actors[1].sprite)
    
    level_mock:DestroyLevel()
    self:ASSERT_FALSE (actors[1].sprite)
end)

return u