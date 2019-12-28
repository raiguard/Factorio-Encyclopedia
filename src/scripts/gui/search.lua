-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SEARCH GUI SCRIPTING

-- dependencies
local event = require('lualib/event')
local mod_gui = require('mod-gui')

-- modules
local gui_defs = require('scripts/gui/gui-definitions')
local modal_dialog = require('scripts/gui/modal-dialogs/root')

-- library
local search_gui = {}

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

local function action_button_clicked(e)
  local action = e.element.name:gsub('fe_search_action_button_', '')
  local player = game.get_player(e.player_index)
  local gui_data = global.players[e.player_index].gui
  local search_gui_data = gui_data.search
  local elem_value = search_gui_data.search_elems.choose_elem_button.elem_value
  if gui_data.modal then
    modal_dialog.destroy(gui_data, e.player_index)
  end
  -- create modal dialog
  -- gui_data.modal = modal_dialog.create(player, player.gui.screen, search_gui_data.category, elem_value, action)
  game.print('create modal dialog: '..action)
end

local function search_elem_changed(e)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui.search
  local search_textfield = gui_data.search_elems.textfield
  local encyclopedia = global.encyclopedia[gui_data.category]
  if e.element.elem_value then
    local entry = encyclopedia[e.element.elem_value]
    if entry then
      search_textfield.text = entry.translated_name
      gui_data.search_query = search_textfield.text
    else
      error('\''..e.element.elem_value..'\' not found in '..gui_data.category..' encyclopedia')
    end
    -- update GUI state
    gui_data.state = 'choose_action'
    gui_data.search_elems.results_pane.visible = false
    gui_data.search_elems.actions_scrollpane.visible = true
  else
    search_textfield.text = ''
    if gui_data.state == 'choose_action' then
      gui_data.state = 'search'
      gui_data.search_elems.results_pane.visible = true
      gui_data.search_elems.results_listbox.clear_items()
      gui_data.search_elems.actions_scrollpane.visible = false
    end
  end
end

local function search_textfield_text_changed(e)
  -- local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui.search
  local results_listbox = gui_data.search_elems.results_listbox
  local query = string.lower(e.element.text)
  local search_table = player_table.search[gui_data.category]
  -- override all if it's empty
  if e.element.text == '' then
    results_listbox.clear_items()
    return
  end
  -- perform search
  local items = {}
  local items_len = 0
  for localised,internal in pairs(search_table) do
    if localised:match(query) then
      for i=1,#internal do
        items_len = items_len + 1
        items[items_len] = '[img='..gui_data.category..'/'..internal[i]..']  '..localised
      end
    end
  end
  results_listbox.items = items
  -- update search query
  gui_data.search_query = query
end

local function search_textfield_confirmed(e)
  -- TODO: keyboard navigation
end

local function search_textfield_clicked(e)
  local gui_data = global.players[e.player_index].gui.search
  if gui_data.state == 'choose_action' then
    -- update GUI state
    gui_data.state = 'search'
    gui_data.search_elems.results_pane.visible = true
    gui_data.search_elems.actions_scrollpane.visible = false
    e.element.text = gui_data.search_query
    -- update search results
    search_textfield_text_changed{player_index=e.player_index, element=gui_data.search_elems.textfield}
  end
end

local function results_listbox_selection_state_changed(e)
  local _,_,internal,localised = e.element.items[e.element.selected_index]:find('^.*/(.*)%]  (.*)$') -- extract object names from rich text definition
  local gui_data = global.players[e.player_index].gui.search
  gui_data.search_elems.choose_elem_button.elem_value = internal
  gui_data.search_elems.textfield.text = localised
  e.element.selected_index = 0
  -- update GUI state
  gui_data.state = 'choose_action'
  gui_data.search_elems.results_pane.visible = false
  gui_data.search_elems.actions_scrollpane.visible = true
end

local function category_button_clicked(e)
  local gui_data = global.players[e.player_index].gui.search
  e.element.parent['fe_category_button_'..gui_data.category].style = 'tool_button'
  e.element.style = 'fe_tool_button_selected'
  gui_data.category = e.element.name:gsub('fe_category_button_', '')
  search_gui.refresh_search_pane(game.get_player(e.player_index), gui_data)
end

-- KEYBINDING HANDLERS



local handlers = {
  search_action_button_clicked = action_button_clicked,
  search_elem_changed = search_elem_changed,
  search_textfield_text_changed = search_textfield_text_changed,
  search_textfield_confirmed = search_textfield_confirmed,
  search_textfield_clicked = search_textfield_clicked,
  search_results_listbox_selection_state_changed = results_listbox_selection_state_changed,
  search_category_button_clicked = category_button_clicked
}

event.on_load(function()
  event.load_conditional_handlers(handlers)
end)

-- -----------------------------------------------------------------------------
-- LIBRARY

