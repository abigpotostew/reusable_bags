--[[---------------------------------------------------------------------------

 DebugLevel 
 * a child class for Level which enables debug features
 * Usage: 
   local debug_level = require('src.debug.debug_level'):new() -- or just ()

-----------------------------------------------------------------------------]]
local Level = require "opal.src.level"
local fps = require "opal.libs.fps"

local DebugLevel = Level:extends()

function DebugLevel:init(...)
    
    debugTexturesSheetInfo = require("images.debug_image_sheet")
    debugTexturesImageSheet = graphics.newImageSheet( "images/debug_image_sheet.png", debugTexturesSheetInfo:getSheet() )
    self.texture_sheet = debugTexturesSheetInfo
    
    --Construct parent class
	self:super('init', unpack(arg))
    
    self:EnableDebugKeys()
    self:EnableDebugPhysicsShake()
    
    self:AddKeyReleaseEvent("s", function(event)
        self:SpawnRandomFood(nil,nil,1)
    end)
    
    local performance = fps.new()
	performance.group.alpha = 0.7
    
	--return self
end

function DebugLevel:key (event)
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

-- Turn on keyboard event listeners
function DebugLevel:EnableDebugKeys (event)
    self.keys_down = {}
    self.key_events = {}
    Runtime:addEventListener("key", self)
end

-- Attach a listener function to a key release event
function DebugLevel:AddKeyReleaseEvent (key, event)
    if not self.key_events[key] then
        self.key_events[key] = {}
    end
    table.insert(self.key_events[key], event)
end

-- Toggle debug physics drawing when device is shaken
function DebugLevel:EnableDebugPhysicsShake (initialDrawState)
    -- switches physics mode easily on device
    initialDrawState = initialDrawState or "normal"
    local hybrid_on = initialDrawState == "hybrid" or false
    local physics = require "physics"
    physics.setDrawMode(initialDrawState)
    local function jerk(e)
        if (e.isShake) then
                hybrid_on = not hybrid_on
                if hybrid_on then
                        physics.setDrawMode("hybrid")
                else
                        physics.setDrawMode("normal")
                end
        end
        return true
    end
    Runtime:addEventListener ("accelerometer",jerk)
end


function DebugLevel:create (event, scene_group)
    self:super("create", event, scene_group)
    
end


return DebugLevel