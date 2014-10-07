-----------------------------------------------------------------------------------------
--
-- Reusable Bag game entry point!
-- By Stewart Bracken
--
-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

require("mobdebug").start()

require "opal.src.oSetup".setup()

local composer = require "composer"

--local level = "reusable_bags.levels.level1"
local level = "plant_seed.levels.level1"
composer.gotoScene('opal.src.levelScene', {params={level=level, debug_draw = true}})