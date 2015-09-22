-- Vector2.lua
local LCS = require "opal.libs.LCS"

local EPSILON = 0.00001

local Vector2 = LCS.class {x=0, y=0}

local function isVector2Equivalent(obj)
	return (type(obj) == "table" and type(obj.x) == "number" and type(obj.y) == "number")
end

function Vector2:init (...)
    if (#arg == 0) then
		self.x = 0
		self.y = 0
	elseif (#arg == 1) then
		local other = arg[1]
		assert(isVector2Equivalent(other), "The Vector2 single argument constructor takes a table with both an x and a y property")
		self.x = other.x
		self.y = other.y
	elseif (#arg == 2) then
		self.x = arg[1]
		self.y = arg[2]
	else
		error("The Vector2 constructor takes zero, one or two arguments")
	end
end

function Vector2.__add (a, b)
    if (isVector2Equivalent(a) and isVector2Equivalent(b)) then
		return Vector2(a.x + b.x, a.y + b.y)
	else
		error("Cannot add dissimilar object to Vector2: " .. type(a) .. " to " .. type(b))
	end
end

function Vector2.__sub (a, b)
    if (isVector2Equivalent(a) and isVector2Equivalent(b)) then
		return Vector2(a.x - b.x, a.y - b.y)
	else
		error("Cannot subtract dissimilar object to Vector2: " .. type(a) .. " to " .. type(b))
	end
end
    
    
function Vector2.__mul (a, b)
    if (not isVector2Equivalent(a)) then a, b = b, a end

	if (type(b) == "number") then
		return Vector2(a.x * b, a.y * b)
	else
		error("Multiplying Vector2 by non-number object: " .. type(b))
	end
end
        
function Vector2.__div (a, b)
    if (not isVector2Equivalent(a)) then a, b = b, a end

	if (type(b) == "number") then
		return Vector2(a.x / b, a.y / b)
	else
		error("Dividing Vector2 with non-number object: " .. type(b))
	end
end
 

function Vector2.__unm (a)
	return Vector2(-a.x, -a.y)
end

function Vector2.__eq (a, b)
    if (not isVector2Equivalent(a)) then a, b = b, a end

	if (b == nil) then
		return false
	elseif (isVector2Equivalent(b)) then
		return (math.abs(a.x - b.x) <= EPSILON and math.abs(a.y - b.y) <= EPSILON)
	else
		error("Can't compare Vector2 to dissimilar object of type " .. type(b))
	end
end

function Vector2:__tostring ()
    return string.format("<%8.02f, %8.02f>", self.x ,self.y)
end

function Vector2:Lerp (other, t)
    return other * t + self * (1 - t)
end

function Vector2:Dot (other)
    assert(isVector2Equivalent(other), "Can't perform Vector2 dot product on dissimilar object of type " .. type(b))
	return (self.x * other.x + self.y * other.y)
end

function Vector2:Length()
    return math.sqrt(self:Dot(self))
end

function Vector2:Distance(other)
    assert(isVector2Equivalent(other), "Can't perform Vector2 distance on dissimilar object of type " .. type(b))
    return math.sqrt(math.pow(other.x-self.x,2) + math.pow(other.y-self.y,2))
end

function Vector2:Length2()
    return self:Dot(self)
end

function Vector2:Normalized()
    local mag = self:Length()
	return self / mag, mag
end

-- In Radians!
function Vector2:Angle (other)
    other = other or Vector2(0,0)
	assert(isVector2Equivalent(other), "Can't perform Vector2 angle on dissimilar object of type " .. type(other))
	return math.atan2(other.y-self.y,other.x-self.x)
end

function Vector2:Copy (other)
    return Vector2(self.x,self.y)
end

function Vector2:Mid (other)
    return ((other + -self)/2)+self
end

function Vector2.isVector2 (obj)
    return isVector2Equivalent(obj)
end

--Only non-const method besides constructor
function Vector2:Set (x, y)
    self.x, self.y = x or 0, y or 0
end

function Vector2:Get()
    return self.x, self.y
end

return Vector2