----------------------------------------------------------------------------------
-- Time class. This is static!
-- 
----------------------------------------------------------------------------------

local LCS = require "opal.libs.LCS"
local oEvent = require "opal.src.event"

local oTime = oEvent:extends({
        fps             = display.fps,          -- constant
        s_per_frame     = 1/display.fps,        --constant
        ms_per_frame    = 1/display.fps * 1000, -- constant
        elapsed_time    = system.getTimer(),    -- initial time, mutable
        frame_count     = 0,                    -- number of frame since app started
        --ms_per_frame    = 0,
        last_frame_time = system.getTimer(),
        initial_time    = system.getTimer(),    -- never changed
        delta_time      = 0
    })

function oTime:init()
    -- blank object to create event listeners against
    self.phony_subject = display.newGroup()
end

function oTime:describe()
    print ( string.format("FPS: %d\t Elapsed Time: %4d", self.fps, self:ElapsedTime() ) )
end
----------------------------------------------------------------------------------
-- Corona Time event listener
-- Call once per frame
----------------------------------------------------------------------------------
function oTime:enterFrame()
    
    local temp_time_ms = self:TotalRuntime()  --Get current game time in ms
    local dt_ms = (temp_time_ms-self.last_frame_time) / (self.ms_per_frame)
    self.delta_time = dt_ms
    self.frame_count = self.frame_count + self.fps * dt_ms/1000
    --60fps(16.666666667) or 30fps(33.333333333) as base
    self.last_frame_time = temp_time_ms  --Store game time
end

----------------------------------------------------------------------------------
-- Getters
----------------------------------------------------------------------------------
-- Delta time in milliseconds since last frame.
function oTime:DeltaTime()
    return self.delta_time
end

-- Delta time in seconds since last frame.
function oTime:DeltaTimeSeconds()
    return self.delta_time / 1000
end

function oTime:FrameCount()
    return self.frame_count
end

-- Time since Time:ResetElapsedTime() or Time instantiation
function oTime:ElapsedTime()
    return self:TotalRuntime() - self.elapsed_time
end

function oTime:TotalRuntime()
    return system.getTimer()
end

----------------------------------------------------------------------------------
-- Resetters
----------------------------------------------------------------------------------
function oTime:ResetElapsed()
    self.elapsed_time = self:TotalRuntime() 
end

function oTime:ResetFrameCount()
    self.frame_count = 0
end

return oTime