local Unit = require "opal.src.test.unit"
local oAssert = require "opal.src.utils.assert"

local u = Unit("oAssert Test Suite")


u:Test ( "Assert True", function(self)
    oAssert(1==1)
    self:ASSERT_TRUE(1==1)
end)

u:Test ( "Assert type", function(self)
    local a = "hi"
    oAssert.type(a,'string','unit test for oAssert bool fail')
    self:ASSERT_TRUE(type(a)=='string')
end)

u:Test ( "Assert multi_type", function(self)
    local a,b,c = 1,2,3
   oAssert.multi_type('number', 'oAssert mult object type check', a,b,c)
    self:ASSERT_TRUE(type(a)=='number','BUMMER')
    self:ASSERT_TRUE(type(b)=='number','BUMMER')
    self:ASSERT_TRUE(type(c)=='number','BUMMER')
end)

return u