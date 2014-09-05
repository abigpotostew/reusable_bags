-----------------------------------------------------------------------------------------
-- Global Logger static class
----------------------------------------------------------------------------------------

local LCS = require "libs.LCS"

local Log = LCS.class.abstract({
        log_level       = 1,
        VERBOSE         = 0,
        WARNING          = 1,
        FATAL           = 2,
        SILENT          = 3,
    })

local level_names = { 
                      [Log.VERBOSE] = "Verbose",
                      [Log.WARNING] = "Warning",
                      [Log.FATAL]   = "Fatal",
                      [Log.SILENT]  = "Silent",
                     }

function Time:init()
    -- Intentionally left blank, Time is an static class.
end

----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------

function Log:LevelName (log_level)
    return level_names[log_level]
end

function Log:SetLevel (log_level)
    assert (type(log_level)=="number")
    self.log_level = log_level
end

function Log:Log (log_level, ...)
    if log_level <= self.log_level then
        arg.n=nil
        print('['..self:LevelName (log_level)..']', unpack(arg))
    end
end

function Log:Verbose(...)
    arg.n=nil
    self:Log (self.VERBOSE, unpack(arg))
end

function Log:Warning(...)
    self:Log (self.WARNING, arg)
end
function Log:Fatal(...)
    self:Log (self.FATAL, arg)
end

function Log:Silent(...)
    self:Log (self.SILENT, arg)
end


return Log