-----------------------------------------------------------------------------------------
--
-- Opal game entry point!
-- By Stewart Bracken
--
-----------------------------------------------------------------------------------------
local fps = require "opal.libs.fps"

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
    oLog.SetLogLevel(oLog.DEBUG)
    physics = corona_physics
end

local opal = require"opal.src.opal"() --new instance of opal framework

local additional_tests = {
    ['plant_seed.tests.']={'plant_tests'},
    ['plant_math.tests.']={'plant_math_tests'},
    ['clean_ocean.tests.']={'clean_ocean_tests'},
    ['ocean_pinball.tests.']={'ocean_pinball_tests'},
    }

local game_options = opal:GetOptions()
    :Set('run_all_tests', true)
    :Set('tests_only', false)
    :Set('global_test_setup', test_setup)
    :Set('global_test_teardown', test_teardown)
    --:Set('entry_scene', "plant_math.menu.main_menu")
    --:Set('game', {level="plant_math.levels.level1"})
    
    --:Set('entry_scene', 'clean_ocean.menu.main_menu')
    
    --:Set('entry_scene', "reusable_bags.menu.main_menu")
    :Set('entry_scene', 'opal.src.levelScene')
    :Set('game', {level="plant_seed.levels.level1"})
    
    :Set("debug_draw", true)
    :Set('composer_debug', true) --doesn't work?
    :Set('tests', additional_tests)

local performance = fps.new()
performance.group.alpha = 0.7

opal:Setup(game_options)
opal:Begin() --kick off game