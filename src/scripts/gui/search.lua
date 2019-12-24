-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SEARCH GUI SCRIPTING

-- dependencies
local event = require('lualib/event')
local mod_gui = require('mod-gui')
local util = require('lualib/util')

-- modules
local search_data = require('scripts/data/search')
local modal_dialog = require('scripts/gui/modal-dialogs/root')

-- library
local search_gui = {}

-- -----------------------------------------------------------------------------
-- LOCAL UTILITIES



-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

local function category_button_clicked(e)
  local gui_data = global.players[e.player_index].gui.search
  e.element.parent['fe_category_button_'..gui_data.selected_category].style = 'tool_button'
  e.element.style = 'fe_tool_button_selected'
  gui_data.selected_category = e.element.name:gsub('fe_category_button_', '')
end

local function action_button_clicked(e)
  local action = e.element.name:gsub('fe_search_action_button_', '')
  local player = game.get_player(e.player_index)
  local gui_data = global.players[e.player_index].gui
  local search_gui = gui_data.search
  if gui_data.modal then
    modal_dialog.destroy(gui_data, e.player_index)
  end
  -- create modal dialog
  gui_data.modal = modal_dialog.create(player, player.gui.screen, search_gui.selected_category, search_gui.elems.choose_elem_button.elem_value, 'view_prototype')
end

local handlers = {
  category_button_clicked = category_button_clicked,
  action_button_clicked = action_button_clicked
}

event.on_load(function()
  event.load_conditional_handlers(handlers)
end)

-- -----------------------------------------------------------------------------
-- LIBRARY

-- -------------------------------------
-- UTILITIES

local function create_base_gui(player, mod_frame_flow)
  local frame_flow = mod_frame_flow.add{type='flow', name='fe_mod_gui_frame_flow', direction='horizontal'}
  local window = frame_flow.add{type='frame', name='fe_search_window', style='dialog_frame', direction='vertical'}
  -- titlebar
  local titlebar = window.add{type='flow', name='fe_search_titlebar_flow', style='fe_titlebar_flow'}
  titlebar.add{type='label', name='fe_search_titlebar_label', style='frame_title', caption={'gui-search.window-label-caption'}}
  -- toolbar
  local content_pane = window.add{type='frame', name='fe_search_content_pane', style='fe_search_content_pane', direction='horizontal'}
  local category_bar = content_pane.add{type='frame', name='fe_search_category_bar', style='fe_toolbar_left', direction='vertical'}
  for name,_ in pairs(global.encyclopedia) do
    category_bar.add{type='button', name='fe_category_button_'..name, style='tool_button', caption={'gui-search.category-button-caption-'..name}}
  end
  local search_pane = content_pane.add{type='frame', name='fe_search_dialog_pane', style='fe_search_dialog_pane'}
  event.on_gui_click(category_button_clicked, {name='category_button_clicked', player_index=player.index, gui_filters='fe_category_button_'})
  return {window=window, category_bar=category_bar, search_pane=search_pane}
end

-- -------------------------------------
-- EXTERNAL

-- toggle search GUI
function search_gui.toggle(player, selected_category, used_hotkey) -- used_hotkey will be used to turn on keyboard shortcuts sometime in the future
  local mod_frame_flow = mod_gui.get_frame_flow(player)
  if mod_frame_flow.fe_mod_gui_frame_flow then -- destroy the GUI
    mod_frame_flow.fe_mod_gui_frame_flow.destroy()
    -- deregister conditional handlers
    for name,handler in pairs(handlers) do
      if event.is_registered(name, player.index) then
        event.deregister_conditional(handler, {name=name, player_index=player.index})
      end
    end
  else -- create the GUI
    -- base window
    local base_elems = create_base_gui(player, mod_frame_flow)
    -- set active category button
    base_elems.category_bar['fe_category_button_'..(selected_category or 'entities')].style = 'fe_tool_button_selected'
    -- create search pane (hardcoded for now)
    local choose_elem_button = base_elems.search_pane.add{type='choose-elem-button', name='fe_search_choose_elem_button', style='quick_bar_slot_button',
                                                          elem_type='entity'}
    local view_prototype_button = base_elems.search_pane.add{type='button', name='fe_search_action_button_view_prototype', caption='View prototype data'}
    event.on_gui_click(action_button_clicked, {name='action_button_clicked', player_index=player.index, gui_filters='fe_search_action_button_'})
    base_elems.choose_elem_button = choose_elem_button
    base_elems.view_prototype_button = view_prototype_button
    -- update global
    global.players[player.index].gui.search = {
      elems = base_elems,
      selected_category = selected_category or 'entities'
    }
  end
end

return search_gui