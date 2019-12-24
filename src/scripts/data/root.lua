-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATA ROOT SCRIPTING
-- Entry point for the data structure

-- dependencies
local event = require('lualib/event')
local util = require('lualib/util')

local data = {}

function data.build_encyclopedia()
  local entities = {}
  for name,prototype in pairs(game.entity_prototypes) do
    entities[name] = {prototype=prototype}
  end
  global.encyclopedia = {
    entities = entities,
    items = game.item_prototypes
  }
end

return data