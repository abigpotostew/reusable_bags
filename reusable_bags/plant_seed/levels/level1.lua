local seed_level = require "plant_seed.src.level"

local l = seed_level()
local width, height = l:GetWorldViewSize()
local players = 2

local function setup()
    l:SetNumPlayer(2)
    l:BuildHolesNStuff()

end
return {l, setup}