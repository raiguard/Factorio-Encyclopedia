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
  stack_size = true,
  place_result = 'place_result',
  place_as_tile_result = 'place_as_tile_result',
  fuel_value = true,
  fuel_category = true,
  burnt_result = 'item',
  inventory_size_bonus = true,
  durability = true,
  magazine_size = true
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

  local generic_buttons = {}
  local generic_listboxes = {}

  -- CREATE GUI STRUCTURE
  local gui_data = gui.create(content_scrollpane, 'item', player.index,
    {type='table', style='enc_content_table', column_count=1, children={
      {type='table', style='bordered_table', column_count=1, save_as='general_info_table'},
      {type='flow', save_as='recipe_usages_cell'},
      {type='flow', save_as='module_effects_cell'}
    }}
  )

  -- GENERAL INFO TABLE
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
    elseif action == 'item' then
      local item = item_data.prototype[key]
      if item then
        local value_flow = common_elems.info_table_entry(info_table, key)
        generic_buttons[#generic_buttons+1] = value_flow.add{type='button',
          caption='[img=item/'..item.name..']  '..dictionary.item.translations[item.name]}
      end
    end
  end

  -- RECIPE USAGES
  if item_data.as_ingredient or item_data.as_product then
    local cell_flow = common_elems.standard_cell(gui_data.recipe_usages_cell, {'fe-gui.usage-in-recipes'}, 'horizontal')
    cell_flow.style.horizontal_spacing = 8
    -- hardcode the height logic for now, until the stretch_and_expand stretchable type comes out
    -- be the height of the max amount of items in the two listboxes, up to six
    local height = math.min(math.max(#(item_data.as_ingredient or {}), #(item_data.as_product or {})) * 28, 168)
    for _,type in ipairs{'ingredient', 'product'} do
      local listbox, label, other_elems = common_elems.listbox_with_label(cell_flow)
      other_elems.listbox_frame.style.height = height
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

  -- MODULE INFO
  if item_data.prototype.module_effects then
    local cell_flow = common_elems.standard_cell(gui_data.module_effects_cell, {'fe-gui.module-info'}, 'horizontal')
    cell_flow.style.horizontal_spacing = 8
    -- effects
    local effects_flow = cell_flow.add{type='flow', direction='vertical'}
    effects_flow.add{type='label', style='enc_listbox_label', caption={'fe-gui.module-effects'}}
    local effects_table = effects_flow.add{type='table', style='bordered_table', column_count=1}
    effects_table.style.minimal_width = 225
    for n,e in pairs(item_data.prototype.module_effects) do
      common_elems.info_table_entry(effects_table, n, tostring(math.floor(e.bonus*100))..'%')
    end
    -- limitations
    local limitations = item_data.prototype.limitations
    if #limitations > 0 then
      local recipes_listbox = common_elems.listbox_with_label(cell_flow, nil, {'fe-gui.allowed-recipes'})
      local add_item = recipes_listbox.add_item
      local recipe_translations = dictionary.recipe.translations
      for _,n in ipairs(limitations) do
        add_item('[img=recipe/'..n..']  '..(recipe_translations[n] or 'untranslated'))
      end
      generic_listboxes[#generic_listboxes+1] = recipes_listbox
    else
      effects_flow.add{type='label', caption={'fe-gui.allowed-in-all-recipes'}}
    end
  else
    gui_data.module_effects_cell.destroy()
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