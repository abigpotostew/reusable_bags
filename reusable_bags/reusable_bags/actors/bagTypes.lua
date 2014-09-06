--bagTypes--bag
local Bags = setmetatable({}, nil)

local Bag = require "reusable_bags.actors.bag"
local _ = require "opal.libs.underscore"

local function newTypeInfo()
    return {physics={}, anims={}, sounds={}}
end

local bag_types = { "plastic", "paper", "canvas" }

-------------------------------------------------------------------------------
-- bag Defaults

local function SetDefaults(b)
	-- Anims: What the bag looks like
	b.anims.normal = ""										-- What the bag b.anims.normally looks like
	b.anims.hurt = ""										-- When the bag gets b.anims.hurt (hits anything for now)
	b.anims.hurtParticle = ""--"art/explosions/sonar_explosion"	-- When the bag gets hurt spawn this particle
	b.anims.death = ""										-- When the bag dies (all causes of death for now)
	b.anims.deathParticle = ""--"art/explosions/wings"			-- When the bag dies spawn this particle
	b.anims.hitHut = ""--"art/explosions/sonar_explosion"		-- The graphic played when a bag hits a hut -> soon to be moved to huts

	-- Sounds: What the bag sounds like
	b.sounds.launch = "boink1.wav"		-- When a bag launches
	b.sounds.hitHut = "kung-fu.wav"	-- When a bag hits the player's base
	b.sounds.hurt = "kung-fu.wav"			-- When a bag hits something
	b.sounds.death = "kung-fu.wav"		-- When a bag dies (all causes of b.anims.death for now)

	-- Physics: How the bag acts in the physics simulator
	b.physics.mass = 2.0		-- How much b.physics.mass the bag has in kilograms
	b.physics.bounce = 0.3		-- How bouncy the bag is - 0.0 means no b.physics.bounce 1.0 means b.physics.bounce  away at full speed
	b.physics.friction = 0.3	-- How much friction the bag has when sliding on things
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
	b.scoreScale = 1.0			-- How much to multiply scored points when hitting this bag
    
    b.typeName = "bag"
    b.bagType = ""

end

-------------------------------------------------------------------------------
-- plastic bag, weak!

Bags["plastic"] = function()
	local b = newTypeInfo()
	SetDefaults(b)
    
    b.bagType = "plastic"

	b.sounds.hitHut = "smack_jaw.wav"	-- When a bag hits the player's base
	b.sounds.hurt = "smack_bag01.wav"			-- When a bag hits something
	
	b.physics.mass = 1
	b.physics.bounce = 0.0
    

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

	b.sounds.hitHut = "smack_jaw.wav"	-- When a bag hits the player's base
	b.sounds.hurt = "smack_bag01.wav"			-- When a bag hits something
	
	b.physics.mass = 20.1
	b.physics.bounce = 0.9
    

	b.scale = .25
	b.capacity = 12 -- Holy Angry bag! (dont want to die right away)

	return b
end

Bags["GetBagTypes"] = function()
    local out_copy = {}
    _.each(bag_types, function(i) table.insert(out_copy,i) end)
    return out_copy
end

Bags["CreateBag"] = function(bag_name, x, y, level, scale)
    local bagType = Bags[bag_name](scale)
    if scale then bagType.scale = scale end
    return Bag(x or 0,y or 0, bagType, level)
end



-- Don't put anything after this line or it won't work!
return Bags

