local boat_direction = setmetatable({}, nil)
local Vector2 = require 'opal.src.vector2'
local _ = require "opal.libs.underscore"

local i=0
local function add_index(name, v)
    boat_direction[name] = v or i
    i=i+1
end

add_index ('NONE', Vector2(0,0))
add_index ('RIGHT', Vector2(1,0))
add_index ('DOWN', Vector2(0,1))
add_index ('LEFT', Vector2(-1,0))
add_index ('UP', Vector2(0,-1))

_.each (boat_direction, function(d) oUtil.lockObjectProperties(d) end)

oUtil.lockObjectProperties(boat_direction)

return boat_direction