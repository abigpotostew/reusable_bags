

local Actor = require 'opal.src.actor'
local _ = require "opal.libs.underscore"
local OceanBlock = require 'clean_ocean.src.ocean_block'
local Vector2 = require 'opal.src.vector2'
local OceanGrid = Actor:extends()

function OceanGrid:init (level)
    self:super("init", {typeName="OceanGrid"}, level)
    
    self.sprite = display.newGroup()
    
    self.blocks = {} --list of blocks associated with this group
    
    
    self.group = self.level:GetWorldGroup()
    
end

local function spawn_block(self, block_idx, ix, iy, grid_block_width, block_size)
    local B = OceanBlock(self.level, block_size, block_size)
    --first_block_id = math.min(B.id, first_block_id)
    self.sprite:insert(B.sprite)
    B.grid_id = block_idx
    self:InsertBlock(B, block_idx)
    local x, y = grid_block_width*(ix-1)+block_size/2, grid_block_width*(iy-1)+block_size/2
    B:SetPos (x, y) 
    return B
end

function OceanGrid:SpawnBoundaryBlocks()
    local boundary_blocks = {}
    local gw, gh = self:Bounds()
    local gc, gr = self:Dimensions()
    local x, y, size = self:Pos(), self.block_size
    local block_idx = #self.blocks+1
    _.map({
        {Vector2(1,0),Vector2(gc,0)}, --TOP ROW
        {Vector2(gc+1,1),Vector2(gc+1,gr)}, --right column
        {Vector2(1,gr+1),Vector2(gc,gr+1)}, --bottom row
        {Vector2(0,1),Vector2(0,gr)} --left column
        },
        function(start_finish)
            local start = start_finish[1]
            local finish = start_finish[2]
            
            local isX = finish.x-start.x ~= 0
            local n = isX and gc or gr
            local lerp =  start:Copy()
            for i=1, n do
                local ix, iy = lerp:Get()
                local b = spawn_block (self, block_idx, ix, iy, self.grid_block_width, self.block_size)
                b.is_boundary_block = true
                --b:AddEventListener(b.sprite, 'block_touch', self)
                b:AddEventListener(b.sprite, 'block_touch_release', self)
                b:SetBlockColor(0.1,0.1,0.9)
                table.insert (boundary_blocks, b)
                block_idx = block_idx+1
                if isX then
                    lerp:Set(lerp.x + 1, lerp.y)
                else
                    lerp:Set(lerp.x, lerp.y+1)
                end
            end
            return start_finish
        end
    )
end



function OceanGrid:SpawnGrid(grid_width, grid_height, grid_cols, grid_rows)
    self.grid_width, self.grid_height = grid_width, grid_height
    self.grid_cols, self.grid_rows = grid_cols, grid_rows
    local grid_block_width = grid_width/grid_cols
    self.grid_block_width = grid_block_width
    local spacing = 1
    local block_size = (grid_width-spacing*grid_cols)/grid_cols
    self.block_size = block_size
    self.block_w = grid_width/grid_cols
    self.block_h = grid_height/grid_rows
    local total_blocks_ct = grid_cols*grid_rows
    local block_idx = 1
    local w, h = self.level:GetWorldViewSize()
    local x, y = w/2-grid_width/2, h/2-grid_height/2
    self:SetPos(x,y)
    x, y = 0, 0
    for j=1,grid_rows do
        for i=1,grid_cols do
            local B = spawn_block(self, block_idx, i, j, grid_block_width, block_size)
            B:AddEventListener (B.sprite, "block_touch", self)
            block_idx = block_idx+1
        end
    end
end

function OceanGrid:block_touch(event)
    local block = event.block
    oLog.Debug("touch "..block:describe())
    if block.is_boundary_block then
        self:DispatchEvent(self.sprite, "boundary_block_touch",
            {block = block, phase = event.phase, target = event.target})
    else
        self:DispatchEvent(self.sprite, "grid_touch",
            {block = block, phase = event.phase, target = event.target})
    end
end

--when user actually releases touch while on the block
function OceanGrid:block_touch_release(event)
    local block = event.block
    oLog.Debug("release "..block:describe())
    self:DispatchEvent(self.sprite, "block_touch_release",
        {block = block, phase = event.phase, target = event.target})
end

function OceanGrid:InsertBlock (block, block_idx)
    self.sprite:insert(block.sprite)
    
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

function OceanGrid:GetBlockPosition (id)
    local x, y = self:GetBlockCoords (id)
    x = x * self.block_w
    y = y * self.block_h
    return x, y
end

function OceanGrid:GetBlockWorldPosition (id)
    local x, y = self:GetBlockPosition (id)
    x = x + self:x()
    y = y + self:y()
    return x, y
end

--returns number of blocks across and down
function OceanGrid:Dimensions()
    return self.grid_cols, self.grid_rows
end

--returns pixel size of grid
function OceanGrid:Bounds()
    return self.grid_width, self.grid_height
end

return OceanGrid