
local DebugLevel = require "opal.src.debug.debugLevel"
local _ = require 'opal.libs.underscore'
local Actor = require 'opal.src.actor'
local Snake = require 'ride_the_snake.src.snake'

local Vector2 = require 'opal.src.vector2'

local composer = require 'composer'

-------------------------------------------------------------------------------
-- Physics filters
-------------------------------------------------------------------------------
local collision_groups = require "opal.src.collision"
collision_groups.SetGroups{'all', 'Snake'}

local filters = {}
local function add_collision(name, category, colliders)
    filters[name] = collision_groups.MakeFilter( category, colliders )
end

add_collision('all', 'all', {'all'})
add_collision('Snake', 'Snake', {'all'})


-------------------------------------------------------------------------------
-- Constructor
-------------------------------------------------------------------------------
local SnakeLevel = DebugLevel:extends({name="SnakeLevel"})

function SnakeLevel:init ()
    self:super('init')
    --self.collision_groups = collision_groups
    
    local settings_default = {
        num_players = 1,
    }
    self.width, self.height = self:GetWorldViewSize()

    self:Setting(settings_default)
       
       
    self:SetCollisionGroups (collision_groups)
end

local function CancelTouch(event)
    local sprite = event.target
    if sprite.has_focus then
        display.getCurrentStage():setFocus( nil )
        sprite.has_focus = false
    end
end

local function screen_touch_event (event)
    event.target.owner:touch(event)
end

function SnakeLevel:touch (event)
    local target = event.target
    local level = self
    local x, y = target:localToContent (event.x, event.y)
    if event.phase == "began" then
        display.getCurrentStage():setFocus( target )
        event.target.has_focus = true
        self.snake:SetTouchPosition (x,y)
        
    elseif event.phase == "moved" then
        
        self.snake:SetTouchPosition (x,y)
    elseif event.phase == "ended" then
        display.getCurrentStage():setFocus( nil )
        event.target.has_focus = false
        --TODO:revamp touch to trigger event on touch release
        -- if the block is the original block touched and is also released on top, call event
        oLog.Debug(string.format ("Release Mouse [ %d, %d ]", event.x, event.y))
    end
    return true
end

--when player taps an ocean grid block
function SnakeLevel:grid_touch (event)
    oLog.Debug("grid block touch "..event.block:describe())
end

local function setup_physics(snake_level)
    physics.setGravity(0,0)
    
    physics.start()
end

-- level is on screen
function SnakeLevel:show (event, sceneGroup)
    self:super("show", event, sceneGroup)

    if event.phase == 'will' then
        sceneGroup:insert(self.world_group)
        return
    end
    
    -- All code after here is run when the scene has come on screen.
    setup_physics(self)
    --Runtime:addEventListener("enterFrame", self)
    
    if self.snake then self.snake:StartEvents() end
    local grp = self:GetWorldGroup()
    grp.owner = self
    self:AddEventListener (grp, "touch", screen_touch_event)
    
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
    
    self:super("create", event, sceneGroup)
    local world_group = self:GetWorldGroup()
    world_group.owner = self
    
    self:SpawnSnake(100,100)
end

function SnakeLevel:DestroyLevel ()
    self:super("DestroyLevel")
    
    self.snake = nil
end

function SnakeLevel:SpawnSnake (x,y)
    self.snake = Snake(self, self:GetWorldGroup(), x,y)
    self:InsertActor (self.snake, true)
end


function SnakeLevel:GetFilter(filter_name)
    return filters[filter_name]
end

return SnakeLevel