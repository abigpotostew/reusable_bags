-- unit.lua is a test suite for testing something that requires multiple cases.

local LCS = require "opal.libs.LCS"
local _ = require "opal.libs.underscore"

local Unit = LCS.class({PASS=1, FAIL=-1, FATAL_FAIL=0})

local msg_prefixes = {
    thick   = "[==========] ",
    line    = "[----------] ",
    run     = "[ RUN      ] ",
    ok      = "[       OK ] ",
    fail    = "[  FAILED  ] ",
    pass    = "[  PASSED  ] ",
}

function Unit:print(prefix, msg)
    print (string.format("%s %s",msg_prefixes[prefix] , msg))
end

function Unit:init (test_suite_name)
    self.test_suite_name = test_suite_name
    self.tests = {}
end

function Unit:SetUp()
    -- override by instance
end

function Unit:TearDown()
    -- override by instance
end

local function new_test(test_name, test_func)
    return {name=test_name,test=test_func}
end

function Unit:TestCount ()
    return #self.tests
end

function Unit:Name()
    return self.test_suite_name
end

-- Unit:Test() - add a unit test case to the suite. Won't run immeditably, but 
-- will run in FIFO order with Unit:Run().
function Unit:Test (test_name, test_func)
    assert (test_name and type (test_name)=="string"
            and test_func and type (test_func)=="function")
    if _.detect(self.tests,function(i)return i.name==test_name end) then
        error (string.format([[Unit:Test(): a test already exists with the name 
                %s in the %s test suite.]], test_name, self.test_name))
    end
    table.insert ( self.tests, new_test(test_name,test_func) )
end

function Unit:FAIL ()
    error (self:FailMsg(4))
end
    
function Unit:FAIL_OK ()
    print (self:FailMsg(4))
end

-- assuming stack is 3 away from test case, or set by lvl
function Unit:FailMsg (lvl)
    lvl = lvl or 3
    return string.format("%s:%d: Assertion Failure.",
        self.current_test,debug.getinfo(lvl))
end

function Unit:ASSERT_TRUE (condition)
    if not condition then
        self:FAIL()
    end
end

function Unit:ASSERT_FALSE (condition)
    if condition then
        self:FAIL()
    end
end

function Unit:EXPECT_TRUE (condition)
    if not condition then
        self:FAIL_OK()
    end
end

function Unit:EXPECT_FALSE (condition)
    if condition then
        self:FAIL_OK()
    end
end



-- Unit:Run() - specify a list of test names, or nothing to run all tests in 
-- this suite.
function Unit:Run ( tests_to_run )
    
    self:SetUp()
    
    --run tests
    local passes, fails = 0, {}
    
    for i,t in ipairs (tests_to_run) do
        local test_env_table = {}        -- create new environment
        local _G = _G
        setmetatable (test_env_table, {__index = _G})
        setfenv(1, test_env_table)
        --run test here
        local name = self.test_suite_name..'.'..t.name
        self.current_test = name
        self:print("run",name)
        --local result;
        local status, err = pcall(function() t.test() end)
        print(err)
        if not status then
            table.insert (fails, t.name)
            self:print ("fail", self.test_suite_name..'.'..name)
        else
            passes = passes + 1
            self:print ("ok", name)
        end
        setfenv (1, _G)
    end
    
    self:TearDown()
    
    return passes, fails
end

function Unit:RunAllTests ()
    --print(string.format("*** %s: RUNNING ALL TESTS! ******",
    --        self.test_suite_name))
    return self:Run (self.tests)
    --print(string.format("*** %s: FINISHED RUNNING ALL TESTS! ******",
    --       self.test_suite_name))
end

return Unit