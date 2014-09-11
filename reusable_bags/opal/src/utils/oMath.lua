local o_math = setmetatable ({}, nil)

o_math.binom = function()
    return math.random() - math.random()
end

return o_math