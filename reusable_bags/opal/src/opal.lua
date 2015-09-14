local Opal = require "opal.src.event":extends()
local _ = require "opal.libs.underscore"
local composer = require 'composer'
local Chain = require 'opal.src.utils.chain'

function Opal:init(name)
    self:super("init", name or "Opal Instance")
    self:GetOptions()
end

local function run_tests(setup, teardown, additional_tests)
    require "opal.src.opal_tests.test_all".Run(setup, teardown, additional_tests)
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
    oColor = require 'opal.src.utils.color'
    -- Put GLOBAL table in _G
    --TODO:
    require "opal.src.globals"
end

function Opal:Setup(options)
    self.options = options
    load_modules(self:Option('modules'))
    
    math.randomseed(self:Option('random_seed') or os.time())
    
    Runtime:addEventListener("enterFrame", oTime)
    
    if self:Option('multitouch') then
        system.activate( "multitouch" )
    end
    
end

function Opal:Option(name)
  if self.options then
    return self.options:Get(name)
  end
end

--Kick off unit tests and game
function Opal:Begin()
    if self:Option('run_all_tests') or self.options:Get('tests_only') then
        run_tests(self:Option('global_test_setup'),self:Option('global_test_teardown'),self:Option('tests'))
        if self:Option('tests_only') then
            os.exit(0)
            return
        end
        (require "opal.src.actor").ClearTypenames()
    end
    
    if self:Option('skip_scene_creation') then
        return
    end
    
    if self:Option('composer_debug') then
        composer.isDebug = true -- this isn't working
    end
    
    -- Go to entry scene from game options (set in main)
    if not self:Option('entry_scene') then
        oLog.Fatal ("Opal:Begin() - entry_scene required in main game options")
        return os.exit(1)
    end
    local entry_scene = self:Option('entry_scene')
    --local game_parms = {params=self:Option("game")}
    self:GoToScene (entry_scene)
end

function Opal:Destroy()
    --cleanup code
end

function Opal:GetOptions()
    if not self.options then
        self.options = Chain () --create empty chain table
    end
    return self.options
end

--params in this case is composer params table
function Opal:GoToScene (scene_path, params)
    if params then
        oAssert.type (params, 'table', 'plz use table for params. k.')
    end

    composer.gotoScene (scene_path, params)
end

--params is a key value table which gets assigned to the corona corona params table
function Opal:GoToLevelScene (level_scene_path, params)
    if params then
        oAssert.type (params, 'table', 'plz use table for params. k.')
    end
    
    params = params or {}
    params.level = level_scene_path

    self:GoToScene ('opal.src.levelScene', {params=params})
end

return Opal