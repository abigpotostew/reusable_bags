local Opal = require "opal.src.event"
local _ = require "opal.libs.underscore"


function Opal:init()
    
end

local function run_tests()
    require "opal.src.opal_tests.test_all".Run()
end

local function load_modules(module_paths_and_name)
    -- Addtional custom modules to load and place in global namespace
    if module_paths_and_name then
        _.each (module_paths_and_name, function(m) 
                _G[m.name] = require (m.path)
        end)
    end
    --standard opal setup
    oUtil = require "opal.src.utils.util"
    oLog = require "opal.src.utils.log"
    oTime = require "opal.src.utils.time"
    oAssert = require "opal.src.utils.assert"
    oMath = require "opal.src.utils.math"
    -- Put GLOBAL table in _G
    --TODO:
    require "opal.src.globals"
end

function Opal:Setup(options)
    options = options or {}
    self.options = options
    load_modules(options.modules)
    
    math.randomseed(options.random_seed or os.time())
    
    Runtime:addEventListener("enterFrame", oTime)
    
    oLog.SetLogLevel (options.log_level or oLog.DEBUG)
    
    if options.multitouch then
        system.activate( "multitouch" )
    end
    
end

--Kick off unit tests and game
function Opal:Begin()
    if self.options.run_all_tests or self.options.tests_only then
        run_tests()
        if self.options.tests_only then
            os.exit(0)
            return
        end
    end
    
    local composer = require "composer"
    composer.gotoScene('opal.src.levelScene', options.game)
end

return Opal