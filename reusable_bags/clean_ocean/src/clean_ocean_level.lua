
local DebugLevel = require "opal.src.debug.debugLevel"
local _ = require 'opal.libs.underscore'
local Actor = require 'opal.src.actor'

local Vector2 = require 'opal.src.vector2'

local OceanGrid = require 'clean_ocean.src.ocean_grid'
local Boat = require 'clean_ocean.src.boat'
local BoatDirection = require 'clean_ocean.src.boat_direction'

local composer = require 'composer'

local collision_groups = require "opal.src.collision"
collision_groups.SetGroups{'all'}

local filters = {}
local function add_collision(name, category, colliders)
    filters[name] = collision_groups.MakeFilter( category, colliders )
end

add_collision('all', 'all', {'all'})


local CleanOceanLevel = DebugLevel:extends()

local ocean_objects = {
    EMPTY='EMPTY',
    TRASH='TRASH',
}

function CleanOceanLevel:init ()
    self:super('init')
    self.collision_groups = collision_groups
    
    local settings_default = {
        num_players = 1,
        round = 0,
        grid_columns = 6,
        grid_rows = 6,
        
    }
    self.width, self.height = self:GetWorldViewSize()

    self:Setting(settings_default)
    
    self.boat = nil
    self.grid = nil
    self.trash_count = 0
        
end

function CleanOceanLevel:DetermineNextGridPosition(current_block_direction, current_block_grid_position, boat_prev_direction)
    local direction = current_block_direction
    local next_position = current_block_grid_position + direction
    if next_position == current_block_grid_position then
        next_position = next_position + boat_prev_direction
        direction = boat_prev_direction
    end
    return next_position, direction
end

local sail_boat_from = nil

-- TODO make some sort of formal command system
local function resolve_block_action(self, boat, block)
    local set_sail = true
    if block.action then
        --somehow control whether we set sail
        local action_output = block:DoAction(self, boat)
        if not action_output then
            set_sail = false
        end
    end
    
    local can_boat_sail = boat:CanSail()
    
    if set_sail and can_boat_sail then
        boat:IncrementRemainingSails(-1)
        sail_boat_from(self, boat, block)
        oLog.Debug ("Finished sailing, "..boat:RemainingSails().." RemainingSails.")
        return
    end
end 

--Cancel player boat transitions
--move player boat to this block position
--determine next block
--build callback when boat reaches next block
--start transition to next block
function sail_boat_from(self, boat, start_ocean_block)
    boat:CancelAllTransions() --possible bug, cancel only the known sailing transition
    boat:SetPos (start_ocean_block:ScreenPos())
    boat.previous_direction = boat:Direction()
    local previous_direction = boat.previous_direction or BoatDirection.NONE
    
    local next_position, direction = self:DetermineNextGridPosition (start_ocean_block.direction, start_ocean_block.grid_position, previous_direction)
    
    local next_block = self.grid:GetBlockFromCoords (next_position:Get())
    boat:SetDirection (direction)
    if not next_block then return end
    if next_block.is_boundary_block then
        -- return some event
        return
    end
    local nx, ny = next_block:ScreenPos()
    local function onComplete(event)
            boat:DispatchEvent (boat.sprite, 'sail_event', {phase="ended", boat=boat, start=start_ocean_block, destination=next_block})
            return resolve_block_action (self, boat, next_block)
    end
    boat:AddTransition ({ x=nx, y = ny, time=500, onComplete= onComplete})
    oLog.Debug ("Boat sailing in direction "..tostring(direction).." to "..tostring(next_block))
    boat:DispatchEvent (boat.sprite, 'sail_event', {phase="began", boat=boat, start=start_ocean_block, destination=next_block})
    
end

--function CleanOceanLevel:StartBoatSetSail(boat, start_ocean_block)

--end

--when player taps a boundary block
function CleanOceanLevel:boundary_block_touch (event)
    oLog.Debug("Boundary block touch "..event.block:describe())
end

--when player taps a boundary block
function CleanOceanLevel:block_touch_release (event)
    oLog.Debug("Boundary release "..event.block:describe())
    
    local block = event.block
    if block.is_boundary_block then
        
        self.boat:SetRemainingSails(5)
        resolve_block_action (self, self.boat, block)
    end
end


--when player taps an ocean grid block
function CleanOceanLevel:grid_touch (event)
    oLog.Debug("grid block touch "..event.block:describe())
end

