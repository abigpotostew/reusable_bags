--[[
Project Sunlight
Actor
]]--

--local spSprite = require "src.libs.swiftping.sp_sprite"
local stateMachine = require "src.stateMachine"
local LCS = require "libs.LCS"
local util = require "src.utils.util"
local _ = require "libs.underscore"
local collision = require "src.collision"
local physics = require 'physics'
local Vector2 = require 'src.vector2'

local Actor = LCS.class()

function Actor:init(typeInfo, level)
    assert(level, "Level required to instance an actor")
    
    self.level = level

	self.typeName = typeInfo.typeName or "actor"
	
	-- POSITION access through sprite
    self.position = Vector2()
    
    local actorType = typeInfo or {}
	if actorType then
		self.typeInfo = actorType
	end
    
	self.sprite = nil
	self._timers = {}
    self._transitions = {}
	self._listeners = {}
	
	self.sheet = debugTexturesImageSheet
    
    self.group = nil

	--return self
end

function Actor:createSprite(animName, x, y, scaleX, scaleY, events)
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
	sprite.gravityScale = (self.typeInfo.physics and self.typeInfo.physics.gravityScale) or 0.0
    sprite.alpha = self.typeInfo.alpha or 1.0
    
    self.position:Set(x,y)

	return sprite
end

--???
function Actor:createRectangleSprite (w,h,x,y,strokeWidth)
    assert(self.group,"Please initialize this actor's group before creating a sprite")
    x, y = x or 0, y or 0
    self.sprite = display.newRect(self.group, x, y, w, h)
    self.sprite.owner = self
	self.sprite:setFillColor(1,0,1)
	self.sprite:setStrokeColor(1,0,1)    
    self.sprite.anchorX, self.sprite.anchorY = self.typeInfo.anchorX or 0.5, self.typeInfo.anchorY or 0.5
    if strokeWidth then self.sprite.strokeWidth = strokeWidth end
end

function Actor:buildRectangleSprite (group,w,h,x,y,strokeWidth)
    assert(group,"Please initialize group before creating a sprite")
    x, y = x or 0, y or 0
    local sprite = display.newRect(group, x, y, w, h)
    sprite.owner = self
	sprite:setFillColor(1,0,1)
	sprite:setStrokeColor(1,0,1)    
    sprite.anchorX, sprite.anchorY = self.typeInfo.anchorX or 0.5, self.typeInfo.anchorY or 0.5
    if strokeWidth then sprite.strokeWidth = strokeWidth end
    return sprite
end

function Actor:removeSprite ()
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
end

function Actor:removeSelf ()
    transition.cancel ( self.sprite )
    self._transitions = {}
    
	self:removeSprite()

	for _, _timer in ipairs(self._timers) do
		timer.cancel(_timer)
	end
	self._timers = {}
    
	for _, _listener in ipairs(self._listeners) do
		_listener.object:removeEventListener(_listener.name, _listener.callback)
	end
	self._timers = {}
    
end

function Actor:removePhysics ()
    physics.removeBody( self.sprite )
end

function Actor:addPhysics (data)
    assert(self.sprite, "Actor:addPhysics() - Must have a sprite to add physics to")
	data = data or {}

	local scale = (data.scale or self.typeInfo.scale) * (data.collisionBoxScale or self.typeInfo.collisionBoxScale or 1.0)
    self.phys_body_scale = scale
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
end


--TODO: Timers are never removes from _timers
function Actor:AddTimer( delay, callback, count)
	assert(delay and type(delay) == "number", "addTimer requires that delay be a number")
	assert(callback and (
		type(callback) == "function" or
		(type(callback) == "table" and callback.timer and type(callback.timer) == "function")),
		"addTimer requires a callback that is either a function, or a table with a 'timer' function")
	assert(count == nil or type(count) == "number", "addTimer requires that count be nil or a number")

	table.insert(self._timers, timer.performWithDelay(delay, callback, count))
end

--
function Actor:AddTransition( data, target )
    assert(data and data.time, "Actor:AddTransition(): requires data and time params")
    local ref = transition.to ( target or self.sprite, data )
    table.insert ( self._transitions, ref )
    return ref
end

function Actor:CancelTransition (ref)
    _.reject ( self._transitions, function(i) return i==ref end )
    transition.cancel ( ref )
end

function Actor:addListener (object, name, callback)
	assert(name and type(name) == "string", "addListener requires that name be a string")
	assert(callback and (
		type(callback) == "function" or
		(type(callback) == "table" and callback[name] and type(callback[name]) == "function")),
		"addListener requires that callback be either a function, or a table with a function that has the same name as the event")

	table.insert(self._listeners, {object = object, name = name, callback = callback})
	object:addEventListener(name, callback)
end

function Actor:removeListener (listener)
    _.reject(self._listeners, function(i) return i.name ~= actor end)
end


-- Sprite Event Commands get called during the various event phases for sprites animations:
-- see http://docs.coronalabs.com/api/event/sprite/index.html
function Actor:ClearSpriteEventCommands ()
	self.state.spriteEventCommands = {}
	self.state.spriteEventCommands["end"] = {}
	self.state.spriteEventCommands["loop"] = {}
	self.state.spriteEventCommands["next"] = {}
	self.state.spriteEventCommands["prepare"] = {}
end

function Actor:AddSpriteEventCommand (eventName, command)
	self.state.spriteEventCommands[eventName] = self.state.spriteEventCommands[eventName] or {}
	table.insert(self.state.spriteEventCommands[eventName], command)
end

-- Commands called may add new commands, so before we call anything, reassign to an empty list
function Actor:ProcessSpriteEvent (event)
	local commands = self.state.spriteEventCommands[event.phase]
	self.state.spriteEventCommands[event.phase] = {}

	for _, command in ipairs(commands) do
		command()
	end
end


-- Call after the actor's sprite has been created
function Actor:SetupStateMachine ()
	self.state = stateMachine.Create()
	self:ClearSpriteEventCommands()
	self.sprite:addEventListener("sprite", function(event) self:ProcessSpriteEvent(event) end)
end

function Actor:GetState ()
	if (self.state ~= nil) then
		local stateName, _ = self.state:GetState()
		return stateName
	else
		return nil
	end
end

function Actor:x ()
    assert(self.sprite,"Sprite mustn't be null when accessing x position")
    return self.sprite.x
end

function Actor:y ()
    assert(self.sprite,"Sprite mustn't be null when accessing y position")
    return self.sprite.y
end

function Actor:posVector ()
	assert(self.sprite,"Sprite mustn't be null when accessing pos")
	return Vector2(self:x(),self:y())
end

function Actor:pos ()
    assert(self.sprite,"Sprite mustn't be null when accessing pos")
	return self:x(), self:y()
end

function Actor:setPos (x, y)
	assert(self.sprite,"Sprite mustn't be null when accessing pos")
    if Vector2.isVector2(x) then
        self.sprite.x, self.sprite.y = x.x, x.y
    else
        self.sprite.x, self.sprite.y = x, y
    end
end

function Actor:update (...)
    if self.updateFunc then
        self.updateFunc(self,unpack(arg))
    end
end

function Actor:SetState(state)
    assert(self.state, "Actor:SetState(): requires state machine member.")
    self.state:GoToState(state)
end


return Actor
