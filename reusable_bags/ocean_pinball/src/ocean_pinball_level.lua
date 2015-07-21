--[[---------------------------------------------------------------------------



-----------------------------------------------------------------------------]]

local DebugLevel = require "opal.src.debug.debugLevel"
local _ = require 'opal.libs.underscore'


local Bags = require 'reusable_bags.actors.bagTypes'
local BagBase = require 'reusable_bags.actors.BagBase'
local Foods = require 'reusable_bags.actors.foodTypes'
local Cannon = require "reusable_bags.actors.cannon"


local collision_groups = require "opal.src.collision"
collision_groups.SetGroups{
    --[[
    "ground", 
    --"wall", 
    --"nothing"--]]
    'all'
    }


local filters = {}
local function add_collision(name, category, colliders)
    filters[name] = collision_groups.MakeFilter( category, colliders )
end

--add_collision('dirt', 'dirt', 
--    {'ground', 'dirt', 'ground_collider',"seed"})
add_collision('all', 'all', {'all'})


local OceanPBLevel = DebugLevel:extends()

function OceanPBLevel:init ()
    self:super('init')

    self.collision_groups = collision_groups
end

function OceanPBLevel:create (event, group)
    self:super("create", event, group)
    
    self:AddKeyReleaseEvent("s", function(event)
        --self:SpawnRandomFood(nil,nil,1)
    end)
end

--[[function OceanPBLevel:RemoveFoodActor (food)
    assert(food.typeName == "food", "Required food actor")
    food:RemoveFoodSelf()
    self:RemoveActor (food)
end--]]


function OceanPBLevel:InsertFood (food)
    self:InsertActor(food)
end


--[[ Private function to spawn a bag
local function SpawnBag (level, bag_name, x, y)
    local b = Bags.CreateBag(bag_name, x, y, level)
    b:AddEventListener(b.sprite, "collision", level)
    level:InsertActor(b)
    return b
end--]]


function OceanPBLevel:AddGround ()
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



function OceanPBLevel:TimelineSpawnFood (data)
	if (data.wait ~= nil) then
		self:TimelineWait(data.wait)
	end

	local function SpawnFood()
		self:SpawnFood( data.foodName or data.weight, data.x, data.y, data.cannon)
	end

	table.insert(self.timeline, SpawnFood)
end

return OceanPBLevel