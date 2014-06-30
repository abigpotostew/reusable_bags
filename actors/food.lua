--generic food class

local Actor = require"src.actor"
local Vector2 = require 'src.vector2'

local Food = Actor:makeSubclass("Food")

Food:makeInit(function(class, self, x, y, typeInfo, image_name, level)
	class.super:initWith(self, typeInfo, level )
    
    self.weight = typeInfo.weight or 1 -- current weight in bag
    
    self.foodType = typeInfo.foodType
    
    self.sprite = self:createSprite(image_name or 'apple', x or 0, y or 0)
    self:addPhysics()
    self.sprite.gravityScale = typeInfo.physics.gravityScale
    local world_group = self.level:GetWorldGroup()
    world_group:insert(self.sprite)
    self.group = world_group
    
    return self
end)

Food.GetWeight = Food:makeMethod(function(self)
    return self.weight
end)

return Food