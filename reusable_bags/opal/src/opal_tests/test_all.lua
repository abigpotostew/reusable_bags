local test_all = setmetatable({},nil)
local _ = require 'opal.libs.underscore'
local Tests = require 'opal.src.test.tests'('opal_all')

local test_suites = {
    "opal.src.opal_tests.test_assert",
    "opal.src.opal_tests.test_opal",
    "opal.src.opal_tests.test_event",
}

test_all.Run = function()
    Tests:RunAll (_.map(test_suites,
            function(i)
                return require(i)
            end))
end

return test_all
