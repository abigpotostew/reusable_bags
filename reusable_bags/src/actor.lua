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

Actor:makeInit(function(class, self, typeInfo, level)
    assert(level, "Level required to instance an actor")
	class.super:initWith(self)
    
    self.level = level

	self.typeName = typeInfo.typeName or "actor"
	
	-- POSITION access through sprite
    self.position = Vector2:init()
    
    local actorType = typeInfo or {}
	if actorType then
		self.typeInfo = actorType
	end
    
	self.sprite = nil
	self._timers = {}
	self._listeners = {}
	
	self.sheet = debugTexturesImageSheet
    
    self.group = nil

	return self
end)

Actor.createSprite = Actor:makeMethod(function(self, animName, x, y, scaleX, scaleY, events)
	assert(animName, "You must provide an anim name when creating an actor sprite")
	assert(x and y, "You must specify a position when creating an actor sprite")

	scaleX = scaleX or self.typeInfo.scale or 1
	scaleY = scaleY or self.typeInfo.scale or 1

	local sprite = display.newImage( debugTexturesImageSheet , debugTexturesSheetInfo:getFrameIndex(animName))

	sprite.anchorX, sprite.anchorY = self.anchorX or 0.5, self.anchorY or  0.5
	sprite.owner = self
	sprite.x, sprite.y = x, y
	sprite:scale(scaleX, scaleY)
	sprite.radiousSprite = nil
	sprite.gravityScale = self.typeInfo.physics.gravityScale or 0.0
    sprite.alpha = self.typeInfo.alpha or 1.0
    
    self.position:set(x,y)

	return sprite
end)

Actor.createRectangleSprite = Actor:makeMethod(function(self,w,h,x,y,strokeWidth)
    assert(self.group,"Please initialize this actor's group before creating a sprite")
    x, y = x or 0, y or 0
    self.sprite = display.newRect(self.group, x, y, w, h)
    self.sprite.actor = self
	self.sprite:setFillColor(1,0,1)
	self.sprite:setStrokeColor(1,0,1)    
    self.sprite.anchorX, self.sprite.anchorY = self.typeInfo.anchorX or 0.5, self.typeInfo.anchorY or 0.5
    if strokeWidth then self.sprite.strokeWidth = strokeWidth end
end)

Actor.removeSprite = Actor:makeMethod(function(self)
	if (self.sprite and self.sprite.disposed == nil or self.sprite.disposed == false) then
		--self.sprite:clearEventListeners()
		--TODO: may not be clearing event listeners properly here since above func is from other sprite class
		self.sprite:removeSelf()
		self.sprite.disposed = true
        self.sprite = nil
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

Actor.removePhysics = Actor:makeMethod(function(self)
    physics.removeBody( self.sprite )
end)

Actor.addPhysics = Actor:makeMethod(function(self, data)
    assert(self.sprite, "Actor:addPhysics() - Must have a sprite to add physics to")
	data = data or {}

	local scale = (data.scale or self.typeInfo.scale) * (data.collisionBoxScale or self.typeInfo.collisionBoxScale or 1.0)
	local mass = data.mass or self.typeInfo.physics.mass

	local phys = {
		density = 1, --we don't care about density
		friction = data.friction or self.typeInfo.physics.friction,
		bounce = data.bounce or self.typeInfo.physics.bounce,
		filter = collision.MakeFilter(data.category or self.typeInfo.physics.category,
			data.colliders or self.typeInfo.physics.colliders or nil),
		isSensor = data.isSensor or self.typeInfo.physics.isSensor or false,
        bodyType = data.bodyType or self.typeInfo.physics.bodyType or "kinematic",
        radius = data.radius or self.typeInfo.physics.radius or nil
	}
    --Optionally set a custom shape for the actor. Default uses sprite to shape it
    if data.shape or self.typeInfo.physics.shape then
        phys.shape = data.shape or self.typeInfo.physics.shape
    end
    
    --create a rectangular body if the sprite is scaled
    if not phys.shape and scale ~= 1.0 then
        if phys.radius then
            phys.radius = phys.radius * scale
        else
            local hW = scale * 2*self.sprite.contentWidth
            local hH = scale * 2*self.sprite.contentHeight
            phys.shape = {hW, -hH, hW, hH, -hW, hH, -hW, -hH}
        end
    end

	physics.addBody(self.sprite, phys.bodyType, phys)
    
    self.sprite.gravityScale = data.gravityScale or self.typeInfo.physics.gravityScale or 1.0
end)

local function addTimer(self, delay, callback, count)
	assert(delay and type(delay) == "number", "addTimer requires that delay be a number")
	assert(callback and (
		type(callback) == "function" or
		(type(callback) == "table" and callback.timer and type(callback.timer) == "function")),
		"addTimer requires a callback that is either a function, or a table with a 'timer' function")
	assert(count == nil or type(count) == "number", "addTimer requires that count be nil or a number")

	table.insert(self._timers, timer.performWithDelay(delay, callback, count))
end
Actor.addTimer = Actor:makeMethod(addTimer)

Actor.addListener = Actor:makeMethod(function(self, object, name, callback)
	assert(name and type(name) == "string", "addListener requires that name be a string")
	assert(callback and (
		type(callback) == "function" or
		(type(callback) == "table" and callback[name] and type(callback[name]) == "function")),
		"addListener requires that callback be either a function, or a table with a function that has the same name as the event")

	table.insert(self._listeners, {object = object, name = name, callback = callback})
	object:addEventListener(name, callback)
end)


-- Sprite Event Commands get called during the various event phases for sprites animations:
-- see http://docs.coronalabs.com/api/event/sprite/index.html
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

Actor.posVector = Actor:makeMethod(function(self)
	assert(self.sprite,"Sprite mustn't be null when accessing pos")
	return Vector2:init(self:x(),self:y())
end)

Actor.pos = Actor:makeMethod(function(self)
    assert(self.sprite,"Sprite mustn't be null when accessing pos")
	return self:x(), self:y()
end)

Actor.setPos = Actor:makeMethod(function(self, x, y)
	assert(self.sprite,"Sprite mustn't be null when accessing pos")
    if Vector2:isVector2(x) then
        self.sprite.x, self.sprite.y = x.x, x.y
    else
        self.sprite.x, self.sprite.y = x, y
    end
end)

Actor.update = Actor:makeMethod(function(self,...)
    if self.updateFunc then
        self.updateFunc(self,unpack(arg))
    end
end)


return Actor
