--[[
Project Sunlight
Actor
]]--

--local spSprite = require "src.libs.swiftping.sp_sprite"
local stateMachine = require "src.stateMachine"
local class = require "src.class"
local util = require "src.util"
local collision = require "src.collision"
local physics = require 'physics'
local Vector2 = require 'src.vector2'

local Actor = class:makeSubclass("Actor")

Actor:makeInit(function(class, self, x, y)
	class.super:initWith(self)

	self.typeName = "actor"

	self.hitCount = 0
    self.health = 1
    self.originalHealth = self.health
	
	-- POSITION access through sprite
    
    local actorType={}
	if actorType then
		self.typeInfo = actorType
	else
		self.typeInfo = {}
		self.typeInfo.hitHoldAnims = {}
	end
	self.sprite = nil
	self._timers = {}
	self._listeners = {}
	
	self.sheet = debugTexturesImageSheet
    
    self.group = nil
    --self.grid = nil -- associated grid that this actor is in

	return self
end)

Actor.createSprite = Actor:makeMethod(function(self, animName, x, y, scaleX, scaleY, events)
	assert(animName, "You must provide an anim name when creating an actor sprite")
	assert(x and y, "You must specify a position when creating an actor sprite")

	scaleX = scaleX or 1
	scaleY = scaleY or 1

	--local sprite = spSprite.init(self.typeInfo.animSet, animName, events)
	local sprite = display.newImage( debugTexturesImageSheet , debugTexturesSheetInfo:getFrameIndex(animName))
	--self.sheet, self.sequenceData
    --sprite:setReferencePoint( display.TopLeftReferencePoint )
	sprite.anchorX, sprite.anchorY = 0.5, 0.5
	sprite.owner = self
	sprite.x, sprite.y = x, y
	sprite:scale(scaleX, scaleY)
	sprite.radiousSprite = nil
	sprite.gravityScale = 0.0

	return sprite
end)

Actor.createRectangleSprite = Actor:makeMethod(function(self,w,h,strokeWidth)
    assert(self.group,"Please initialize this actor's group before creating a sprite")
    local x, y = self.X*sun.tileWidth, self.Y*sun.tileHeight
    self.sprite = display.newRect(self.group, x-w/2, y-h/2, w, h)
    self.sprite.actor = self
	self.sprite:setFillColor(1,0,1)
	self.sprite:setStrokeColor(1,0,1)    
    if strokeWidth then self.sprite.strokeWidth = strokeWidth end
end)

Actor.removeSprite = Actor:makeMethod(function(self)
	if (self.sprite and self.sprite.disposed == nil or self.sprite.disposed == false) then
		--self.sprite:clearEventListeners()
		--TODO: may not be clearing event listeners properly here since above func is from other sprite class
		self.sprite:removeSelf()
		self.sprite.disposed = true
	else
		print("WARNING: Attempting to remove a nonexistant or already-disposed sprite!")
		print(debug.traceback())
	end
end)

Actor.removeSelf = Actor:makeMethod(function(self)
	self:removeSprite()

	for _, _timer in ipairs(self._timers) do
		timer.cancel(_timer)
	end
	self._timers = {}

	for _, _listener in ipairs(self._listeners) do
		_listener.object:removeEventListener(_listener.name, _listener.callback)
	end
	self._timers = {}
end)

Actor.addPhysics = Actor:makeMethod(function(self, data)
	data = data or {}

	local scale = data.scale or self.typeInfo.scale
	local mass = data.mass or self.typeInfo.physics.mass

	local phys = {
		density = 1, --we don't care about density
		friction = data.friction or self.typeInfo.physics.friction,
		bounce = data.bounce or self.typeInfo.physics.bounce,
		filter = collision.MakeFilter(data.category or self.typeInfo.physics.category,
			data.colliders or self.typeInfo.physics.colliders),
		isSensor = data.isSensor or self.typeInfo.physics.isSensor or true,
        bodyType = data.bodyType or self.typeInfo.physics.bodyType or "kinematic"
	}
    --Optionally set a custom shape for the actor. Default uses sprite to shape it
    if data.shape or self.typeInfo.physics.shape then
        phys.shape = data.shape or self.typeInfo.physics.shape
    end    

	physics.addBody(self.sprite, phys)
end)

