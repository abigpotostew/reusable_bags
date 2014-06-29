--bag

local physics = require "physics"

local Actor = require"src.actor"
local Vector2 = require 'src.vector2'

local Bag = class:makeSubclass("Actor")

Bag:makeInit(function(class, self)
	class.super:initWith(self)
    
    self.capacity = 1
    
    self.weight = 0
    
end)