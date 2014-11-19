local Unit = require "opal.src.test.unit"
local Opal = require "opal.src.opal"

local u = Unit("Opal_Test_Suite")


u:Test ( "Setup_default_modules", function(self)
    local opal = Opal()
    
    self:ASSERT_TRUE (_G.oAssert)
    self:ASSERT_TRUE (_G.oUtil)
    self:ASSERT_TRUE (_G.oLog)
    self:ASSERT_TRUE (_G.oTime)
    self:ASSERT_TRUE (_G.oMath)
end)

u:Test ("Setup_custom_module", function(self)
    local opal = Opal()
    local function m(name,path)
        return {name=name,path=path}
    end
    opal:Setup({skip_scene_creation=true, modules = {m('OpalTestGlobal', 'opal.src.opal')}})
    self:ASSERT_TRUE (_G.OpalTestGlobal)
end)

return u