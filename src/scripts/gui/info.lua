-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INFO GUI

-- dependencies
local event = require('lualib/event')

-- locals


-- objects
local self = {}
local handlers = {common={}}
local pages = {}
for _,category in ipairs(categories) do
  pages[category] = pcall(require,'scripts/gui/info-pages/'..category)
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

end

function handlers.common.forward_button_clicked(e)

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

function self.open(player, category, name, player_table)
  if not category or not name then error('Cannot open info GUI without info!') end
  player_table = player_table or global.players[player.index]
  local encyclopedia = global.encyclopedia[category]
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
                                        clicked_sprite='fe_search_dark', tooltip={'fe-gui.return-to-search'}}
    common.close_button = titlebar.add{type='sprite-button', name='fe_close_button', style='close_button', sprite='utility/close_white',
                                        hovered_sprite='utility/close_black', clicked_sprite='utility/close_black'}
    -- BACKGROUND PANE AND INFO BAR
    common.background_pane = common.window.add{type='frame', name='fe_background_pane', style='window_content_frame_packed', direction='vertical'}
    common.info_bar = common.background_pane.add{type='frame', name='fe_info_bar', style='fe_toolbar_frame', direciton='horizontal'}
    common.info_bar.add{type='sprite', name='fe_object_icon', style='fe_object_icon', sprite=category..'/'..name}
    common.info_bar.add{type='label', name='fe_object_name', style='subheader_caption_label', caption=encyclopedia[name].prototype.localised_name}
    -- CONTENT SCROLLPANE
    common.content_scrollpane = common.background_pane.add{type='scroll-pane', name='fe_content_scrollpane', style='scroll_pane_under_subheader'}
    -- dummy content
    local dummy = common.content_scrollpane.add{type='empty-widget', name='fe_dummy'}
    dummy.style.height = 400
    dummy.style.width = 500
    -- ACTION BAR
    common.action_bar = common.background_pane.add{type='frame', name='fe_action_bar', style='subfooter_frame', direction='horizontal'}
    common.action_bar.add{type='empty-widget', name='fe_pusher', style='fe_horizontal_pusher'}
    -- dummy content
    common.action_bar.add{type='sprite-button', name='fe_tool_button', style='tool_button'}
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
end

-- will prevent opening the GUI if dictionary translation is not finished
function self.protected_open(player, category, name)
  local player_table = global.players[player.index]
  if player_table.flags.allow_open_gui then
    self.open(player, category, name, player_table)
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

function self.toggle(player, options)
  local gui_data = global.players[player.index].gui
  if gui_data.search then
    self.close(player, gui_data)
  else
    self.protected_open(player, options)
  end
end

-- -----------------------------------------------------------------------------

return self