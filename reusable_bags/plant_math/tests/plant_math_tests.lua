local u = require 'opal.src.test.unit'('plant_math_test')

local dirt_types = require "plant_math.src.dirt_types"

local PlantLevel = require "plant_math.src.plant_math_level"

u:Test ( "Evaluate math", function()
    --u:ASSERT_TRUE(1==1)
    
    local level_mock = PlantLevel()
    local val_a, val_b = 10, 3
    local num_a = dirt_types.Number(val_a, 5,5,level_mock)
    level_mock:InsertActor(num_a)
    local num_b = dirt_types.Number(val_b, 5,5,level_mock)
    level_mock:InsertActor(num_b)
    
    local ops = { 
        sub = {op=dirt_types.Operator(dirt_types.Operator.SUB, 5,5, level_mock), expected = val_a-val_b},
        add = {op=dirt_types.Operator(dirt_types.Operator.ADD, 5,5, level_mock), expected = val_a+val_b},
        mul = {op=dirt_types.Operator(dirt_types.Operator.MUL, 5,5, level_mock), expected = val_a*val_b},
        div = {op=dirt_types.Operator(dirt_types.Operator.DIV, 5,5, level_mock), expected = val_a/val_b} 
        }
    for k,op in pairs(ops) do level_mock:InsertActor(op.op); end
    
    for k, op_table in pairs(ops) do
        local num_1a, op_1, num_1b = level_mock:CanEvalBlocks(num_a, op_table.op, num_b)
        u:ASSERT_TRUE (num_1a)
        
        local actual = op_1:Evaluate(num_1a, num_1b)
        u:ASSERT_TRUE ( actual == op_table.expected )
    end
    
    level_mock:Destroy()
end)


return u