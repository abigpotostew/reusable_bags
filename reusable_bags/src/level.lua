----------------------------------------------------------------------------------
--
-- level.lua
--
----------------------------------------------------------------------------------


-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()
physics.setContinuous( false )
physics.setGravity(0,0)--0.6)

local LCS = require('libs.LCS') 
local util = require"src.utils.util"
local _ = require 'libs.underscore'
local collision = require "src.collision"
local Vector2 = require 'src.vector2'

local Actor = require 'src.actor'
local Bags = require 'actors.bagTypes'
local Foods = require 'actors.foodTypes'


collision.SetGroups{"bag", "food", "head", "ground", "wall", "nothing"}


local Level = LCS.class()

-------------------------------------------------------------------------------
-- Constructor
function Level:init()
    --Possibly call super init here
    
    self.food_list = self:GetFoodNameList(self.texture_sheet)
    
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
    self.bags = {}
    self.foods = {}
    self.spawn_points = {}
    self.actors = {}
    
    -- Use the Create[X]() functions for these tables.
    self.timeline = {}
	self.timers = {}
	self.transitions = {}
	self.listeners = {}
    
    
	--return self
end

function Level:GetFoodNameList (textureSheetInfo)
    local list = _(textureSheetInfo.frameIndex):chain():keys()
        :select(function(v) return string.find(v, "food_") end):value()
        
    local renamed_list = {}
    _.each(list, function(i) 
            local food_name = string.gsub(i, "food_", "")
            table.insert(renamed_list, food_name )
        end)
    return renamed_list
end


-- Called when the scene's view does not exist:
function Level:create (event, sceneGroup)
    Log:Verbose("Level:create")
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
    
    self:AddGround()
    

    Log:Verbose(string.format("Screen Resolution: %i x %i", display.contentWidth, display.contentHeight))
	Log:Verbose(string.format("Level Size: %i x %i", self.width, self.height))
    
    self:ProcessTimeline()
    
    self:PeriodicCheck()
end

function Level:enterFrame (event)
    local phase = event.phase
    
    local dt = Time:DeltaTime()
    
    _.each( self.bags, function(bag)
        bag:update(dt)
    end)

    if self.physics_to_remove then
        _.each( self.physics_to_remove, function(actor)
            physics.removeBody(actor.sprite)
        end)
        self.physics_to_remove = nil
    end

end



-- Called immediately after scene has moved onscreen:
function Level:show (event)
	local sceneGroup = self.sceneGroup
    
    
    if event.phase == 'will' then
        sceneGroup:insert(self.world_group)
    elseif event.phase == 'did' then 
        physics.start()
        Runtime:addEventListener("enterFrame", self)
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

--params: x, y, directionX, data.directionY, speed, angular_velocity, w, h
function Level:CreateSpawner (data)
    assert(data.directionX and
           data.directionY and
           data.speed,
           "required directionX and directionY and speed when creating spawner")
    local spawner = Actor({typeName="spawner"}, self)
    spawner.group = self:GetWorldGroup()
    spawner:createRectangleSprite(data.w or 15,data.h or 50, data.x or 0, data.y or 0)
    local direction = Vector2(data.directionX, data.directionY)
    spawner.velocity = direction * data.speed
    spawner.angular_velocity = data.angular_velocity or 0
    table.insert(self.spawn_points, spawner)
    return #self.spawn_points
end

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
    if actor.typeName == "food" then
        self:RemoveFoodActor(actor)
    elseif actor.typeName == "bag" then
        self:RemoveBagActor(actor)
    end
end

function Level:RemoveFoodActor (food)
    assert(food.typeName == "food", "Required food actor")
    food:RemoveFoodSelf()
    self.foods = _.select(self.foods, function(i) return i ~= food end)
end

function Level:RemoveBagActor (bag)
    assert(bag.typeName == "bag", "Required bag actor")
    bag:removeSelf()
    self.bags = _.select(self.bags, function(i) return i ~= bag end)
end

function Level:RemoveActorPhysics (actor)
    if not self.physics_to_remove then
        self.physics_to_remove = {}
    end
    table.insert(self.physics_to_remove, actor)
end


function Level:InsertFood (food)
    table.insert(self.foods,food)
end

function Level:InsertActor (a)
    table.insert(self.actors,a)
end


--Set posY to nil to spawn food at the location of a food spawner and pass spawner id as second parameter
function Level:SpawnFood (weight_or_name, posX, posY, spawner_id)
    assert(weight_or_name, "Weight or food name required.")
    local spawner_function = nil
    if type(weight_or_name) == "string" then --by name
        spawner_function = Foods.CreateFood_ByName
    elseif type(weight_or_name) == "number" then
        spawner_function = Foods.CreateFood_ByWeight
    else
        assert(false,"Error spawning food")
    end
    local x, y = posX, posY
    local spawner = spawner_id
    if spawner then
        spawner = self:GetSpawner(spawner_id)
        x, y = spawner:Pos()
    end
    
    local f = spawner_function( x, y, weight_or_name, self )
        
    if spawner then
        f.sprite.angularVelocity = spawner.angular_velocity
        f.sprite:setLinearVelocity ( spawner.velocity:Get() )
    end
    self:InsertFood(f)
end

function Level:SpawnRandomFood (posX, posY, spawner_id)
    self:SpawnFood( self:GetRandomFoodName(), posX, posY, spawner_id)
end

function Level:collision (event)
    
end

function Level:SpawnBag (bag_name, x, y)
    local b = Bags.CreateBag(bag_name, x, y, self)
    b.sprite:addEventListener("collision", self)
    
    table.insert(self.bags,b)
    return b
end

function Level:SetBagCount (bag_count)
    self.bag_count = bag_count
end

function Level:AddGround ()
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


-------------------------------------------------------------------------------
-- Getters and utility functions
-------------------------------------------------------------------------------
function Level:GetSpawner (idx)
    assert( #self.spawn_points > 0, "Create a spawner before spawning food.")
	return self.spawn_points[idx]
end

function Level:GetRandomFoodName ()
    assert( self.food_list and #self.food_list > 0, "Required food name list before." )
    return self.food_list[math.random(#self.food_list)]
end

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

function Level:TimelineSpawnFood (data)
	if (data.wait ~= nil) then
		self:TimelineWait(data.wait)
	end

	local function SpawnFood()
		self:SpawnFood( data.foodName or data.weight, data.x, data.y, data.spawner_id)
	end

	table.insert(self.timeline, SpawnFood)
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