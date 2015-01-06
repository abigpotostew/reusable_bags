local GoalDisplayType = require "plant_math.src.display.goal_display_type"

local function basic(level, id)
    local t = GoalDisplayType(level, id)
    local width = 45
    local radius = 15
    local hidden = {}
    
    hidden.enter = function (self)
        self.circle = display.newCircle( self.id * width, 0, radius )      
        
        self.sprite:insert(
            self.circle
            )
    end
    
    local reveal = {}
    
    reveal.enter = function (self, goal_text)
        local text = display.newText{text = tostring(goal_text), x= self.id * width,y=0,fontSize=24,parent=self.sprite, font=native.systemFont}
        text:setFillColor (1,1,1)
        text.anchorX = 0
        self.text = text
        
        transition.to(self.circle, {xScale=0.0001, yScale=0.0001, time=300, transition=easing.inOutCubic, onComplete=function()
                self.circle:removeSelf() end}) 
    end
    local destroy = {}
    destroy.enter = function(self)
        --self.text:removeSelf()
        self:removeSelf()
    end
    t.states = {
            [t.state_ids.HIDDEN]=hidden,
            [t.state_ids.REVEAL]=reveal,
            [t.state_ids.DESTROY]=destroy}
    t:SetupStates (t.states)
    return t
end

local function timer_basic (level)
    
end
    
return {
    basic=basic,
}