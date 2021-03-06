

local Actor = require 'opal.src.actor'
local _ = require "opal.libs.underscore"
local OceanBlock = require 'clean_ocean.src.ocean_block'
local Vector2 = require 'opal.src.vector2'
local OceanGrid = Actor:extends()

local BoatDirection = require 'clean_ocean.src.boat_direction'

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
    self:InsertBlock(B, block_idx, ix, iy)
    local x, y = grid_block_width*(ix-1)+block_size/2, grid_block_width*(iy-1)+block_size/2
    B:SetPos (x, y)
    B.grid_position:Set (ix, iy)
    return B
end


function OceanGrid:SpawnGrid(grid_width, grid_height, grid_cols, grid_rows)
    grid_cols = grid_cols + 2
    grid_rows = grid_rows + 2
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
    local blocks = self.blocks
    for x=1,grid_cols do
        table.insert(blocks, {})
        for y=1,grid_rows do
            local B = spawn_block(self, block_idx, x, y, grid_block_width, block_size)
            local is_boundary_block = x==1 or x==grid_cols or y==1 or y==grid_rows
            if not is_boundary_block then
                B.direction = BoatDirection.NONE
                B:SetBlockColor(unpack (oColor.OCEAN))
                B:AddEventListener (B.sprite, "block_touch", self)
            else
                B.is_boundary_block = true
                
                local direction = nil
                if x==1 then
                    direction = BoatDirection.RIGHT
                elseif x==grid_cols then
                    direction = BoatDirection.LEFT
                elseif y==1 then
                    direction = BoatDirection.DOWN
                elseif y==grid_rows then
                    direction = BoatDirection.UP
                end
                B:SetDirection (direction)
                
                B:AddEventListener(B.sprite, 'block_touch_release', self)
                B:SetBlockColor(unpack (oColor.GREEN))
            end
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

function OceanGrid:InsertBlock (block, block_idx, gx, gy)
    self.sprite:insert(block.sprite)
    
    self.blocks[gx][gy] = block
    return block
end

--Does not delete the block
function OceanGrid:RemoveBlock (block)
    self.blocks[block.grid_position.x][block.grid_position.y] = nil
    return block
end

----unused
--function OceanGrid:GetID(x, y)
--    return self.grid_cols*(y-1)+x
--end

--use this
function OceanGrid:GetBlockFromCoords (x, y)
    local is_boundary_block = x<1 or x>self.grid_cols or y<1 or y>self.grid_rows
    if is_boundary_block then
        return nil
    end
    return self.blocks[x][y]
end

----unused
--function OceanGrid:GetBlockCoords (id)
--    local x = id%self.grid_cols
--    local y = math.floor(id/self.grid_rows)+1
--    return x, y
--end

function OceanGrid:OffsetCoords (x,y, direction_offset)
    return (Vector2(x,y) + direction_offset):Get()
end

---- unused??
--function OceanGrid:GetBlock (id, direction_offset)
--    local b = self.blocks[id]
--    if b and direction_offset then
--        return self:OffsetCoords(self:GetBlockCoords(id),direction_offset)
--    end
--    return self:GetBlockCoords(b.grid_id)
--end

---- unused.??
--function OceanGrid:GetBlockPosition (id)
--    local x, y = self:GetBlockCoords (id)
--    x = x * self.block_w
--    y = y * self.block_h
--    return x, y
--end

----unused?
--function OceanGrid:GetBlockWorldPosition (id)
--    local x, y = self:GetBlockPosition (id)
--    x = x + self:x()
--    y = y + self:y()
--    return x, y
--end

--returns number of blocks across and down
function OceanGrid:Dimensions()
    return self.grid_cols, self.grid_rows
end

--returns pixel size of grid
function OceanGrid:Bounds()
    return self.grid_width, self.grid_height
end

function OceanGrid:removeSelf ()
    for x=1,self.grid_cols do
        for y=1,self.grid_rows do
            self.blocks[x][y]:removeSelf()
        end
    end 
    self:super('removeSelf')
end

return OceanGrid