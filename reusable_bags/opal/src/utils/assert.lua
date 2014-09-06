-----------------------------------------------------------------------------------------
-- Assert for OpalEngine
-- Require this once in setup.
----------------------------------------------------------------------------------------


local do_opal_assert = not (system.getInfo("environment") == "device" )

local function opal_assert(condition, error_msg)
    if not condition then
        error (error_msg)
    end
end

local OAssert = do_opal_assert and opal_assert or function() end

return OAssert