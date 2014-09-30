
local oSetup = setmetatable ({}, nil)

local function load_modules()
    oUtil = require "opal.src.utils.util"
    oLog = require "opal.src.utils.oLog"
    oTime = require "opal.src.utils.oTime"
    oAssert = require "opal.src.utils.oAssert"
    oMath = require "opal.src.utils.oMath"
    -- Put GLOBAL table in _G
    require "opal.src.globals"
end

local function opal_setup(options)
    options = options or {}
    load_modules()
    
    math.randomseed(options.random_seed or os.time())
    Runtime:addEventListener("enterFrame", oTime)
    
    oLog.SetLogLevel (options.log_level or oLog.DEBUG)
    
    if options.multitouch then
        system.activate( "multitouch" )
    end
end

oSetup.setup = opal_setup

return oSetup