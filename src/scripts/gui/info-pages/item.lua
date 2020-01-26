-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ITEM INFO GUI

-- dependencies
local event = require('lualib/event')
local gui = require('lualib/gui')

local common_elems = require('scripts/gui/common-elements')
local common_handlers = require('scripts/gui/common-handlers')

-- locals
local table_sort = table.sort

local general_data = {
  -- 'localised_description',
  stack_size = true,
  fuel_value = true,
  place_result = 'place_result',
  place_as_equipment_result = 'place_as_equipment_result',
  place_as_tile_result = 'place_as_tile_result'
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
  local item_data = encyclopedia.item[name]
  local dictionary = player_table.dictionary

  -- CREATE GUI STRUCTURE
  local gui_data = gui.create(content_scrollpane, 'item', player.index,
    {type='table', style='fe_content_table', column_count=1, children={
      -- general info table
      {type='table', style='bordered_table', column_count=1, save_as='general_info_table'},
      -- recipe usages
      {type='flow', direction='vertical', save_as='recipe_usages_cell'}
    }}
  )

  -- POPULATE INFO TABLE
  local generic_buttons = {}
  local info_table = gui_data.general_info_table
  for key,action in pairs(general_data) do
    if action == true then
      -- common action
      local data = item_data.prototype[key]
      if data and (type(data) == 'string' or (type(data) == 'number' and data > 0)) then
        common_elems.info_table_entry(info_table, key, data)
      end
    elseif action == 'place_result' or action == 'place_as_equipment_result' then
      local place_result = item_data.prototype[key]
      if place_result then
        local category = action:find('as_equipment') and 'equipment' or 'entity'
        local value_flow = common_elems.info_table_entry(info_table, key)
        generic_buttons[#generic_buttons+1] = value_flow.add{type='button',
          caption='[img='..category..'/'..place_result.name..']  '..dictionary[category].translations[place_result.name]}
      end
    elseif action == 'place_as_tile_result' then
      local place_result = item_data.prototype[key]
      if place_result then
        place_result = place_result.result
        local value_flow = common_elems.info_table_entry(info_table, key)
        generic_buttons[#generic_buttons+1] = value_flow.add{type='button',
          caption='[img=tile/'..place_result.name..']  '..dictionary.tile.translations[place_result.name]}
      end
    end
  end

  -- POPULATE RECIPE USAGES
  local generic_listboxes = {}
  if item_data.as_ingredient or item_data.as_product then
    local cell_flow = common_elems.standard_cell(gui_data.recipe_usages_cell, {'fe-gui.usage-in-recipes'}, 'horizontal')
    cell_flow.style.horizontal_spacing = 8
    for _,type in ipairs{'ingredient', 'product'} do
      local listbox, label = common_elems.listbox_with_label(cell_flow)
      local as_data = item_data['as_'..type]
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

--[[
function self.create(player, player_table, content_scrollpane, name)
  local elems = {}
  elems.listboxes = {}
  elems.buttons = {}
  local encyclopedia = global.encyclopedia
  local item_data = encyclopedia.item[name]
  local dictionary = player_table.dictionary
  local table = content_scrollpane.add{type='table', name='fe_table', style='fe_content_table', column_count=1}
  --
  -- USAGE IN RECIPES
  --
  do
    if item_data.as_ingredient or item_data.as_product then
      local content_flow = common_elems.standard_cell(table, 'usage_in_recipes', {'fe-gui.usage-in-recipes'}, 'horizontal')
      content_flow.style.horizontal_spacing = 8
      for _,type in ipairs{'ingredient', 'product'} do
        local listbox, label = common_elems.listbox_with_label(content_flow, type)
        local as_data = item_data['as_'..type]
        local add_item = listbox.add_item
        if as_data then
          table_sort(as_data)
          for i=1,#as_data do
            local recipe_name = as_data[i]
            add_item('[img=recipe/'..recipe_name..']  '..(dictionary.recipe.translations[recipe_name] or recipe_name))
          end
        end
        label.caption = {'fe-gui.as-'..type, as_data and #as_data or 0}
        elems.listboxes[#elems.listboxes+1] = listbox
      end
    end
  end
  return elems, {
    {defines.events.on_gui_selection_state_changed, {name='listbox_selection_changed', gui_filters=elems.listboxes}},
    {defines.events.on_gui_click, {name='object_button_clicked', gui_filters=elems.buttons}}
  }
end
]]

return self