
local oSetup = setmetatable ({}, nil)

local function load_modules()
    oUtil = require "opal.src.utils.util"
    oLog = require "opal.src.utils.log"
    oTime = require "opal.src.utils.time"
    oAssert = require "opal.src.utils.assert"
    oMath = require "opal.src.utils.math"
    -- Put GLOBAL table in _G
    require "opal.src.globals"
end

local game;



local function opal_start_game
end

local function opal_setup(options)
    
end



oSetup.setup = opal_setup

return oSetup