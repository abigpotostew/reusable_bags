-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------


-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()
physics.setGravity(0,0.6)

local class = require "src.class"
local util = require"src.util"
local _ = require 'libs.underscore'
local fps = require "libs.fps"
local collision = require "src.collision"

local Actor = require 'src.actor'
local Bags = require 'actors.bagTypes'
local Foods = require 'actors.foodTypes'

collision.SetGroups{"bag", "food", "head", "ground", "wall"}


local Level = class:makeSubclass("Level")



-------------------------------------------------------------------------------
-- Constructor
local function init(class, self)
	class.super:initWith(self)
    
    --debug stuff
    debugTexturesSheetInfo = require("images.debug_image_sheet")
    debugTexturesImageSheet = graphics.newImageSheet( "images/debug_image_sheet.png", debugTexturesSheetInfo:getSheet() )
    --end debug stuff
    
    self.foodList = self:GetFoodList(debugTexturesSheetInfo)
    
    --Constructor-----------------------------
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
    
    self.runtime = 0
    
	return self
end
Level:makeInit(init)

local GetFoodList = function(self, textureSheetInfo)
    local list = _(textureSheetInfo.frameIndex):chain():keys()
        :select(function(v) return string.find(v, "food_") end):value()
        
    local renamed_list = {}
    _.each(list, function(i) 
            local food_name = string.gsub(i, "food_", "")
            table.insert(renamed_list, food_name )
        end)
    return renamed_list
end
Level.GetFoodList = Level:makeMethod(GetFoodList)


