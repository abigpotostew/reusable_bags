--generic food class

local Actor = require"src.actor"
local Vector2 = require 'src.vector2'

local Food = Actor:makeSubclass("Food")

Food:makeInit(function(class, self, x, y, typeInfo, image_name)
	class.super:initWith(self, typeInfo )
    
    self.weight = typeInfo.weight or 1 -- current weight in bag
    
    self.sprite = self:createSprite(image_name or 'apple', x or 0, y or 0)
    self:addPhysics()
    
    return self
end)

return Food