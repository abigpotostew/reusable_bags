
--incomplete
local Actor = require 'opal.src.actor'
local _ = require "opal.libs.underscore"
local OceanBlock = require 'clean_ocean.src.block'

local Grid = Actor:extends()

function Grid:init (level)
    self:super("init", {typeName="Grid"}, level)
    
    self.sprite = display.newGroup()
    
    self.blocks = {} --list of blocks associated with this group
    
end

function Grid:SpawnGrid(grid_width, grid_height, grid_cols, grid_rows, spawn_func)
    self.grid_width, self.grid_height = grid_width, grid_height
    self.grid_cols, self.grid_rows = grid_cols, grid_rows
    local grid_block_width = grid_width/grid_cols
    local spacing = 1
    local block_size = (grid_width-spacing*grid_cols)/grid_cols
    local total_blocks_ct = grid_cols*grid_rows
    local block_idx = 1
    local first_block_id = math.huge
    local w, h = self.level:GetWorldViewSize()
    local x, y = w/2-grid_width/2, h/2-grid_height/2
    
    for j=1,grid_rows do
        for i=1,grid_cols do
            local x, y = grid_block_width*(i-1)+x+block_size/2, grid_block_width*(j-1)+y+block_size/2
            local B = spawn_func(self.level, block_size, x, y)
            first_block_id = math.min(B.id, first_block_id)
            
            local B = OceanBlock(self.level, block_size, block_size)
            self.sprite:insert(B.sprite)
            self:InsertBlock(B)
            
            B:SetPos (x, y)
            block_idx = block_idx+1
        end
    end
    self.first_block_id = first_block_id
end

function Grid:block_touch(event)
    oLog.Debug("touch "..event.block:describe())    
end

function Grid:InsertBlock (block)
    block:AddEventListener (block.sprite, "block_touch", self)
    self.sprite:insert(block.sprite)
    
    local typeName = block.typeName
    if not self.blocks[typeName] then
        self.blocks[typeName] = {}
    end
    self.blocks[typeName][block.id] = block
    return block
end

function Grid:RemoveBlock (block)
    self.blocks[block.typeName][block.id] = nil
    return block
end

return Grid