
local Actor = require "opal.src.actor"

local BASE = 0
local OPERATOR = 1
local NUMBER = 2

local function CancelTouch(event)
    local sprite = event.target
    if sprite.has_focus then
        display.getCurrentStage():setFocus( nil )
        sprite.has_focus = false
    end
end

local function touch (event)
    if event.phase == "began" then
        --display.getCurrentStage():setFocus( event.target )
        --event.target.has_focus = true
        event.target.owner:DispatchEvent(event.target, "block_touch",
            {block = event.target.owner, phase = event.phase})
    elseif event.phase == "moved" then
    elseif event.phase == "ended" then
        --TODO:revamp touch to trigger event on touch release
    end 
    return true
end

---------------------------
-- BaseDirt block
---------------------------
local BaseDirt = Actor:extends()
function BaseDirt:init(typeInfo, level)
    self:super("init", typeInfo, level, level:GetWorldGroup() )
    self.sprite = display.newGroup()
    self.group:insert(self.sprite)
    self.sprite.owner = self
    self.kind = BASE
    self:AddEvent("block_touch")
    self:AddEventListener(self.sprite, "touch", touch)
end

function BaseDirt:Kind ()
    return self.kind
end

function BaseDirt:CreateBlock (w,h,sprite_data)
    oAssert(self.sprite, 'BaseDirt:CreateBlock() - requires a sprite group')
    sprite_data = sprite_data or {}
    sprite_data.anchorX, sprite_data.anchorY = 0, 0
    local block = self:buildRectangleSprite (self.sprite, w, h, 0, 0, sprite_data)
    return block
end

function BaseDirt:AddLabel (text, options)
    options = options or {}
    options.text = text
    options.font = options.font or native.systemFont
    options.fontSize = options.fontSize or 12
    options.parent = options.parent or self.sprite
    local t = display.newText(options)
    self.sprite:insert(t)
    t:setFillColor (1,0,0)
end

function BaseDirt:IsNum()
    return false
end

function BaseDirt:IsOp()
    return false
end


---------------------------
-- OPERATOR dirt block
---------------------------
local Operator = BaseDirt:extends({ADD=1,SUB=2,MUL=3,DIV=4})

function Operator:GetOpColor(operator)
    if operator == Operator.ADD then
        return {.933333333,.862745098,.635294118} --light orange
    elseif operator == Operator.SUB then
        return {.635294118,.850980392,.933333333} --light blue
    elseif operator == Operator.MUL then
        return {.666666667,.533333333,.949019608} --light purple
    elseif operator == Operator.DIV then
        return {.949019608,.533333333,.576470588} --light red
    else
        return {1,0,1} --error color
    end
end

function Operator:init(operator, w, h, level)
    self:super("init",{typeName="Operator"},level)
    self.kind = OPERATOR
    oAssert.type(operator, 'number', "Operator dirt block requires a number type for it's operator")
    self.op = self:GetOp(operator)
    self.operator = operator
    self.block = self:CreateBlock ( w, h, {fill_color=self:GetOpColor(operator), stroke_color={0,0,0}})
    self:AddLabel(self.op, {x=w/2,y=h/2})
end

function Operator:Evaluate(block_a, block_b)
    oAssert (block_a:Kind() == NUMBER and block_b:Kind() ~= NUMBER , 
        "Can't evaluate on a block on a non-operator block")
    
    local operator = self.operator
    if operator == Operator.ADD then
        return block_a:Value() + block_b:Value()
    elseif operator == Operator.SUB then
        return block_a:Value() - block_b:Value()
    elseif operator == Operator.MUL then
        return block_a:Value() * block_b:Value()
    elseif operator == Operator.DIV then
        return block_a:Value() / block_b:Value()
    else
        return nil
    end
end

function Operator:GetOp (operator)
    if operator == Operator.ADD then
        return '+'
    elseif operator == Operator.SUB then
        return '-'
    elseif operator == Operator.MUL then
        return 'x'
    elseif operator == Operator.DIV then
        return '÷'
    else
        return 'ø'
    end
end

function Operator:IsOp()
    return true
end

---------------------------
-- NUMBER dirt block
---------------------------
local Number = BaseDirt:extends()

function Number:init(value, w, h, level)
    self:super("init",{typeName="Number"},level)
    self.kind = NUMBER
    oAssert.type(value, 'number', "Number dirt block requires a number for it's value")
    self.value = value
    self.block = self:CreateBlock ( w, h, {fill_color=
            {.850980392, .925490196,.631372549 }, stroke_color={0,0,0}})
    self:AddLabel(string.format("%d",value),{x=w/2,y=h/2})
end

function Number:Value(block_a, block_b)
    return self.value
end

function Number:IsNum()
    return true
end

return {Number=Number, Operator=Operator}