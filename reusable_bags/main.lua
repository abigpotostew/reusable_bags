-----------------------------------------------------------------------------------------
--
-- Opal game entry point!
-- By Stewart Bracken
--
-----------------------------------------------------------------------------------------
display.setStatusBar( display.HiddenStatusBar )

require("mobdebug").start()

local corona_physics = nil
local function test_setup()
    oLog.SetLogLevel(oLog.DEBUG)
    
    --Suppress physics error messages for tests
    corona_physics = physics
    local empty_function = function()end
    physics = {start=empty_function, stop=empty_function,addBody=empty_function}
end

local function test_teardown()
    oLog.SetLogLevel(oLog.VERBOSE)
    physics = corona_physics
end

local opal = require"opal.src.opal"() --new instance of opal framework

local game_options = opal:GetOptions()
    :Set('run_all_tests', true)
    :Set('tests_only', false)
    :Set('global_test_setup', test_setup)
    :Set('global_test_teardown', test_teardown)
    :Set('entry_scene', "plant_math.menu.main_menu")
    :Set('game', {level="plant_math.levels.level1"})
    :Set("debug_draw", true)




opal:Setup(game_options)
opal:Begin() --kick off game