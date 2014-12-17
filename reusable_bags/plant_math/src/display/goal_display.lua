--todo
-- GoalDisplay shows a goal

local Actor = require 'opal.src.actor'
local _ = require "opal.libs.underscore"

local GoalDisplay = Actor:extends()

function GoalDisplay:init (level)
    self:super("init", {typeName="GoalDisplay"}, level)
    self.num_goals=0
    self.sprite = display.newGroup()
    self.first_goal = true
end

function GoalDisplay:SetNumGoals(n)
    self.num_goals = n
end

--Assumes that the user set the actor.sprite field
function GoalDisplay:CreateHiddenGoalTypes(level,num_goals,goal_type)
    --x, y, w, h = x or 0, y or 0, w or 200, h or 50
    self.goals = {}
    for i=1,num_goals do
        -- create goal type
        local goal_display_object = goal_type(level)
        goal_display_object:SetState(goal_display_object.state_ids.HIDDEN)
        self.sprite:insert(goal_display_object.sprite)
        table.insert(self.goals, goal_display_object)
    end
end

function GoalDisplay:RevealNextGoal(...)
    oAssert(#self.goals>0,"GoalDisplay:RevealNextGoal():: requires at least 1 goal in the goals list")
    if not self.first_goal then
        local curr_goal = table.remove(self.goals,1)
        curr_goal:SetState(curr_goal.state_ids.DESTROY,curr_goal)
    else
        self.first_goal = false
    end
    local next_goal = self.goals[1]
    if not next_goal then return end
    next_goal:SetState(next_goal.state_ids.REVEAL, next_goal, unpack(arg))
end

--TODO
function GoalDisplay:GetCurrentGoal()
    return 
end

return GoalDisplay