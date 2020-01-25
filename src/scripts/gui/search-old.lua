-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SEARCH GUI

-- dependencies
local event = require('lualib.event')

-- locals
local string_match = string.match
local string_lower = string.lower
local table_sort = table.sort

-- objects
local self = {}
local handlers = {
  common = {},
  search = {},
  search_nav = {},
  history = {}
}

-- -----------------------------------------------------------------------------
-- UTILITIES

-- registers GUI events in a more compact form
local function register_gui_handlers(player_index, prefix, t)
  for _,data in ipairs(t) do
    event.register(data[1], handlers[prefix][data[2].name], {name='search_'..prefix..'_'..data[2].name, player_index=player_index,
                   gui_filters=data[2].gui_filters})
  end
end

-- deregisters GUI events in a more compact form
local function deregister_gui_handlers(player_index, prefix)
  for name,handler in pairs(handlers[prefix]) do
    if event.is_registered('search_'..prefix..'_'..name, player_index) then
      event.deregister_conditional(handler, {name='search_'..prefix..'_'..name, player_index=player_index})
    end
  end
end

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS

-- COMMON

function handlers.common.gui_closed(e)
  local gui_data = global.players[e.player_index].gui
  local search_data = gui_data.search
  if search_data.state == 'select_category' then
    self.close(game.get_player(e.player_index), gui_data)
  end
end

function handlers.common.selected_tab_changed(e)
  local gui_data = global.players[e.player_index].gui.search
  local search_elems = gui_data.search_elems
  local state = gui_data.state
  local index = e.element.selected_tab_index
  if index == 1 then -- search
    if state == 'search' then -- refocus textfield
      search_elems.textfield.select_all()
      search_elems.textfield.focus()
    end
  else

  end
end

-- SEARCH

-- change current category and refresh GUI
function handlers.search.category_button_clicked(e)
  if e.used_keyboard_nav == nil then e.used_keyboard_nav = false end
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui.search
  local search_elems = gui_data.search_elems
  if not e.used_keyboard_nav then
    e.element.style = 'fe_tool_button_active'
    if not e.used_keyboard_confirm then
      search_elems.category_frame['fe_category_button_'..gui_data.category].style = 'tool_button'
    end
  end
  _,_,gui_data.category = e.element.name:find('fe_category_button_(.*)')
  self.reset_search_pane(e.player_index, player_table, not e.used_keyboard_nav)
end

-- open dialog for the chosen element
function handlers.search.choose_elem_button_elem_changed(e)
  local category = e.element.elem_type
  local object_name = e.element.elem_value
  self.close(game.get_player(e.player_index), global.players[e.player_index].gui)
  event.raise(open_info_gui_event, {player_index=e.player_index, category=category, object_name=object_name, source='fe_search'})
end

-- update search results list
function handlers.search.textfield_text_changed(e)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui.search
  local search_elems = gui_data.search_elems
  local query = string_lower(e.text)
  local category = gui_data.category
  local search_table = player_table.dictionary[category].searchable
  local results_listbox = search_elems.results_listbox
  local add_item = results_listbox.add_item
  local set_item = results_listbox.set_item
  local remove_item = results_listbox.remove_item
  local items_length = #results_listbox.items
  local i = 0
  for i1=1,#search_table do
    local t = search_table[i1]
    local translated = t.translated
    if string_match(string_lower(translated), query) then
      local caption = '[img='..category..'/'..t.internal..']  '..translated
      i = i + 1
      if i <= items_length then
        set_item(i, caption)
      else
        add_item(caption)
      end
    end
  end
  for i=#results_listbox.items,i+1,-1 do
    remove_item(i)
  end
end

-- enter keyboard navigation of search results
function handlers.search.textfield_confirmed(e)
  local gui_data = global.players[e.player_index].gui.search
  local search_elems = gui_data.search_elems
  -- register navigation handlers
  register_gui_handlers(e.player_index, 'search_nav', {
    {{'fe-nav-up', 'fe-nav-down'}, {name='up_down'}},
    {'fe-nav-confirm', {name='confirm'}},
    {defines.events.on_gui_closed, {name='closed', gui_filters=search_elems.results_listbox}}
  })
  -- set initial selected index
  search_elems.results_listbox.selected_index = 1
  -- set GUI state
  gui_data.state = 'select_result'
  -- set open GUI
  game.get_player(e.player_index).opened = search_elems.results_listbox
