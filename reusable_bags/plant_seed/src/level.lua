--[[---------------------------------------------------------------------------

 Plant seeds level

-----------------------------------------------------------------------------]]

--local Level = require "opal.src.oLevel"
local DebugLevel = require "opal.src.debug.oDebugLevel"
local _ = require 'opal.libs.underscore'
local Actor = require 'opal.src.actor'

local collision_groups = require "opal.src.collision"
collision.SetGroups{
    "dirt", 
    "seed",
    "ground_collider",     -- sensor that detects how much dirt in hole
    "ground", 
    "nothing"}

local PlantSeedsLevel = DebugLevel:extends()

function PlantSeedsLevel:init ()
    self:super('init')
    self.collision_groups = collision_groups
    self.ground_hole_ct = 0
    
    physics.setDrawMode("hybrid")
end


local function get_hole_shapes(hole_width, hole_depth, hole_offset_bottom, x, y)
    
    --hole dimensions
    local hole_w = hole_width
    local hhole_w = hole_w/2
    
    local y0 = 0
    local y1 = hole_depth*0.80
    local y2 = hole_depth*0.90
    local y3 = hole_depth + hole_offset_bottom
    
    local x0 = hhole_w * .25
    local x1 = hhole_w * .75
    local x2 = hhole_w
    
    return {
        {-x2,y0, -x2,y3, -x1,y3, -x1,y1 },
        {-x1,y1, -x1,y3, -x0,y3, -x0,y2},
        {-x0,y2, -x0,y3, x0,y3, x0,y2},
        {x0,y2, x0,y3, x1,y3, x1,y1},
        {x1,y1, x1,y3, x2,y3, x2,y0}
    }
    
end

function PlantSeedsLevel:AddGround (x, y, width, height)
    local actor = Actor({typeName="ground",physics={}},self)
    actor.group = self:GetWorldGroup()
    actor:createRectangleSprite(width,height,x,y,{fill_color={0,0,0,1}})
    actor.sprite.y = y + height/2
    actor:addPhysics ({mass=1.0,bodyType="static", friction='0.4',bounce='0.1',category='ground',colliders={'dirt'}})
    
    self:InsertActor (actor)
end

function PlantSeedsLevel:SpawnSeed(hole,sensor)
        local seed = Actor({typeName="seed"},self)
        seed.group = self:GetWorldGroup()
        seed:createRectangleSprite (35,35,hole:x(), 35,{fill_color={0,1,0,1}})
        seed:addPhysics ({mass=1.0, radius=35,bodyType="dynamic", friction=0.4,bounce=0.4,category="seed",colliders={"dirt", "ground","ground_collider"}})
        self:InsertActor (seed)
        hole.seed = seed
    end

