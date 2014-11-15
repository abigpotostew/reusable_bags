local test_all = setmetatable({},nil)
local _ = require 'opal.libs.underscore'
local Tests = require 'opal.src.test.tests'('opal_all')

local test_suites = {
    --"opal.src.opal_tests.test_assert",
    --"opal.src.opal_tests.test_opal",
    --"opal.src.opal_tests.test_event",
    ['opal.src.opal_tests.']={'test_assert',
                               'test_opal',
                               'test_event',
                               'test_level',
        },
    ['plant_seed.tests.']={'plant_tests'},
    ['plant_math.tests.']={'plant_math_tests'}
}

local function get_tests(prefix,tests_list)
    local out = {}
    for k,test in pairs(tests_list) do
        if type(test)=='string' then
            table.insert(out,require(string.format("%s%s",prefix or"",test)))
        elseif type(test)=='table' then
            local t_out = get_tests ((prefix or "")..''..k,test)
            _.each(t_out,function(t) table.insert(out, t) end)
        end
    end
    return out
end

test_all.Run = function(setup, teardown)
    Tests:RunAll ( get_tests(nil, test_suites), setup, teardown )
end

return test_all
