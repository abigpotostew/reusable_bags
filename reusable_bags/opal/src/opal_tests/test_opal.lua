local Unit = require "opal.src.test.unit"
local Opal = require "opal.src.opal"

u = Unit("Opal_Test_Suite")


u:Test ( "Setup_default_modules", function()
    local opal = Opal()
    
    u:ASSERT_TRUE (_G.oAssert)
    u:ASSERT_TRUE (_G.oUtil)
    u:ASSERT_TRUE (_G.oLog)
    u:ASSERT_TRUE (_G.oTime)
    u:ASSERT_TRUE (_G.oMath)
end)

u:Test ("Setup_custom_module", function()
    local opal = Opal()
    local function m(name,path)
        return {name=name,path=path}
    end
    opal:Setup({skip_scene_creation=true, modules = {m('OpalTestGlobal', 'opal.src.opal')}})
    u:ASSERT_TRUE (_G.OpalTestGlobal)
end)

return u