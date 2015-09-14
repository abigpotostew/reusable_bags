local Actor = require "opal.src.actor"

local DebugActor = Actor:extends()

function DebugActor:init(...)
    --Construct parent class
    --unpack isn't working for me at the moment, not sure why
	self:super('init', arg[1],arg[2],arg[3],arg[4]) 
end

--copy next few methods from actor. still haven't refactored it out.
function DebugActor:createCircularSprite (radius,x,y,sprite_data)    
    assert(self.group,"DebugActor:createCircularSprite(): Please initialize this actor's group before creating a sprite")
    sprite_data = sprite_data or {}
    x, y = x or 0, y or 0
    local fill_color = sprite_data.fill_color or {1,0,1} --hot pink!
    local stroke_color = sprite_data.stroke_color or {1,0,1} --hot 

    local sprite = display.newCircle(self.group, x, y, radius)
    sprite.owner = self
    sprite:setFillColor(unpack(fill_color))
    sprite:setStrokeColor (unpack (stroke_color))
    if sprite_data.stroke_width then sprite.strokeWidth = sprite_data.stroke_width end
    self.sprite = sprite
    return sprite
end

--???
function DebugActor:createRectangleSprite (w,h,x,y,sprite_data)
    assert(self.group,"DebugActor:createRectangleSprite(): Please initialize this actor's group before creating a sprite")
    self.sprite =  self:buildRectangleSprite (self.group, w, h, x, y, sprite_data)
    return self.sprite
end

-- sprite_data = {fill_color={1,0,1}, stroke_color={1,0,1}, anchorX = .5, anchorY = .5, stroke_width=1}
function DebugActor:buildRectangleSprite (group,w,h,x,y, sprite_data)
    assert(group,"DebugActor:buildRectangleSprite(): Please initialize group before creating a sprite rectangle")
    sprite_data = sprite_data or {}
    x, y = x or 0, y or 0
    local fill_color = sprite_data.fill_color or {1,0,1} --hot pink!
    local stroke_color = sprite_data.stroke_color or {1,0,1} --hot pink!
    local anchorX = sprite_data.anchorX or sprite_data.typeInfo and sprite_data.anchorX or self.typeInfo.anchorX or 0.5
    local anchorY = sprite_data.anchorY or sprite_data.typeInfo and sprite_data.typeInfo.anchorY or self.typeInfo.anchorY or 0.5

    local sprite = display.newRect(group, x, y, w, h)
    sprite.owner = self
    sprite:setFillColor(unpack(fill_color))
    sprite:setStrokeColor (unpack (stroke_color))    
    sprite.anchorX, sprite.anchorY = anchorX, anchorY
    if sprite_data.stroke_width then sprite.strokeWidth = sprite_data.stroke_width end
    return sprite
end

return DebugActor