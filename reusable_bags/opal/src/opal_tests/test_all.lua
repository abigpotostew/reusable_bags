local test_all = setmetatable({},nil)
local _ = require 'opal.libs.underscore'
local Tests = require 'opal.src.test.tests'('opal_all')
local oAssert = require 'opal.src.utils.assert'

local test_suites = {
    ['opal.src.opal_tests.']={'test_assert',
                               'test_opal',
                               'test_event',
                               'test_level',
                               'test_chain',
        },
}

local function load_tests (test_paths)
    local tests = {}
    return _.map (test_paths, function(path)
        local unit_test = require (path)
        oAssert.type(unit_test,'table','Make sure the unit test file is returning your instance of Unit!')
        return unit_test
    end)
end

-- Recursively get path to test files using key + sub table strings then load the test
local function get_test_paths(prefix,tests_list)
    local out = {}
    for k,test in pairs(tests_list) do
        if type(test)=='string' then
            local test_path = string.format("%s%s",prefix or"",test)
            table.insert(out,test_path)
        elseif type(test)=='table' then
            local t_out = get_test_paths ((prefix or "")..''..k,test)
            _.each(t_out,function(t) table.insert(out, t) end)
        end
    end
    return out
end

test_all.Run = function(setup, teardown, additional_tests)
    if additional_tests then
        _.extend (test_suites, additional_tests)
    end
    Tests:RunAll ( load_tests (get_test_paths(nil, test_suites)), setup, teardown )
end

return test_all
