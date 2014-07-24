--bag


local Actor = require "src.actor"
local Vector2 = require 'src.vector2'
local Food = require "actors.food"

local bag_states = {NORMAL="normal",FOOD_COLLISION_STATE="food_collision", BAG_FULL="bag_full"}

local Bag = Actor:extends({states = bag_states})

function Bag:init(x, y, typeInfo, level)
	self:super("init", typeInfo, level )
    
    self.capacity = typeInfo.capacity or 1
    self.weight = typeInfo.weight or 0 -- current weight in bag
    
    self.bagType = typeInfo.bagType
    
    
    self.sprite = self:createSprite(string.format("bag_%s",self.bagType), x or 0, y or 0)
    self:addPhysics()
    self.sprite.gravityScale = 0
    local world_group = self.level:GetWorldGroup()
    world_group:insert(self.sprite)
    self.group = world_group
    
	self.sprite:addEventListener("collision", self)
    
    self:SetupStateMachine()
	self:SetupStates()
	self.state:GoToState("normal")
    
    self.timer = 0
    
    --return self
end

function Bag:CanFitWeight (itemWeight)
    return ((itemWeight + self.weight) <= self.capacity)
end

function Bag:AddItem (item)
    assert(item and item.typeName == "food", "item must be an food actor")
    
    item.bag_target = {}
    item.bag_target.x, item.bag_target.y = self:pos() 
    item:SetState(Food.states.BAG_COLLISION_STATE)
    
    self.weight = item.weight + self.weight
    
    --self.level:RemoveActor(item)
end

function Bag:collision (event)

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
        self.state:GoToState(self.states.FOOD_COLLISION_STATE, otherOwner)
	elseif otherName then
		print("Bag hit unknown named object: " .. otherName)
	end
end

function Bag:update(dt)
    --Update position for overall changes in bag position
    self:setPos(self.position + {x = 0, y = -25*math.abs(math.sin(Time:ElapsedTime()/10))})
end


function Bag:SetupStates ()

	self.state:SetState(self.states.NORMAL, {
		enter = function()
            
		end
	})

    self.state:SetState(self.states.FOOD_COLLISION_STATE, {
        enter = function(food)
            if food.removed then return end --i dont think i need this

            if self:CanFitWeight (food:GetWeight()) then
                self:AddItem(food)
            end
        end
            
    })
    

	self.state:SetState(self.states.BAG_FULL, {
		enter = function()
			--set
		end,
        exit= function()
            return false --can't ever leave this state
        end
	})

end

return Bag