

local Actor = require 'opal.src.actor'
local _ = require "opal.libs.underscore"
local OceanBlock = require 'clean_ocean.src.block'
local Vector2 = require 'opal.src.vector2'
local OceanGrid = Actor:extends()

function OceanGrid:init (level)
    self:super("init", {typeName="OceanGrid"}, level)
    
    self.sprite = display.newGroup()
    
    self.blocks = {} --list of blocks associated with this group
    
    
    self.group = self.level:GetWorldGroup()
    
end

function OceanGrid:SpawnGrid(grid_width, grid_height, grid_cols, grid_rows)
    self.grid_width, self.grid_height = grid_width, grid_height
    self.grid_cols, self.grid_rows = grid_cols, grid_rows
    local grid_block_width = grid_width/grid_cols
    local spacing = 1
    local block_size = (grid_width-spacing*grid_cols)/grid_cols
    self.block_w = grid_width/grid_cols
    self.block_h = grid_height/grid_rows
    local total_blocks_ct = grid_cols*grid_rows
    local block_idx = 1
    local first_block_id = math.huge
    local w, h = self.level:GetWorldViewSize()
    local x, y = w/2-grid_width/2, h/2-grid_height/2
    for j=1,grid_rows do
        for i=1,grid_cols do
            local B = OceanBlock(self.level, block_size, block_size)
            first_block_id = math.min(B.id, first_block_id)
            self.sprite:insert(B.sprite)
            B.grid_id = block_idx
            self:InsertBlock(B, block_idx)
            local x, y = grid_block_width*(i-1)+x+block_size/2, grid_block_width*(j-1)+y+block_size/2
            B:SetPos (x, y) 
            block_idx = block_idx+1
        end
    end
    self.first_block_id = first_block_id
end

function OceanGrid:block_touch(event)
    oLog.Debug("touch "..event.block:describe())    
end

function OceanGrid:InsertBlock (block, block_idx)
    block:AddEventListener (block.sprite, "block_touch", self)
    self.sprite:insert(block.sprite)
    
    --[[local typeName = block.typeName
    if not self.blocks[typeName] then
        self.blocks[typeName] = {}
    end --]]
    self.blocks[block_idx] = block
    return block
end

function OceanGrid:RemoveBlock (block)
    self.blocks[block.grid_id] = nil
    return block
end

function OceanGrid:GetID(x, y)
    return self.grid_cols*(y-1)+x
end

function OceanGrid:GetBlockFromCoords (x, y)
    return self.blocks[self:GetID(x, y)]
end

function OceanGrid:GetBlockCoords (id)
    local x = id%self.grid_cols
    local y = math.floor(id/self.grid_rows)+1
    return x, y
end

function OceanGrid:OffsetCoords (x,y, direction_offset)
    return (Vector2(x,y) + direction_offset):Get()
end

function OceanGrid:GetBlock (id, direction_offset)
    local b = self.blocks[id]
    if b and direction_offset then
        return self:OffsetCoords(self:GetBlockCoords(id),direction_offset)
    end
    return self:GetBlockCoords(b.grid_id)
end

function OceanGrid:GetBlockWorldPosition (id)
    local x, y = self:GetBlockCoords (id)
    x = x * self.block_w + self:x()
    y = y * self.block_h + self:y()
    return x, y
end


return OceanGrid