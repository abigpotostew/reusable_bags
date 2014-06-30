-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()
physics.setDrawMode("hybrid")
physics.setGravity(0,0.6)

local sprite = require "sprite"
local class = require "src.class"
local util = require"src.util"
local fps = require"src.libs.fps"
local collision = require "src.collision"

local Actor = require 'src.actor'
local Bags = require 'actors.bagTypes'
local Foods = require 'actors.foodTypes'

collision.SetGroups{"bag", "food", "head", "ground", "wall"}




local Level = class:makeSubclass("Level")


-------------------------------------------------------------------------------
-- Constructor

Level:makeInit(function(class, self)
	class.super:initWith(self)

	-- forward declarations and other locals
    self.screenW, self.screenH, self.halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
    self.width, self.height = self.screenW, self.screenH
    
    --Level actors:
    self.bags = {}
    self.foods = {}
    
    self.timeline = {}
	self.timers = {}
	self.transitions = {}
	self.listeners = {}
	self.lastFrameTime = 0

    self.worldScale = display.contentWidth / self.width
	self.worldOffset = { x = 0, y = 0}

    self.scene = storyboard.newScene()
    self.scene.view = display.newGroup()
	self.scene:addEventListener("createScene", self)
	self.scene:addEventListener("enterScene", self)
	self.scene:addEventListener("exitScene", self)
	self.scene:addEventListener("destroyScene", self)
    --self.scene:addEventListener("touch", self)

	self.worldGroup = display.newGroup()
	self.scene.view:insert(self.worldGroup)
	self.worldGroup.xScale = self.worldScale
	self.worldGroup.yScale = self.worldScale
    
    
	

	return self
end)



--------------------------------------------


