-----------------------------------------------------------------------------------------
-- Global Logger static class
-- Usage:
--      require('src.utils.log')        --require once
--      Log:SetLogLevel (Log.WARNING)
--      Log:Verbose ("hey dingus")      --won't print anything
--      Log:FATAL ("oh my gosh")        --will print
----------------------------------------------------------------------------------------

local LCS = require "libs.LCS"

local Log = LCS.class.abstract({
        DEBUG           = 0,    -- Prints everything
        VERBOSE         = 1,    -- Print most things
        WARNING          = 2,   -- Prints errors & warnings
        FATAL           = 3,    -- Prints just the bad things
        SILENT          = 4,    -- prints nothing :(
    })

local level_names = { 
                      [Log.DEBUG]   = "Debug",
                      [Log.VERBOSE] = "Verbose",
                      [Log.WARNING] = "Warning",
                      [Log.FATAL]   = "Fatal",
                      [Log.SILENT]  = "Silent",
                     }
                     
local current_log_level = Log.VERBOSE

function Log:init()
    -- Intentionally left blank, Log is an static class.
end

-- Prepends "filename[line_number]:" before a print message
local function debug_print(...)
    local info = debug.getinfo(5) -- Back up frames in stack
    local source_file = info.source
    local debug_path = source_file:match('%a+.lua')
    if debug_path then 
        debug_path = debug_path  ..' ['.. info.currentline ..']'
    end
    local pre_msg = ((debug_path and (debug_path..": ")) or "")
    local msg = ''
    for i,v in ipairs(arg) do
        msg = msg .. tostring(v) .. "\t"
    end
    print(pre_msg.." "..msg)
end

local function log (log_level, ...)
    if log_level >= current_log_level then
        arg.n=nil
        debug_print('['..level_names [log_level]..']', unpack(arg))
    end
end

local function log_arg (log_level, arg_table)
    arg_table.n=nil
    log (log_level, unpack(arg_table))
end

----------------------------------------------------------------------------------
-- Public Log Methods:
----------------------------------------------------------------------------------

function Log:LevelName (log_level)
    return level_names[log_level]
end

function Log:SetLogLevel (log_level)
    assert (type(log_level)=="number", "Log.lua: Incorrect Log level")
    current_log_level = log_level
end

function Log:Debug(...)
    log_arg (self.DEBUG, arg)
end
function Log:Verbose(...)
    log_arg (self.VERBOSE, arg)
end
function Log:Warning(...)
    log_arg (self.WARNING, arg)
end
function Log:Fatal(...)
    log_arg(self.FATAL, arg)
end
function Log:Silent(...)
    log_arg(self.SILENT, arg)
end

-- override print() function to improve performance when running on device
-- and print out file and line number for each print
local original_print = print
if ( system.getInfo("environment") == "device" ) then
	print("Print & Log now going silent. With Love, log.lua")
   print = function() end
end

return Log