-- level is on screen
function CleanOceanLevel:show (event, sceneGroup)
    self:super("show", event, sceneGroup)

    if event.phase == 'will' then
        sceneGroup:insert(self.world_group)
        return
    end
    
    -- All code after here is run when the scene has come on screen.
    --physics.start()
    --Runtime:addEventListener("enterFrame", self)
    
    do -- spawn the ocean
        self.grid = OceanGrid(self)
        local m = math.min(self.width,self.height)*0.8
        local w,h = self:GetSetting('grid_columns'), self:GetSetting('grid_rows')
        self.grid:SpawnGrid(m,m, w,h)
        self.grid:AddEventListener(self.grid.sprite,'grid_touch', self)
        self.grid:AddEventListener(self.grid.sprite,'boundary_block_touch', self)
        self.grid:AddEventListener(self.grid.sprite,'block_touch_release', self)
    end
    
    do --spawn the boat
        self.boat = Boat(self)
        self:InsertActor (self.boat)
    end
    
    
    --should be called last to kick off game event timeline.
    --self:ProcessTimeline()
    --self:PeriodicCheck()
    
end

local function valid_ocean_object (object, ocean_objects)
    return _.any (ocean_objects, function(o) return o==object end)
end

function CleanOceanLevel:DecrementTrashCount(n)
    n = n or 1
    self.trash_count = self.trash_count - n
end

--perhaps this will be time based in the future
function CleanOceanLevel:CheckLevelComplete(trash_count)
    if trash_count <= 0 then
        --do other level complete stuff
        self:DispatchEvent (self:GetWorldGroup(), 'level_progress', {phase='ended'})
        return true
    end
end

--event for when boat interacts with trash on the grid
function CleanOceanLevel:trash_action_event(event)
    
end

local function boat_action_trash(block, level, boat)
    oLog.Debug ( string.format ("Doing trash action for %s", block:describe()))
    --boat:CleanTrashAction (block)
    
    --remove trash from the block
    block:ClearAction()
    block:SetBlockColor (unpack (oColor.OCEAN))
    level:DecrementTrashCount(1)
    level:CheckLevelComplete (level.trash_count)
    return true, boat:DispatchEvent (boat.sprite, 'trash_action_event', {phase='ended', block=block, remaining = level.trash_count})
end

local function boat_action_add_sail (block, level, boat)
    local sails = boat:RemainingSails()
    boat:IncrementRemainingSails (block.sails)
    return true
end

local function apply_level_object_type (self, block, level_object)
    oAssert (valid_ocean_object (level_object, ocean_objects), tostring(level_object).." is not a valid ocean object, please use a valid ocean object.")
    
    if level_object == ocean_objects.TRASH then
        block:SetBlockColor (unpack (oColor.TRASH))
        self:DecrementTrashCount(-1) --equivalent to adding 1. yea, it's dumb
        block:SetAction(boat_action_trash)
        
    elseif type(level_object) =='number' then
        block:SetBlockColor ( unpack(oColor.LIGHT_BLUE) )
        block.sails = level_object
        block:SetAction (boat_action_add_sail)
        block:AddLabel (string.format("%d",level_object))
    end
end

-- Resolve object type and apply actions to block
local function set_block_object_type (self, block, level_object)
    -- Set block as a direction vector
    local obj_type = type(level_object)
    
    if Vector2.isVector2(level_object) then
        block:SetDirection (level_object, 0.5)
        
    --set block as an object
    else 
        apply_level_object_type (self, block, level_object)
    end
end

function CleanOceanLevel:SetOceanVectors(vectors2d)
    local level_object = nil
    local direction = nil
    for x=1, #vectors2d do
        for y=1, #vectors2d[x] do
            -- offset by 1 because of border blocks
            local block = self.grid:GetBlockFromCoords (x+1,y+1)
            if block then
                --transpose to display on screen the same as level data
                level_object = vectors2d[y][x]
                -- resolve object type and setup block
                set_block_object_type (self, block, level_object)
            end
        end
    end
end

--called when scene is in view
function CleanOceanLevel:create (event, sceneGroup)
    physics.start()
    self:super("create", event, sceneGroup)
    local world_group = self.world_group
end

function CleanOceanLevel:DestroyLevel ()
    if self.grid then 
        self.grid:removeSelf()
    end
    self:super("DestroyLevel")
end

function CleanOceanLevel:GetOceanObjects()
    return _.extend({}, ocean_objects)
end


return CleanOceanLevel