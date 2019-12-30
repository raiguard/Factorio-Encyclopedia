-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INFO GUI

-- dependencies
local event = require('lualib/event')

-- locals
local string_lower = string.lower
local table_insert = table.insert
local table_remove = table.remove

-- objects
local self = {}
local handlers = {common={}}
local pages = {}
for _,category in ipairs(categories) do
  _,pages[category] = pcall(require,'scripts/gui/info-pages/'..category)
end

-- -----------------------------------------------------------------------------
-- UTILITIES

-- registers GUI events in a more compact form
local function register_gui_handlers(player_index, prefix, t)
  for _,data in ipairs(t) do
    event.register(data[1], handlers[prefix][data[2].name], {name='info_'..prefix..'_'..data[2].name, player_index=player_index,
                   gui_filters=data[2].gui_filters})
  end
end

-- deregisters GUI events in a more compact form
local function deregister_gui_handlers(player_index, prefix)
  for name,handler in pairs(handlers[prefix]) do
    if event.is_registered('info_'..prefix..'_'..name, player_index) then
      event.deregister_conditional(handler, {name='info_'..prefix..'_'..name, player_index=player_index})
    end
  end
end

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS

function handlers.common.back_button_clicked(e)
  local player_table = global.players[e.player_index]
  local session_history = player_table.history.session
  local back_obj = session_history[session_history.position+1]
  if back_obj.source then
    self.close(game.get_player(e.player_index), player_table.gui)
    event.raise(reopen_source_event, {player_index=e.player_index, source=back_obj.source})
  else
    session_history.position = session_history.position + 1
    -- update content
    self.update_content(game.get_player(e.player_index), player_table, back_obj.category, back_obj.name, nil, nil, true)
  end
end

function handlers.common.forward_button_clicked(e)
  local player_table = global.players[e.player_index]
  local session_history = player_table.history.session
  local forward_obj = session_history[session_history.position-1]
  session_history.position = session_history.position - 1
  -- update content
  self.update_content(game.get_player(e.player_index), player_table, forward_obj.category, forward_obj.name, nil, nil, true)
end

function handlers.common.search_button_clicked(e)
  -- self.close(game.get_player(e.player_index), global.players[e.player_index].gui)
  event.raise(open_search_gui_event, {player_index=e.player_index})
end

function handlers.common.window_closed(e)
  self.close(game.get_player(e.player_index), global.players[e.player_index].gui)
end

event.on_load(function()

end)

-- -----------------------------------------------------------------------------
-- OBJECT

function self.open(player, category, name, source, player_table)
  if not category or not name then error('Cannot open info GUI without info!') end
  local player_table = player_table or global.players[player.index]
  local dictionary = player_table.dictionary
  local translations = dictionary[category].translations
  -- local encyclopedia = global.encyclopedia[category]
  local gui_data = {}
  --
  -- COMMON
  --
  do
    local common = {}
    common.window = player.gui.screen.add{type='frame', name='fe_info_window', style='dialog_frame', direction='vertical'}
    common.window.enabled = false
    -- TITLEBAR
    local titlebar = common.window.add{type='flow', name='fe_titlebar', style='fe_titlebar_flow', direction='horizontal'}
    common.back_button = titlebar.add{type='sprite-button', name='fe_back_button', style='close_button', sprite='fe_nav_backward',
                                      hovered_sprite='fe_nav_backward_dark', clicked_sprite='fe_nav_backward_dark'}
    common.forward_button = titlebar.add{type='sprite-button', name='fe_forward_button', style='close_button', sprite='fe_nav_forward',
                                         hovered_sprite='fe_nav_forward_dark', clicked_sprite='fe_nav_forward_dark'}
    titlebar.add{type='label', name='fe_window_title', style='frame_title', caption={'fe-gui.category-'..category}}.style.left_padding = 7
    titlebar.add{type='empty-widget', name='fe_draggable_space', style='fe_titlebar_draggable_space'}.drag_target = common.window
    common.search_button = titlebar.add{type='sprite-button', name='fe_search_button', style='close_button', sprite='fe_search', hovered_sprite='fe_search_dark',
                                        clicked_sprite='fe_search_dark', tooltip={'gui.search'}}
    common.close_button = titlebar.add{type='sprite-button', name='fe_close_button', style='close_button', sprite='utility/close_white',
                                        hovered_sprite='utility/close_black', clicked_sprite='utility/close_black'}
    -- BACKGROUND PANE AND INFO BAR
    common.background_pane = common.window.add{type='frame', name='fe_background_pane', style='window_content_frame_packed', direction='vertical'}
    common.info_bar = common.background_pane.add{type='frame', name='fe_info_bar', style='fe_toolbar_frame', direciton='horizontal'}
    common.info_sprite = common.info_bar.add{type='sprite', name='fe_object_icon', style='fe_object_icon', sprite=category..'/'..name}
    common.info_name = common.info_bar.add{type='label', name='fe_object_name', style='subheader_caption_label', caption=translations[name]}
    -- CONTENT SCROLLPANE
    common.content_scrollpane = common.background_pane.add{type='scroll-pane', name='fe_content_scrollpane', style='scroll_pane_under_subheader'}
    -- ACTION BAR
    common.action_bar = common.background_pane.add{type='frame', name='fe_action_bar', style='subfooter_frame', direction='horizontal'}
    common.action_bar.add{type='empty-widget', name='fe_pusher', style='fe_horizontal_pusher'}
    -- REGISTER GUI HANDLERS
    register_gui_handlers(player.index, 'common', {
      {defines.events.on_gui_click, {name='back_button_clicked', gui_filters=common.back_button}},
      {defines.events.on_gui_click, {name='forward_button_clicked', gui_filters=common.forward_button}},
      {defines.events.on_gui_click, {name='search_button_clicked', gui_filters=common.search_button}},
      {{defines.events.on_gui_click, defines.events.on_gui_closed}, {name='window_closed', gui_filters={common.close_button, common.window}}}
    })
    -- EXPORT INFO
    gui_data.common_elems = common
  end
  --
  -- THE REST
  --
  gui_data.common_elems.window.force_auto_center()
  player.opened = gui_data.common_elems.window
  player_table.gui.info = gui_data
  -- populate content
  self.update_content(player, player_table, category, name, source, true)
