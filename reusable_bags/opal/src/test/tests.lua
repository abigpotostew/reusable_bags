-- Test runs a bunch of test suites. for example, there is typically only one 
-- instance of this class per program which defines a global setup / teardown
-- between which it runs multiple test suites.
-- Test will call os.exit(1) after running all tests if any failures are reported from a test suite. This prevents the game from running in an unstable state. It is default behavior that can be changed by setting do_not_exit_on_failure to true in the constructor.

local Unit = require "opal.src.test.unit"
local _ = require "opal.libs.underscore"

local Tests = Unit:extends()
function Tests:init(name, do_not_exit_on_failure )
    self:super("init", name)
    self.do_not_exit_on_failure = do_not_exit_on_failure
end

-- Run all test suites from param.
function Tests:RunAll(tests_suites, setup_func, teardown_func)
    local tests = tests_suites
    local suites_count = #tests
    local tests_count = _.reduce(tests, 0, 
        function(memo, t) return memo+t:TestCount() end)
    self:print("thick", string.format("%s: Running %d tests from %d test suites.", self.test_suite_name, tests_count, suites_count))
    
    if setup_func and type(setup_func)=='function' then
        self:print ('line', "Global setup.")
        setup_func()
    end
    
    -- Run each test and print results
    -- fails = {{name="...", error_msg="..."},...}
    local passes, fails = 0, {}
    _.each (tests, function(t)
        self:print ("line", string.format("%d test from %s.", t:TestCount(), t:Name()))
        local pass, suite_fails = t:RunAllTests()
        if pass then
            passes = passes + pass
        end
        if suite_fails then
            _.each(suite_fails, function(s) 
                    s.name = t:Name(s.name)
                    table.insert(fails,s) 
                end)
        end
    end)

    if teardown_func then
        self:print ('line', "Global teardown.")
        teardown_func()
    end
    
    -- Print summary
    self:print ('thick', string.format("%s: %d tests from %d test suites finished.",self.test_suite_name, tests_count, suites_count))
    self:print ('pass', string.format ('%d out of %d tests.', passes, tests_count))
    
    if #fails > 0 then
        self:print ('fail', string.format ('%d tests, listed below:',#fails))
        _.each(fails, function(f)
                self:print('fail',string.format("%s %s",f.name, f.error_msg))
            end)
        print(string.format('%d FAILED TESTS', #fails))
        if not self.do_not_exit_on_failure then 
            os.exit(1) 
        end
    end
end

return Tests