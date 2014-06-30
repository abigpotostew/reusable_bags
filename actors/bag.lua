--bag


local Actor = require"src.actor"
local Vector2 = require 'src.vector2'

local Bag = Actor:makeSubclass("Bag")

Bag:makeInit(function(class, self, x, y, typeInfo)
	class.super:initWith(self, typeInfo )
    
    self.capacity = typeInfo.capacity or 1
    self.weight = typeInfo.weight or 0 -- current weight in bag
    
    typeInfo.physics.gravityScale = 0
    
    self.sprite = self:createSprite(string.format("%s_bag",self.typeName), x or 0, y or 0)
    self:addPhysics()
    
    return self
    
end)

return Bag