end

-- exit keyboard navigation of results
function handlers.search.textfield_clicked(e)
  local gui_data = global.players[e.player_index].gui.search
  if gui_data.state == 'select_result' or gui_data.state == 'select_category' then
    local search_elems = gui_data.search_elems
    -- deregister navigation handlers
    deregister_gui_handlers(e.player_index, 'search_nav')
    -- unset selected index
    search_elems.results_listbox.selected_index = 0
    if gui_data.selected_category then
      search_elems.category_frame.children[gui_data.selected_category].style = 'fe_tool_button_active'
      gui_data.selected_category = nil
    end
    -- set GUI state
    gui_data.state = 'search'
    game.get_player(e.player_index).opened = search_elems.textfield
    -- focus textfield if needed
    if e.closed_from_nav then
      search_elems.textfield.focus()
    end
  end
end

-- go to category selection
function handlers.search.textfield_closed(e)
  local gui_data = global.players[e.player_index].gui.search
  if gui_data.state == 'search' then
    local search_elems = gui_data.search_elems
    -- defocus textfield
    search_elems.category_frame.focus()
    -- set initial selected index
    for i,elem in ipairs(search_elems.category_frame.children) do
      if elem.style.name:find('active') then
        gui_data.selected_category = i
        elem.style = 'fe_tool_button_selected'
        break
      end
    end
    -- register navigation handlers
    register_gui_handlers(e.player_index, 'search_nav', {
      {{'fe-nav-up', 'fe-nav-down'}, {name='up_down'}},
      {'fe-nav-confirm', {name='confirm'}}
    })
    -- set GUI state
    gui_data.state = 'select_category'
    game.get_player(e.player_index).opened = gui_data.window
  end
end

-- open dialog for the chosen item
function handlers.search.result_selection_changed(e)
  local gui_data = global.players[e.player_index].gui
  local _,_,category,object_name = e.element.get_item(e.element.selected_index):find('^%[img=(.*)/(.*)%].*$')
  self.close(game.get_player(e.player_index), gui_data)
  event.raise(open_info_gui_event, {player_index=e.player_index, category=category, object_name=object_name, source='fe_search'})
end

-- SEARCH NAVIGATION

