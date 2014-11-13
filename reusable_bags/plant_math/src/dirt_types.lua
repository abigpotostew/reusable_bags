
local Actor = require "opal.src.actor"

local BASE = 0
local OPERATOR = 1
local NUMBER = 2

---------------------------
-- BaseDirt block
---------------------------
local BaseDirt = Actor:extends()
function BaseDirt:init(typeInfo, level)
    self:super("init", typeInfo, level )
    self.sprite = display.newGroup()
    self.kind = BASE
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
    options.text = text
    options.font = options.font or native.systemFont
    options.fontSize = options.fontSize or 10
    display.newText(options)
end

---------------------------
-- OPERATOR dirt block
---------------------------
local Operator = BaseDirt:extends({PLUS=1,SUB=2,MUL=3,DIV=4})

function Operator:init(operator, w, h, level)
    self:super("init",{typeName="Operator"},level)
    self.kind = OPERATOR
    oAssert.type(operator, 'number', "Operator dirt block requires a number type for it's operator")
    self.op = self:GetOp(operator)
    self.operator = operator
    self.block = self:CreateBlock ( w, h, {fill_color={.850980392, .925490196,.631372549 }, stroke_color={0,0,0}})
    self:AddLabel(self.op,{parent=self.sprite})--, x = w/2, y = h/2
end

function Operator:Evaluate(block_a, block_b)
    oAssert (block_a:Kind() == NUMBER and block_b:Kind() ~= NUMBER , "Can't evaluate on a block on a non-operator block")
end

function Operator:GetOp (operator)
    if operator == Operator.PLUS then
        return '+'
    elseif operator == Operator.SUB then
        return '-'
    elseif operator == Operator.MUL then
        return 'x'
    elseif operator == Operator.PLUS then
        return '÷'
    else
        return 'ø'
    end
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
    self.block = self:CreateBlock ( w, h, {fill_color={.850980392, .925490196,.631372549 }, stroke_color={0,0,0}})
    self:AddLabel(string.format("%d",value),{parent=self.sprite})--, x = w/2, y = h/2
end

function Number:Value(block_a, block_b)
    oAssert (block_a:Kind() == NUMBER and block_b:Kind() ~= NUMBER , "Can't evaluate on a block on a non-operator block")
end

return {Number=Number, Operator=Operator}