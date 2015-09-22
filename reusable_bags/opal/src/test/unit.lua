-- unit.lua is a test suite for testing something that requires multiple cases.

local LCS = require "opal.libs.LCS"
local _ = require "opal.libs.underscore"
local Util = require "opal.src.utils.util"

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

function Unit:Name(case_name)
    return string.format("%s.%s",self.test_suite_name,case_name or "")
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

function Unit:FAIL (stack_depth)
    error (self:FailMsg(stack_depth or 4))
end
    
function Unit:FAIL_OK (stack_depth)
    print (self:FailMsg(stack_depth or 4))
end

-- assuming stack is 3 away from test case, or set by lvl
function Unit:FailMsg (lvl)
    lvl = lvl or 3
    return string.format("%s:%d: Assertion Failure.",
        self.current_test,debug.getinfo(lvl).currentline)
end

function Unit:ASSERT_TRUE (condition, stack_depth)
    if not condition then
        self:FAIL(stack_depth)
    end
end

function Unit:ASSERT_FALSE (condition, stack_depth)
    if condition then
        self:FAIL(stack_depth)
    end
end

function Unit:ASSERT_EQ (a,b, stack_depth)
    if a ~= b then
        self:FAIL(stack_depth)
    end
end

function Unit:ASSERT_NEQ (a,b, stack_depth)
    if a == b then
        self:FAIL(stack_depth)
    end
end

function Unit:ASSERT_ARRAY_EQ (a,b, stack_depth)
    if not Util.ArrayEqual(a,b) then
        self:FAIL(stack_depth)
    end
end

--Protected calls function and asserts it runs without error
function Unit:FUNC_ASSERT (func)
    local status, err = pcall(func)
    self:ASSERT_TRUE (status,5)
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
    
    
    
    --run tests
    local passes, fails = 0, {}
    
    for i,t in ipairs (tests_to_run) do
        local test_env_table = {}        -- create new environment
        local _G = _G
        setmetatable (test_env_table, {__index = _G})
        setfenv(1, test_env_table)
        --run test here
        local name = self:Name(t.name)
        self.current_test = name
        self:print("run",name)
        
        self:SetUp()
        local status, err = pcall(function() t.test(self) end)
        self:TearDown()
        
        if not status then
            print (err)
            table.insert (fails, {name=t.name, error_msg=err, trace=debug.traceback()})
            self:print ("fail", name)
            break
        else
            passes = passes + 1
            self:print ("ok", name)
        end
        setfenv (1, _G)
    end
    
    
    
    return passes, fails
end

function Unit:RunAllTests ()
    return self:Run (self.tests)
end

return Unit