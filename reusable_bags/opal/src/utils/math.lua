local o_math = setmetatable ({}, nil)

o_math.Binom = function()
    return math.random() - math.random()
end

--Returns -1 or 1
o_math.RandomSign = function()
    return math.random(0,1)*2-1
end

return o_math