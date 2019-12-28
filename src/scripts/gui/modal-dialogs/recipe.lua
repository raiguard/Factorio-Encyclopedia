-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RECIPE DIALOG

-- dependencies
local event = require('lualib/event')

local self = {}

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS

local function previous_recipe_button_clicked(e)

end

local function next_recipe_button_clicked(e)

end

local handlers = {
  modal_previous_recipe_button_clicked = previous_recipe_button_clicked,
  modal_next_recipe_button_clicked = next_recipe_button_clicked
}

event.on_load(function()
  event.load_conditional_handlers(handlers)
end)

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(player, parent, action_data, content_data)
  local encyclopedia = global.encyclopedia
  local gui_data = {}
  local recipe_data
  local background_pane = parent.add{type='frame', name='fe_background_pane', style='inside_deep_frame', direction='vertical'}
  if content_data.as then
    local as = content_data.as
    local as_encyclopedia = encyclopedia[as.category][as.name]
    local toolbar = {}
    toolbar.frame = background_pane.add{type='frame', name='fe_toolbar', style='fe_toolbar_frame', direction='horizontal'}
    toolbar.previous_recipe_button = toolbar.frame.add{type='sprite-button', name='fe_previous_recipe_button', style='fe_recipe_nav_button',
                                                       sprite='fe_nav_backward_dark', tooltip={'fe-gui-recipe.previous-recipe-button-tooltip'}}
    event.on_gui_click(previous_recipe_button_clicked, {name='modal_previous_recipe_button_clicked', player_index=player.index,
                                                        gui_filters=toolbar.previous_recipe_button})
    toolbar.frame.add{type='empty-widget', name='fe_pusher_1', style='fe_invisible_horizontal_pusher'}
    toolbar.frame.add{type='sprite', name='fe_recipe_as_icon', style='fe_recipe_as_icon', sprite=as.category..'/'..as.name}
    toolbar.frame.add{type='label', name='fe_recipe_as_name', style='caption_label', caption=encyclopedia[as.category][as.name].prototype.localised_name}
    toolbar.frame.add{type='empty-widget', name='fe_pusher_2', style='fe_invisible_horizontal_pusher'}
    toolbar.next_recipe_button = toolbar.frame.add{type='sprite-button', name='fe_next_recipe_button', style='fe_recipe_nav_button',
                                                   sprite='fe_nav_forward_dark', tooltip={'fe-gui-recipe.next-recipe-button-tooltip'}}
    event.on_gui_click(next_recipe_button_clicked, {name='modal_next_recipe_button_clicked', player_index=player.index,
                                                    gui_filters=toolbar.next_recipe_button})
    recipe_data = encyclopedia.recipe[encyclopedia[as.category][as.name]['as_'..as.type][1]]
    gui_data.toolbar = toolbar
  else
    recipe_data = encyclopedia.recipe[action_data.name]
  end
  local content_pane = background_pane.add{type='scroll-pane', name='fe_content_pane', style='fe_content_scroll_pane', direction='vertical'}
  -- RECIPE
  local name_flow = content_pane.add{type='flow', name='fe_name_flow', style='fe_vertically_centered_flow', direction='horizontal'}
  name_flow.add{type='label', name='fe_name_label', style='caption_label', caption={'fe-gui-recipe.recipe-name-label-caption'}}
  local name_icon = name_flow.add{type='sprite-button', name='fe_name_icon', style='quick_bar_slot_button', sprite='recipe/'..recipe_data.prototype.name}
  name_icon.style.width = 30
  name_icon.style.height = 30
  name_icon.ignored_by_interaction = true
  name_flow.add{type='label', name='fe_recipe_name', caption=recipe_data.prototype.localised_name}
  -- ITEMS
  local items_flow = content_pane.add{type='flow', name='fe_items_flow', direction='horizontal'}
  items_flow.style.horizontal_spacing = 8
  -- ingredients
  for _,type in ipairs{'ingredients', 'products'} do
    local items = {}
    for i,item in ipairs(recipe_data.prototype[type]) do
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