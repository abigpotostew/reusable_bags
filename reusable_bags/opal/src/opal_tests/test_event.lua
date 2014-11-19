local Unit = require "opal.src.test.unit"
local oEvent = require 'opal.src.event'

local u = Unit("oEvent_Tests")


u:Test ( "add_event", function(self)
    self:FUNC_ASSERT (function()
        local group = display.newGroup()
        local event = oEvent:new()
        event:AddEvent ("event1")
    end)
end)

u:Test ( "dispatch_event", function(self)
    local event_name = 'big_butt_warrior'
    local event_dispatched = false
    local group = display.newGroup()
    
    local listener = function(event)
        self:ASSERT_TRUE (event.dang_snag_test_data=='ffft')
        event_dispatched = true
    end
    local event = oEvent()
    event:AddEventListener (group,event_name,listener)
    local event_data={
        dang_snag_test_data='ffft'
    }
    event:DispatchEvent (group, event_name, event_data)
    self:ASSERT_TRUE(event_dispatched)
    
    event_dispatched = false
    
    local table_listen = {}
    table_listen[event_name] = function(event)
        self:ASSERT_TRUE (event.dang_snag_test_data=='ffft')
        event_dispatched = true
    
    end
    event:DispatchEvent(group,event_name,event_data)
    self:ASSERT_TRUE(event_dispatched)
end)

u:Test ( "remove_event", function(self)
    local event_name = 'big_butt_warrior'
    local event_dispatched = false
    local group = display.newGroup()
    local event = oEvent()
    event:AddEvent ("event1")
    local event_data={
        nothing='nothing'
    }
    local listener = function(event)
        event_dispatched = true
        end
    event:DispatchEvent (group, event_name, event_data)
    self:ASSERT_FALSE (event_dispatched)
end)

return u