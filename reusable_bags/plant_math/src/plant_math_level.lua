--[[---------------------------------------------------------------------------

 Plant seeds level

-----------------------------------------------------------------------------]]

--local Level = require "opal.src.oLevel"
local DebugLevel = require "opal.src.debug.debugLevel"
local _ = require 'opal.libs.underscore'
local Actor = require 'opal.src.actor'
local dirt_blocks = require "plant_math.src.dirt_types"

local collision_groups = require "opal.src.collision"
collision_groups.SetGroups{
    "dirt", 
    "seed",
    "ground_collider",     -- sensor that detects how much dirt in hole
    "ground", 
    "nothing"}

--DIRT TYPES
--local dirt_types = {NUM=1, PLUS=2,  

local filters = {}
local function add_collision(name, category, colliders)
    filters[name] = collision_groups.MakeFilter( category, colliders )
end

add_collision('dirt', 'dirt', 
    {'ground', 'dirt', 'ground_collider',"seed"})



local PlantMathLevel = DebugLevel:extends()

function PlantMathLevel:init ()
    self:super('init')
    self.collision_groups = collision_groups
    
    physics.setDrawMode("hybrid")
    
    self.num_players = 1
    
    self.round = 0
    
    self.gridx, self.gridy = 10, 10
    self.width, self.height = self:GetWorldViewSize()
end

-- called after levelX.lua setup
function PlantMathLevel:begin()
    
end

local function create_dirt_block(x, y, dirt_type)
    
end

local function add_dirt (dirt_grid, ix, iy, dirt_type)
    
end

--called when scene is in view
function PlantMathLevel:create (event, sceneGroup)
    self:super("create", event, sceneGroup)
    local world_group = self.world_group
    self.ground_group = display.newGroup()
    self.dirt_group = display.newGroup()
    self.wall_group = display.newGroup()
    world_group:insert(self.ground_group)
    world_group:insert(self.dirt_group)
    world_group:insert(self.wall_group)
    
    local grid_width = self.height / 2
    local grid_height = grid_width
    local grid_block_width = grid_width/self.gridx
    local spacing = 3
    local block_size = (grid_width-spacing*self.gridx)/self.gridx
    local dirt_grid = {}
    for i=1,self.gridx do
        dirt_grid[i]={}
        for j=1,self.gridy do
            local B = dirt_blocks.Number(i*j+i,block_size,block_size,self)
            local x, y = grid_block_width*(i-1), grid_block_width*(j-1)
            B:SetPos (x, y) 
            dirt_grid[i][j] = B
        end
    end
    self.dirt_grid = dirt_grid
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
        display.getCurrentStage():setFocus( event.target )
        event.target.has_focus = true
    elseif event.phase == "moved" then
    elseif event.phase == "ended" then
        CancelTouch(event)
    end 
    return true
end

function PlantMathLevel:SetNumPlayer (count)
    self.num_players = 2
end

function PlantMathLevel:WorldOffsetX()
    return -self.world_group.x
end

function PlantMathLevel:NextRound()
    self.round = self.round + 1
end

return PlantMathLevel