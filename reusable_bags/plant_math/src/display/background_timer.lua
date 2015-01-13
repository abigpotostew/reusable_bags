local _ = require "opal.libs.underscore"
local BackgroundTimer = (require 'opal.src.actor'):extends()
local Vector2 = require "opal.src.vector2"

function BackgroundTimer:init (level, width, height, color_bg, color_fg, progress)
    self:super("init", {typeName="Background"}, level)
    oAssert(width and height, "BackgroundTimer:init() - requires width & height")
    
    self.sprite = display.newGroup()
    progress = progress or 1.0
    color_bg = color_bg or {255/255,153/255,153/255}
    color_fg = color_fg or {243/255,124/255,124/255}
    
    self.size = Vector2(width, height)
    
    self.background = display.newRect (self.sprite, 0,0, width, height)
    self.background:setFillColor (unpack (color_bg))
    self.background.anchorX = 0.0
    self.background.anchorY = 0.0
    self.foreground = display.newRect (self.sprite, 0,0, width, height)
    self.foreground:setFillColor (unpack (color_fg))
    self.foreground.anchorX = 0.0
    self.foreground.anchorY = 0.0
    
    self.time = 0
end

--progress is [0..1], 0 means you're out of time...
function BackgroundTimer:ResetProgress (progress, time_ms)
    self.time = time_ms
    
    --local scale = (self.time - self.timer)/self.time 
    --self.foreground.xScale = scale
    
    self:AddTransition ({onComplete=function()end, xScale=0.0001,time=time_ms*progress}, self.foreground)
end

return BackgroundTimer