-- Called when the scene's view does not exist:
local create = function(self, event, sceneGroup)
    print("Level:create")
    assert(sceneGroup,"Please provide Level with a scene group")
    
    -----------
    self.sceneGroup = sceneGroup
    
    self.aspect = display.contentHeight / display.contentWidth
	self.height = self.width * self.aspect
    
    self.worldScale = 1--display.contentWidth / self.width
	self.worldOffset = { x = 0, y = 0}
    
    self.worldGroup = display.newGroup()
	sceneGroup:insert(self.worldGroup)
	self.worldGroup.xScale = self.worldScale
	self.worldGroup.yScale = self.worldScale
    
    self:AddGround()
    
    --start spawning debug guys
    local plastic_bag1 = self:SpawnBag("plastic", 100, 350)
    local paper_bag1 = self:SpawnBag("paper", 350, 350)
    local canvas_bag1 = self:SpawnBag("canvas", 600, 350)
    
    for i=0, 4 do
        --self:SpawnFood(175+i*250, 200, self.foodList[math.random(#self.foodList)])
    end
    --local food1 = self:SpawnFood( 175, 200, self.foodList[math.random(#self.foodList)])
    --local food2 = self:SpawnFood( 425, 200, self.foodList[math.random(#self.foodList)])
    --local food3 = self:SpawnFood( 675, 200, self.foodList[math.random(#self.foodList)])
    
    local left_spawner = Actor:init({typeName="spawner"}, self)
    left_spawner = Actor:init({typeName="spawner"}, self)
    left_spawner.group = self:GetWorldGroup()
    left_spawner:createRectangleSprite(15,50, 20, 50)
    self.left_spawner = left_spawner
    
    
    print(string.format("Screen Resolution: %i x %i", display.contentWidth, display.contentHeight))
	print(string.format("Level Size: %i x %i", self.width, self.height))
    
    self:ProcessTimeline()

	local performance = fps.new()
	performance.group.alpha = 0.7
    
    self:PeriodicCheck()
end
Level.create = Level:makeMethod(create)

local getDeltaTime = function(self)
   local temp = system.getTimer()  --Get current game time in ms
   local dt = (temp-self.runtime) / (33.333333333)  --60fps(16.666666667) or 30fps(33.333333333) as base
   self.runtime = temp  --Store game time
   return dt
end
Level.getDeltaTime = Level:makeMethod(getDeltaTime)

local enterFrame = function(self, event)
    local phase = event.phase
    
    local dt = self:getDeltaTime()
    
    _.each( self.bags, function(bag)
        bag:update(dt)
    end)
end
Level.enterFrame = Level:makeMethod(enterFrame)

local key = function(self, event)
    print (event.keyName)
end
Level.key = Level:makeMethod(key)

-- Called immediately after scene has moved onscreen:
local show = function(self, event)
	local sceneGroup = self.sceneGroup
    
    if event.phase == 'will' then
        
    elseif event.phase == 'did' then 
        physics.start()
        self.worldGroup = display.newGroup()
        sceneGroup:insert(self.worldGroup)
        self.worldGroup.xScale = self.worldScale
        self.worldGroup.yScale = self.worldScale
        
        Runtime:addEventListener("enterFrame", self)
        Runtime:addEventListener("key", self)
    end
	
	
end
Level.show = Level:makeMethod(show)

-- Called when scene is about to move offscreen:
local hide = function(self, event)
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
Level.hide = Level:makeMethod(hide)

local touchListener = function(self, event)
    
    
end
Level.touch = Level:makeMethod(touchListener)

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
local destroyScene = function(self, event)
	local group = self.sceneGroup
	
	package.loaded[physics] = nil
	physics = nil
end
Level.destroy = Level:makeMethod(destroyScene)


--------------------------------------------

local PeriodicCheck = function(self)
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
Level.PeriodicCheck = Level:makeMethod(PeriodicCheck)

local ProcessTimeline = function(self)
	while #self.timeline ~= 0 do
		local event = table.remove(self.timeline, 1)
		local result = event()
		if (type(result) == "number") then
			self:CreateTimer(result, function() self:ProcessTimeline() end)
			break
		end
	end
end
Level.ProcessTimeline = Level:makeMethod(ProcessTimeline)

local TimelineWait = function(self, seconds)
	table.insert(self.timeline, function() return seconds end)
end
Level.TimelineWait = Level:makeMethod(TimelineWait)

local SpawnBag = function(self, bag_name, x, y)
    local b = Bags.CreateBag(bag_name, x, y, self)
    table.insert(self.bags,b)
end
Level.SpawnBag = Level:makeMethod(SpawnBag)

-- removeActor
----------------------------------------------
local RemoveActor = function(self, actor)
    local actorList
    if actor.typeName == "food" then
        actorList = self.foods
    elseif actor.typeName == "bag" then
        actorList = self.bags
    end
    _.reject(actorList, function(i) return i ~= actor end)
    
    actor:removeSelf()
end
Level.RemoveActor = Level:makeMethod(RemoveActor)

local InsertFood = function(self, food)
    table.insert(self.foods,food)
end
Level.InsertFood = Level:makeMethod(InsertFood)

local SpawnFood = function(self, x, y, weight_or_name)
    assert(weight_or_name, "Weight or food name required.")
    local spawner_function = nil
    if type(weight_or_name) == "string" then --by name
        spawner_function = Foods.CreateFood_ByName
    elseif type(weight_or_name) == "number" then
        spawner_function = Foods.CreateFood_ByWeight
    else
        assert(false,"Error spawning food")
    end
    local f = spawner_function( x, y, weight_or_name, self )
    self:InsertFood(f)
end
Level.SpawnFood = Level:makeMethod(SpawnFood)
--Level.SpawnFood = Level:makeMethod(SpawnFood)

local AddGround = function(self)
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
    local function createBoundary(x,y,w,h)
        local boundary = display.newRect(x, y, w, h)
        boundary.anchorX, boundary.anchorY = 0.5, 0.5
        boundary.x = x
        boundary.y = y
        boundary.alpha = 1
        boundary.typeName = "ground"
        local halfWidth = w * 0.5
        local halfHeight = h * 0.5
        local shape = {	-halfWidth, -halfHeight,
                         halfWidth, -halfHeight,
                         halfWidth,  halfHeight,
                        -halfWidth,  halfHeight }
        physics.addBody(boundary, "static", {
            shape = shape,
            bounce = 0.00001,
            friction = 1,
            filter = collision.MakeFilter("ground",{"food","bag"})
        })
        self:GetWorldGroup():insert(boundary)
    end
    createBoundary(width/2,height,width,22) --ground
    createBoundary(0,height/2,22,height) --left
    createBoundary(width,height/2,22,height) --ceiling
    createBoundary(width/2,0,width,22) --right
    
    --[[Ground
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
    --]]
end
Level.AddGround = Level:makeMethod(AddGround)


-------------------------------------------------------------------------------
-- Getters and utility functions
-------------------------------------------------------------------------------

local GetWorldGroup = function(self)
	return self.worldGroup
end
Level.GetWorldGroup = Level:makeMethod(GetWorldGroup)

local GetScreenGroup = function(self)
	return self.scene.view
end
Level.GetScreenGroup = Level:makeMethod(GetScreenGroup)

local GetWorldScale = function(self)
	return self.worldScale
end
Level.GetWorldScale = Level:makeMethod(GetWorldScale)

local WorldToScreen = function(self, x, y)
	return (x * self.worldScale + self.worldOffset.x), (y * self.worldScale + self.worldOffset.y)
end
Level.WorldToScreen = Level:makeMethod(WorldToScreen)

local ScreenToWorld = function(self, x, y)
	return ((x - self.worldOffset.x) / self.worldScale), ((y - self.worldOffset.y) / self.worldScale)
end
Level.ScreenToWorld = Level:makeMethod(ScreenToWorld)

local GetWorldViewSize = function(self)
	return self.width, self.height
end
Level.GetWorldViewSize = Level:makeMethod(GetWorldViewSize)

local CreateTimer = function(self, secondsDelay, onTimer)
	table.insert(self.timers, timer.performWithDelay(secondsDelay * 1000, onTimer))
end
Level.CreateTimer = Level:makeMethod(CreateTimer)

local CreateListener = function(self, object, name, listener)
	table.insert(self.listeners, {object = object, name = name, listener = listener})
	object:addEventListener(name, listener)
end
Level.CreateListener = Level:makeMethod(CreateListener)

local CreateTransition = function(self, object, params)
	table.insert(self.transitions, transition.to(object, params))
end
Level.CreateTransition = Level:makeMethod(CreateTransition)


-----------------------------------------------------------------------------------------
-- Timeline functions
----------------------------------------------------------------------------------------

Level.TimelineWait = Level:makeMethod(function(self, seconds)
	table.insert(self.timeline, function() return seconds end)
end)

Level.TimelineSpawnFood = Level:makeMethod(function(self, data)
	if (data.wait ~= nil) then
		self:TimelineWait(data.wait)
	end

	local function SpawnFood()
		self:SpawnFood(data.x, data.y, data.foodName or data.weight)
	end

	table.insert(self.timeline, SpawnFood)
end)




return Level