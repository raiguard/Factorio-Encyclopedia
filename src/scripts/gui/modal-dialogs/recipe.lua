-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RECIPE DIALOG

-- dependencies
local event = require('lualib/event')

local self = {}

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS



local handlers = {

}

event.on_load(function()
  event.load_conditional_handlers(handlers)
end)

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(player, parent, action_data, content_data)
  local encyclopedia = global.encyclopedia
  local gui_data = {}
  local recipe = encyclopedia.recipe[action_data.name]
  local background_pane = parent.add{type='frame', name='fe_background_pane', style='inside_deep_frame', direction='vertical'}
  -- TOOLBAR
  local toolbar = {}
  toolbar.frame = background_pane.add{type='frame', name='fe_toolbar', style='fe_toolbar_frame', direction='horizontal'}
  toolbar.frame.add{type='sprite', name='fe_recipe_icon', style='fe_recipe_icon', sprite='recipe/'..recipe.prototype.name}
  toolbar.frame.add{type='label', name='fe_recipe_name', style='caption_label', caption=recipe.prototype.localised_name}
  toolbar.frame.add{type='empty-widget', name='fe_pusher_2', style='fe_invisible_horizontal_pusher'}
  gui_data.toolbar = toolbar
  -- CONTENT PANE
  local content_pane = background_pane.add{type='scroll-pane', name='fe_content_pane', style='fe_content_scroll_pane', direction='vertical'}
  -- ITEMS
  local items_flow = content_pane.add{type='flow', name='fe_items_flow', direction='horizontal'}
  items_flow.style.horizontal_spacing = 8
  -- ingredients
  for _,type in ipairs{'ingredients', 'products'} do
    local items = {}
    for i,item in ipairs(recipe.prototype[type]) do
      items[i] = {
        '',
        '[img='..item.type..'/'..item.name..']  '..item.amount..'x ',
        encyclopedia[item.type][item.name].prototype.localised_name
      }
    end
    local item_flow = items_flow.add{type='flow', name='fe_'..type..'_flow', direction='vertical'}
    item_flow.add{type='label', name='fe_items_label', style='caption_label', caption={'fe-gui-recipe.'..type..'-label-caption'}}
    local items_pane = item_flow.add{type='frame', name='fe_items_pane', style='fe_recipe_items_listbox_pane'}
    gui_data[type..'_listbox'] = items_pane.add{type='list-box', name='fe_items_listbox', style='fe_light_listbox', items=items}
  end
  return gui_data
end

-- -----------------------------------------------------------------------------

return self