end

-- will prevent opening the GUI if dictionary translation is not finished
function self.protected_open(player, category, name, source)
  local player_table = global.players[player.index]
  if player_table.flags.allow_open_gui then
    if player_table.gui.info then
      if source then
        self.close(player, player_table.gui)
      else
        self.update_content(player, player_table, category, name)
        return
      end
    end
    self.open(player, category, name, source, player_table)
  else
    player.print{'fe-chat-message.translation-not-finished'}
    player_table.flags.tried_to_open_gui = true
  end
end

function self.close(player, gui_data)
  gui_data.info.common_elems.window.destroy()
  deregister_gui_handlers(player.index, 'common')
  gui_data.info = nil
end

function self.toggle(player, category, name, source)
  local gui_data = global.players[player.index].gui
  if gui_data.search then
    self.close(player, gui_data)
  else
    self.protected_open(player, category, name, source)
  end
end

-- updates the content in the body of the window, and the action buttons
function self.update_content(player, player_table, category, name, source, initial_content, nav_button)
  local gui_data = player_table.gui.info
  local common_elems = gui_data.common_elems
  local dictionary = player_table.dictionary
  --
  -- SEARCH HISTORY
  --
  if not nav_button then
    table_insert(player_table.history.overall, 1, {category=category, name=name})
  end
  local session_history = player_table.history.session
  if source then
    -- reset session history
    player_table.history.session = {position=1, [1]={category=category, name=name}, [2]={source=source}}
    session_history = player_table.history.session
  elseif not nav_button then
    -- modify session history
    if session_history.position > 1 then
      for i=1,session_history.position - 1 do
        table_remove(session_history, 1)
      end
      session_history.position = 1
    end
    table_insert(session_history, 1, {category=category, name=name})
  end
  -- set navigation button properties
  local forward_button = common_elems.forward_button
  if session_history.position > 1 then
    forward_button.enabled = true
    local forward_obj = session_history[session_history.position-1]
    forward_button.tooltip = {'fe-gui.forward-to', string_lower(dictionary[forward_obj.category].translations[forward_obj.name])}
  else
    forward_button.enabled = false
    forward_button.tooltip = ''
  end
  local back_button = common_elems.back_button
  local back_obj = session_history[session_history.position+1]
  if back_obj.source then
    back_button.tooltip = {'fe-gui.back-to', {'fe-remote-interface.history-source-name-'..back_obj.source}}
  else
    back_button.tooltip = {'fe-gui.back-to', string_lower(dictionary[back_obj.category].translations[back_obj.name])}
  end
  --
  -- INFO BAR
  --
  common_elems.info_sprite.sprite = category..'/'..name
  common_elems.info_name.caption = dictionary[category].translations[name]
  --
  -- MAIN CONTENT
  --
  -- DESTROY EXISTING CONTENT
  local content_scrollpane = common_elems.content_scrollpane
  if not initial_content then
    -- clear content and deregister handlers
    content_scrollpane.clear()
    deregister_gui_handlers(player.index, 'content')
  end
  -- BUILD NEW CONTENT
  -- for now, pages only support static handlers. dynamic ones may come later if they prove necessary.
  local content_elems, handler_registration_table = pages[category].create(player, player_table, content_scrollpane, name)
  gui_data.content_elems = content_elems
  handlers.content = pages[category].handlers
  register_gui_handlers(player.index, 'content', handler_registration_table)
  --
  -- UPDATE GLOBAL DATA
  --
  gui_data.category = category
  gui_data.name = name
end

-- -----------------------------------------------------------------------------

return self