local u = require 'opal.src.test.unit'('plant_math_test')
local _ = require 'opal.libs.underscore'

local dirt_types = require "plant_math.src.dirt_types"
local BlockGroup = require "plant_math.src.block_group"

local PlantLevel = require "plant_math.src.plant_math_level"

function u:SetUp()
    physics.start()
end

function u:TearDown()
    physics.stop()
end

local function default_setup(val_a, val_b, operator_type, enable_touch)
    local level_mock = PlantLevel()
    local b_group = BlockGroup(level_mock)
    level_mock:InsertActor(b_group)
    local num_a, num_b
    if val_a ~= nil then 
        num_a = dirt_types.Number(val_a, 5,5,level_mock)
        level_mock:InsertBlock (b_group, num_a)
    end
    if val_b ~= nil then
        num_b = dirt_types.Number(val_b, 5,5,level_mock)
        level_mock:InsertBlock (b_group, num_b)
    end
    
    --optional op creation
    local op = nil
    if operator_type then
        op = dirt_types.Operator(operator_type, 5,5, level_mock)
        b_group:InsertBlock (op)
    end
    
    return level_mock, b_group, num_a, num_b, op
end

u:Test ( "Evaluate math", function(self)
    local val_a, val_b = 10, 3
    
    local level_mock, b_group, num_a, num_b = default_setup (val_a, val_b, nil, false)
    
    local ops = { 
        sub = {op=dirt_types.Operator(dirt_types.Operator.SUB, 5,5, level_mock), expected = val_a-val_b},
        add = {op=dirt_types.Operator(dirt_types.Operator.ADD, 5,5, level_mock), expected = val_a+val_b},
        mul = {op=dirt_types.Operator(dirt_types.Operator.MUL, 5,5, level_mock), expected = val_a*val_b},
        div = {op=dirt_types.Operator(dirt_types.Operator.DIV, 5,5, level_mock), expected = val_a/val_b} 
        }
    for k,op in pairs(ops) do level_mock:InsertBlock(b_group,op.op); end
    
    for k, op_table in pairs(ops) do
        local num_1a, op_1, num_1b = b_group:CanEvalBlocks(num_a, op_table.op, num_b)
        self:ASSERT_TRUE (num_1a)
        
        local actual = op_1:Evaluate(num_1a, num_1b)
        self:ASSERT_TRUE ( actual == op_table.expected )
    end
    
    level_mock:DestroyLevel()
end)

u:Test ( "Evaluation Stack", function(self)
    local val_a, val_b = 2, 3
    local level_mock, b_group, num_a, num_b, sub_op = default_setup (val_a, val_b, dirt_types.Operator.SUB, true)
    
    --simulate touch event on block
    num_a:DispatchEvent(num_a.sprite, "block_touch",
            {block = num_a, phase = "began"})
        
    --Can't eval stack with only 1 number in it.
    u:ASSERT_FALSE( pcall(function() b_group:EvalStack() end))
    
    --simulate touch event
    num_b:DispatchEvent(num_b.sprite, "block_touch",
            {block = num_b, phase = "began"})
    
    --Can't eval stack with only 2 numbers in it.
    u:ASSERT_FALSE( pcall(function() b_group:EvalStack() end))
    
    --simulate touch event
    num_b:DispatchEvent(num_b.sprite, "block_touch",
            {block = num_b, phase = "began"})
        
    --stack should be [a, b, b]
    --Can't eval stack with no operators in it.
    u:ASSERT_FALSE( pcall(function() b_group:EvalStack() end))
    
    --EvalStack() call with 3 objects in it will pop all 3 and try to evaluate
    self:ASSERT_TRUE (b_group:StackSize() == 0)
    
    
    --Now test actually evaluating stack
    num_a:DispatchEvent(num_a.sprite, "block_touch",
            {block = num_a, phase = "began"})
    sub_op:DispatchEvent(sub_op.sprite, "block_touch",
            {block = sub_op, phase = "began"})
    --don't simulate touch on last block so we cna manually evaluate the stack
    b_group:Queue(num_b)
    
    local result = b_group:EvalStack()
    self:ASSERT_TRUE( result and result == 2-3 )
    
    
    --clean up
    level_mock:DestroyLevel()
end)

