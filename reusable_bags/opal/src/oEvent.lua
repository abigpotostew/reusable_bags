----------------------------------------------------------------------------------
--
-- oEvent.lua
-- Similar to Corona's event system, but extends to all opan engine actors.
-- Usage: the Event or Actor or anything that extends this class creates an event using AddEvent()
--  The Event then calls Trigger() when it wants to fire that event
--  An observer can call AddEventListener() to become an observer for that event.
--  The event object passed to event listeners are only guaranteed the event name. Please don't modify the event as the name table is passed to every listener.
--
----------------------------------------------------------------------------------


local LCS = require "opal.libs.LCS"
local _ = require "opal.libs.underscore"

local Event = LCS.class()

function Event:init ()
    self.events = {}
end

function Event:AddEvent (event_name)
    self.events[event_name] = {listeners={}}
end

function Event:Trigger (event_name, event)
    event.name = event_name
    _.each (self.events[event_name], function(listener)
        if type (listener) == "table" then
            listener [event_name](event)
        elseif type (listener) == "function" then
            listener (event)
        else
            oLog.Error(string.format("Event:Trigger(): Listener for %s event is not correct type (table or function)", event_name))
        end
    end)
end

function Event:AddEventListener (event_name, callback)
    oAssert (self.events[event_name], string.format ("Event:AddEventListener(): Can't add event listener of type '%s', it hasn't been created yet.", event_name))
    table.insert (self.events[event_name], callback)
end

function Event:RemoveEventListener (event_name, listener)
    _.reject(self.events[event_name], function(l) return l == listener end)
end

return Event