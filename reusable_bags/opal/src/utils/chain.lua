--generic chaining pattern instance for derived instances
-- immutable
local LCS = require 'opal.libs.LCS'
local _ = require "opal.libs.underscore"
local util = require 'opal.src.utils.util'
local oAssert = require 'opal.src.utils.assert'

local Chain = LCS.class()

local function get_properties_copy(chain_instance)
    return util.DeepCopy(chain_instance.properties)
end

-- Contructor and optional copy constructor
function Chain:init (other_chain)
    oAssert(not other_chain or LCS.is_A(other_chain, 'object'), 'Chain(): pass in nothing for a new Chain or another instance to copy it.')
    
    if other_chain then --copy chain
        self.properties = get_properties_copy(other_chain)
    else --new Chain
        self.properties = setmetatable({}, nil) 
    end
    return self
end

function Chain:Get(property_id)
    return self.properties[property_id]
end

--Allows chaining
function Chain:Set (property_id_or_table, value)
    local copy = Chain(self)
    if type(property_id_or_table)=='table' then
        _.extend (copy.properties, property_id_or_table)
    else
        copy.properties[property_id_or_table] = value
    end
    return copy
end
    
return Chain
