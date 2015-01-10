local Opal = require "opal.src.event":extends()
local _ = require "opal.libs.underscore"


function Opal:init(name)
    self:super("init", name or "Opal Instance")
    self:GetOptions()
end

local function run_tests(setup, teardown)
    require "opal.src.opal_tests.test_all".Run(setup, teardown)
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
    oTime = require "opal.src.utils.time"() --instance of time
    oAssert = require "opal.src.utils.assert"
    oMath = require "opal.src.utils.math"
    -- Put GLOBAL table in _G
    --TODO:
    require "opal.src.globals"
end

function Opal:Setup(options)
    self.options = options
    load_modules(self:Option('modules'))
    
    math.randomseed(self:Option('random_seed') or os.time())
    
    Runtime:addEventListener("enterFrame", oTime)
    
    oLog.SetLogLevel (self:Option('log_level') or oLog.DEBUG)
    
    if self:Option('multitouch') then
        system.activate( "multitouch" )
    end
    
end

function Opal:Option(name)
    return self.options:Get(name)
end

--Kick off unit tests and game
function Opal:Begin()
    if self:Option('run_all_tests') or self.options:Get('tests_only') then
        run_tests(self:Option('global_test_setup'),self:Option('global_test_teardown'))
        if self:Option('tests_only') then
            os.exit(0)
            return
        end
    end
    
    if self:Option('skip_scene_creation') then
        return
    end
    
    local composer = require "composer"
    local entry_scene = self:Option('entry_scene')
    local game_parms = {params=self:Option("game")}
    composer.gotoScene (entry_scene, game_parms)
    --composer.gotoScene('opal.src.levelScene', self.options.game)
end

function Opal:Destroy()
    --cleanup code
end

function Opal:GetOptions()
    if not self.options then
        self.options = require 'opal.src.utils.chain' ()
    end
    return self.options
end

return Opal