----------------------------------------------------------------------------------
--
-- level.lua
--
----------------------------------------------------------------------------------


-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()
physics.setContinuous( false )


local LCS = require ('opal.libs.LCS') 
local util = require "opal.src.utils.util"
local _ = require 'opal.libs.underscore'
local collision = require "opal.src.collision"
local Vector2 = require 'opal.src.vector2'
local oEvent = require "opal.src.event"

local Actor = require 'opal.src.actor'

local Level = oEvent:extends()

-------------------------------------------------------------------------------
-- Constructor
function Level:init()
    --Possibly call super init here
    
    
    
    -- Display constants
    self.screenW    = display.contentWidth 
    self.screenH    = display.contentHeight
    self.halfW      = display.contentWidth*0.5
    self.width, self.height = self.screenW, self.screenH
    self.world_scale = display.contentWidth / self.width
	self.world_offset = Vector2(0, 0)
    
    
    self.world_group = display.newGroup()
    self.world_group.xScale = self.world_scale 
    self.world_group.yScale = self.world_scale
    
    --Level actors:
    self.actors = {}
    
    -- Use the Create[X]() functions for these tables.
    self.timeline = {}
	self.timers = {}
	self.transitions = {}
	self.listeners = {}

end



-- Called when the scene's view does not exist:
function Level:create (event, sceneGroup)
    oLog.Verbose("Level:create")
    assert(sceneGroup,"Please provide Level with a scene group")
    
    -----------
    self.sceneGroup = sceneGroup
    
    self.aspect = display.contentHeight / display.contentWidth
	self.height = self.width * self.aspect
    
    self.world_scale = 1--display.contentWidth / self.width
	self.world_offset = { x = 0, y = 0}
    
    self.world_group = display.newGroup()
	sceneGroup:insert(self.world_group)
	self.world_group.xScale = self.world_scale
	self.world_group.yScale = self.world_scale

    oLog.Verbose(string.format("Screen Resolution: %i x %i", display.contentWidth, display.contentHeight))
	oLog.Verbose(string.format("Level Size: %i x %i", self.width, self.height))
    
end

function Level:enterFrame (event)
    local phase = event.phase
    
    local dt = oTime:DeltaTime()

    if self.physics_to_remove then
        _.each( self.physics_to_remove, function(actor)
            physics.removeBody(actor.sprite)
        end)
        self.physics_to_remove = nil
    end

end


-- Called immediately after scene has moved onscreen:
function Level:show (event, sceneGroup)
    
    if event.phase == 'will' then
        sceneGroup:insert(self.world_group)
    elseif event.phase == 'did' then 
        physics.start()
        Runtime:addEventListener("enterFrame", self)
        self:ProcessTimeline()
        self:PeriodicCheck()
    end
end

-- Called when scene is about to move offscreen:
function Level:hide (event)
	print("scene:hide")
	
    if event.phase == 'will' then
        
    elseif event.phase == 'did' then
        physics.stop()
    
        for _, timerToStop in ipairs(self.timers) do
            timer.cancel(timerToStop)
        end
        self.timers = {}

        for _, transitionToStop in ipairs(self.transitions) do
            transition.cancel(transitionToStop)
        end
        self.transitions = {}

        for _, listener in ipairs(self.listeners) do
            if (listener.object and listener.object.removeEventListener) then
                listener.object:removeEventListener(listener.name, listener.listener)
            end
        end
        self.listeners = {}
    end
    
end

function Level:touchListener (event)
    
    
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function Level:destroyScene (event)
	local group = self.sceneGroup
	
	package.loaded[physics] = nil
	physics = nil
end


--------------------------------------------


function Level:PeriodicCheck()
	-- Remove birds that have left the screen (using a separate kill list so we don't step all over ourselves)
--	local killList = {}
--	local width, height = self:GetWorldViewSize()
--	for i, inst in ipairs(self.birds) do
--		if (inst.sprite) then
--			local x = inst.sprite.x
--			local y = inst.sprite.y
--			if (x < -(width  * 2) or x > (width  * 3) or
--				y < -(height * 3) or y > (height * 1)) then
--				table.insert(killList, inst)
--			end
--		end
--	end
--	for i, inst in ipairs(killList) do
--		self:RemoveBird(inst)
--	end

--	-- Check for win/lose conditions here

	if (levelLost) then
		self:CreateTimer(2.0, function(event) gamestate.ChangeState("LevelLost") end)
	elseif (levelWon) then
		self:CreateTimer(2.0, function(event) gamestate.ChangeState("LevelWon") end)
	else
		self:CreateTimer(0.5, function(event) self:PeriodicCheck() end) -- Runs every 500ms (~15 frames)
	end
end





-- removeActor
----------------------------------------------
function Level:RemoveActor (actor)
    local a = self.actors[actor.typeName][actor.id]
    a:removeSelf()
    self.actors[actor.typeName][actor.id] = nil
end

function Level:RemoveActorPhysics (actor)
    if not self.physics_to_remove then
        self.physics_to_remove = {}
    end
    table.insert(self.physics_to_remove, actor)
end

function Level:InsertActor (a)
    if not self.actors[a.typeName] then
        self.actors[a.typeName] = {}
    end
    self.actors[a.typeName][a.id] = a
end

function Level:GetActor (type_name, id)
    local actor_list = self.actors[type_name]
    oAssert (actor_list, "Level:GetActor(): Actor doesn't exist")
    local actor = actor_list[id]
    oAssert (actor, "Level:GetActor(): Actor doesn't exist")
    
    return actor
end



function Level:collision (event)
    
end


-------------------------------------------------------------------------------
-- Getters and utility functions
-------------------------------------------------------------------------------



function Level:GetWorldGroup ()
	return self.world_group
end

function Level:GetScreenGroup ()
	return self.scene.view
end

function Level:GetWorldScale ()
	return self.world_scale
end

function Level:WorldToScreen (x, y)
	return (x * self.world_scale + self.world_offset.x), (y * self.world_scale + self.world_offset.y)
end

function Level:ScreenToWorld (x, y)
	return ((x - self.world_offset.x) / self.world_scale), ((y - self.world_offset.y) / self.world_scale)
end

function Level:GetWorldViewSize ()
	return self.width, self.height
end

function Level:CreateTimer (secondsDelay, onTimer)
	table.insert(self.timers, timer.performWithDelay(secondsDelay * 1000, onTimer))
end

function Level:CreateListener (object, name, listener)
	table.insert(self.listeners, {object = object, name = name, listener = listener})
	object:addEventListener(name, listener)
end

function Level:CreateTransition (object, params)
	table.insert(self.transitions, transition.to(object, params))
end


-----------------------------------------------------------------------------------------
-- Timeline functions
----------------------------------------------------------------------------------------
function Level:TimelineWait (seconds)
	table.insert(self.timeline, function() return seconds end)
end

function Level:ProcessTimeline ()
	while #self.timeline ~= 0 do
		local event = table.remove(self.timeline, 1)
		local result = event()
		if (type(result) == "number") then
			self:CreateTimer(result, function() self:ProcessTimeline() end)
			break
		end
	end
end


return Level