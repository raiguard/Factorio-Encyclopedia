-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ITEM INFO GUI

-- gui elements
-- local recipe_usage_pane = require('scripts/gui/elements/recipe-usage')

-- locals
local table_sort = table.sort

-- objects
local self = {}
local handlers = {}

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS

function handlers.recipe_as_listbox_selection_changed(e)
  local _,_,_,recipe_name = e.element.caption:find('^%[img=(.*)/(.*)%].*$')
  script.raise_event(open_info_gui_event, {player_index=e.player_index, category='recipe', object_name=recipe_name})
end

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(player, player_table, content_scrollpane, name)
  local elems = {}
  local encyclopedia = global.encyclopedia
  local item_data = encyclopedia.item[name]
  local dictionary = player_table.dictionary
  local table = content_scrollpane.add{type='table', name='fe_table', style='fe_bordered_table', column_count=1}
  --
  -- USAGE IN RECIPES
  --
  do
    elems.recipe_usage = {}
    local cell_flow = table.add{type='flow', name='fe_recipes_flow', direction='vertical'}
    cell_flow.add{type='label', name='fe_cell_title', style='caption_label', caption={'fe-gui.usage-in-recipes'}}
    local lower_flow = cell_flow.add{type='flow', name='fe_lower_flow', direction='horizontal'}
    lower_flow.style.horizontal_spacing = 8
    for _,type in ipairs{'ingredient', 'product'} do
      local flow = lower_flow.add{type='flow', name='fe_'..type..'_flow', direction='vertical'}
      local label = flow.add{type='label', name='fe_listbox_label', style='fe_listbox_label'}
      local listbox = flow.add{type='frame', name='fe_listbox_frame', style='fe_listbox_frame'}
      .add{type='list-box', name='fe_as_ingredient_listbox', style='fe_listbox'}
      local as_data = item_data['as_'..type]
      local add_item = listbox.add_item
      if as_data then
        table_sort(as_data)
        for i=1,#as_data do
          local recipe_name = as_data[i]
          add_item('[img=recipe/'..recipe_name..']  '..dictionary.recipe.translations[recipe_name])
        end
      end
      label.caption = {'fe-gui.as-'..type, as_data and #as_data or 0}
      elems.recipe_usage['as_'..type..'_listbox'] = listbox
    end
  end
  return elems, {
    {defines.events.on_gui_selection_state_changed, {name='recipe_as_listbox_selection_changed',
     gui_filters={elems.recipe_usage.as_ingredient_listbox, elems.recipe_usage.as_product_listbox}}}
  }
end

self.handlers = handlers

return self