-----------------------------------------------------------------------------------------
-- Assert for OpalEngine
-- Require this once in setup.
----------------------------------------------------------------------------------------
local _ = require "opal.libs.underscore"
local oUtil = require 'opal.src.utils.util'

local function opal_assert(condition, error_msg)
    assert (condition, error_msg)
    return true
end

local function opal_assert_type(object, obj_type, error_msg)
    assert (object and type (object) == obj_type, error_msg)
    return true
end

local function opal_assert_multi_type(obj_type, error_msg, ...)
    _.each (arg, function(object)
        assert (object and type (object) == obj_type, error_msg)
    end)
    return true
end

local on_device = (system.getInfo("environment") == "device" )
if on_device then
    opal_assert, opal_assert_type = function()end, function()end
end

local mt = {}
mt.__call = opal_assert
local oAssert = setmetatable ({}, mt)

oAssert.boolean = opal_assert
oAssert.type = opal_assert_type
oAssert.multi_type = opal_assert_multi_type

oUtil.lockObjectProperties (oAssert)

return oAssert