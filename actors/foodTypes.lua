--food types definitions
local Foods = setmetatable({}, nil)

local Food = require "actors.food"

local function newTypeInfo()
    return {physics={}, anims={}, sounds={}}
end

-------------------------------------------------------------------------------
-- Bird Defaults

local function SetDefaults(f)
	-- Anims: What the food looks like
	f.anims.normal = ""										-- What the bird b.anims.normally looks like
	f.anims.hurt = ""										-- When the bird gets b.anims.hurt (hits anything for now)
	f.anims.hurtParticle = ""--"art/explosions/sonar_explosion"	-- When the bird gets hurt spawn this particle
	f.anims.death = ""										-- When the bird dies (all causes of death for now)
	f.anims.deathParticle = ""--"art/explosions/wings"			-- When the bird dies spawn this particle
	f.anims.hitHut = ""--"art/explosions/sonar_explosion"		-- The graphic played when a bird hits a hut -> soon to be moved to huts

	-- Sounds: What the bird sounds like
	f.sounds.launch = "boink1.wav"		-- When a bird launches
	f.sounds.hitHut = "kung-fu.wav"	-- When a bird hits the player's base
	f.sounds.hurt = "kung-fu.wav"			-- When a bird hits something
	f.sounds.death = "kung-fu.wav"		-- When a bird dies (all causes of b.anims.death for now)

	-- Physics: How the bird acts in the physics simulator
	f.physics.mass = 2.0		-- How much b.physics.mass the bird has in kilograms
	f.physics.bounce = 0.5		-- How bouncy the bird is - 0.0 means no b.physics.bounce 1.0 means b.physics.bounce  away at full speed
	f.physics.friction = 0.3	-- How much friction the bird has when sliding on things
    f.physics.category = 'food'
    f.physics.colliders = {'bag', 'food', 'ground'}
    f.physics.gravityScale = 1.0
    f.physics.angularDamping = 0.01
    f.physics.linearDamping = 0.01
    f.physics.isSensor = false
    
    f.physics.bodyType = 'dynamic'
    

	-- General Food Info
	f.scale = 0.25				-- How big the bird is compared to its normal anim size
	f.weight = 2 		-- How many seconds the b.anims.hurt anim should be held for before returning to b.anims.normal
	f.scoreScale = 1.0			-- How much to multiply scored points when hitting this bird
    
    f.foodType = "light"
    f.typeName = "food"

end

-------------------------------------------------------------------------------
-- light weight foods,

Foods["light"] = function()
	local f = newTypeInfo()
	SetDefaults(f)
    f.foodType = "light_food"
	f.weight = 1
	return f
end

Foods["lightmedium"] = function()
	local f = newTypeInfo()
	SetDefaults(f)
    f.foodType = "lightmedium_food"
	f.weight = 2
	return f
end
Foods["medium"] = function()
	local f = newTypeInfo()
	SetDefaults(f)
    f.foodType = "medium_food"
	f.weight = 3
	return f
end
Foods["mediumheavy"] = function()
	local f = newTypeInfo()
	SetDefaults(f)
    f.foodType = "mediumheavy_food"
	f.weight = 4
	return f
end
Foods["heavy"] = function()
	local f = newTypeInfo()
	SetDefaults(f)
    f.foodType = "heavy_food"
	f.weight = 5
	return f
end



Foods["CreateFood"] = function( x, y, weight, food_name, level, scale)
    local foodType = Foods[weight]()
    if scale then foodType.scale = scale end
    return Food:init(x or 0, y or 0, foodType, food_name, level)
end



-- Don't put anything after this line or it won't work!
return Foods

