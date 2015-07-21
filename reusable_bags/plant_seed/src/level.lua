--[[---------------------------------------------------------------------------

 Plant seeds level

-----------------------------------------------------------------------------]]

--local Level = require "opal.src.oLevel"
local DebugLevel = require "opal.src.debug.debugLevel"
local _ = require 'opal.libs.underscore'
local Actor = require 'opal.src.actor'
local composer = require 'composer'

local collision_groups = require "opal.src.collision"
collision_groups.SetGroups{
    "dirt", 
    "seed",
    "ground_collider",     -- sensor that detects how much dirt in hole
    "ground", 
    "nothing"}

local filters = {}
local function add_collision(name, category, colliders)
    filters[name] = collision_groups.MakeFilter( category, colliders )
end

add_collision('dirt', 'dirt', 
    {'ground', 'dirt', 'ground_collider',"seed"})
add_collision('ground_collider', 'ground_collider', 
    {'dirt',"seed"})
add_collision('ground', 'ground' ,
    {'dirt',"seed"} )
add_collision('seed', 'seed', 
    {"dirt", "ground","ground_collider"})


local PlantSeedsLevel = DebugLevel:extends()

function PlantSeedsLevel:init ()
    self:super('init')
    self.collision_groups = collision_groups
    self.ground_hole_ct = 0
    
    physics.setDrawMode("hybrid")
    
    self.num_players = 1
    
    self.round = 0
end

-- called after levelX.lua setup
function PlantSeedsLevel:begin()
    
end

--called when scene is in view
function PlantSeedsLevel:create (event, sceneGroup)
    self:super("create", event, sceneGroup)
    local world_group = self.world_group
    self.ground_group = display.newGroup()
    self.dirt_group = display.newGroup()
    self.wall_group = display.newGroup()
    world_group:insert(self.ground_group)
    world_group:insert(self.dirt_group)
    world_group:insert(self.wall_group)
    
    self:AddKeyReleaseEvent('e', function()self.world_group.x=self.world_group.x+10 end)
    self:AddKeyReleaseEvent('q', function()self.world_group.x=self.world_group.x-10 end)
    
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
    actor.group = self.ground_group
    actor:createRectangleSprite(width,height,x,y,{fill_color={0,0,0,1}})
    actor.sprite.y = y + height/2
    actor:addPhysics ({mass=1.0,bodyType="static", friction=0.4,bounce=0.1,filter=filters['ground']})
    
    self:InsertActor (actor)
end



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
        event.target.joint = physics.newJoint( "touch", event.target, event.x + event.target.owner.level:WorldOffsetX(), event.y )
        event.target.joint.frequency = 1 --low frequency, makes it more floaty
        event.target.joint.dampingRatio = 1 --max damping, doesn't bounce against joint
        display.getCurrentStage():setFocus( event.target )
        event.target.has_focus = true
    elseif event.phase == "moved" then
        if not event.target.joint then --we may have removed another food and finger slid to this food
            return false
        end
        event.target.joint:setTarget(event.x + event.target.owner.level:WorldOffsetX(), event.y)
    elseif event.phase == "ended" then
        CancelTouch(event)
    end 
    return true
end

function PlantSeedsLevel:SetNumPlayer (count)
    self.num_players = 2
end

local function build_wall(self, x,y,w,h)
    local wall = Actor({typeName="wall",physics={}},self)
    wall.group = self.wall_group
    wall:createRectangleSprite(w,h,x,y,{fill_color={0,0,0,1}})
    wall:addPhysics ({mass=1.0,bodyType="static", friction=1,bounce=.1,filter=filters['ground']})
    
    self:InsertActor (wall)
    return wall
end

--private called at each round
local function BuildWalls (self, x_offset, y_offset)
    local xo, yo = x_offset or 0, y_offset or 0
    local w, h = self:GetWorldViewSize()
    local size = 10
    local h_size = size/2
    local left = build_wall(self, -h_size+xo, h/2+yo, size, h)
    local right = build_wall(self, w+h_size+xo, h/2+yo, size, h)
    local top = build_wall(self, w/2+xo, -h_size+yo, w, size)
    local bottom = build_wall(self, w/2+xo, h+h_size+yo, w, size)

end

