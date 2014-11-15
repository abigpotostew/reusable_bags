-----------------------------------------------------------------------------------------
--
-- Reusable Bag game entry point!
-- By Stewart Bracken
--
-----------------------------------------------------------------------------------------
display.setStatusBar( display.HiddenStatusBar )

require("mobdebug").start()

local function test_setup()
    oLog.SetLogLevel(oLog.DEBUG)
end

local function test_teardown()
    oLog.SetLogLevel(oLog.VERBOSE)
end

local game_options = {
        run_all_tests=true,
        tests_only = false, -- runs only tests
        global_test_setup = test_setup,
        global_test_teardown = test_teardown,
        game = {
            params={
--                level = "plant_seed.levels.level1", --initial level of game
                  level="plant_math.levels.level1",
                debug_draw = true
                }
            }
        
    }

local opal = require"opal.src.opal"() --new instance of opal framework

opal:Setup(game_options)
opal:Begin() --kick off game