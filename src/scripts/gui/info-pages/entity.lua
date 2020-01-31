-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENTITY INFO GUI

-- dependencies
local event = require('lualib/event')
local gui = require('lualib/gui')

local common_elems = require('scripts/gui/common-elements')
local common_handlers = require('scripts/gui/common-handlers')

-- locals
local table_sort = table.sort

local general_data = {
  localised_description = true,
  belt_speed = true,
  logistic_radius = true,
  construction_radius = true,
  crafting_speed = true,
  max_distance_of_nearby_sector_revealed = true,
  max_distance_of_sector_revealed = true,
  max_energy = true,
  maximum_temperature = true,
  target_temperature = true,
  mining_speed = true,
  next_upgrade = 'entity',
  production = true,
  pumping_speed = true,
  speed = true,
  max_payload_size = true,
  weight = true,
}

-- objects
local self = {}

-- -----------------------------------------------------------------------------
-- GUI DATA

gui.add_handlers('item', {
  generic_buttons = {
    on_gui_click = common_handlers.open_button_content
  },
  generic_listboxes = {
    on_gui_selection_state_changed = common_handlers.open_listbox_content
  }
})

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(player, player_table, content_scrollpane, name)
  local encyclopedia = global.encyclopedia
  local entity_data = encyclopedia.entity[name]
  local entity_prototype = entity_data.prototype
  local dictionary = player_table.dictionary
  
  local generic_buttons = {}
  local generic_listboxes = {}

  local gui_data = gui.create(content_scrollpane, 'entity', player.index,
    {type='table', style='enc_content_table', column_count=1, children={
      {type='table', style='bordered_table', column_count=1, save_as='general_info_table'}
    }}
  )

  -- GENERAL INFO TABLE
  local info_table = gui_data.general_info_table
  for key,action in pairs(general_data) do
    if action == true then
      -- common action
      local data = entity_prototype[key]
      if data and (type(data) == 'string' or (type(data) == 'number' and data > 0)) then
        common_elems.info_table_entry(info_table, key, data)
      end
    elseif action == 'entity' then
      local entity = entity_prototype[key]
      if entity then
        local value_flow = common_elems.info_table_entry(info_table, key)
        generic_buttons[#generic_buttons+1] = value_flow.add{type='button',
          caption='[img=entity/'..entity.name..']  '..dictionary.entity.translations[entity.name]}
      end
    end
  end

  -- SET UP GENERIC HANDLERS
  gui.register_handlers('item', 'generic_buttons', {name='generic_buttons', player_index=player.index, gui_filters=generic_buttons})
  gui.register_handlers('item', 'generic_listboxes', {name='generic_listboxes', player_index=player.index, gui_filters=generic_listboxes})

  return gui_data
end

function self.destroy(player, content_scrollpane)
  gui.destroy(content_scrollpane.children[1], 'item', player.index)
end

return self