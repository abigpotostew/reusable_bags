local u = require 'opal.src.test.unit'('ocean_pinball_test')
local _ = require 'opal.libs.underscore'
local Vector2 = require 'opal.src.vector2'

function u:SetUp()
end

function u:TearDown()
end


u:Test ("Empty", function(self)
    self:ASSERT_TRUE (true) 
end)