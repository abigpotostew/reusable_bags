--generic food class

local Actor = require"src.actor"
local Vector2 = require 'src.vector2'

local Food = Actor:makeSubclass("Food")

Food:makeInit(function(class, self, x, y, typeInfo, image_name, level)
    assert(image_name, "Image required to instance food.")
	class.super:initWith(self, typeInfo, level )
    
    self.weight = typeInfo.weight or 1 -- current weight in bag
    
    self.sprite = self:createSprite("food_"..image_name, x or 0, y or 0)
    self:addPhysics()
    self.sprite.gravityScale = typeInfo.physics.gravityScale
    local world_group = self.level:GetWorldGroup()
    world_group:insert(self.sprite)
    self.group = world_group
    
    self:SetupStateMachine()
	self:SetupStates()
	self.state:GoToState("normal")
    
    self:addListener(self.sprite, "touch", self)
    
    return self
end)

Food.SetupStates = Food:makeMethod(function(self)

	self.state:SetState("hurt", {
		enter = function()
			--self.sprite:play("hurt", false)
			-- TODO: Hack, will stomp other changes - write a delay into the events queue
			--self:addTimer(self.typeInfo.hurtDuration * 1000, function() self.state:GoToState("normal") end)
		end
	})

	self.state:SetState("normal", {
		enter = function()
			--self.sprite:play("normal")
		end
		--onBirdHit = function(bird)
		--	self.state:GoToState("hit")
		--end
	})

	self.state:SetState("dying", {
		enter = function()
			--self.sprite:play("death", false)
			--self:ClearSpriteEventCommands()
			--self:AddSpriteEventCommand("end", function() self.state:GoToState("dead") end)
		end
	})

	self.state:SetState("dead", {
		enter = function()
			--self:CreateExplosion("deathParticle")
			self.level:RemoveActor(self)
		end
	})

end)

Food.GetWeight = Food:makeMethod(function(self)
    return self.weight
end)

local touch = function(self,event)
    if event.phase == "began" then
        event.target.joint = physics.newJoint( "touch", event.target, event.x, event.y )
        event.target.joint.frequency = 2 --low frequency, makes it more floaty
        event.target.joint.dampingRatio = 1 --max damping, doesn't bounce against joint
        display.getCurrentStage():setFocus( event.target )
    elseif event.phase == "moved" then
        event.target.joint:setTarget(event.x, event.y)
    elseif event.phase == "ended" then
        if not event.target.joint then
            print('oh god')
        end
        event.target.joint:removeSelf()
        display.getCurrentStage():setFocus( nil )
    end 
end
Food.touch = Food:makeMethod(touch)

return Food