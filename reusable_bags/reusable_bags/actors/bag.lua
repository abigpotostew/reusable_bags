--bag


local Actor = require "opal.src.actor"
local Vector2 = require 'opal.src.vector2'
local Food = require "reusable_bags.actors.food"

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
    --self.original_position = Vector2(x,y) --DO I NEED THIS ANYMORE?
    --self.skip_next_collision_for_id = 0
    
    self:SetupStateMachine()
	self:SetupStates()
	self.state:GoToState("normal")
    
    self.timer = 0
    
    self:AddCapacityUI()
    
    self:AddEventListener(self.sprite, "touch", self)
    
    --return self
end

function Bag:describe()
    return self.typeName .. "$" .. self.id
end

function Bag:AddCapacityUI ()
    local UIgroup = display.newGroup ()
    UIgroup.x, UIgroup.y = self:Pos()
    
    local bag_w, bag_h = self:Dimensions()
    bag_h = bag_h + 20
    bag_w = bag_w * 2
    local bar_w, bar_h = bag_w, 10
    
    
    local outline = display.newRect ( UIgroup, 0, bag_h, bar_w, bar_h )
    outline.strokeWidth = 1
    outline:setFillColor( 0,0,0,0 )
    outline:setStrokeColor( 1, 0, 0 )
    
    local bar_fill_w = bar_w-2
    local bar     = display.newRect ( UIgroup, -bar_fill_w/2, bag_h, bar_fill_w, bar_h-2 )
    bar.strokeWidth = 0
    bar:setFillColor( 0, 1, 0 ) 
    bar.o_width = bar_fill_w
    bar.anchorX=0
    bar.width = 0
    UIgroup.bar = bar
    
    
    for i=1,self.capacity-1 do
        local x = bar_fill_w/self.capacity * i - bar_fill_w/2
        display.newLine (UIgroup, x, bar_h/2+bag_h, x, -bar_h/2+bag_h)
    end
    
    self.group:insert(UIgroup)
    self.UIgroup = UIgroup
    --self.sprite:insert (UIgroup)
end

--This isn't creating sensor to the proper size
--sensor should be slightly bigger than the bag
function Bag:addCollisionSensor()
    local collider = Actor({typeName="bag_collider"}, self.level)
    collider.group = self.group
    collider:createRectangleSprite (
         self.typeInfo.collisionBoxScale*self.sprite.contentWidth, 
         self.typeInfo.collisionBoxScale*self.sprite.contentHeight, 
        self:x(), self:y(),
        
        {fill_color={1,0,1,1}}) -- returns x,y
    
    collider:addPhysics({
            bodyType="dynamic", 
            isSensor=true, 
            scale=1.0, 
            collisionBoxScale=1.0, 
            category = "bag_collider",
            colliders= {"food", "bag", 'bag_base'} })
    
    local joint = physics.newJoint ("weld",
        self.sprite, collider.sprite, self:Pos() )
    joint.dampingRatio = 1
    joint.frequency = 10000000
    
    collider.bag = self
    
    self.collision_sensor = {joint=joint, collider=collider}
    
    collider:AddEventListener ( collider.sprite, "collision", self )
	--collider.sprite:addEventListener("collision", self)
end

function Bag:Full()
    return self:Capacity() == self:Weight()
end

function Bag:Capacity()
    return self.capacity
end

function Bag:Weight()
    return self.weight
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

--Edit: bags don't handle their own collision anymore
-- See bag_base and bag_collider'
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
        oLog.Debug (self:describe().." colliding with "..otherOwner:describe())
        self.state:GoToState(self.states.FOOD_COLLISION_STATE, otherOwner)
        
    ---------------------------
    -- BAG COLLISION
    ---------------------------
    elseif otherName == "bagdfgd" then
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
            
            oLog.Debug (self:describe().." colliding with "..other_bag:describe())
            self.last_bag_collision = other_bag.id
            other_bag.last_bag_collision = self.id
            
            oLog.Debug ( string.format("self_state = %s, other_state = %s",self.state.state, other_bag.state.state ) )
            self.state:GoToState(self.states.BAG_COLLISION_STATE, other_bag)

        elseif event.phase == "ended" then
            
        end
    
    elseif otherName == "bag_base" then
    
        return
        
	elseif otherName == "bag" then
    
        return
        
	elseif otherName == "bag_collider" then
    
        return
        
	elseif otherName then
		oLog.Verbose("Bag hit unknown named object: " .. otherName)
	end
end

function Bag:touch (event)
    local body = event.target
    local bag = body.owner --also self
    if event.phase == "began" then
        display.getCurrentStage():setFocus (body)
        body.has_focus = true
    elseif event.phase == "moved" then
        bag:SetPos (event.x, bag:y())
        bag.UIgroup.x, bag.UIgroup.y = event.x, bag:y()
    elseif event.phase == "ended" then
        self:SlideToPosition (self.base:Pos())
        display.getCurrentStage():setFocus (nil)
        event.target.has_focus = false
    end
end

function Bag:update(dt)
    --Update position for overall changes in bag position
    --self:setPos(self.position + {x = 0, y = -25*math.abs(math.sin(oTime:ElapsedTime()/10))})
end

function Bag:SlideToPosition (x, y, onComplete)
    self.slide_transition_ref =
    self:AddTransition ({
            x = x,
            y = y,
            time=500,
            transition=easing.inOutSine,
            tag="bag_slide",
            onComplete = onComplete })
    self:AddTransition ({
            x = x,
            y = y,
            time=500,
            transition=easing.inOutSine,
            tag="bag_slide",
             }, self.UIgroup)
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
        
            if not self:Full() then --and (self:CanFitWeight (food:GetWeight()))then
                self:AddItem(food)
                if self:Weight() >= self:Capacity() then
                    self.weight = self.capacity
                    self.UIgroup.bar:setFillColor (.1875,.5625,1)
                end
                local new_scale_w = self:Weight()/self:Capacity()
                self.UIgroup.bar.width = self.UIgroup.bar.o_width *new_scale_w
                
                self.state:GoToState(self.states.NORMAL)
            else
                self.state:GoToState(self.states.BAG_FULL)
                print(self:describe().." full!")
            end
        end
            
    })
    
    self.state:SetState(self.states.BAG_COLLISION_STATE, {
		enter = function(bag_base)
            if self.slide_transition_ref then
                self:CancelTransition (self.slide_transition_ref)
            end
            self.base = bag_base
            bag_base.bag = self
            self:SlideToPosition (bag_base:Pos()) --function() self.original_position=-1 end)
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
            --return false --can't ever leave this state
        end
	})

end

return Bag