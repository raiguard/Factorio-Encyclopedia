-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SEARCH GUI SCRIPTING

-- dependencies
local event = require('lualib/event')

-- objects
local self = {}
local handlers = {
  search = {},
  history = {}
}

-- -----------------------------------------------------------------------------
-- UTILITIES

-- registers GUI events in a more compact form
local function register_gui_handlers(player_index, prefix, t)
  for _,data in ipairs(t) do
    event.register(data[1], handlers[prefix][data[2].name], {name=prefix..'_'..data[2].name, player_index=player_index, gui_filters=data[2].gui_filters})
  end
end

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS

-- SEARCH

function handlers.search.category_button_clicked(e)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui.search
  local search_data = gui_data.search
  e.element.style = 'fe_tool_button_active'
  search_data.category_frame['fe_category_button_'..search_data.category].style = 'tool_button'
  _,_,search_data.category = e.element.name:find('fe_category_button_(.*)')
  self.reset_search_pane(player_table)
end

function handlers.search.choose_elem_button_elem_changed(e)
  local gui_data = global.players[e.player_index].gui
  local search_data = gui_data.search
  game.print(serpent.block(e))
end

function handlers.search.textfield_text_changed(e)
  local gui_data = global.players[e.player_index].gui
  local search_data = gui_data.search
  game.print(serpent.block(e))
end

function handlers.search.textfield_confirmed(e)
  local gui_data = global.players[e.player_index].gui
  local search_data = gui_data.search
  game.print(serpent.block(e))
end

function handlers.search.textfield_clicked(e)
  local gui_data = global.players[e.player_index].gui
  local search_data = gui_data.search
  game.print(serpent.block(e))
end

function handlers.search.result_item_clicked(e)
  local gui_data = global.players[e.player_index].gui
  local search_data = gui_data.search
  game.print(serpent.block(e))
end

-- HISTORY

event.on_load(function()
  event.load_conditional_handlers(handlers.search)
  event.load_conditional_handlers(handlers.history)
end)

-- -----------------------------------------------------------------------------
-- OBJECT

function self.open(player, options, player_table)
  options = options or {}
  player_table = player_table or global.players[player.index]
  local gui_data = {}
  gui_data.window = player.gui.screen.add{type='frame', name='fe_search_window', style='fe_empty_frame'} -- needed for drag_target to work
  gui_data.tabbed_pane = gui_data.window.add{type='tabbed-pane', name='fe_search_window', style='fe_search_tabbed_pane'}
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
                               tooltip={'fe-gui-general.category-'..category}}
    end
    -- SEARCH
    local search_flow = search_pane.add{type='flow', name='fe_search_flow', style='fe_search_flow', direction='vertical'}
    -- input
    local input_flow = search_flow.add{type='flow', name='fe_input_flow', style='fe_search_input_flow', direction='horizontal'}
    data.choose_elem_button_container = input_flow.add{type='flow', name='fe_choose_elem_button_container', style='fe_paddingless_flow'}
    data.choose_elem_button = data.choose_elem_button_container.add{type='choose-elem-button', name='fe_search_choose_elem_button',
                                                                    style='quick_bar_slot_button', elem_type='item'}
    data.textfield = input_flow.add{type='textfield', name='fe_search_textfield', style='fe_search_textfield'}

    -- results
    data.results_scrollpane = search_flow.add{type='frame', name='fe_results_frame', style='fe_mock_listbox_frame'}
    .add{type='scroll-pane', name='fe_results_scrollpane', style='fe_mock_listbox_scrollpane'}
    -- ADD TAB
    gui_data.tabbed_pane.add_tab(
      gui_data.tabbed_pane.add{type='tab', name='fe_search_tab', style='fe_search_tab', caption={'fe-gui-search.search-tab-caption'}},
      search_pane
    )
    -- REGISTER HANDLERS
    register_gui_handlers(player.index, 'search', {
      {defines.events.on_gui_click, {name='category_button_clicked', gui_filters=data.category_frame.children}},
      {defines.events.on_gui_elem_changed, {name='choose_elem_button_elem_changed', gui_filters='fe_search_choose_elem_button'}},
      {defines.events.on_gui_text_changed, {name='textfield_text_changed', gui_filters=data.textfield}},
      {defines.events.on_gui_confirmed, {name='textfield_confirmed', gui_filters=data.textfield}},
      {defines.events.on_gui_click, {name='textfield_clicked', gui_filters=data.textfield}},
      {defines.events.on_gui_click, {name='result_item_clicked', gui_filters='fe_result_item_'}}
    })
    -- SET INITIAL STATE
    -- category
    data.category_frame['fe_category_button_'..(options.category or 'item')].style = 'fe_tool_button_active'
    data.category = options.category or 'item'
    -- search textfield
    data.textfield.text = player_table.dictionary.other.search[1]..' '..player_table.dictionary.category_name[data.category][1]..'...'
    -- EXPORT DATA
    gui_data.search = data
  end
  --
  -- HISTORY
  --
  do
    local data = {}
    local history_pane = gui_data.tabbed_pane.add{type='frame', name='fe_history_pane', style='window_content_frame_packed', direction='vertical'}
    -- TOOLBAR
    data.delete_button = history_pane.add{type='frame', name='fe_toolbar_frame', style='fe_toolbar_frame', direction='horizontal'}
    .add{type='empty-widget', name='fe_pusher', style='fe_horizontal_pusher'}
    .parent.add{type='sprite-button', name='fe_delete_button', style='red_icon_button', sprite='utility/trash'}
    -- HISTORY
    data.history_scrollpane = history_pane.add{type='frame', name='fe_history_frame', style='fe_history_mock_listbox_frame'}
    .add{type='scroll-pane', name='fe_history_scrollpane', style='fe_mock_listbox_scrollpane'}
    gui_data.tabbed_pane.add_tab(
      gui_data.tabbed_pane.add{type='tab', name='fe_history_tab', style='fe_search_tab', caption={'fe-gui-search.history-tab-caption'}},
      history_pane
    )
    gui_data.history = data
  end
  --
  -- THE REST
  --
  gui_data.state = 'search'
  player_table.gui.search = gui_data
  gui_data.window.force_auto_center()
  -- focus search textfield (we must do this last to keep focus)
  gui_data.search.textfield.select_all()
  gui_data.search.textfield.focus()
end

function self.protected_open(player, options)
  local player_table = global.players[player.index]
  if player_table.flags.allow_open_gui then
    self.open(player, options, player_table)
  else
    player.print{'fe-chat-message.translation-not-finished'}
    player_table.flags.tried_to_open_gui = true
  end
end

function self.close(player)

end

function self.toggle(player, options)
  local gui_data = global.players[player.index].gui
  if gui_data.search then
    self.close(player)
  else
    self.protected_open(player, options)
  end
end

function self.reset_search_pane(player_table)
  local gui_data = player_table.gui.search
  local search_data = gui_data.search
  search_data.choose_elem_button_container.clear()
  search_data.choose_elem_button = search_data.choose_elem_button_container.add{type='choose-elem-button', name='fe_search_choose_elem_button',
                                                                                style='quick_bar_slot_button', elem_type=search_data.category}
  search_data.textfield.text = player_table.dictionary.other.search[1]..' '..player_table.dictionary.category_name[search_data.category][1]..'...'
  search_data.textfield.select_all()
  search_data.textfield.focus()
end

-- -----------------------------------------------------------------------------

return self