Level.PeriodicCheck = Level:makeMethod(function(self)
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

--	-- Check for win/lose conditions
--	local levelLost = true
--	for i, hut in ipairs(self.huts) do
--		if (hut:GetState() ~= "dead") then
--			levelLost = false
--			break
--		end
--	end

--	local levelWon = (#self.timeline == 0 and #self.birds == 0)

	if (levelLost) then
		self:CreateTimer(2.0, function(event) gamestate.ChangeState("LevelLost") end)
	elseif (levelWon) then
		self:CreateTimer(2.0, function(event) gamestate.ChangeState("LevelWon") end)
	else
		self:CreateTimer(0.5, function(event) self:PeriodicCheck() end) -- Runs every 500ms (~15 frames)
	end
end)


Level.ProcessTimeline = Level:makeMethod(function(self)
	while #self.timeline ~= 0 do
		local event = table.remove(self.timeline, 1)
		local result = event()
		if (type(result) == "number") then
			self:CreateTimer(result, function() self:ProcessTimeline() end)
			break
		end
	end
end)

Level.TimelineWait = Level:makeMethod(function(self, seconds)
	table.insert(self.timeline, function() return seconds end)
end)

Level.SpawnBag = Level:makeMethod(function(self, bag_name, x, y)
    local b = Bags.CreateBag(bag_name, x, y, self)
    --table.insert(self.bags,b)
end)

Level.SpawnFood = Level:makeMethod(function(self, weight, x, y)
    local f = Foods.CreateFood( x, y, "light", "apple", self)
    --table.insert(self.foods,f)
    f:addListener(f.sprite,"touch",self)
    --f.sprite:addEventListener("touch", self)
end)

Level.AddGround = Level:makeMethod(function(self)
	--[[local width, height = self:GetWorldViewSize()
	local groundInfo = {}--display.newRect(0, 0, width, 22)
	--ground:setReferencePoint(display.BottomLeftReferencePoint)
    groundInfo.anchorX = 0.5
    groundInfo.anchorY = 0.5
	groundInfo.alpha = 1.0
	groundInfo.typeName = "ground"
    groundInfo.physics = {}
    groundInfo.scale = 1
	local halfWidth = width * 0.5
    self.ground = Actor:init(groundInfo)
    self.ground.group = self:GetWorldGroup()
    --self.ground:createRectangleSprite(0,0, width,14)
    self.ground:addPhysics({bounce=0.2, category='ground', colliders={"food"}, isSensor=false, bodyType="static"})
	self:GetWorldGroup():insert(self.ground.sprite)--]]
    
    local width, height = self:GetWorldViewSize()
	local ground = display.newRect(0, 0, width, 22)
    ground.anchorX, ground.anchorY = 0.5, 0.5
	ground.x = width/2
	ground.y = height
	ground.alpha = 1
	ground.typeName = "ground"
	local halfWidth = width * 0.5
	local shape = {	-halfWidth, -14,
					 halfWidth, -14,
					 halfWidth,  14,
					-halfWidth,  14 }
	physics.addBody(ground, "static", {
		shape = shape,
		bounce = 0.00001,
		friction = 1,
		filter = collision.MakeFilter("ground",{"food","bag"})
	})

	self:GetWorldGroup():insert(ground)
    
end)

-- Called when the scene's view does not exist:
Level.createScene = Level:makeMethod(function(self, event)
    print("Level:CreateScene")
	local group = self.scene.view
    
    self.aspect = display.contentHeight / display.contentWidth
	self.height = self.width * self.aspect
    
    self.worldScale = 1--display.contentWidth / self.width
	self.worldOffset = { x = 0, y = 0}
    
    self.worldGroup = display.newGroup()
	self.scene.view:insert(self.worldGroup)
	self.worldGroup.xScale = self.worldScale
	self.worldGroup.yScale = self.worldScale
    
    self:AddGround()
    
    --start spawning debug guys
    local plastic_bag1 = self:SpawnBag("plastic", 100, 350)
    local paper_bag1 = self:SpawnBag("paper", 350, 350)
    local canvas_bag1 = self:SpawnBag("canvas", 600, 350)
    
    local food1 = self:SpawnFood("light", 100, 250)
    
    
    print(string.format("Screen Resolution: %i x %i", display.contentWidth, display.contentHeight))
	print(string.format("Level Size: %i x %i", self.width, self.height))
    
    self:ProcessTimeline()

	local performance = fps.new()
	performance.group.alpha = 0.7
    
    self:PeriodicCheck()
end)

-- Called immediately after scene has moved onscreen:
Level.enterScene = Level:makeMethod(function(self, event)
	local group = self.view
	
	physics.start()
	
end)

-- Called when scene is about to move offscreen:
Level.exitScene = Level:makeMethod(function(self, event)
	print("scene:exitScene")
	
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
    
    
	
end)


Level.touch = Level:makeMethod(function(self, event)
    if event.phase == "began" then
        event.target.joint = physics.newJoint( "touch", event.target, event.x, event.y )
        event.target.joint.frequency = 1 --low frequency, makes it more floaty
        event.target.joint.dampingRatio = 1 --max damping, doesn't bounce against joint
        display.getCurrentStage():setFocus( event.target )
    elseif event.phase == "moved" then
        event.target.joint:setTarget(event.x, event.y)
    elseif event.phase == "ended" then
        event.target.joint:removeSelf()
        display.getCurrentStage():setFocus( nil )
    end 
    
end)

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
Level.destroyScene = Level:makeMethod(function(self, event)
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
end)

-------------------------------------------------------------------------------
-- Getters and utility functions

Level.GetWorldGroup = Level:makeMethod(function(self)
	return self.worldGroup
end)

Level.GetScreenGroup = Level:makeMethod(function(self)
	return self.scene.view
end)

Level.GetWorldScale = Level:makeMethod(function(self)
	return self.worldScale
end)

Level.WorldToScreen = Level:makeMethod(function(self, x, y)
	return (x * self.worldScale + self.worldOffset.x), (y * self.worldScale + self.worldOffset.y)
end)

Level.ScreenToWorld = Level:makeMethod(function(self, x, y)
	return ((x - self.worldOffset.x) / self.worldScale), ((y - self.worldOffset.y) / self.worldScale)
end)

Level.GetWorldViewSize = Level:makeMethod(function(self)
	return self.width, self.height
end)


Level.CreateTimer = Level:makeMethod(function(self, secondsDelay, onTimer)
	table.insert(self.timers, timer.performWithDelay(secondsDelay * 1000, onTimer))
end)

Level.CreateListener = Level:makeMethod(function(self, object, name, listener)
	table.insert(self.listeners, {object = object, name = name, listener = listener})
	object:addEventListener(name, listener)
end)

Level.CreateTransition = Level:makeMethod(function(self, object, params)
	table.insert(self.transitions, transition.to(object, params))
end)

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------

return Level