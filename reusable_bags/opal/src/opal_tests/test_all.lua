local test_all = setmetatable({},nil)
local test_suites = {}
local Tests = require 'opal.src.test.tests'('opal_all')

table.insert( test_suites, require "opal.src.opal_tests.test_assert" )

test_all.Run = function()
    Tests:RunAll (test_suites)
end

return test_all