-- navigate lists
function handlers.search_nav.up_down(e)
  local gui_data = global.players[e.player_index].gui.search
  local search_elems = gui_data.search_elems
  -- set delta
  local delta
  if e.input_name:find('up') then delta = -1
  else delta = 1
  end
  -- apply delta
  if gui_data.state == 'select_category' then
    local children = search_elems.category_frame.children
    children[gui_data.selected_category].style = 'tool_button'
    gui_data.selected_category = util.clamp(gui_data.selected_category + delta, 1, #children)
    children[gui_data.selected_category].style = 'fe_tool_button_selected'
    e.element = children[gui_data.selected_category]
    e.used_keyboard_nav = true
    handlers.search.category_button_clicked(e)
  elseif gui_data.state == 'select_result' then
    local listbox = search_elems.results_listbox
    listbox.selected_index = util.clamp(listbox.selected_index+delta, 1, #listbox.items)
  end
end

-- confirm selection
function handlers.search_nav.confirm(e)
  local gui_data = global.players[e.player_index].gui.search
  local search_elems = gui_data.search_elems
  if gui_data.state == 'select_category' then
    e.element = search_elems.category_frame.children[gui_data.selected_category]
    e.used_keyboard_nav = false
    e.used_keyboard_confirm = true
    handlers.search.category_button_clicked(e)
  elseif gui_data.state == 'select_result' then
    e.element = search_elems.results_listbox
    handlers.search.result_selection_changed(e)
  end
end

-- escape selection (in the case of selecting a search result)
function handlers.search_nav.closed(e)
  e.closed_from_nav = true
  handlers.search.textfield_clicked(e)
end

-- HISTORY

function handlers.history.listbox_selection_changed(e)
  local _,_,category,object_name = e.element.get_item(e.element.selected_index):find('^%[.*%].*%[img=(.*)/(.*)%].*$')
  self.close(game.get_player(e.player_index), global.players[e.player_index].gui)
  event.raise(open_info_gui_event, {player_index=e.player_index, category=category, object_name=object_name, source='fe_history'})
end

-- ON LOAD

event.on_load(function()
  event.load_conditional_handlers(handlers.common)
  event.load_conditional_handlers(handlers.search)
  event.load_conditional_handlers(handlers.search_nav)
  event.load_conditional_handlers(handlers.history)
end)

-- -----------------------------------------------------------------------------
-- OBJECT

function self.open(player, options, player_table)
  options = options or {}
  player_table = player_table or global.players[player.index]
  local gui_data = {}
  --
  -- COMMON
  --
  gui_data.window = player.gui.screen.add{type='frame', name='fe_search_window', style='fe_empty_frame'} -- needed for drag_target to work
  gui_data.tabbed_pane = gui_data.window.add{type='tabbed-pane', name='fe_search_window', style='fe_search_tabbed_pane'}
  -- REGISTER HANDLERS
  register_gui_handlers(player.index, 'common', {
    {defines.events.on_gui_closed, {name='gui_closed', gui_filters=gui_data.window}},
    {defines.events.on_gui_selected_tab_changed, {name='selected_tab_changed', gui_filters=gui_data.tabbed_pane}}
  })
  --
  -- SEARCH
  --
  do
    local data = {}
    local search_pane = gui_data.tabbed_pane.add{type='frame', name='fe_search_pane', style='window_content_frame_packed', direction='horizontal'}
    -- CATEGORIES
    data.category_frame = search_pane.add{type='frame', name='fe_category_frame', style='fe_toolbar_left', direction='vertical'}
    for category,_ in pairs(global.encyclopedia) do
      data.category_frame.add{type='sprite-button', name='fe_category_button_'..category, style='tool_button', sprite='fe_category_'..category,
                               tooltip={'fe-gui.category-'..category..'-plural'}}
    end
    -- SEARCH
    local search_flow = search_pane.add{type='flow', name='fe_search_flow', style='fe_search_flow', direction='vertical'}
    -- input
    local input_flow = search_flow.add{type='flow', name='fe_input_flow', style='fe_search_input_flow', direction='horizontal'}
    data.choose_elem_button_container = input_flow.add{type='flow', name='fe_choose_elem_button_container', style='fe_paddingless_flow'}
    data.choose_elem_button = data.choose_elem_button_container.add{type='choose-elem-button', name='fe_search_choose_elem_button',
                                                                    style='quick_bar_slot_button', elem_type='item'}
    data.textfield = input_flow.add{type='textfield', name='fe_search_textfield', style='fe_search_textfield', clear_and_focus_on_right_click=true,
                                    lose_focus_on_confirm=true}
    -- results
    data.results_listbox = search_flow.add{type='frame', name='fe_results_frame', style='fe_search_results_listbox_frame'}
    .add{type='list-box', name='fe_results_listbox', style='fe_listbox_for_keyboard_nav'}
    -- ADD TAB
    gui_data.tabbed_pane.add_tab(
      gui_data.tabbed_pane.add{type='tab', name='fe_search_tab', style='fe_search_tab', caption={'gui.search'}},
      search_pane
    )
    -- REGISTER HANDLERS
    register_gui_handlers(player.index, 'search', {
      {defines.events.on_gui_click, {name='category_button_clicked', gui_filters=data.category_frame.children}},
      {defines.events.on_gui_elem_changed, {name='choose_elem_button_elem_changed', gui_filters='fe_search_choose_elem_button'}},
      {defines.events.on_gui_text_changed, {name='textfield_text_changed', gui_filters=data.textfield}},
      {defines.events.on_gui_confirmed, {name='textfield_confirmed', gui_filters=data.textfield}},
      {defines.events.on_gui_click, {name='textfield_clicked', gui_filters=data.textfield}},
      {defines.events.on_gui_closed, {name='textfield_closed', gui_filters=data.textfield}},
      {defines.events.on_gui_selection_state_changed, {name='result_selection_changed', gui_filters=data.results_listbox}}
    })
    -- SET INITIAL STATE
    -- category
    data.category_frame['fe_category_button_'..(options.category or 'item')].style = 'fe_tool_button_active'
    -- search textfield
    data.textfield.text = player_table.dictionary.other.translations.search..' '..player_table.dictionary.category.translations[options.category or 'item']..'...'
    -- EXPORT DATA
    gui_data.search_elems = data
  end
  --
  -- HISTORY
  --
  do
    local data = {}
    local history_pane = gui_data.tabbed_pane.add{type='frame', name='fe_history_pane', style='window_content_frame_packed', direction='vertical'}
    -- TOOLBAR
    data.toolbar = history_pane.add{type='frame', name='fe_toolbar_frame', style='fe_toolbar_frame', direction='horizontal'}
    data.toolbar.add{type='empty-widget', name='fe_pusher', style='fe_horizontal_pusher'}
    data.delete_button = data.toolbar.add{type='sprite-button', name='fe_delete_button', style='red_icon_button', sprite='utility/trash'}
    data.delete_button.enabled = false
    -- HISTORY
    data.history_listbox = history_pane.add{type='frame', name='fe_history_frame', style='fe_history_listbox_frame'}
    .add{type='list-box', name='fe_history_listbox', style='fe_listbox'}
    gui_data.tabbed_pane.add_tab(
      gui_data.tabbed_pane.add{type='tab', name='fe_history_tab', style='fe_search_tab', caption={'fe-gui.history'}},
      history_pane
    )
    -- populate listbox
    local history = player_table.history.overall
    local add_item = data.history_listbox.add_item
    for i=1,#history do
      local entry = history[i]
      add_item('[img=fe_category_'..entry.category..'_yellow]  [img='..entry.category..'/'..entry.name..']  '
               ..(player_table.dictionary[entry.category].translations[entry.name] or entry.name))
    end
    -- REGISTER HANDLERS
    register_gui_handlers(player.index, 'history', {
      {defines.events.on_gui_selection_state_changed, {name='listbox_selection_changed', gui_filters=data.history_listbox}}
    })
    -- EXPORT DATA
    gui_data.history_elems = data
  end
  --
  -- THE REST
  --
  -- complete gui data, add it to global
  gui_data.state = 'search'
  gui_data.category = options.category or 'item'
  player_table.gui.search = gui_data
  gui_data.window.force_auto_center()
  -- focus search textfield (we must do this last to keep focus)
  gui_data.search_elems.textfield.select_all()
  gui_data.search_elems.textfield.focus()
  -- populate search results list
  handlers.search.textfield_text_changed{player_index=player.index, text=''}
  -- set textfield to be the "open" gui to allow escaping into category selection
  player.opened = gui_data.search_elems.textfield
end

-- will prevent opening the GUI if dictionary translation is not finished
function self.protected_open(player, options)
  local player_table = global.players[player.index]
  if player_table.flags.allow_open_gui then
    self.open(player, options, player_table)
  else
    player.print{'fe-chat-message.translation-not-finished'}
    player_table.flags.tried_to_open_gui = true
  end
end

function self.close(player, gui_data)
  gui_data.search.window.destroy()
  deregister_gui_handlers(player.index, 'common')
  deregister_gui_handlers(player.index, 'search')
  deregister_gui_handlers(player.index, 'search_nav')
  deregister_gui_handlers(player.index, 'history')
  gui_data.search = nil
end

function self.toggle(player, options)
  local gui_data = global.players[player.index].gui
  if gui_data.search then
    self.close(player, gui_data)
  else
    self.protected_open(player, options)
  end
end

function self.reset_search_pane(player_index, player_table, used_mouse)
  local gui_data = player_table.gui.search
  local search_elems = gui_data.search_elems
  search_elems.choose_elem_button_container.clear()
  search_elems.choose_elem_button = search_elems.choose_elem_button_container.add{type='choose-elem-button', name='fe_search_choose_elem_button',
                                                                                  style='quick_bar_slot_button', elem_type=gui_data.category}
  search_elems.results_listbox.selected_index = 0
  search_elems.textfield.text = player_table.dictionary.other.translations.search..' '..player_table.dictionary.category.translations[gui_data.category]..'...'
  handlers.search.textfield_text_changed{player_index=player_index, text=''}
  if used_mouse then -- set GUI state and focus textfield
    gui_data.state = 'search'
    search_elems.textfield.select_all()
    search_elems.textfield.focus()
    game.get_player(player_index).opened = search_elems.textfield
  end
end

-- -----------------------------------------------------------------------------

return self