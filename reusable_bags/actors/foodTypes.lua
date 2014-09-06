local _ = require "libs.underscore"

--food types definitions
local Foods = setmetatable({}, nil)
      Foods.by_name = setmetatable({}, nil)
      Foods.by_weight = setmetatable({}, nil)

local Food = require "actors.food"

local function newTypeInfo()
    return {physics={}, anims={}, sounds={}}
end

-------------------------------------------------------------------------------
-- Bird Defaults

local function SetDefaults(f, params)
    params = params or {}
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
	f.physics.mass = 2.0	 or params.mass	-- How much b.physics.mass the bird has in kilograms
	f.physics.bounce = 0.0 or params.bounce		-- How bouncy the bird is - 0.0 means no b.physics.bounce 1.0 means b.physics.bounce  away at full speed
	f.physics.friction = 1 or params.friction	-- How much friction the bird has when sliding on things
    f.physics.category = 'food' or params.category
    f.physics.colliders = {'bag', 'food', 'bag_collider', 'ground'} or params.colliders
    f.physics.gravityScale = 0.0 or params.gravityScale
    f.physics.angularDamping = 0.01 or params.angularDamping
    f.physics.linearDamping = 0.01 or params.linearDamping
    f.physics.isSensor = false or params.isSensor
    f.physics.radius = params.radius or nil
    
    f.physics.bodyType = 'kinematic' or params.bodyType
    
	-- General Food Info
	f.scale = 0.25 or params.scale				-- How big the bird is compared to its normal anim size
    f.collisionBoxScale = 0.75 or params.collisionBoxScale --the physics collision box is basically scale * collisionBoxScale
	f.weight = 2 or params.weight 		-- How many seconds the b.anims.hurt anim should be held for before returning to b.anims.normal
	f.scoreScale = 1.0 or params.scoreScale			-- How much to multiply scored points when hitting this bird
    
    f.typeName = "food" or params.typeName

end

local function assemble_food(food_name, params)
    local food_assembler = function()
        local f = newTypeInfo()
        SetDefaults(f, params)
        f.name = food_name
        return f
    end
    
    Foods.by_name[food_name] = food_assembler
    
    local weight_bucket = Foods.by_weight[params.weight] or {}
    table.insert(weight_bucket, food_assembler)
    Foods.by_weight[params.weight] = weight_bucket
end

assemble_food("apple", { weight=3, radius = 100})

assemble_food("orange", {weight=3, radius = 100})

assemble_food("burrito", {weight=5})

assemble_food("pizza", {weight=7, radius = 250})

-------------------------------------------------------------------------------
-- light weight foods,

--[[
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

--]]

local function spawn_food(x, y, foodType, food_name, level, scale)
    assert(foodType, food_name, level, "Error in required params while spawning food")
    if scale then foodType.scale = scale end
    return Food(x or 0, y or 0, foodType, food_name, level)
end

Foods["CreateFood_ByName"] = function( x, y, food_name, level, scale)
    local foodType = Foods.by_name[food_name]()
    return spawn_food(x, y, foodType, food_name, level, scale)
end

Foods["CreateFood_ByWeight"] = function( x, y, weight, level, scale)
    local weight_bucket = Foods.by_weight[weight]
    local foodType = weight_bucket[math.random(#weight_bucket)]
    local food_name = foodType.name
    return spawn_food(x, y, foodType, food_name, level, scale)
end


Foods["GetFoodTypesList"] = function()
    return _.values(Foods.by_name)
end

Foods["GetFoodWeightsList"] = function()
    local weightset={}
    local n=0

    for k,v in pairs(tab) do
        n=n+1
        weightset[n]=k
    end
    table.sort(weightset)
    
    return weightset
end



-- Don't put anything after this line or it won't work!
return Foods

