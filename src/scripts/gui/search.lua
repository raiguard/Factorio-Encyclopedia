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
    gui_data.use_keyboard_nav = false
  else
    search_textfield.text = ''
    if gui_data.state == 'choose_action' then
      gui_data.state = 'search'
      gui_data.search_elems.results_pane.visible = true
      gui_data.search_elems.results_listbox.clear_items()
      gui_data.search_elems.actions_scrollpane.visible = false
      if gui_data.selected_index then
        gui_data.search_elems.actions_scrollpane.children[gui_data.selected_index].style = 'button'
      end
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

local function search_textfield_clicked(e)
  local gui_data = global.players[e.player_index].gui.search
  if gui_data.state == 'choose_action' then
    -- update GUI state
    gui_data.state = 'search'
    gui_data.search_elems.results_pane.visible = true
    gui_data.search_elems.actions_scrollpane.visible = false
    gui_data.search_elems.results_listbox.selected_index = 0
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
  -- update GUI state
  gui_data.state = 'choose_action'
  gui_data.search_elems.results_pane.visible = false
  gui_data.search_elems.actions_scrollpane.visible = true
  if e.used_keyboard then
    gui_data.selected_index = 1
    gui_data.search_elems.actions_scrollpane.children[1].style = 'fe_button_selected'
  else
    gui_data.use_keyboard_nav = false
  end
end

local function category_button_clicked(e)
  local gui_data = global.players[e.player_index].gui.search
  e.element.parent['fe_category_button_'..gui_data.category].style = 'tool_button'
  e.element.style = 'fe_tool_button_active'
  gui_data.category = e.element.name:gsub('fe_category_button_', '')
  search_gui.refresh_search_pane(game.get_player(e.player_index), gui_data)
end

local function input_nav_dir(e)
  local gui_data = global.players[e.player_index].gui.search
  local base_elems = gui_data.base_elems
  local search_elems = gui_data.search_elems
  local delta = e.input_name:find('up') and -1 or 1
  if gui_data.use_keyboard_nav then
    if gui_data.state == 'choose_category' then
      local children = base_elems.category_bar.children
      local selected = children[gui_data.selected_index]
      if selected.style.name == 'fe_tool_button_active_selected' then
        selected.style = 'fe_tool_button_active'
      else
        selected.style = 'tool_button'
      end
      gui_data.selected_index = util.clamp(gui_data.selected_index+delta, 1, #children)
      selected = children[gui_data.selected_index]
      if selected.style.name == 'fe_tool_button_active' then
        selected.style = 'fe_tool_button_active_selected'
      else
        selected.style = 'fe_tool_button_selected'
      end
    elseif gui_data.state == 'choose_result' then
      local listbox = search_elems.results_listbox
      listbox.selected_index = util.clamp(listbox.selected_index+delta, 1, #listbox.items)
    elseif gui_data.state == 'choose_action' then
      search_elems.actions_scrollpane.children[gui_data.selected_index].style = 'button'
      gui_data.selected_index = util.clamp(gui_data.selected_index+delta, 1, #search_elems.actions_scrollpane.children)
      search_elems.actions_scrollpane.children[gui_data.selected_index].style = 'fe_button_selected'
    end
  end
end

local function input_nav_confirm(e)
  local gui_data = global.players[e.player_index].gui.search
  local search_elems = gui_data.search_elems
  if gui_data.use_keyboard_nav then
    if gui_data.state == 'choose_category' then
      category_button_clicked{player_index=e.player_index, element=gui_data.base_elems.category_bar.children[gui_data.selected_index]}
    elseif gui_data.state == 'choose_result' then
      results_listbox_selection_state_changed{player_index=e.player_index, element=search_elems.results_listbox, used_keyboard=true}
    elseif gui_data.state == 'choose_action' then
      action_button_clicked{player_index=e.player_index, element=search_elems.actions_scrollpane.children[gui_data.selected_index]}
    end
  end
end

local function input_nav_back(e)
  local gui_data = global.players[e.player_index].gui.search
  local search_elems = gui_data.search_elems
  if gui_data.use_keyboard_nav then
    if gui_data.state == 'choose_result' then
      search_elems.textfield.focus()
      search_elems.results_listbox.selected_index = 0
      gui_data.state = 'search'
    elseif gui_data.state == 'choose_action' then
      search_elems.results_pane.visible = true
      search_elems.actions_scrollpane.visible = false
      search_elems.textfield.text = gui_data.search_query
      search_elems.choose_elem_button.elem_value = nil
      search_elems.actions_scrollpane.children[gui_data.selected_index].style = 'button'
      gui_data.state = 'choose_result'
    end
  end
end

local function search_textfield_confirmed(e)
  local gui_data = global.players[e.player_index].gui.search
  -- set initial index
  gui_data.search_elems.results_listbox.selected_index = 1
  -- register keyboard shortcuts
  event.register({'fe-nav-up', 'fe-nav-down'}, input_nav_dir, {name='search_input_nav_dir', player_index=e.player_index})
  event.register('fe-nav-confirm', input_nav_confirm, {name='search_input_nav_confirm', player_index=e.player_index})
  event.register('fe-nav-back', input_nav_back, {name='search_input_nav_back', player_index=e.player_index})
  -- set GUI state
  gui_data.state = 'choose_result'
  gui_data.use_keyboard_nav = true
end


local handlers = {
  search_action_button_clicked = action_button_clicked,
  search_elem_changed = search_elem_changed,
  search_textfield_text_changed = search_textfield_text_changed,
  search_textfield_clicked = search_textfield_clicked,
  search_results_listbox_selection_state_changed = results_listbox_selection_state_changed,
  search_category_button_clicked = category_button_clicked,
  search_input_nav_dir = input_nav_dir,
  search_input_nav_confirm = input_nav_confirm,
  search_input_nav_back = input_nav_back,
  search_textfield_confirmed = search_textfield_confirmed,
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
  for category,_ in pairs(gui_defs) do
    category_bar.add{type='sprite-button', name='fe_category_button_'..category, style='tool_button',
                     sprite='fe_category_'..category, tooltip={'fe-gui-search.category-button-caption-'..category}}
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
function search_gui.toggle(player, use_keyboard_nav, category)
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
    gui_data.base_elems.category_bar['fe_category_button_'..category].style = 'fe_tool_button_active'
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
    event.on_gui_selection_state_changed(results_listbox_selection_state_changed, {name='search_results_listbox_selection_state_changed', player_index=player.index})
    gui_data.search_query = ''
    if use_keyboard_nav then
      -- register keyboard shortcuts
      event.register({'fe-nav-up', 'fe-nav-down'}, input_nav_dir, {name='search_input_nav_dir', player_index=player.index})
      event.register('fe-nav-confirm', input_nav_confirm, {name='search_input_nav_confirm', player_index=player.index})
      event.register('fe-nav-back', input_nav_back, {name='search_input_nav_back', player_index=player.index})
      -- set flag
      gui_data.use_keyboard_nav = true
      gui_data.state = 'choose_category'
      -- set style
      for i,element in ipairs(gui_data.base_elems.category_bar.children) do
        if element.style.name:match('active') then
          element.style = 'fe_tool_button_active_selected'
          gui_data.selected_index = i
          break
        end
      end
    else
      gui_data.use_keyboard_nav = false
      gui_data.search_elems.textfield.focus()
      gui_data.state = 'search'
    end
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
  gui_data.search_elems.textfield.focus()
  gui_data.state = 'search'
  gui_data.search_query = ''
end

return search_gui