--[[---------------------------------------------------------------------------

 DebugLevel 
 * a child class for Level which enables debug features


-----------------------------------------------------------------------------]]
local Level = require "src.level"

local DebugLevel = Level:makeSubclass("DebugLevel")

local function init(class, self, ...)
    
    debugTexturesSheetInfo = require("images.debug_image_sheet")
    debugTexturesImageSheet = graphics.newImageSheet( "images/debug_image_sheet.png", debugTexturesSheetInfo:getSheet() )
    self.texture_sheet = debugTexturesSheetInfo
    
	class.super:initWith(self, unpack(arg))
    
    self:EnableDebugKeys()
    
    self:AddKeyReleaseEvent("s", function(event)
        self:SpawnRandomFood(nil,nil,1)
    end)
    
	return self
end
DebugLevel:makeInit(init)

local key = function(self, event)
    local key_name = event.keyName
    if self.keys_down[key_name] then --key release event
        self.keys_down[key_name] = nil
        local events_for_key = self.key_events[key_name]
        if events_for_key then 
            for _, event in ipairs(events_for_key) do
                event({event="key", keyName=key_name, phase="release"})
            end
        end
    else
        self.keys_down[key_name] = true
    end
end
DebugLevel.key = DebugLevel:makeMethod(key)

local EnableDebugKeys = function(self, event)
    self.keys_down = {}
    
    self.key_events = {}
    
    Runtime:addEventListener("key", self)
end
DebugLevel.EnableDebugKeys = DebugLevel:makeMethod(EnableDebugKeys)

local AddKeyReleaseEvent = function(self, key, event)
    if not self.key_events[key] then
        self.key_events[key] = {}
    end
    
    table.insert(self.key_events[key], event)
end
DebugLevel.AddKeyReleaseEvent = DebugLevel:makeMethod(AddKeyReleaseEvent)

return DebugLevel