--[[---------------------------------------------------------------------------

 Plant seeds level

-----------------------------------------------------------------------------]]

--local Level = require "opal.src.oLevel"
local DebugLevel = require "opal.src.debug.oDebugLevel"
local _ = require 'opal.libs.underscore'
local Actor = require 'opal.src.actor'

local collision = require "opal.src.collision"
collision.SetGroups{
    "dirt", 
    "seed",
    "ground_collider",     -- dynamic body welded to bag to allow collisions with others
    "ground", 
    "nothing"}

local PlantSeedsLevel = DebugLevel:extends()

function PlantSeedsLevel:init ()
    self:super('init')
    self.collision = collision
    self.ground_hole_ct = 0
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
    
    --local x = hw
    --local y = ground_level
    
    local actor = Actor({typeName="ground"},self)
    actor.group = self:GetWorldGroup()
    actor:createRectangleSprite(hole_w,ground_level,x,y,{fill_color={0,0,0,0}})
    
    local phys_shapes = {}
    local filter = self.collision.MakeFilter( 'ground', {'dirt'} )
    for _,shape in ipairs(shapes) do
        table.insert(phys_shapes, 
            {friction=0.2, bounce=0.4, shape=shape, filter=filter})
    end
    
    physics.addBody( actor.sprite, "static", unpack(phys_shapes) )

    self:InsertActor (actor)
    
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
    
    local dirt_count = hole_width/(dirt_radius*2) * hole_depth/(dirt_radius*2)
    local x, y = hole_x, hole_y+hole_depth/2
    for i=1, dirt_count do
        local dirt = Actor({typeName='dirt',physics={}}, self, self:GetWorldGroup())
        dirt:createCircularSprite(25, x+oMath.binom(), y+oMath.binom())
        dirt:addPhysics({mass=1.0,bodyType="dynamic", radius=dirt_radius,friction='0.4',bounce='0.1',category='dirt',colliders={'ground', 'dirt'}})
        self:InsertActor(dirt)
        dirt:addListener (dirt.sprite, "touch", touch)
    end
end



return PlantSeedsLevel