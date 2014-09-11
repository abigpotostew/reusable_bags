--[[---------------------------------------------------------------------------

 Reusable Bags Level 
 * a child class for Level specific to Reusable Bags level

-----------------------------------------------------------------------------]]

--local Level = require "opal.src.oLevel"
local DebugLevel = require "opal.src.debug.oDebugLevel"
local _ = require 'opal.libs.underscore'


local Bags = require 'reusable_bags.actors.bagTypes'
local BagBase = require 'reusable_bags.actors.BagBase'
local Foods = require 'reusable_bags.actors.foodTypes'
local Cannon = require "reusable_bags.actors.cannon"


local collision = require "opal.src.collision"
collision.SetGroups{
    "bag", 
    "food", 
    "head", 
    "bag_collider",     -- dynamic body welded to bag to allow collisions with others
    "bag_base",         -- static body at each bag location
    "ground", 
    "wall", 
    "nothing"}

local BagLevel = DebugLevel:extends()

function BagLevel:init ()
    self:super('init')
    self.food_list = self:GetFoodNameList(self.texture_sheet)
    self.bag_types = Bags.GetBagTypes()
end

function BagLevel:RemoveFoodActor (food)
    assert(food.typeName == "food", "Required food actor")
    food:RemoveFoodSelf()
    self:RemoveActor (food)
end

function BagLevel:GetFoodNameList (textureSheetInfo)
    local list = _(textureSheetInfo.frameIndex):chain():keys()
        :select(function(v) return string.find(v, "food_") end):value()
        
    local renamed_list = {}
    _.each(list, function(i) 
            local food_name = string.gsub(i, "food_", "")
            table.insert(renamed_list, food_name )
        end)
    return renamed_list
end

function BagLevel:InsertFood (food)
    self:InsertActor(food)
end

--Set posY to nil to spawn food at the location of a food spawner and pass spawner id as second parameter
function BagLevel:SpawnFood (weight_or_name, posX, posY, cannon)
    assert(weight_or_name, "Weight or food name required.")
    local spawner_function = nil
    if type(weight_or_name) == "string" then --by name
        spawner_function = Foods.CreateFood_ByName
    elseif type(weight_or_name) == "number" then
        spawner_function = Foods.CreateFood_ByWeight
    else
        assert(false,"Error spawning food")
    end
    local x, y = posX, posY
    local spawner = cannon
    if spawner then
        --spawner = self:GetSpawner(spawner_id)
        x, y = spawner:Pos()
    end
    
    local f = spawner_function( x, y, weight_or_name, self )
        
    if spawner then
        local lin_vel = spawner.velocity:Copy()
        lin_vel.y = lin_vel.y + oMath.binom() * spawner.speed_variation
        f.sprite.angularVelocity = spawner.angular_velocity + oMath.binom() * spawner.rotation_variation
        f.sprite:setLinearVelocity ( lin_vel:Get() )
    end
    self:InsertFood(f)
end

function BagLevel:SpawnRandomFood (posX, posY, spawner_id)
    self:SpawnFood( self:GetRandomFoodName(), posX, posY, spawner_id)
end

-- Private method to spawn bagbase, each bag spawn on a bag base
local function SpawnBagBase (level, x, y, w, h)
    local b = BagBase (x, y, w, h, level)
    level:InsertActor(b)
    return b
end

-- Private function to spawn a bag
local function SpawnBag (level, bag_name, x, y)
    local b = Bags.CreateBag(bag_name, x, y, level)
    b.sprite:addEventListener("collision", level)
    level:InsertActor(b)
    return b
end

-- BagLevel:SpawnBags()
--  bag_count required number of bags to spawn
function BagLevel:SpawnBags (bag_count)
    oAssert.type (bag_count, "number")
    self.bag_count = bag_count
    
    local width, height = self.width, self.height
    
    local layout_border = self.width/4
    for i, bag_name in ipairs (self.bag_types) do
        local x = layout_border + ((width-layout_border)/#self.bag_types)*(i-1)
        local y = height-140
        local bag = SpawnBag (self, bag_name, x, y)
        local base = SpawnBagBase (self, x, y, bag:Dimensions() )
        --bag.last_bag_collision = base.id
        bag.base = base
        base.bag = bag
    
        local cannon = self:SpawnCannon {x = x, y = 250, directionX=0, directionY=1, speed = 80, angular_velocity = 55, speed_variation=40, rotation_variation=35}
        --spawn a bag base here
    end

end

function BagLevel:SpawnCannon (cannon_data)
    local c = Cannon(cannon_data, self)
    self:InsertActor (c)
    return c
end


function BagLevel:AddGround ()
	--[[local width, height = self:GetWorldViewSize()
	local groundInfo = {}--display.newRect(0, 0, width, 22)
	--ground:setReferencePoint(display.BottomLeftReferencePoint)
    groundInfo.anchorX = 0.5
    groundInfo.anchorY = 0.5
	groundInfo.alpha = 1.0
	groundInfo.typeName = "ground"
    groundInfo.physics = {}
    groundInfo.scale = 1
	local halfWidth = width * 0.5
    self.ground = Actor:init(groundInfo)
    self.ground.group = self:GetWorldGroup()
    --self.ground:createRectangleSprite(0,0, width,14)
    self.ground:addPhysics({bounce=0.2, category='ground', colliders={"food"}, isSensor=false, bodyType="static"})
	self:GetWorldGroup():insert(self.ground.sprite)--]]
    
    
    local width, height = self:GetWorldViewSize()
    local function createBoundary(x,y,w,h)
        local boundary = display.newRect(x, y, w, h)
        boundary.anchorX, boundary.anchorY = 0.5, 0.5
        boundary.x = x
        boundary.y = y
        boundary.alpha = 1
        boundary.typeName = "ground"
        local halfWidth = w * 0.5
        local halfHeight = h * 0.5
        local shape = {	-halfWidth, -halfHeight,
                         halfWidth, -halfHeight,
                         halfWidth,  halfHeight,
                        -halfWidth,  halfHeight }
        physics.addBody(boundary, "static", {
            shape = shape,
            bounce = 0.00001,
            friction = 1,
            filter = collision.MakeFilter("ground",{"food","bag"})
        })
        self:GetWorldGroup():insert(boundary)
    end
    createBoundary(width/2,height,width,22) --ground
    createBoundary(0,height/2,22,height) --left
    createBoundary(width,height/2,22,height) --ceiling
    createBoundary(width/2,0,width,22) --right
    
    --[[Ground
	local ground = display.newRect(0, 0, width, 22)
    ground.anchorX, ground.anchorY = 0.5, 0.5
	ground.x = width/2
	ground.y = height
	ground.alpha = 1
	ground.typeName = "ground"
	local halfWidth = width * 0.5
	local shape = {	-halfWidth, -14,
					 halfWidth, -14,
					 halfWidth,  14,
					-halfWidth,  14 }
	physics.addBody(ground, "static", {
		shape = shape,
		bounce = 0.00001,
		friction = 1,
		filter = collision.MakeFilter("ground",{"food","bag"})
	})
	self:GetWorldGroup():insert(ground)
    --]]
end


function BagLevel:GetRandomFoodName ()
    assert( self.food_list and #self.food_list > 0, "Required food name list before." )
    return self.food_list[math.random(#self.food_list)]
end


function BagLevel:TimelineSpawnFood (data)
	if (data.wait ~= nil) then
		self:TimelineWait(data.wait)
	end

	local function SpawnFood()
		self:SpawnFood( data.foodName or data.weight, data.x, data.y, data.cannon)
	end

	table.insert(self.timeline, SpawnFood)
end

return BagLevel