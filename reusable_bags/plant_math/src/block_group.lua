-- BlockGroup handles a group of dirt block, listening for touch events, and then handling evaluating the stack of block operations


local Actor = require 'opal.src.actor'
local _ = require "opal.libs.underscore"

local BlockGroup = Actor:extends()

function BlockGroup:init (level)
    self:super("init", {typeName="BlockGroup"}, level)
    
    self.sprite = display.newGroup()
    
    self.blocks = {Number={}, Operator={}} --list of blocks associated with this group
    --stack actually functions like a queue :)
    self.queue = {}
    
    self.goal = nil
    self.goals = {} --list of number goals for player
    
    self:AddEvent("evaluate") --dispatched whenever player completes operation
end

function BlockGroup:AddGoal(number)
    self.goal = number
    table.insert(self.goals,number)    
end

function BlockGroup:RemoveGoal(number)
    self.goal = nil
end

function BlockGroup:block_touch(event)
    oLog.Debug("touch "..event.block:describe())
    local in_queue = self:Queue(event.block)
    if #self.queue >= 3 then
        self:EvalStack()
    end
end

function BlockGroup:InsertBlock (block)
    block:AddEventListener (block.sprite, "block_touch", self)
    self.sprite:insert(block.sprite)
    
    local typeName = block.typeName
    if not self.blocks[typeName] then
        self.blocks[typeName] = {}
    end
    self.blocks[typeName][block.id] = block
end

function BlockGroup:RemoveBlock (block)
    self.blocks[block.typeName][block.id] = nil
end

--returns the duplicate block in the list if it exists
local function duplicate_in_queue (queue, block)
    return _.detect (queue, function(other)
        return (block == other)
    end)
end

--returns another operator block in queue (if it exists) if the block param is an operator block
local function duplicate_op_in_queue (queue, block)
    if not block:IsOp() then
        return nil
    end
    return _.detect (queue, function(other)
        return other:IsOp()
    end)
end

--don't queue duplicate blocks. swap operators if 2 in queue.
function BlockGroup:Queue(block)
    --push onto end of list
    local duplicate_block = duplicate_in_queue (self.queue, block)
    local both_ops = duplicate_op_in_queue (self.queue, block)
    --[[ local duplicate = _.detect (self.queue, function(b)
            if (block:IsOp() and b:IsOp())then
                both_ops = true
                if b==block then duplicate_block = true end
                return true
            elseif b == block then
                duplicate_block = true
                return true
            end
            return false
        end) --]]
    if duplicate_block or both_ops then
        local duplicate = duplicate_block or both_ops
        -- remove duplicate from queue, to 'unselect' block
        for i, v in ipairs(self.queue) do
            if v == duplicate then
                table.remove(self.queue, i)
                break
            end
        end
        --_.reject(self.queue, function(b) return b==duplicate end)
        
        -- re-insert block if it's an operator, to swap operator
        
        if duplicate_block then
            block = nil
        end
    end
    
    if not block then return end

    if block:IsOp() then
        self.has_operator_queue = true
    end
    table.insert(self.queue,block)
    
end

--actually a dequeue from front to preserve order of clicking from user.
function BlockGroup:Dequeue()
    local block = table.remove(self.queue,1)
    if block.typeName == "Operator" then
        self.has_operator_queue = false
    end
    return block
end



--Accepts variable amounts of blocks and tries to make equation with them
--in the form of [num, op, num]
function BlockGroup:CanEvalBlocks(...)
    local t = arg
    local num_a, num_b, op
    -- O(n), n==number of args
    while (not num_a or not num_b or not op) and t.n>0 do
        local block = table.remove(t,1)
        t.n = t.n-1
        if not num_a and block:IsNum() then
            num_a = block
        elseif not num_b and block:IsNum() then
            num_b = block
        elseif not op and block:IsOp() then
            op = block
        end
    end
    if num_a and num_b and op then
        return num_a, op, num_b 
    else
        return false
    end
end

-- not const
function BlockGroup:EvalStack()
    oAssert(#self.queue >= 3, "block stack must be greater than 3 to eval")
    local num_a, op, num_b = self:CanEvalBlocks( self:Dequeue(),self:Dequeue(),self:Dequeue())
    local result = nil
    if num_a then
        local a, op_op, b = num_a:Value(), op.op, num_b:Value()
        result = op:Evaluate(num_a, num_b)
        oLog.Verbose(string.format("%d %s %d = %f",a, op_op, b, result))
        return result, self:DispatchEvent (self.sprite, "evaluate", {target = self, num_a=num_a, op=op,num_b=num_b, result = result})
    end
    return result
end

function BlockGroup:StackSize()
    return #self.queue
end

--prerequisites: number of blocks
function BlockGroup:GetRandomGoal()
    local numbers = self.blocks['Number']
    local ops = self.blocks['Operator']
    local number_keys = _.keys(numbers)
    local op_keys = _.keys(ops)
    if #number_keys < 2 or #op_keys < 1 then
        return nil
    end
    while true do
        local num_key_idx = math.random(#number_keys)
        local num_a_key = number_keys[num_key_idx]
        table.remove(number_keys,num_key_idx)
        local num_a = numbers[num_a_key]
        local num_b = numbers[number_keys[math.random(#number_keys)]]
        local op = ops[op_keys[math.random(#op_keys)]]
        return op:Evaluate(num_a, num_b)
    end
end

return BlockGroup