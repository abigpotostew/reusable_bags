----------------------------------------------------------------------------------
-- Time class. This is static!
-- 
----------------------------------------------------------------------------------

local LCS = require "opal.libs.LCS"

local Time = LCS.class.abstract({
        fps             = display.fps,          -- constant
        s_per_frame     = 1/display.fps,        --constant
        ms_per_frame    = 1/display.fps * 1000, -- constant
        elapsed_time    = system.getTimer(),    -- initial time, mutable
        frame_count     = 0,                    -- number of frame since app started
        ms_per_frame    = 0,
        last_frame_time = system.getTimer(),
        initial_time    = system.getTimer(),    -- never changed
        delta_time      = 0
    })

function Time:init()
    -- Intentionally left blank, Time is an static class.
end

function Time:describe()
    print ( string.format("FPS: %d\t Elapsed Time: %4d", self.fps, self:ElapsedTime() ) )
end
----------------------------------------------------------------------------------
-- Corona Time event listener
-- Call once per frame
----------------------------------------------------------------------------------
function Time:enterFrame()
    
    local temp_time = self:TotalRuntime()  --Get current game time in ms
    self.delta_time = (temp_time-self.last_frame_time) / (self.ms_per_frame) 
    
    self.frame_count = self.frame_count + self.fps * self.delta_time/1000
    
    --60fps(16.666666667) or 30fps(33.333333333) as base
    self.last_frame_time = temp_time  --Store game time
end

----------------------------------------------------------------------------------
-- Getters
----------------------------------------------------------------------------------
-- Delta time in milliseconds since last frame.
function Time:DeltaTime()
    return self.delta_time
end

function Time:FrameCount()
    return self.frame_count
end

-- Time since Time:ResetElapsedTime() or Time instantiation
function Time:ElapsedTime()
    return self:TotalRuntime() - self.elapsed_time
end

function Time:TotalRuntime()
    return system.getTimer()
end

----------------------------------------------------------------------------------
-- Resetters
----------------------------------------------------------------------------------
function Time:ResetElapsed()
    self.elapsed_time = self:TotalRuntime() 
end

function Time:ResetFrameCount()
    self.frame_count = 0
end

return Time