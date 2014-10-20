local Unit = require "opal.src.test.unit"
local oAssert = require "opal.src.utils.assert"

assert_unit = Unit("oAssert Test Suite")


assert_unit:Test ( "Assert True", function()
    assert_unit:ASSERT_TRUE(true)
end)

assert_unit:Test ( "Assert False", function()
    assert_unit:ASSERT_FALSE(false)
end)

return assert_unit