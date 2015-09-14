----------------------------------------------------------------------------------
--
-- event.lua
-- Wrapper for Corona's Event System to aid custom event management. This class is
-- an interface to corona's event model.
-- Usage: the Event or Actor or anything that extends this class (the subject) 
-- creates an event using AddEvent(), or just calling AddEventListener().
-- The subject then calls DispatchEvent() when it wants to fire that event
-- An observer can call AddEventListener() to become an observer for that event.
-- The event object passed to event listeners are only guaranteed the event name. 
-- Please don't allow the observers to modify the event table as the same table is
-- passed to every observer.
--
----------------------------------------------------------------------------------

local LCS = require "opal.libs.LCS"
local _ = require "opal.libs.underscore"

local Event = LCS.class()

function Event:init ()
    self.events = {}
end

function Event:AddEvent (event_name)
    self.events[event_name] = {}
end

--- Notify all listeners for event_name, calling respective events.
-- @tparam displayobject object display object that will dispatch the corona event
-- @
function Event:DispatchEvent (object, event_name, event)
    oAssert (object, "oEvent:DispatchEvent requries an object to as the subject to listen to.")
    oAssert.type (event_name, "string", "oEvent:DispatchEvent requires that name be a string.")
	oAssert.type (event, "table", "oEvent:DispatchEvent requires an event table")
    event.name = event_name
    object:dispatchEvent ( event )
end

-- object       - which corona display object this listener is attached to.
-- event_name   - string name of the listener
-- callback     - table or function as callback 
function Event:AddEventListener (object, event_name, callback)
    oAssert (object, "oEvent:AddEventListener requries an object to as the subject to listen to.")
    oAssert.type (event_name, "string", "addListener requires that name be a string")
	assert(callback and (
		type(callback) == "function" or
		(type(callback) == "table" and callback[event_name] and type(callback[event_name]) == "function")),
		"oEvent:AddEventListener requires that callback be either a function, or a table with a function that has the same name as the event")
    if not self.events[event_name] then
        self:AddEvent (event_name)
    end
    table.insert (self.events[event_name], {object=object, callback=callback})
    object:addEventListener (event_name, callback)
end

local function remove_event (event_table, event_name)
    event_table.object:removeEventListener(event_name, event_table.callback)
end

function Event:RemoveEventListener (event_name, callback)
    _.reject(self.events[event_name], function(l) 
        if l.callback == callback then
            remove_event (event_name, l)
            return true
        end
    end)
end

--private
local function remove_all_events (events)
    _.each (_.keys(events), 
        function(event_name)
            _.each (events[event_name], 
                function(ev_table) 
                    remove_event (ev_table, event_name) 
                end)
            events[event_name] = nil
        end
    )
end

function Event:RemoveAllEventListeners ()
    remove_all_events (self.events)
    self.events = nil
    self.events = {}
end

function Event:removeSelf ()
    remove_all_events (self.events)
    self.events = nil
end

return Event