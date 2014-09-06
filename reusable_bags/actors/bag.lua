--bag


local Actor = require "src.actor"
local Vector2 = require 'src.vector2'
local Food = require "actors.food"

local bag_states = {NORMAL="normal",FOOD_COLLISION_STATE="food_collision", BAG_FULL="bag_full", BAG_COLLISION_STATE="bag_collision"}

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
    
    self:addCollisionSensor()
    
    --Store the position under the food spawner
    self.original_position = Vector2(x,y)
    self.skip_next_collision_for_id = 0
    
    self:SetupStateMachine()
	self:SetupStates()
	self.state:GoToState("normal")
    
    self.timer = 0
    
    
    self.sprite:addEventListener("touch", self)
    
    --return self
end

function Bag:describe()
    return self.typeName .. "$" .. self.id
end

--This isn't creating sensor to the proper size
--sensor should be slightly bigger than the bag
function Bag:addCollisionSensor()
    local collider = Actor({typeName="bag_collider",physics={}}, self.level)
    collider.group = self.group
    collider:createRectangleSprite (
         self.typeInfo.collisionBoxScale*self.sprite.contentWidth, 
         self.typeInfo.collisionBoxScale*self.sprite.contentHeight, 
        self:Pos() ) -- returns x,y
    
    collider:addPhysics({
            bodyType="dynamic", 
            isSensor=true, 
            scale=1.0, 
            collisionBoxScale=1.0, 
            category = "bag_collider",
            colliders= {"food", "bag"} })
    
    local joint = physics.newJoint ("weld",
        self.sprite, collider.sprite, self:Pos() )
    joint.dampingRatio = 1
    joint.frequency = 10000000
    
    self.collision_sensor = {joint=joint, collider=collider}
    
	collider.sprite:addEventListener("collision", self)
end

function Bag:CanFitWeight (itemWeight)
    return ((itemWeight + self.weight) <= self.capacity)
end

function Bag:AddItem (item)
    assert(item and item.typeName == "food", "item must be an food actor")
    
    item.bag_target = {}
    item.bag_target.x, item.bag_target.y = self:Pos() 
    item:SetState(Food.states.BAG_COLLISION_STATE, self)
    
    self.weight = item.weight + self.weight
    
    --self.level:RemoveActor(item)
end


-----------------------------------------------------------------------------------------
-- Events for bag
----------------------------------------------------------------------------------------

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

    ---------------------------
    -- FOOD COLLISION
    ---------------------------
	if (otherName == "food") then
        Log:Debug (self:describe().." colliding with "..otherOwner:describe())
        self.state:GoToState(self.states.FOOD_COLLISION_STATE, otherOwner)
        
    ---------------------------
    -- BAG COLLISION
    ---------------------------
    elseif otherName == "bag" then
        --SELF IS THE ONE THAT MOVES INTO THE STATIONARY BAG
        --swap positions of bags
        local other_bag = otherOwner
        
        if event.phase == "began" then
            --Prevent the other from calling this same collision method
            local skip_id = self.skip_next_collision_for_id
            if skip_id and (skip_id == other_bag.id) then
                self.skip_next_collision_for_id = 0
                return
            else
                -- Other bag won't run this collision
                other_bag.skip_next_collision_for_id = self.id
            end
            
            Log:Debug (self:describe().." colliding with "..other_bag:describe())
            self.last_bag_collision = other_bag.id
            other_bag.last_bag_collision = self.id
            
            Log:Debug ( string.format("self_state = %s, other_state = %s",self.state.state, other_bag.state.state ) )
            self.state:GoToState(self.states.BAG_COLLISION_STATE, other_bag)

        elseif event.phase == "ended" then
            
        end
        
	elseif otherName then
		Log:Verbose("Bag hit unknown named object: " .. otherName)
	end
end

function Bag:touch (event)
    local body = event.target
    local bag = body.owner
    if event.phase == "began" then
        display.getCurrentStage():setFocus (body)
        body.has_focus = true
    elseif event.phase == "moved" then
        bag:SetPos (event.x, bag:y())
    elseif event.phase == "ended" then
        self:SlideToPosition (self.original_position:Get())
        display.getCurrentStage():setFocus (nil)
        event.target.has_focus = false
    end
end

function Bag:update(dt)
    --Update position for overall changes in bag position
    --self:setPos(self.position + {x = 0, y = -25*math.abs(math.sin(Time:ElapsedTime()/10))})
end

function Bag:SlideToPosition (x, y, onComplete)
    self:AddTransition ({
            x = x,
            y = y,
            time=500,
            transition=easing.inOutSine,
            tag="bag_slide",
            onComplete = onComplete })
end


function Bag:SetupStates ()

	self.state:SetState(self.states.NORMAL, {
		enter = function()
            
		end
	})

    self.state:SetState(self.states.FOOD_COLLISION_STATE, {
        enter = function(food)
            if food.removed then 
                return
            end --i dont think i need this
        
            if self:CanFitWeight (food:GetWeight()) then
                self:AddItem(food)
                
                self.state:GoToState(self.states.NORMAL)
            else
                self.state:GoToState(self.states.BAG_FULL)
                print(self:describe().." full!")
            end
        end
            
    })
    
    self.state:SetState(self.states.BAG_COLLISION_STATE, {
		enter = function(other_bag)
            local tmp = other_bag.original_position
            other_bag.original_position = self.original_position
			self.original_position = tmp
            self:SlideToPosition (self.original_position:Get()) --function() self.original_position=-1 end)
            self.state:GoToState(self.states.NORMAL)
		end,
        exit= function()
            
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