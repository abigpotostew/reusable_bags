--todo
--builds states for display goals
-- user defined hidden and revealed states. controlled by goal_display.lua

local Actor = require 'opal.src.actor'
local _ = require "opal.libs.underscore"
local stateMachine = require "opal.src.stateMachine"

local state_ids = {HIDDEN=1, REVEAL=2, DESTROY=3}

local GoalDisplayType = Actor:extends({state_ids=state_ids})

function GoalDisplayType:init (level)
    self:super("init", {typeName="GoalDisplayType"}, level)
    
    self.sprite = display.newGroup()
    self.state_machine = stateMachine.Create()
end


--requires 2 states tables with minimum an enter function contained
function GoalDisplayType:SetupStates (display_states)
    local state_machine = self.state_machine
    for key,state in pairs(state_ids) do
        state_machine:SetState(state, {
            enter = display_states[state].enter,
            exit = display_states[state].exit
        })
    end
end

return GoalDisplayType