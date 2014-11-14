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
    
    self.gridx, self.gridy = 6, 6
    self.width, self.height = self:GetWorldViewSize()
end

-- called after levelX.lua setup
function PlantMathLevel:begin()
    
end

local function create_dirt_block(x, y, dirt_type)
    
end

local function add_dirt (dirt_grid, ix, iy, dirt_type)
    
end

local function block_touch(event)
    --local level = event.target.owner
    oLog("touch "..event.target.owner:describe())
end

function PlantMathLevel:SpawnNumberDirt( value, w, h )
    local out = dirt_blocks.Number(value,w,h,self)
    out:AddEventListener(self.world_group, "block_touch", block_touch)
    return out
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
            local B = self:SpawnNumberDirt(i*j+j,block_size,block_size)
            local x, y = grid_block_width*(i-1), grid_block_width*(j-1)
            B:SetPos (x, y) 
            dirt_grid[i][j] = B
        end
    end
    self.dirt_grid = dirt_grid
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

--Accepts variable amounts of blocks and tries to make equation with them
--in the form of [num, op, num]
function PlantMathLevel:CanEvalBlocks(...)
    local t = arg
    local num_a, num_b, op
    while (not num_a or not num_b or not op) and t.n>0 do
        local block = table.remove(t,1)
        t.n = t.n-1
        if not num_a and block:IsNum() then
            num_a = block
        elseif not num_b and block:IsNum() then
            num_b = block
        elseif not op and block:IsOp() then
            op = block
        end
    end
    if num_a and num_b and op then
        return num_a, op, num_b 
    else
        return false
    end
end

return PlantMathLevel