function PlantSeedsLevel:AddGroundHole(x, y, hole_width, hole_depth, hole_offset_bottom )
    self.ground_hole_ct = self.ground_hole_ct + 1
    local width, height = self:GetWorldViewSize()
    local hw, hh = width/2, height/2
    local left = 0
    local right = width
    local bottom = height
    
    
    --hole dimensions
    local hole_w = hole_width
    local ground_level = y
    
    local shapes = get_hole_shapes(hole_w, hole_depth, hole_offset_bottom)
    
    local ground_actor = Actor({typeName="ground"},self)
    ground_actor.group = self:GetWorldGroup()
    ground_actor:createRectangleSprite(hole_w,ground_level,x,y,{fill_color={0,0,0,0}})
    
    local phys_shapes = {}
    local filter = self.collision.MakeFilter( 'ground', {'dirt',"seed"} )
    for _,shape in ipairs(shapes) do
        table.insert(phys_shapes, 
            {friction=0.2, bounce=0.4, shape=shape, filter=filter})
    end
    
    physics.addBody( ground_actor.sprite, "static", unpack(phys_shapes) )
    self:InsertActor (ground_actor)
    
    
    ----------
    -- Create dirt sensor in ground
    ----------
    local ground_sensor_collide=function(event)
        local sensor = event.target.owner
        if event.other.owner.typeName == 'seed' then
            if event.phase == 'began' then
                sensor.seed = event.other.owner
            elseif event.phase =='ended' then
                sensor.seed = nil
            end
            return
        end
        if event.phase == "began" then
            sensor.dirt_count = sensor.dirt_count + 1
            sensor:DispatchEvent (sensor.sprite, "dirt_collide", {target=sensor,other=event.other,phase="began",dirt_count=sensor.dirt_count})
        elseif event.phase == "ended" then
            sensor.dirt_count = sensor.dirt_count - 1
            sensor:DispatchEvent (sensor.sprite,"dirt_collide", {target=sensor,other=event.other, phase="ended",dirt_count=sensor.dirt_count})
        end
    end
    local ground_sensor = Actor({typeName="ground_collider"},self)
    ground_sensor.group = self:GetWorldGroup()
    local sensor_height = hole_depth*0.6
    ground_sensor:createRectangleSprite(hole_w,sensor_height,x,y+hole_depth-sensor_height/2, {fill_color={0,0,0,1}})
    ground_sensor:addPhysics ({mass=1.0,bodyType="static", isSensor=true, friction=0.0,bounce=0.0,category="ground_collider",colliders={'dirt',"seed"}})
    self:InsertActor (ground_sensor)
    ground_sensor.dirt_count = 0
    ground_sensor:AddEventListener ( ground_sensor.sprite, "collision", ground_sensor_collide)
    ground_sensor:AddEvent ("dirt_collide")
    
    local digging_listener, planting_listener
    
    digging_listener = function(event)
        if event.dirt_count <= 5 and not ground_actor.seed then
            --spawn seed now
            timer.performWithDelay(0,function()
                self:SpawnSeed(ground_actor,ground_sensor)
            end)
            event.target:RemoveEventListener ("dirt_collide", digging_listener)
            event.target:AddEventListener (event.target.sprite,"dirt_collide", planting_listener)
        end
    end
    planting_listener = function(event)
        local sensor = event.target
        if sensor.seed and event.dirt_count > 10 then
            oLog("you win")
            sensor:RemoveEventListener ("dirt_collide", planting_listener)
        end
    end
    
    timer.performWithDelay(100, function()
        ground_sensor:AddEventListener (ground_sensor.sprite,"dirt_collide", digging_listener)
        end)
    
    return x, y, hole_w, hole_depth
end

function PlantSeedsLevel:AddDirt( hole_x, hole_y, hole_width, hole_depth, dirt_radius)
    local function CancelTouch(event)
        local sprite = event.target
        if sprite.joint then
            sprite.joint:removeSelf()
            sprite.joint = nil
        end
        if sprite.has_focus then
            display.getCurrentStage():setFocus( nil )
            sprite.has_focus = false
        end
    end
    local function touch (event)
        if event.phase == "began" then
            event.target.joint = physics.newJoint( "touch", event.target, event.x, event.y )
            event.target.joint.frequency = 1 --low frequency, makes it more floaty
            event.target.joint.dampingRatio = 1 --max damping, doesn't bounce against joint
            display.getCurrentStage():setFocus( event.target )
            event.target.has_focus = true
        elseif event.phase == "moved" then
            if not event.target.joint then --we may have removed another food and finger slid to this food
                return false
            end
            event.target.joint:setTarget(event.x, event.y)
        elseif event.phase == "ended" then
            CancelTouch(event)
        end 
        return true
    end
    
    local dirt_count = hole_width/(dirt_radius*2)*0.9 * hole_depth/(dirt_radius*2)
    local x, y = hole_x, hole_y+hole_depth/2
    for i=1, dirt_count do
        local dirt = Actor({typeName='dirt',physics={}}, self, self:GetWorldGroup())
        dirt:createCircularSprite(25, x+oMath.binom(), y+oMath.binom())
        dirt:addPhysics({mass=1.0,bodyType="dynamic", radius=dirt_radius,friction='0.4',bounce='0.1',category='dirt',colliders={'ground', 'dirt', 'ground_collider',"seed"}})
        self:InsertActor(dirt)
        dirt:AddEventListener (dirt.sprite, "touch", touch)
    end
end



return PlantSeedsLevel