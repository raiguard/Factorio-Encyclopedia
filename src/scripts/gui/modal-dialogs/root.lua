-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MODAL DIALOG ROOT

-- dependencies
local event = require('lualib/event')

-- modules
local content_modules = {}
for _,name in ipairs{'recipe-usage', 'prototype', 'recipe'} do
  content_modules[name] = require('scripts/gui/modal-dialogs/'..name)
end

local modal_dialog = {}

-- -----------------------------------------------------------------------------
-- ACTION TO CONTENT TRANSLATION

local action_to_content = {
  fluid = {
    recipe_usage = {name='recipe-usage', data={type='fluid'}},
    view_prototype = {name='prototype', data='LuaItemPrototype'}
  },
  item = {
    recipe_usage = {name='recipe-usage', data={type='item'}},
    view_prototype = {name='prototype', data='LuaItemPrototype'}
  },
  recipe = {
    view_recipe = {name='recipe'},
    view_prototype = {name='prototype', data='LuaRecipePrototype'}
  }
}

-- -----------------------------------------------------------------------------
-- TITLEBAR EVENT HANDLERS

local function nav_backward_button_clicked(e)

end

local function nav_forward_button_clicked(e)

end

local function search_button_clicked(e)
  event.raise(open_search_gui_event, {player_index=e.player_index})
end

local function modal_dialog_closed(e)
  modal_dialog.destroy(global.players[e.player_index].gui, e.player_index)
end

local handlers = {
  modal_nav_backward_button_clicked = nav_backward_button_clicked,
  modal_nav_forward_button_clicked = nav_forward_button_clicked,
  modal_search_button_clicked = search_button_clicked,
  modal_dialog_closed = modal_dialog_closed
}

event.on_load(function()
  event.load_conditional_handlers(handlers)
end)

-- -----------------------------------------------------------------------------
-- LIBRARY

function modal_dialog.create(player, category, name, action)
  -- destroy existing dialog, if there is one
  if global.players[player.index].gui.modal then
    modal_dialog.destroy(global.players[player.index].gui.modal, player.index)
  end
  local encyclopedia = global.encyclopedia
  local window = player.gui.screen.add{type='frame', name='fe_modal_window', style='dialog_frame', direction='vertical'}
  window.enabled = false
  -- titlebar
  local titlebar = window.add{type='flow', name='fe_modal_titlebar', style='fe_titlebar_flow', direction='horizontal'}
  titlebar.add{type='sprite-button', name='fe_modal_titlebar_button_nav_backward', style='close_button', sprite='fe_nav_backward',
               hovered_sprite='fe_nav_backward_dark', clicked_sprite='fe_nav_backward_dark'}
  titlebar.add{type='sprite-button', name='fe_modal_titlebar_button_nav_forward', style='close_button', sprite='fe_nav_forward',
               hovered_sprite='fe_nav_forward_dark', clicked_sprite='fe_nav_forward_dark'}.enabled = false
  titlebar.add{type='label', name='fe_modal_titlebar_label', style='frame_title',
               caption={'fe-gui-modal.titlebar-label-caption-'..action, encyclopedia[category][name].prototype.localised_name}}.style.left_padding = 7
  titlebar.add{type='empty-widget', name='fe_modal_titlebar_pusher', style='fe_titlebar_draggable_space'}.drag_target = window
  local search_button = titlebar.add{type='sprite-button', name='fe_modal_titlebar_button_search', style='close_button', sprite='fe_search',
                                     hovered_sprite='fe_search_dark', clicked_sprite='fe_search_dark', tooltip={'fe-gui-modal.titlebar-search-button-tooltip'}}
  local close_button = titlebar.add{type='sprite-button', name='fe_modal_titlebar_button_close', style='close_button', sprite='utility/close_white',
                                    hovered_sprite='utility/close_black', clicked_sprite='utility/close_black'}
  -- get content module from data
  local content = action_to_content[category]
  if not content then error('No content!') end
  if type(content) == 'function' then
    content = content(name, encyclopedia)
  else
    content = content[action]
  end
  if not content then error('No content!') end
  if type(content) == 'function' then
    content = content(name, encyclopedia)
  end
  -- create window content
  local content_data = content_modules[content.name].create(player, window, {category=category, name=name, action=action}, content.data or {})
  -- screen
  window.force_auto_center()
  player.opened = window
  -- register events
  event.on_gui_click(search_button_clicked, {name='modal_search_button_clicked', player_index=player.index, gui_filters=search_button})
  event.register({defines.events.on_gui_click, defines.events.on_gui_closed}, modal_dialog_closed,
                 {name='modal_dialog_closed', player_index=player.index, gui_filters={window, close_button}})

  return {window=window, titlebar=titlebar}
end

function modal_dialog.destroy(gui_data, player_index)
  for name,handler in pairs(handlers) do
    local registered = event.is_registered(name, player_index)
    if registered then
      event.deregister_conditional(handler, {name=name, player_index=player_index})
    end
  end
  gui_data.modal.window.destroy()
  gui_data.modal = nil
end

return modal_dialog