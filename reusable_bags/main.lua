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
--composer.gotoScene('opal.src.levelScene', {params={level=require("reusable_bags.levels.level1")}})
composer.gotoScene('opal.src.levelScene', {params={level=require("plant_seed.levels.level1")}})