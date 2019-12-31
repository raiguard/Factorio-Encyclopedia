-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ITEM INFO GUI

local common_elems = require('scripts/gui/common-elements')
local common_handlers = require('scripts/gui/common-handlers')

-- locals
local table_sort = table.sort

-- objects
local self = {}
local handlers = {}

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS

handlers.listbox_selection_changed = common_handlers.open_listbox_content

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(player, player_table, content_scrollpane, name)
  local elems = {}
  elems.listboxes = {}
  local encyclopedia = global.encyclopedia
  local fluid_data = encyclopedia.fluid[name]
  local dictionary = player_table.dictionary
  local table = content_scrollpane.add{type='table', name='fe_table', style='fe_bordered_table', column_count=1}
  --
  -- USAGE IN RECIPES
  --
  do
    local content_flow = common_elems.standard_cell(table, 'usage_in_recipes', {'fe-gui.usage-in-recipes'}, 'horizontal')
    content_flow.style.horizontal_spacing = 8
    for _,type in ipairs{'ingredient', 'product'} do
      local listbox, label = common_elems.listbox_with_label(content_flow, type)
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
      elems.listboxes[#elems.listboxes+1] = listbox
    end
  end
  return elems, {
    {defines.events.on_gui_selection_state_changed, {name='listbox_selection_changed', gui_filters=elems.listboxes}}
  }
end

self.handlers = handlers

return self