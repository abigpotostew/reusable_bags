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
    world_group:insert(self.sprite)
    self.sprite:addEventListener ("collision", self)
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
            --Prevent the other from calling this same collision method
            --[[local skip_id = self.skip_next_collision_for_id
            if skip_id and (skip_id == other_bag.id) then
                self.skip_next_collision_for_id = 0
                return
            else
                -- Other bag won't run this collision
                other_bag.skip_next_collision_for_id = self.id
            end --]]
            if self.id == colliding_bag.base.id then
                return
            end
            
            --oLog:Debug (self:describe().." colliding with "..colliding_bag:describe())
            
            local last_bag_here = self.bag
            local other_bag_base = colliding_bag.base
            
            --self.last_bag_collision = other_bag.id
            self.bag = colliding_bag
            --other_bag.last_bag_collision = self.id
            colliding_bag.base = self
            
            --oLog:Debug ( string.format("self_state = %s, other_state = %s",self.state.state, other_bag.state.state ) )
            -- Move the last bag to the colliding bag's base
            last_bag_here.state:GoToState(last_bag_here.states.BAG_COLLISION_STATE, other_bag_base)

        elseif event.phase == "ended" then
            
        end
        
	elseif otherName then
		oLog:Verbose("BagBase hit unknown named object: " .. otherName)
	end
end

return BagBase