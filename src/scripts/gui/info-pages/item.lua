-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ITEM INFO GUI

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
local handlers = {}

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS

handlers.listbox_selection_changed = common_handlers.open_listbox_content
handlers.object_button_clicked = common_handlers.open_button_content

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(player, player_table, content_scrollpane, name)
  local elems = {}
  elems.listboxes = {}
  elems.buttons = {}
  local encyclopedia = global.encyclopedia
  local item_data = encyclopedia.item[name]
  local dictionary = player_table.dictionary
  local table = content_scrollpane.add{type='table', name='fe_table', style='fe_content_table', column_count=1}
  --
  -- GENERAL INFO
  --
  do
    local content_flow = common_elems.standard_cell(table, 'general', nil, 'vertical')
    local info_table = content_flow.add{type='table', name='fe_info_table', style='bordered_table', column_count=1}
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
          elems.buttons[#elems.buttons+1] = value_flow.add{type='button', name='fe_value_button',
                                            caption='[img='..category..'/'..place_result.name..']  '..dictionary[category].translations[place_result.name]}
        end
      elseif action == 'place_as_tile_result' then
        local place_result = item_data.prototype[key]
        if place_result then
          place_result = place_result.result
          local value_flow = common_elems.info_table_entry(info_table, key)
          elems.buttons[#elems.buttons+1] = value_flow.add{type='button', name='fe_value_button',
                                            caption='[img=tile/'..place_result.name..']  '..dictionary.tile.translations[place_result.name]}
        end
      end
    end
  end
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

self.handlers = handlers

return self