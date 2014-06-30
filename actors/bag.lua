--bag


local Actor = require"src.actor"
local Vector2 = require 'src.vector2'

local Bag = Actor:makeSubclass("Bag")

Bag:makeInit(function(class, self, x, y, typeInfo, level)
	class.super:initWith(self, typeInfo, level )
    
    self.capacity = typeInfo.capacity or 1
    self.weight = typeInfo.weight or 0 -- current weight in bag
    
    self.bagType = typeInfo.bagType
    
    
    self.sprite = self:createSprite(string.format("%s_bag",self.bagType), x or 0, y or 0)
    self:addPhysics()
    self.sprite.gravityScale = 0
    local world_group = self.level:GetWorldGroup()
    world_group:insert(self.sprite)
    self.group = world_group
    
    self.sprite.collision = function(self, event)
        --self:OnBagCollision(self, event) 
    end
	self.sprite:addEventListener("collision", self)
    
    return self
    
end)

Bag.CanFitWeight = Bag:makeMethod(function(self, itemWeight)
    return ((itemWeight + self.weight) <= self.capacity)
end)

Bag.AddItem = Bag:makeMethod(function(self, item)
    assert(item and item.typeName == "food", "item must be an food actor")
    
    self.weight = item.weight + self.weight
    
    item:removeSelf()
end)

Bag.collision = Bag:makeMethod(function(self, event)

	if (event.phase == "ended") then
		return
	end

	local other = event.other
	local otherName = other.typeName
	local otherOwner = other.owner

	if (otherOwner ~= nil) then
		otherName = otherOwner.typeName
	end

	if (otherName == "food") then
		if self:CanFitWeight (otherOwner:GetWeight()) then
            self:AddItem(otherOwner)
        end
	elseif otherName then
		print("Bag hit unknown named object: " .. otherName)
	end
end)



return Bag