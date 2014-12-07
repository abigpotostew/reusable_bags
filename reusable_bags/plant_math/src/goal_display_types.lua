local GoalDisplayType = require "plant_math.src.goal_display_type"

local function basic(level)
    local t = GoalDisplayType(level)
    local hidden = {}
    
    hidden.enter = function()end
    
    local reveal = {}
    
    reveal.enter = function(self,goal_text)
        local text = display.newText{text = tostring(goal_text), x=0,y=0,fontSize=24,parent=self.sprite, font=native.systemFont}
        text:setFillColor (1,1,1)
        text.anchorX = 0
        self.text = text
    end
    local destroy = {}
    destroy.enter = function(self)
        self.text:removeSelf()
    end
    t.states = {
            [t.state_ids.HIDDEN]=hidden,
            [t.state_ids.REVEAL]=reveal,
            [t.state_ids.DESTROY]=destroy}
    t:SetupStates (t.states)
    return t
end
    
return {
    basic=basic,
}