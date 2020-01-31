-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RECIPE INFO GUI

-- dependencies
local event = require('lualib/event')
local gui = require('lualib/gui')

local common_elems = require('scripts/gui/common-elements')
local common_handlers = require('scripts/gui/common-handlers')

-- locals
local table_sort = table.sort

local general_data = {
  localised_description = true,
  main_product = 'product',
  category = true,
  energy = true,
  emissions_multiplier = true
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
  local recipe_data = encyclopedia.recipe[name]
  local recipe_prototype = recipe_data.prototype
  local dictionary = player_table.dictionary

  local generic_buttons = {}
  local generic_listboxes = {}

  local gui_data = gui.create(content_scrollpane, 'recipe', player.index,
    {type='table', style='enc_content_table', column_count=1, save_as='content_table', children={
      {type='table', style='bordered_table', column_count=1, save_as='general_info_table'}
    }}
  )

  -- GENERAL INFO TABLE
  local info_table = gui_data.general_info_table
  for key,action in pairs(general_data) do
    if action == true then
      -- common action
      local data = recipe_prototype[key]
      if data and (type(data) == 'string' or (type(data) == 'number' and data > 0)) then
        common_elems.info_table_entry(info_table, key, data)
      end
    elseif action == 'product' and #recipe_prototype.products > 1 then
      local product = recipe_prototype[key]
      if product then
        local value_flow = common_elems.info_table_entry(info_table, key)
        generic_buttons[#generic_buttons+1] = value_flow.add{type='button',
          caption='[img='..product.type..'/'..product.name..']  '..product.amount..'x '..dictionary[product.type].translations[product.name]}
      end
    end
  end

  -- RECIPE INFORMATION
  local heights = {
    items = math.min(math.max(#recipe_prototype.ingredients, #recipe_prototype.products) * 28, 168),
    machines_techs = math.min(math.max(#(recipe_data.made_in or {}), #(recipe_data.unlocked_by or {})) * 28, 168)
  }
  for row,cell in pairs{items={'ingredients', 'products'}, machines_techs={'made_in', 'unlocked_by'}} do
    local cell_flow = common_elems.standard_cell(gui_data.content_table)
    cell_flow.style.horizontal_spacing = 8
    for _,type in ipairs(cell) do
      local listbox, label, other_elems = common_elems.listbox_with_label(cell_flow)
      other_elems.listbox_frame.style.height = heights[row]
      local add_item = listbox.add_item
      local objects
      if row == 'items' then
        objects = recipe_prototype[type]
      else
        objects = recipe_data[type]
      end
      if objects then
        for i=1,#objects do
          local object = objects[i]
          if type == 'made_in' then
            add_item('[img=entity/'..object..']  '..dictionary.entity.translations[object] or object)
          elseif type == 'unlocked_by' then
            add_item('[img=technology/'..object..']  '..dictionary.technology.translations[object] or object)
          else
            add_item('[img='..object.type..'/'..object.name..']  '..object.amount..'x '..dictionary[object.type].translations[object.name] or object.name)
          end
        end
      end
      label.caption = {'fe-gui.'..type:gsub('_', '-'), objects and #objects or 0}
      generic_listboxes[#generic_listboxes+1] = listbox
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