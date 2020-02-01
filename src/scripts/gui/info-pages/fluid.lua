-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FLUID INFO GUI

-- dependencies
local event = require('lualib/event')
local gui = require('lualib/gui')

local common_elems = require('scripts/gui/common-elements')
local common_handlers = require('scripts/gui/common-handlers')

-- locals
local table_sort = table.sort

local general_data = {
  localised_description = true,
  default_temperature = true,
  max_temperature = true,
  heat_capacity = true,
  gas_temperature = true,
  emissions_multiplier = true,
  fuel_value = true
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
  local fluid_data = encyclopedia.fluid[name]
  local fluid_prototype = fluid_data.prototype
  local dictionary = player_table.dictionary

  local generic_buttons = {}
  local generic_listboxes = {}

  local gui_data = gui.create(content_scrollpane, 'fluid', player.index,
  {type='table', style='enc_content_table', column_count=1, children={
    {type='table', style='bordered_table', column_count=1, save_as='general_info_table'},
    {type='flow', save_as='recipe_usages_cell'}
  }}
  )

  -- GENERAL INFO TABLE
  local info_table = gui_data.general_info_table
  for key,action in pairs(general_data) do
    if action == true then
      -- common action
      local data = fluid_prototype[key]
      if data and (type(data) == 'string' or (type(data) == 'number' and data > 0)) then
        common_elems.info_table_entry(info_table, key, data)
      end
    end
  end

  -- POPULATE RECIPE USAGES
  if fluid_data.as_ingredient or fluid_data.as_product then
    local cell_flow = common_elems.standard_cell(gui_data.recipe_usages_cell, {'fe-gui.usage-in-recipes'}, 'horizontal')
    cell_flow.style.horizontal_spacing = 8
    for _,type in ipairs{'ingredient', 'product'} do
      local listbox, label = common_elems.listbox_with_label(cell_flow)
      local as_data = fluid_data['as_'..type]
      local add_item = listbox.add_item
      if as_data then
        table_sort(as_data)
        for i=1,#as_data do
          local recipe_name = as_data[i]
          add_item('[img=recipe/'..recipe_name..']  '..(dictionary.recipe.translations[recipe_name] or recipe_name))
        end
      end
      label.caption = {'fe-gui.as-'..type, as_data and #as_data or 0}
      generic_listboxes[#generic_listboxes+1] = listbox
    end
  else
    gui_data.recipe_usages_cell.destroy()
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