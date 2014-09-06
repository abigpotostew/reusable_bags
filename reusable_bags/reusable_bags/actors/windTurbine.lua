--bag


local Actor = require "opal.src.actor"
local Vector2 = require 'opal.src.vector2'

local turbine_states = {NORMAL="normal",FOOD_COLLISION_STATE="food_collision", BAG_FULL="bag_full"}

local WindTurbine = Actor:extends({states = turbine_states})

function WindTurbine:init(x, y, typeInfo, level)
    typeInfo = {}
    typeInfo.scale = 1
    typeInfo.physics ={}
    typeInfo.typeName = "wind_turbine"
	self:super("init", typeInfo, level )
    
    
    self.sprite = self:createSprite("food_pizza", x or 200, y or 200)
    self:addPhysics({bodyType="dynamic"})
    self.sprite.gravityScale = 0
    local world_group = self.level:GetWorldGroup()
    world_group:insert(self.sprite)
    self.group = world_group
    
    self.anchor_body = Actor({typeName="actor", physics={}, scale = 1}, level)
    self.anchor_body.group = world_group
    self.anchor_body:createRectangleSprite(10,10,x,y,3)
    self.anchor_body:addPhysics({bodyType="static", category="nothing"})
    
    self.pivotJoint = physics.newJoint( "pivot", self.sprite, self.anchor_body.sprite, x, y )
    self.pivotJoint.isMotorEnabled = true
    self.pivotJoint.maxMotorTorque = 100000
    self.pivotJoint.motorSpeed = 100000
    
	
    self:addListener(self.sprite, "touch", self)
    self:addListener(self.sprite, "enterFrame", self)

end


function WindTurbine:CancelTouch()
    if self.sprite.joint then
        self.sprite.joint:removeSelf()
        self.sprite.joint = nil
    end
    if self.sprite.has_focus then
        display.getCurrentStage():setFocus( nil )
        self.sprite.has_focus = false
    end
end



function WindTurbine:touch (event)
    if event.phase == "began" then
        event.target.joint = physics.newJoint( "touch", event.target, event.x, event.y )
        event.target.joint.frequency = 2 --low frequency, makes it more floaty
        event.target.joint.dampingRatio = 1 --max damping, doesn't bounce against joint
        display.getCurrentStage():setFocus( event.target )
        event.target.has_focus = true
    elseif event.phase == "moved" then
        if not event.target.joint then --we may have removed another food and finger slid to this food
            return false
        end
        event.target.joint:setTarget(event.x, event.y)
    elseif event.phase == "ended" then
        self:CancelTouch()
    end 
    return true
end


function WindTurbine:enterFrame(dt)
    --Update position for overall changes in bag position
    
end


return WindTurbine