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
  local background_pane = parent.add{type='frame', name='fe_background_pane', style='window_content_frame_packed', direction='vertical'}
  -- TOOLBAR
  local toolbar = {}
  toolbar.frame = background_pane.add{type='frame', name='fe_toolbar', style='fe_toolbar_frame', direction='horizontal'}
  toolbar.frame.add{type='sprite', name='fe_recipe_icon', style='fe_recipe_icon', sprite='recipe/'..recipe.prototype.name}
  toolbar.frame.add{type='label', name='fe_recipe_name', style='caption_label', caption=recipe.prototype.localised_name}
  toolbar.frame.add{type='empty-widget', name='fe_pusher_2', style='fe_invisible_horizontal_pusher'}
  gui_data.toolbar = toolbar
  -- CONTENT SCROLLPANE
  local content_scrollpane = background_pane.add{type='scroll-pane', name='fe_content_pane', style='scroll_pane_under_subheader', direction='vertical'}
  content_scrollpane.style.padding = 8
  -- ITEMS
  local items_flow = content_scrollpane.add{type='flow', name='fe_items_flow', direction='horizontal'}
  items_flow.style.horizontal_spacing = 8
  -- ingredients / products
  for _,type in ipairs{'ingredients', 'products'} do
    local item_flow = items_flow.add{type='flow', name='fe_'..type..'_flow', direction='vertical'}
    item_flow.add{type='label', name='fe_items_label', style='fe_mock_listbox_label', caption={'fe-gui-recipe.'..type..'-label-caption'}}
    local items_pane = item_flow.add{type='frame', name='fe_items_pane', style='fe_recipe_mock_listbox_frame'}
    local items_listbox = items_pane.add{type='scroll-pane', name='fe_items_listbox', style='fe_mock_listbox_scrollpane'}
    for i,item in ipairs(recipe.prototype[type]) do
      local caption = {
        '',
        '[img='..item.type..'/'..item.name..']  '..item.amount..'x ',
        encyclopedia[item.type][item.name].prototype.localised_name
      }
      items_listbox.add{type='button', name='fe_items_listbox_item_'..i, style='fe_mock_listbox_item', caption=caption,
                        tooltip={'fe-gui-recipe.item-listbox-item-tooltip', caption}}
    end
    gui_data[type..'_listbox'] = items_listbox
  end

  local lower_flow = content_scrollpane.add{type='flow', name='fe_lower_flow', direction='horizontal'}
  lower_flow.style.horizontal_spacing = 8
  -- made in
  local made_in_flow = lower_flow.add{type='flow', name='fe_made_in_flow', direction='vertical'}
  made_in_flow.add{type='label', name='fe_listbox_label', style='fe_mock_listbox_label', caption={'fe-gui-recipe.made-in-label-caption'}}
  local made_in_listbox = made_in_flow.add{type='frame', name='fe_made_in_pane', style='fe_recipe_mock_listbox_frame'}
  .add{type='scroll-pane', name='fe_made_in_listbox', style='fe_mock_listbox_scrollpane'}
  for i,name in ipairs(recipe.made_in) do
    local entity = encyclopedia.entity[name]
    local caption = {'', '[img=entity/'..name..']  ', entity.prototype.localised_name}
    made_in_listbox.add{type='button', name='fe_made_in_item_'..i, style='fe_mock_listbox_item', caption=caption, tooltip=caption}
  end
  gui_data.filename = 'recipe'
  return gui_data
end

function self.get_handlers() return handlers end

-- -----------------------------------------------------------------------------

return self