u:Test ("Prevent Queue Duplicates", function(self)
    local val_a, val_b = 2, 3
    local level_mock, b_group, num_a, num_b, sub_op = default_setup (val_a, val_b, dirt_types.Operator.SUB, true)
    local add_op = dirt_types.Operator(dirt_types.Operator.ADD, 5,5, level_mock)
    b_group:InsertBlock (add_op)
    
    --prevent duplicate numbers
    num_a:DispatchEvent(num_a.sprite, "block_touch",
            {block = num_a, phase = "began"})
    num_a:DispatchEvent(num_a.sprite, "block_touch",
            {block = num_a, phase = "began"})
    self:ASSERT_TRUE (b_group:StackSize() == 0)
    
    --prevent duplicate ops
    sub_op:DispatchEvent(sub_op.sprite, "block_touch",
            {block = sub_op, phase = "began"})
    sub_op:DispatchEvent(sub_op.sprite, "block_touch",
            {block = sub_op, phase = "began"})
    self:ASSERT_TRUE (b_group:StackSize() == 0)
    
    --swaps 2 diff ops
    sub_op:DispatchEvent(sub_op.sprite, "block_touch",
            {block = sub_op, phase = "began"})
    add_op:DispatchEvent(add_op.sprite, "block_touch",
            {block = add_op, phase = "began"})
    self:ASSERT_TRUE (b_group:StackSize() == 1)
    
    
    --clean up
    level_mock:DestroyLevel()
end)


u:Test ("Random Goal", function(self)
        
    local val_a, val_b = 2, 3
    local level_mock, b_group, num_a, num_b, sub_op = default_setup (val_a, val_b, dirt_types.Operator.SUB, true)
    
    self:ASSERT_FALSE ( BlockGroup(PlantLevel()):GetRandomGoal(),"can't call get goal when no more blocks left") 
    
    local random_goal = b_group:GetRandomGoal()
    
    local actual_goal1, actual_goal2 = sub_op:Evaluate(num_a,num_b), sub_op:Evaluate(num_b,num_a)
    
    self:ASSERT_TRUE( random_goal == actual_goal1 or random_goal == actual_goal2)
    
    level_mock:DestroyLevel()
end)

u:Test ("Remove Blocks On goal", function(self)
    local val_a, val_b = 2, 3
    local level_mock, b_group, num_a, num_b, sub_op = default_setup (val_a, val_b, dirt_types.Operator.SUB, true)
    
    b_group:AddGoal(-1)
    
    num_a:DispatchEvent(num_a.sprite, "block_touch",
            {block = num_a, phase = "began"})
    self:ASSERT_TRUE (b_group:StackSize() == 1)
    sub_op:DispatchEvent(sub_op.sprite, "block_touch",
            {block = sub_op, phase = "began"})
    self:ASSERT_TRUE (b_group:StackSize() == 2)
    num_b:DispatchEvent (num_b.sprite, "block_touch", {block = num_b, phase = "began"})
    self:ASSERT_TRUE (b_group:StackSize() == 0)
    
    level_mock:DestroyLevel()
end)

u:Test ("Op Queue Order", function(self)
    local val_a, val_b = 2, 3
    local level_mock, b_group, num_a, num_b, sub_op = default_setup (val_a, val_b, dirt_types.Operator.SUB, true)
    
    num_a:DispatchEvent(num_a.sprite, "block_touch",
            {block = num_a, phase = "began"})
    sub_op:DispatchEvent(sub_op.sprite, "block_touch",
            {block = sub_op, phase = "began"})
    b_group:Queue(num_b)
    self:ASSERT_TRUE (b_group:Dequeue() == num_a)
    self:ASSERT_TRUE (b_group:Dequeue() == sub_op)
    self:ASSERT_TRUE (b_group:Dequeue() == num_b)
    
    level_mock:DestroyLevel()
end)

u:Test ("Inserting blocks", function(self)
    local val_a, val_b = nil, nil
    local level_mock, b_group, num_a, num_b, sub_op = default_setup (val_a, val_b, dirt_types.Operator.SUB, true)
    
    num_a = level_mock:SpawnNumberDirt(b_group, 1, 2, 2)
    num_b = level_mock:SpawnRandomOpDirt(b_group, 2, 2)
    
    self:ASSERT_TRUE (b_group:RemoveBlock(num_a))
    self:ASSERT_TRUE (b_group:RemoveBlock(num_b))
    
    level_mock:DestroyLevel()
end)

u:Test ("Display goal", function(self)
    local val_a, val_b = 3, 7
    local level_mock, b_group, num_a, num_b, sub_op = default_setup (val_a, val_b, dirt_types.Operator.SUB, true)
    
    num_a = level_mock:SpawnNumberDirt(b_group, 1, 2, 2)
    num_b = level_mock:SpawnRandomOpDirt(b_group, 2, 2)
    
    self:ASSERT_TRUE (b_group:RemoveBlock(num_a))
    self:ASSERT_TRUE (b_group:RemoveBlock(num_b))
    
    level_mock:DestroyLevel()
end)

return u