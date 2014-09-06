--bagTypes--bag
local Bags = setmetatable({}, nil)

local Bag = require "actors.bag"

local function newTypeInfo()
    return {physics={}, anims={}, sounds={}}
end

-------------------------------------------------------------------------------
-- Bird Defaults

local function SetDefaults(b)
	-- Anims: What the bird looks like
	b.anims.normal = ""										-- What the bird b.anims.normally looks like
	b.anims.hurt = ""										-- When the bird gets b.anims.hurt (hits anything for now)
	b.anims.hurtParticle = ""--"art/explosions/sonar_explosion"	-- When the bird gets hurt spawn this particle
	b.anims.death = ""										-- When the bird dies (all causes of death for now)
	b.anims.deathParticle = ""--"art/explosions/wings"			-- When the bird dies spawn this particle
	b.anims.hitHut = ""--"art/explosions/sonar_explosion"		-- The graphic played when a bird hits a hut -> soon to be moved to huts

	-- Sounds: What the bird sounds like
	b.sounds.launch = "boink1.wav"		-- When a bird launches
	b.sounds.hitHut = "kung-fu.wav"	-- When a bird hits the player's base
	b.sounds.hurt = "kung-fu.wav"			-- When a bird hits something
	b.sounds.death = "kung-fu.wav"		-- When a bird dies (all causes of b.anims.death for now)

	-- Physics: How the bird acts in the physics simulator
	b.physics.mass = 2.0		-- How much b.physics.mass the bird has in kilograms
	b.physics.bounce = 0.3		-- How bouncy the bird is - 0.0 means no b.physics.bounce 1.0 means b.physics.bounce  away at full speed
	b.physics.friction = 0.3	-- How much friction the bird has when sliding on things
    b.physics.category = 'bag'
    b.physics.colliders = {'bag_collider'}
    b.physics.gravityScale = 0.0
    
    b.physics.bodyType = 'kinematic'
    b.physics.isSensor = false
    

	-- General Bag Info
	b.scale = 0.5				-- How big the bag is compared to its normal anim size
    b.collisionBoxScale = 0.5
	b.capacity = 13				-- How many capacities a bag can take before it fills
	b.weight = 0 		-- How many seconds the b.anims.hurt anim should be held for before returning to b.anims.normal
	b.scoreScale = 1.0			-- How much to multiply scored points when hitting this bird
    
    b.typeName = "bag"
    b.bagType = ""

end

-------------------------------------------------------------------------------
-- plastic bag, weak!

Bags["plastic"] = function()
	local b = newTypeInfo()
	SetDefaults(b)
    
    b.bagType = "plastic"

	b.sounds.hitHut = "smack_jaw.wav"	-- When a bird hits the player's base
	b.sounds.hurt = "smack_bird01.wav"			-- When a bird hits something
	
	b.physics.mass = 1
	b.physics.bounce = 0.0
    
    b.physics.category = 'bag'

	b.scale = 0.25
	b.capacity = 3

	return b
end

-------------------------------------------------------------------------------
-- paper bag, medium strength

Bags["paper"] = function()
	local b = newTypeInfo()
	SetDefaults(b)
    
    b.bagType = "paper"
    
	b.physics.mass = 20.1
	b.physics.bounce = 0.9
    

	b.scale = .25
	b.capacity = 6

	return b
end

-------------------------------------------------------------------------------
-- canvas reusable bag

Bags["canvas"] = function()
	local b = newTypeInfo()
	SetDefaults(b)
    
    b.bagType = "canvas"

	b.sounds.hitHut = "smack_jaw.wav"	-- When a bird hits the player's base
	b.sounds.hurt = "smack_bird01.wav"			-- When a bird hits something
	
	b.physics.mass = 20.1
	b.physics.bounce = 0.9
    

	b.scale = .25
	b.capacity = 12 -- Holy Angry bird! (dont want to die right away)

	return b
end


Bags["CreateBag"] = function(bag_name, x, y, level, scale)
    local bagType = Bags[bag_name](scale)
    if scale then bagType.scale = scale end
    return Bag(x or 0,y or 0, bagType, level)
end



-- Don't put anything after this line or it won't work!
return Bags

