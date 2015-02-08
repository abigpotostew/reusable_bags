
local DebugLevel = require "opal.src.debug.debugLevel"
local _ = require 'opal.libs.underscore'
local Actor = require 'opal.src.actor'

local Vector2 = require 'opal.src.vector2'

local OceanGrid = require 'clean_ocean.src.ocean_grid'
local Boat = require 'clean_ocean.src.boat'

local composer = require 'composer'

local collision_groups = require "opal.src.collision"
collision_groups.SetGroups{'all'}

local filters = {}
local function add_collision(name, category, colliders)
    filters[name] = collision_groups.MakeFilter( category, colliders )
end

add_collision('all', 'all', {'all'})


local CleanOceanLevel = DebugLevel:extends()

function CleanOceanLevel:init (size_w, size_h)
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
        
end

--when player taps a boundary block
function CleanOceanLevel:boundary_block_touch (event)
    oLog("Boundary block touch "..event.block:describe())
end

--when player taps a boundary block
function CleanOceanLevel:block_touch_release (event)
    oLog("Boundary block touch release "..event.block:describe())
end


--when player taps an ocean grid block
function CleanOceanLevel:grid_touch (event)
    oLog("grid block touch "..event.block:describe())
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
        local n = 8
        self.grid:SpawnGrid(m,m, n,n)
        self.grid:AddEventListener(self.grid.sprite,'grid_touch', self)
    end
    
    do --spawn the boat
        self.boat = Boat(self)
        self:InsertActor (self.boat)
    end
    
    do -- spawn boat starting positions
        self.grid:SpawnBoundaryBlocks()
        self.grid:AddEventListener(self.grid.sprite,'boundary_block_touch', self)
        self.grid:AddEventListener(self.grid.sprite,'block_touch_release', self)
    end
    
    --should be called last to kick off game event timeline.
    --self:ProcessTimeline()
    --self:PeriodicCheck()
    
    
    
end

--called when scene is in view
function CleanOceanLevel:create (event, sceneGroup)
    physics.start()
    self:super("create", event, sceneGroup)
    local world_group = self.world_group
end


return CleanOceanLevel