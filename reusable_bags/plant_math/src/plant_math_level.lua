--[[---------------------------------------------------------------------------

 Plant seeds level

-----------------------------------------------------------------------------]]

--local Level = require "opal.src.oLevel"
local DebugLevel = require "opal.src.debug.debugLevel"
local _ = require 'opal.libs.underscore'
local Actor = require 'opal.src.actor'
local dirt_blocks = require "plant_math.src.dirt_types"
local BlockGroup = require "plant_math.src.block_group"

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
    
    self.gridx, self.gridy = 4, 4
    self.op_block_ratio = 1/3
    self.width, self.height = self:GetWorldViewSize()
    
    self.player_goals = {}
end

-- called after levelX.lua setup
function PlantMathLevel:begin()
    
end

function PlantMathLevel:evaluate(event)
    
end

function PlantMathLevel:SpawnNumberDirt( block_group, value, w, h )
    local out = dirt_blocks.Number(value,w,h,self)
    block_group:InsertBlock (out)
    return out
end

function PlantMathLevel:SpawnRandomOpDirt (block_group, w,h)
    local out = dirt_blocks.Operator(math.random(1,4),w,h,self)
    block_group:InsertBlock (out)
    return out
end

function PlantMathLevel:CreateBlockGroup(grid_width, grid_height, gridx, gridy)
    local grid_block_width = grid_width/gridx
    local spacing = 3
    local block_size = (grid_width-spacing*gridx)/gridx
    --local dirt_grid = {}
    local total_blocks_ct = gridx*gridy
    local num_op_blocks = math.floor(total_blocks_ct *self.op_block_ratio)
    local block_idx = 1
    local bgroup1 = BlockGroup(self)
    for i=1,self.gridx do
        --dirt_grid[i]={}
        for j=1,self.gridy do
            local B
            if total_blocks_ct-block_idx <= num_op_blocks or (num_op_blocks>0 and math.random()<=self.op_block_ratio) then
                B = self:SpawnRandomOpDirt(bgroup1, block_size,block_size)
                num_op_blocks = num_op_blocks-1
            else
                B = self:SpawnNumberDirt(bgroup1, math.random(10),block_size,block_size)
            end
            local x, y = grid_block_width*(i-1), grid_block_width*(j-1)
            B:SetPos (x, y) 
            block_idx = block_idx+1
            --dirt_grid[i][j] = B
        end
    end
    bgroup1:SetPos(self.width/2-grid_width/2, self.height/2-grid_height/2)
    self:InsertActor(bgroup1, true)
    bgroup1:AddEventListener(bgroup1.sprite, 'evaluate', self)
    
    
    
    --self.dirt_grid = dirt_grid
    return bgroup1
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
    
    self:CreateBlockGroup(self.height/2, self.height/2, self.gridx, self.gridy)
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