function PlantSeedsLevel:BuildHolesNStuff (round)
    local l = self
    local width, height = l:GetWorldViewSize()
    local ro = round and (round*width) or 0
    if self.num_players == 2 then

        local ground_level = height*0.6
        local x, y, w, d = l:AddGroundHole(  width/4 + ro, ground_level,
            width/4 , height-height*.6-50,
            50)
        l:AddDirt(x, y, w, d, 23)
        
        local ground ={w=x-w/2,h=d+50}
        l:AddGround (x-w/2-ground.w/2, y, ground.w, ground.h)
        
        local middle_grd_w = width/2-w
        
        l:AddGround (3*width/4-middle_grd_w + ro, y, middle_grd_w, ground.h)
        
        l:AddGround (3*width/4+w/2+ground.w/2 + ro, y, ground.w, ground.h)
        
        x,y,w,d = l:AddGroundHole(3*width/4 + ro, ground_level, 
            width/4, height-height*.6-50, 
            50)
        l:AddDirt(x, y, w, d, 23)

    elseif self.num_players == 1 then
        local x, y, w, d = l:AddGroundHole(width/2 + ro, height*0.6, width/3, height-height*.6-50,50)
        l:AddDirt(x, y, w, d, 23)
        
        local ground_w = width/3
        local ground_h = d+50
        l:AddGround (width/3-ground_w/2 + ro, y, ground_w, ground_h)
        l:AddGround (2*width/3+ground_w/2 + ro, y, ground_w, ground_h)
    end
    
    BuildWalls(self,ro,0)
end

function PlantSeedsLevel:WorldOffsetX()
    return -self.world_group.x
end


function PlantSeedsLevel:SpawnSeed(hole,sensor)
    local type_name = 'seed'
        local seed = Actor({typeName=type_name},self)
        seed.group = self.world_group
        seed:createRectangleSprite (35,35,hole:x(), 35,{fill_color={0,1,0,1}})
        seed:addPhysics ({mass=1.0, radius=35,bodyType="dynamic", friction=0.4,bounce=0.4,filter=filters[type_name]})
        self:InsertActor (seed)
        seed:AddEventListener(seed.sprite, "touch", touch)
        hole.seed = seed
end

function PlantSeedsLevel:NextRound()
    local world = self.world_group
    local world_x, world_w = world.x, self:GetWorldViewSize()
    --transition.to (world, {x=world_x-world_w, time=2000, transition=easing.inOutCubic})
    self.round = self.round + 1
    self:BuildHolesNStuff(0)--self.round)
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
    
    local ground_actor = Actor({typeName="ground"},self, self.ground_group)
    --ground_actor.group = self.ground_group
    ground_actor:createRectangleSprite(hole_w,ground_level,x,y,{fill_color={0,0,0,0}})
    
    local phys_shapes = {}
    local filter = filters['ground']
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
    local type_name='ground_collider'
    local ground_sensor = Actor({typeName=type_name},self)
    ground_sensor.group = self.ground_group
    local sensor_height = hole_depth*1
    ground_sensor:createRectangleSprite(hole_w,sensor_height,x,y+hole_depth-sensor_height/2, {fill_color={0,0,0,1}})
    ground_sensor:addPhysics ({mass=1.0,bodyType="static", isSensor=true, friction=0.0,bounce=0.0,filter=filters[type_name]})
    self:InsertActor (ground_sensor)
    ground_sensor.dirt_count = 0
    ground_sensor:AddEventListener ( ground_sensor.sprite, "collision", ground_sensor_collide)
    ground_sensor:AddEvent ("dirt_collide")
    
    local digging_listener, planting_listener
    
    digging_listener = function(event)
        if event.dirt_count <= 10 and not ground_actor.seed then
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
        if sensor.seed then--and event.dirt_count > 10 then
            oLog("you win")
            timer.performWithDelay (1000, function(event)
                self:NextRound()
                timer.performWithDelay(100, function()
        ground_sensor:AddEventListener (ground_sensor.sprite,"dirt_collide", digging_listener)
        end)
            end)
            sensor:RemoveEventListener ("dirt_collide", planting_listener)
        end
    end
    
    timer.performWithDelay(100, function()
        ground_sensor:AddEventListener (ground_sensor.sprite,"dirt_collide", digging_listener)
        end)
    
    return x, y, hole_w, hole_depth
end



function PlantSeedsLevel:AddDirt( hole_x, hole_y, hole_width, hole_depth, dirt_radius)
    local type_name = 'dirt'
    
    local dirt_count = hole_width/(dirt_radius*2)*0.9 * hole_depth/(dirt_radius*2)
    local x, y = hole_x, hole_y+hole_depth/2
    for i=1, dirt_count do
        local dirt = Actor({typeName=type_name,physics={}}, self, self.dirt_group)
        dirt:createCircularSprite(25, x+oMath.binom(), y+oMath.binom())
        dirt:addPhysics({mass=1.0,bodyType="dynamic", radius=dirt_radius,friction='0.4',bounce='0.1',filter=filters[type_name]})
        self:InsertActor(dirt)
        dirt:AddEventListener (dirt.sprite, "touch", touch)
    end
end




return PlantSeedsLevel