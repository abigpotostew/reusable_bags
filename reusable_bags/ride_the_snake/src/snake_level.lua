
local DebugLevel = require "opal.src.debug.debugLevel"
local _ = require 'opal.libs.underscore'
local Actor = require 'opal.src.actor'

local Vector2 = require 'opal.src.vector2'

local composer = require 'composer'

--[[local collision_groups = require "opal.src.collision"
collision_groups.SetGroups{'all'}

local filters = {}
local function add_collision(name, category, colliders)
    filters[name] = collision_groups.MakeFilter( category, colliders )
end

add_collision('all', 'all', {'all'})
--]]

local SnakeLevel = DebugLevel:extends()

function SnakeLevel:init ()
    self:super('init')
    --self.collision_groups = collision_groups
    
    local settings_default = {
        num_players = 1,
    }
    self.width, self.height = self:GetWorldViewSize()

    self:Setting(settings_default)
    
    --self.boat = nil
    --self.grid = nil
    --self.trash_count = 0
        
end


--when player taps an ocean grid block
function SnakeLevel:grid_touch (event)
    oLog.Debug("grid block touch "..event.block:describe())
end

-- level is on screen
function SnakeLevel:show (event, sceneGroup)
    self:super("show", event, sceneGroup)

    if event.phase == 'will' then
        sceneGroup:insert(self.world_group)
        return
    end
    
    -- All code after here is run when the scene has come on screen.
    --physics.start()
    --Runtime:addEventListener("enterFrame", self)
    
    do -- spawn the ocean
        
        local m = math.min(self.width,self.height)*0.8
        --local w,h = self:GetSetting('grid_columns'), self:GetSetting('grid_rows')
        --self.grid:SpawnGrid(m,m, w,h)
        --self.grid:AddEventListener(self.grid.sprite,'grid_touch', self)
    end
    
    do --spawn the boat
        --self.boat = Boat(self)
        --self:InsertActor (self.boat)
    end
    
    
    --should be called last to kick off game event timeline.
    --self:ProcessTimeline()
    --self:PeriodicCheck()
    
end

--called when scene is being built
function SnakeLevel:create (event, sceneGroup)
    physics.start()
    self:super("create", event, sceneGroup)
    local world_group = self.world_group
end

function SnakeLevel:DestroyLevel ()
    if self.grid then 
        --self.grid:removeSelf()
    end
    self:super("DestroyLevel")
end



return SnakeLevel