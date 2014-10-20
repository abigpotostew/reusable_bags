-- Test runs a bunch of test suites. for example, there is typically only one instance of this class per program which defines a global setup / teardown between which runs multiple test tuites.

local Unit = require "opal.src.test.unit"
local _ = require "opal.libs.underscore"

local Tests = Unit:extends()

function Tests:init(name)
    self:super("init", name)
end

function Tests:RunAll(tests_suites)
    local tests = tests_suites
    local suites_count = #tests
    local tests_count = _.reduce(tests, 0, 
        function(memo, t) return memo+t:TestCount() end)
    self:print("thick", string.format("%s: Running %d tests from %d test suites.", self.test_suite_name, tests_count, suites_count))
    
    local passes, fails = 0, {}
    _.each (tests, function(t)
        self:print ("line", string.format("%d test from %s.", t:TestCount(), t:Name()))
        local pass, suite_fails = t:RunAllTests()
        if pass then
            passes = passes + pass
        end
        if suite_fails then
            _.each(suite_fails, function(s) table.insert(fails,s) end)
        end
    end)
    
    self:print ('thick', string.format("%s: %d tests from %d test suites finished.",self.test_suite_name, tests_count, suites_count))
    self:print ('pass', string.format ('%d tests.', passes))
    
    if #fails > 0 then
        self:print ('fail', string.format ('%d tests, listed below:',#fails))
        _.each(fails, function(f)self:print('fail',f)end)
        print(string.format('%d FAILED TESTS', #fails))
    end
    
    --print
end

return Tests