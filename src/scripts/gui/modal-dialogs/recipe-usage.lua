local self = {}

function self.create(player, parent, action_data, content_data)
  local encyclopedia = global.encyclopedia
  local object = encyclopedia[action_data.category][action_data.name]
  local content_pane = parent.add{type='frame', name='fe_content_pane', style='fe_window_content_frame', direction='horizontal'}
  local gui_data = {}
  for _,type in ipairs{'ingredient', 'product'} do
    local recipes = {}
    if not object['as_'..type] then goto continue end
    for _,name in ipairs(object['as_'..type]) do
      local recipe_obj = encyclopedia.recipe[name]
      if recipe_obj.prototype.hidden == false then
        recipes[#recipes+1] = {'', '[img=recipe/'..name..']  ', recipe_obj.prototype.localised_name}
      end
    end
    ::continue::
    local recipe_flow = content_pane.add{type='flow', name='fe_'..type..'_flow', direction='vertical'}
    recipe_flow.add{type='label', name='fe_recipes_label', style='caption_label', caption={'fe-gui-recipe-usage.as-'..type..'-label-caption'}}.style.left_padding = 2
    local recipes_pane = recipe_flow.add{type='frame', name='fe_recipes_pane', style='fe_recipe_listbox_pane'}
    gui_data[type..'_listbox'] = recipes_pane.add{type='list-box', name='fe_recipes_listbox', style='fe_light_listbox', items=recipes}
  end
  return gui_data
end

return self