local function create_base_gui(player, mod_frame_flow)
  local frame_flow = mod_frame_flow.add{type='flow', name='fe_mod_gui_frame_flow', direction='horizontal'}
  local window = frame_flow.add{type='frame', name='fe_search_window', style='dialog_frame', direction='vertical'}
  -- titlebar
  local titlebar = window.add{type='flow', name='fe_search_titlebar_flow', style='fe_titlebar_flow'}
  titlebar.add{type='label', name='fe_search_titlebar_label', style='frame_title', caption={'fe-gui-search.window-label-caption'}}
  -- toolbar
  local content_pane = window.add{type='frame', name='fe_search_content_pane', style='fe_search_content_pane', direction='horizontal'}
  local category_bar = content_pane.add{type='frame', name='fe_search_category_bar', style='fe_toolbar_left', direction='vertical'}
  for name,_ in pairs(gui_defs) do
    category_bar.add{type='button', name='fe_category_button_'..name, style='tool_button', caption={'fe-gui-search.category-button-caption-'..name}}
  end
  local search_pane = content_pane.add{type='frame', name='fe_search_dialog_pane', style='fe_search_dialog_pane', direction='vertical'}
  event.on_gui_click(category_button_clicked, {name='search_category_button_clicked', player_index=player.index, gui_filters='fe_category_button_'})
  return {window=window, category_bar=category_bar, search_pane=search_pane}
end

local function create_search_pane(parent, player, gui_defs)
  local elems = {}
  local top_flow = parent.add{type='flow', name='fe_search_top_flow', style='fe_vertically_centered_flow', direction='horizontal'}
  top_flow.style.top_margin = 4
  top_flow.style.left_margin = 3
  if gui_defs.choose_elem_button then
    elems.choose_elem_button = top_flow.add{type='choose-elem-button', name='fe_search_choose_elem_button', style='quick_bar_slot_button',
                                            elem_type=gui_defs.choose_elem_button}
    elems.choose_elem_button.style.right_margin = 2
  end
  elems.textfield = top_flow.add{type='textfield', name='fe_search_textfield', style='fe_search_textfield', lose_focus_on_confirm=true,
                                        clear_and_focus_on_right_click=true}
  elems.results_pane = parent.add{type='frame', name='fe_search_results_pane', style='fe_search_results_pane'}
  elems.results_listbox = elems.results_pane.add{type='list-box', name='fe_search_results_listbox', style='fe_search_results_listbox'}
  elems.actions_scrollpane = parent.add{type='scroll-pane', name='fe_search_actions_scroll', style='scroll_pane_light', direction='vertical'}
  elems.actions_scrollpane.style.margin = 4
  elems.actions_scrollpane.style.vertically_stretchable = true
  elems.actions_scrollpane.visible = false
  for _,action in ipairs(gui_defs.action_buttons) do
    elems.actions_scrollpane.add{type='button', name='fe_search_action_button_'..action, caption={'fe-gui-search.action-button-caption-'..action}}
    .style.horizontally_stretchable = true
  end
  return elems
end

-- toggle search GUI
function search_gui.toggle(player, category)
  category = category or 'item'
  local gui_data = {category=category}
  local mod_frame_flow = mod_gui.get_frame_flow(player)
  if mod_frame_flow.fe_mod_gui_frame_flow then -- destroy the GUI
    mod_frame_flow.fe_mod_gui_frame_flow.destroy()
    -- deregister conditional handlers
    for name,handler in pairs(handlers) do
      if event.is_registered(name, player.index) then
        event.deregister_conditional(handler, {name=name, player_index=player.index})
      end
    end
  elseif global.players[player.index].flags.allow_open_gui then -- create the GUI
    -- base window
    gui_data.base_elems = create_base_gui(player, mod_frame_flow)
    -- set active category button
    gui_data.base_elems.category_bar['fe_category_button_'..category].style = 'fe_tool_button_selected'
    -- create search pane
    gui_data.search_elems = create_search_pane(gui_data.base_elems.search_pane, player, gui_defs[gui_data.category])
    -- register handlers
    -- use names instead of direct elements so we don't have to re-register then when switching categories
    event.on_gui_click(action_button_clicked, {name='search_action_button_clicked', player_index=player.index, gui_filters='fe_search_action_button_'})
    event.on_gui_elem_changed(search_elem_changed, {name='search_elem_changed', player_index=player.index, gui_filters='fe_search_choose_elem_button'})
    event.on_gui_click(search_textfield_clicked, {name='search_textfield_clicked', player_index=player.index, gui_filters='fe_search_textfield'})
    event.on_gui_text_changed(search_textfield_text_changed, {name='search_textfield_text_changed', player_index=player.index,
                              gui_filters='fe_search_textfield'})
    event.on_gui_confirmed(search_textfield_confirmed, {name='search_textfield_confirmed', player_index=player.index,
                           gui_filters='fe_search_textfield'})
    event.on_gui_selection_state_changed(results_listbox_selection_state_changed, {name='search_results_listbox_selection_state_changed'})
    gui_data.state = 'search'
    gui_data.search_query = ''
    gui_data.search_elems.textfield.focus()
    global.players[player.index].gui.search = gui_data
  else
    player.print{'fe-chat-message.translation-not-finished'}
    global.players[player.index].flags.tried_to_open_gui = true
  end
end

-- recreates the search pane
function search_gui.refresh_search_pane(player, gui_data)
  gui_data.base_elems.search_pane.clear()
  gui_data.search_elems = create_search_pane(gui_data.base_elems.search_pane, player, gui_defs[gui_data.category])
end

return search_gui