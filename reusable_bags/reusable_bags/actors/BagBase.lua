-- BagBase for collisions when draggin bag around


local Actor = require "opal.src.actor"
local Vector2 = require 'opal.src.vector2'

local BagBase = Actor:extends()

function BagBase:init(x, y, w, h, level)
    oAssert.multi_type ("number", "BagBase(): requires x, y, w, & h numbers", x, y, w, h)
    local b = self:NewTypeInfo()
    b.typeName = "bag_base"
    b.physics.category = 'bag_base'
    b.physics.colliders = {'bag_collider'}
    b.physics.bodyType = 'static'
    b.physics.isSensor = true
	self:super("init", b, level )
    
    --self.original_position = Vector2(x,y)
    
    local world_group = self.level:GetWorldGroup()
    self.group = world_group
    
    self:createRectangleSprite (w, h, x, y, {fill_color={1,0,1,0}})
    
    self:addPhysics()
    level:InsertActor(self)
    self:AddEventListener (self.sprite, "collision", self)
end

-----------------------------------------------------------------------------------------
-- Events for bag
----------------------------------------------------------------------------------------

function BagBase:collision (event)

	local other = event.other
	local otherName = other.typeName
	local otherOwner = other.owner

	if (otherOwner ~= nil) then
		otherName = otherOwner.typeName
	end

        
    ---------------------------
    -- BAG COLLISION
    ---------------------------
    if otherName == "bag_collider" then
        --SELF IS THE ONE THAT MOVES INTO THE STATIONARY BAG
        --swap positions of bags
        
        local colliding_bag = otherOwner.bag
        
        if event.phase == "began" then
            if self.id == colliding_bag.base.id then
                return
            end
            
            local last_bag_here = self.bag
            local other_bag_base = colliding_bag.base
            
            self.bag = colliding_bag
            colliding_bag.base = self
            
            -- Move the last bag to the colliding bag's base
            last_bag_here.state:GoToState(last_bag_here.states.BAG_COLLISION_STATE, other_bag_base)

        elseif event.phase == "ended" then
            
        end
        
	elseif otherName then
		oLog.Verbose("BagBase hit unknown named object: " .. otherName)
	end
end

return BagBase