-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RECIPE USAGE DIALOG

-- dependencies
local event = require('lualib/event')

local self = {}

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS

local function as_ingredient_recipe_button_clicked(e)
  local _,_,name = e.element.caption[2]:find('^.*/(.*)%].*$') -- extract object names from rich text definition
  event.raise(open_modal_dialog_event, {player_index=e.player_index, category='recipe', obj_name=name, action='view_recipe'})
end

local function as_product_recipe_button_clicked(e)
  local _,_,name = e.element.caption[2]:find('^.*/(.*)%].*$') -- extract object names from rich text definition
  event.raise(open_modal_dialog_event, {player_index=e.player_index, category='recipe', name=name, action='view_recipe'})
end

local handlers = {
  recipe_usage_as_ingredient_recipe_button_clicked = as_ingredient_recipe_button_clicked,
  recipe_usage_as_product_recipe_button_clicked = as_product_recipe_button_clicked
}

event.on_load(function()
  event.load_conditional_handlers(handlers)
end)

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(player, parent, action_data, content_data)
  local encyclopedia = global.encyclopedia
  local object = encyclopedia[action_data.category][action_data.name]
  local content_pane = parent.add{type='frame', name='fe_content_pane', style='fe_window_content_frame', direction='horizontal'}
  local gui_data = {}
  -- scrollpane contents
  for _,type in ipairs{'ingredient', 'product'} do
    -- frame and scrollpane
    local recipe_flow = content_pane.add{type='flow', name='fe_'..type..'_flow', direction='vertical'}
    recipe_flow.add{type='label', name='fe_recipes_label', style='fe_mock_listbox_label', caption={'fe-gui-recipe-usage.as-'..type..'-label-caption'}}
    local recipes_pane = recipe_flow.add{type='frame', name='fe_recipes_pane', style='fe_recipe_mock_listbox_frame'}
    local recipes_listbox = recipes_pane.add{type='scroll-pane', name='fe_recipes_mock_listbox', style='fe_mock_listbox_scrollpane'}
    -- populate scrollpane
    if object['as_'..type] then
      local i = 0
      for _,name in ipairs(object['as_'..type]) do
        local recipe_obj = encyclopedia.recipe[name]
        if recipe_obj.prototype.hidden == false then
          i = i + 1
          recipes_listbox.add{type='button', name='fe_'..type..'_listbox_item_'..i, style='fe_mock_listbox_item',
                              caption={'', '[img=recipe/'..name..']  ', recipe_obj.prototype.localised_name}}
        end
      end
    end
    gui_data[type..'_listbox'] = recipes_listbox
  end
  -- event handlers
  event.on_gui_click(as_ingredient_recipe_button_clicked, {name='recipe_usage_as_ingredient_recipe_button_clicked', player_index=player.index,
                 gui_filters='fe_ingredient_listbox_item_'})
  event.on_gui_click(as_product_recipe_button_clicked, {name='recipe_usage_as_product_recipe_button_clicked', player_index=player.index,
                 gui_filters='fe_product_listbox_item_'})
  gui_data.filename = 'recipe-usage'
  return gui_data
end

function self.get_handlers() return handlers end

return self