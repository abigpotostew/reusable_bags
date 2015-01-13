--TODO, INCOMPLETE, use this in opal.src.level when there's time
-- TODO, when adding events, and timeline is empty, begin running timeline.

local _ = require 'opal.libs.underscore'
local Timeline = nil
do
    local oEvent = require "opal.src.event"
    --Can listen for events
    Timeline = oEvent:extends()
end

function Timeline:init()
    self.timeline = {}
    self.paused = true
end

----------------------------------------------------------------------------------
-- Private functions
----------------------------------------------------------------------------------

local function timeline_insert_back (timeline, callback)
    table.insert(timeline, callback)
end

local function timeline_insert_front (timeline, callback)
    table.insert(timeline, 1, callback)
end

local function timeline_add_wait_event (timeline, event, insert_func, seconds)
    if seconds and type(seconds)=='number' then
        insert_func (timeline,function() return seconds end)
    end
    if event and type(event)=='function' then
        insert_func (timeline, event)
    end
end

----------------------------------------------------------------------------------
-- Public functions
----------------------------------------------------------------------------------

-- Queues a wait event in back
function Timeline:TimelineWait (seconds)
    timeline_add_wait_event (self.timeline, nil, seconds, timeline_insert_back)
end

-- Queues an event in timeline, with optional wait time before event is triggered in timeline. Both parms are optional.
function Timeline:TimelineAddEvent (event, seconds)
    timeline_add_wait_event ( self.timeline, event, timeline_insert_back, seconds)
end

-- Adds event and/or wait at front of timeline
function Timeline:TimelineAddEventFront (event, seconds)
    timeline_add_wait_event (self.timeline, event, timeline_insert_front, seconds)
end

function Timeline:SetPaused(is_paused)
    self.paused = is_paused
end

--stops processing timeline if timeline is empty
function Timeline:ProcessTimeline ()
    if self.paused then return end
	while #self.timeline ~= 0 do
		local event = table.remove(self.timeline, 1)
		local result = event()
		if (type(result) == "number") then
			self:CreateTimer(result, function() self:ProcessTimeline() end)
			break
		end
	end
end