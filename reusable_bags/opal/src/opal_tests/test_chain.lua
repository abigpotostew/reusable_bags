local Chain = require 'opal.src.utils.chain'
local Unit = require "opal.src.test.unit"
local oAssert = require "opal.src.utils.assert"

local u = Unit("oAssert Test Suite")

u:Test ( "Copy", function(self)
    --self:ASSERT_TRUE(1==1)
    local chain1 = Chain():Set('big_butt', 'yes')
    --chain1
    local chain2 = Chain(chain1)
    
    self:ASSERT_TRUE(chain1:Get('big_butt')=='yes')
    self:ASSERT_TRUE(chain2:Get('big_butt')=='yes')
end)

u:Test ( "Basic_Set_And_Get", function(self)
    --self:ASSERT_TRUE(1==1)
    local chain = Chain():Set('pickle', 'dill'):Set('fermented', 'yes'):Set(12, 12)
    self:ASSERT_TRUE(chain:Get('pickle')=='dill')
    self:ASSERT_TRUE(chain:Get('fermented')=='yes')
    self:ASSERT_TRUE(chain:Get(12)==12)
end)


u:Test ( "Immutibility", function(self)
    --self:ASSERT_TRUE(1==1)
    local chain1 = Chain():Set('big_butt', true)
    local chain2 = Chain(chain1):Set('cia_tortures','yes')
    self:ASSERT_FALSE(chain1:Get('cia_tortures')=='no')
end)

u:Test ("Table_Set", function(self)
    local chain = Chain():Set({one=2, sex='please', [3]='four'})
    self:ASSERT_TRUE(chain:Get('one')==2)
    self:ASSERT_TRUE(chain:Get('sex')=='please')
    self:ASSERT_TRUE(chain:Get(3)=='four')
end)

return u
