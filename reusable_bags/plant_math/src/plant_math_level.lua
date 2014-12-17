--[[---------------------------------------------------------------------------

 Plant seeds level
 This is the controller for the level

-----------------------------------------------------------------------------]]

--local Level = require "opal.src.oLevel"
local DebugLevel = require "opal.src.debug.debugLevel"
local _ = require 'opal.libs.underscore'
local Actor = require 'opal.src.actor'
local dirt_blocks = require "plant_math.src.dirt_types"
local BlockGroup = require "plant_math.src.block_group"

local composer = require 'composer'

local collision_groups = require "opal.src.collision"
collision_groups.SetGroups{'all'}--[[
    'all',
    "dirt", 
    "seed",
    "ground_collider",     -- sensor that detects how much dirt in hole
    "ground", 
    "nothing"}--]]

--DIRT TYPES
--local dirt_types = {NUM=1, PLUS=2,  

local filters = {}
local function add_collision(name, category, colliders)
    filters[name] = collision_groups.MakeFilter( category, colliders )
end

--add_collision('dirt', 'dirt', 
--    {'ground', 'dirt', 'ground_collider',"seed"})
add_collision('all', 'all', {'all'})


local PlantMathLevel = DebugLevel:extends()

function PlantMathLevel:init (size_w, size_h)
    self:super('init')
    self.collision_groups = collision_groups
    
    self.num_players = 1
    
    self.round = 0
    
    self.gridx, self.gridy = size_w or 6, size_h or 6
    self.op_block_ratio = 1/3
    self.width, self.height = self:GetWorldViewSize()
    
    self.player_goals = {}
    
    
    
end

-- called after levelX.lua setup
function PlantMathLevel:begin()
    
end

function PlantMathLevel:SetGoal(b_group)
    b_group.goal = b_group:GetRandomGoal()
    self.goal_display:RevealNextGoal(b_group.goal)
    oLog('Goal = '.. tostring(b_group.goal))
end

function PlantMathLevel:GetCurrentGoal(player)
    return self:GetPlayerGroup(player).goal
end

function PlantMathLevel:GetPlayerGroup(player)
    return self.block_groups[player]
end

--event listener for block group
function PlantMathLevel:queue_update (event)
    --local b_group = event.target
    local queue = event.queue
    local a, op, b = queue[1], queue[2], queue[3]
    a = a and a.value
    op = op and op.op
    b = b and b.value
    self:DisplayEquationQueue(a,op,b)
end

function PlantMathLevel:UpdateGoalDisplay()
    for i=1, self.num_players do
        --local 
    end
end

--event listener for block group
function PlantMathLevel:evaluate(event)
    local b_group = event.target
    local a, op, b = event.num_a, event.op, event.num_b
    self:DisplayEquationQueue (a and a:Value(), op and op.op, b and b:Value(), event.result)
    if event.result == b_group.goal then
        oLog("You did it!")
        
        local to_remove = {event.num_a,event.num_b,event.op}
        _.each(to_remove, function(b)
            b_group:RemoveBlock (b)
            self:RemoveActor (b)
        end)
        
        self:SetGoal(b_group)
    end
end


function PlantMathLevel:InsertBlock (block_group, block)
    block_group:InsertBlock (block)
    self:InsertActor (block)
    return block
end

function PlantMathLevel:SpawnNumberDirt( block_group, value, w, h )
    local out = dirt_blocks.Number(value,w,h,self)
    return self:InsertBlock (block_group, out)
end

local function spawn_operator_block (level, block_group, w, h, block_selections)
    block_selections = block_selections or {1,2,3}
    local random_op = block_selections[math.random (#block_selections)]
    local out = dirt_blocks.Operator (random_op, w, h, level)
    return level:InsertBlock (block_group, out)
end

function PlantMathLevel:SpawnOperatorBlock (block_group, w, h, block_selections)
    return spawn_operator_block (self, block_group, w, h, block_selections)
end

function PlantMathLevel:SpawnGround (x,y,w,h)
    local g = Actor({typeName="ground"},self,self:GetWorldGroup())
    
    g:createRectangleSprite(w,h,x,y)
    g:addPhysics({bodyType="static", category='all',colliders={'all'},friction=1})
end

function PlantMathLevel:CreateBlockGroup(grid_width, grid_height, gridx, gridy)
    local grid_block_width = grid_width/gridx
    local spacing = 1
    local block_size = (grid_width-spacing*gridx)/gridx
    local total_blocks_ct = gridx*gridy
    local num_op_blocks = math.floor(total_blocks_ct *self.op_block_ratio)
    local block_idx = 1
    local bgroup1 = BlockGroup(self)
    bgroup1.group = self:GetWorldGroup()
    local x, y = self.width/2-grid_width/2, self.height/2-grid_height/2
    for i=1,self.gridx do
        for j=1,self.gridy do
            local B
            if total_blocks_ct-block_idx <= num_op_blocks or (num_op_blocks>0 and math.random()<=self.op_block_ratio) then
                B = spawn_operator_block(self, bgroup1, block_size,block_size)
                num_op_blocks = num_op_blocks-1
            else
                B = self:SpawnNumberDirt(bgroup1, math.random(10),block_size,block_size)
            end
            local x, y = grid_block_width*(i-1)+x+block_size/2, grid_block_width*(j-1)+y+block_size/2
            B:SetPos (x, y) 
            block_idx = block_idx+1
        end
    end
    
    self:InsertActor(bgroup1, true)
    bgroup1:AddEventListener(bgroup1.sprite, 'evaluate', self)
    bgroup1:AddEventListener(bgroup1.sprite, 'queue_update', self)
    
    local ground_w, ground_h = grid_width, 10
    self:SpawnGround(self.width/2, self.height/2+grid_height/2 +ground_h/2, ground_w,ground_h)
    
    
    --self.dirt_grid = dirt_grid
    return bgroup1
end

-- todo: accept num players
local function create_goal_displays (self)
    local gd = require "plant_math.src.display.goal_display"
    local goal_types = require "plant_math.src.display.goal_display_types"
    local goal_display = gd(self)
    goal_display:SetPos(100,100)
    local num_goals = math.floor(self.gridx*self.gridy/2)
    goal_display:SetNumGoals ( num_goals )
    goal_display:CreateHiddenGoalTypes (self,num_goals, goal_types.basic)
    self.goal_display = goal_display
end

--todo: accept number of players
local function setup_block_groups(self)
    local bg1 = self:CreateBlockGroup(self.height/2, self.height/2, self.gridx, self.gridy)
    self.block_groups = {bg1}
    self:SetGoal(bg1)
end

--called when scene is in view
function PlantMathLevel:create (event, sceneGroup)
    physics.start()
    self:super("create", event, sceneGroup)
    local world_group = self.world_group
    self.ground_group = display.newGroup()
    self.dirt_group = display.newGroup()
    self.wall_group = display.newGroup()
    world_group:insert(self.ground_group)
    world_group:insert(self.dirt_group)
    world_group:insert(self.wall_group)
    
    
    --setup for a round
    create_goal_displays(self)
    setup_block_groups(self)
    
    --Create test button to change scene
    local button = display.newRect(self.width-110,10,100,100)
    button:addEventListener('touch', function(e)
        if e.phase=='ended' then
            composer.removeScene('opal.src.levelScene')
        end
    end)
end

function PlantMathLevel:DestroyLevel (event, sceneGroup)
    physics.stop()
    if self.goal_display then 
        self.goal_display:removeSelf()
    end
    self:super("DestroyLevel")
end


function PlantMathLevel:SetNumPlayer (count)
    self.num_players = count
end

function PlantMathLevel:WorldOffsetX()
    return -self.world_group.x
end

function PlantMathLevel:NextRound()
    self.round = self.round + 1
end

function PlantMathLevel:DisplayEquationQueue (num_a_value, operator_text, num_b_value, answer)
    local a = num_a_value and type(num_a_value)=='number' and string.format("%3d",num_a_value) or ""
    local op = operator_text or ""
    local b = num_b_value and type(num_b_value)=='number' and string.format("%3d",num_b_value) or ""
    answer = answer and type(answer)=='number' and string.format("= %3d",answer) or ""
    
    local text = self.equation_text
    if not text then
        text = display.newText{text = "", x=100-36,y=self.height-100,fontSize=36,parent=self:GetWorldGroup(), font=native.systemFont}
        text:setFillColor (1,1,1)
        text.anchorX = 0
    end
    --todo not showing operator when deselect number.
    text.text = string.format("%s %s %s %s", a, op, b, answer)
    
    self.equation_text = text
    
    return text
end
    

return PlantMathLevel