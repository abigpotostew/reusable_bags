-----------------------------------------------------------------------------------------
-- Globals go here
-- require this once, ideally in main before anything.
----------------------------------------------------------------------------------------

local globals

local function GetNewActorID()
    
end

globals = 
{
    --actor_ct        = 1,
    --GetNewActorID   = GetNewActorID
}
GLOBAL = globals

 --[[ 
 Consider using :
    local globals = {}        -- create new environment
    setmetatable(globals, {__index = _G})
    setfenv(1, globals)    -- set it
--]]

return GLOBAL