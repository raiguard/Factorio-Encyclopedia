-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RECIPE USAGE DIALOG

-- dependencies
local event = require('lualib/event')

local self = {}

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS

local function recipe_button_clicked(e)
  local _,_,name = e.element.caption[2]:find('^.*/(.*)%].*$') -- extract object names from rich text definition
  event.raise(open_modal_dialog_event, {player_index=e.player_index, category='recipe', obj_name=name, action='view_recipe'})
end

local handlers = {
  recipe_usage_recipe_button_clicked = recipe_button_clicked
}

event.on_load(function()
  event.load_conditional_handlers(handlers)
end)

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(player, parent, action_data, content_data)
  local encyclopedia = global.encyclopedia
  local object = encyclopedia[action_data.category][action_data.name]
  local gui_data = {}
  local content_pane = parent.add{type='frame', name='fe_content_pane', style='window_content_frame_packed', direction='vertical'}
  -- TOOLBAR
  local toolbar = {}
  toolbar.frame = content_pane.add{type='frame', name='fe_toolbar', style='fe_toolbar_frame', direction='horizontal'}
  toolbar.frame.add{type='sprite', name='fe_recipe_icon', style='fe_recipe_icon', sprite=''..action_data.category..'/'..object.prototype.name}
  toolbar.frame.add{type='label', name='fe_recipe_name', style='caption_label', caption=object.prototype.localised_name}
  toolbar.frame.add{type='empty-widget', name='fe_pusher_2', style='fe_invisible_horizontal_pusher'}
  gui_data.toolbar = toolbar
  local recipes_flow = content_pane.add{type='flow', name='fe_recipes_flow', direction='horizontal'}
  recipes_flow.style.horizontal_spacing = 8
  recipes_flow.style.padding = 8
  -- scrollpane contents
  for _,type in ipairs{'ingredient', 'product'} do
    -- frame and scrollpane
    local recipe_flow = recipes_flow.add{type='flow', name='fe_'..type..'_flow', direction='vertical'}
    recipe_flow.add{type='label', name='fe_recipes_label', style='fe_mock_listbox_label', caption={'fe-gui-recipe-usage.as-'..type..'-label-caption'}}
    local recipes_pane = recipe_flow.add{type='frame', name='fe_recipes_pane', style='fe_recipe_mock_listbox_frame'}
    local recipes_listbox = recipes_pane.add{type='scroll-pane', name='fe_recipes_listbox', style='fe_mock_listbox_scrollpane'}
    -- populate scrollpane
    if object['as_'..type] then
      local i = 0
      for _,name in ipairs(object['as_'..type]) do
        local recipe_obj = encyclopedia.recipe[name]
        if recipe_obj.prototype.hidden == false then
          i = i + 1
          local caption = {'', '[img=recipe/'..name..']  ', recipe_obj.prototype.localised_name}
          recipes_listbox.add{type='button', name='fe_recipes_listbox_item_'..i, style='fe_mock_listbox_item',
                              caption=caption, tooltip={'fe-gui-recipe-usage.recipe-listbox-item-tooltip', caption}}
        end
      end
    end
    gui_data[type..'_listbox'] = recipes_listbox
  end
  -- event handlers
  event.on_gui_click(recipe_button_clicked, {name='recipe_usage_recipe_button_clicked', player_index=player.index,
                 gui_filters='fe_recipes_listbox_item'})
  gui_data.filename = 'recipe-usage'
  return gui_data
end

function self.get_handlers() return handlers end

return self