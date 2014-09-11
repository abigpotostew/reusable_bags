
local oSetup = setmetatable ({}, nil)

local function load_modules()
    oLog = require "opal.src.utils.oLog"
    oTime = require "opal.src.utils.oTime"
    oAssert = require "opal.src.utils.oAssert"
    oMath = require "opal.src.utils.oMath"
    -- Put GLOBAL table in _G
    require "opal.src.globals"
end

local function opal_setup()
    load_modules()
    
    math.randomseed(os.time())
    Runtime:addEventListener("enterFrame", oTime)
    
    oLog:SetLogLevel (oLog.DEBUG)
end

oSetup.setup = opal_setup

return oSetup