Actor.addKinematicSensor = Actor:makeMethod(function(self, data)
    data = data or {}

	local scale = data.scale or 1
	local mass = data.mass or 1

	local phys = {
		density = 1, --we don't care about density
		friction = data.friction or 0.5,
		bounce = data.bounce or 0.75,
		filter = collision.MakeFilter(data.category or "food",
			data.colliders or {"bag", "head"}),
		isSensor = data.isSensor or true,
        bodyType = data.bodyType or self.typeInfo.physics.bodyType or "kinematic"
	}
    --Optionally set a custom shape for the actor. Default uses sprite to shape it
    if data.shape or self.typeInfo.physics.shape then
        phys.shape = data.shape or self.typeInfo.physics.shape
    end    

	physics.addBody(self.sprite, phys)
        
end)

Actor.addTimer = Actor:makeMethod(function(self, delay, callback, count)
	assert(delay and type(delay) == "number", "addTimer requires that delay be a number")
	assert(callback and (
		type(callback) == "function" or
		(type(callback) == "table" and callback.timer and type(callback.timer) == "function")),
		"addTimer requires a callback that is either a function, or a table with a 'timer' function")
	assert(count == nil or type(count) == "number", "addTimer requires that count be nil or a number")

	table.insert(self._timers, timer.performWithDelay(delay, callback, count))
end)

Actor.addListener = Actor:makeMethod(function(self, object, name, callback)
	assert(name and type(name) == "string", "addListener requires that name be a string")
	assert(callback and (
		type(callback) == "function" or
		(type(callback) == "table" and callback[name] and type(callback[name]) == "function")),
		"addListener requires that callback be either a function, or a table with a function that has the same name as the event")

	table.insert(self._listeners, {object = object, name = name, callback = callback})
	object:addEventListener(name, callback)
end)

Actor.ClearSpriteEventCommands = Actor:makeMethod(function(self)
	self.state.spriteEventCommands = {}
	self.state.spriteEventCommands["end"] = {}
	self.state.spriteEventCommands["loop"] = {}
	self.state.spriteEventCommands["next"] = {}
	self.state.spriteEventCommands["prepare"] = {}
end)

Actor.AddSpriteEventCommand = Actor:makeMethod(function(self, eventName, command)
	self.state.spriteEventCommands[eventName] = self.state.spriteEventCommands[eventName] or {}
	table.insert(self.state.spriteEventCommands[eventName], command)
end)

-- Commands called may add new commands, so before we call anything, reassign to an empty list
Actor.ProcessSpriteEvent = Actor:makeMethod(function(self, event)
	local commands = self.state.spriteEventCommands[event.phase]
	self.state.spriteEventCommands[event.phase] = {}

	for _, command in ipairs(commands) do
		command()
	end
end)

-- Call after the actor's sprite has been created
Actor.SetupStateMachine = Actor:makeMethod(function(self)
	self.state = stateMachine.Create()
	self:ClearSpriteEventCommands()
	self.sprite:addEventListener("sprite", function(event) self:ProcessSpriteEvent(event) end)
end)

Actor.GetState = Actor:makeMethod(function(self)
	if (self.state ~= nil) then
		local stateName, _ = self.state:GetState()
		return stateName
	else
		return nil
	end
end)

Actor.x = Actor:makeMethod(function(self)
    assert(self.sprite,"Sprite mustn't be null when accessing x position")
    return self.sprite.x
end)

Actor.y = Actor:makeMethod(function(self)
    assert(self.sprite,"Sprite mustn't be null when accessing y position")
    return self.sprite.y
end)

Actor.pos = Actor:makeMethod(function(self)
	assert(self.sprite,"Sprite mustn't be null when accessing pos")
	return Vector2:init(self:x(),self:y())
end)

Actor.dispose = Actor:makeMethod(function(self)
	if self.sprite then
		self.sprite:removeSelf()
		self.sprite = nil
	end
end)

--TODO: add more checks here
Actor.canOverlapWith = Actor:makeMethod(function(self,actorOther)
	if not actorOther then return false end
	if actorOther.typeName == "building" then return false end
	return true
end)

Actor.update = Actor:makeMethod(function(self,...)
    if self.updateFunc then
        self.updateFunc(self,unpack(arg))
    end
end)

return Actor
