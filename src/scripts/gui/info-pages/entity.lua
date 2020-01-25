-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENTITY INFO GUI

local common_elems = require('scripts/gui/common-elements')
local common_handlers = require('scripts/gui/common-handlers')

-- locals
local table_sort = table.sort

-- objects
local self = {}
local handlers = {}

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS



-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(player, player_table, content_scrollpane, name)
  local elems = {}
  elems.listboxes = {}
  local encyclopedia = global.encyclopedia
  local entity_data = encyclopedia.entity[name]
  local dictionary = player_table.dictionary
  local table = content_scrollpane.add{type='table', name='fe_table', style='fe_content_table', column_count=1}
  return elems, {}
end

self.handlers = handlers

return self