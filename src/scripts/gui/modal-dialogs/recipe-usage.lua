local self = {}

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
  return gui_data
end

return self