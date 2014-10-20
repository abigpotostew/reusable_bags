-----------------------------------------------------------------------------------------
--
-- Reusable Bag game entry point!
-- By Stewart Bracken
--
-----------------------------------------------------------------------------------------
display.setStatusBar( display.HiddenStatusBar )

require("mobdebug").start()

local game_options = {
        run_all_tests=true,
        tests_only = true, -- runs only tests
        game = {
            params={
                level = "plant_seed.levels.level1", --initial level of game
                debug_draw = true
                }
            }
        
    }

local opal = require"opal.src.opal"() --new instance of opal framework

opal:Setup(game_options)
opal:Begin() --kick off game