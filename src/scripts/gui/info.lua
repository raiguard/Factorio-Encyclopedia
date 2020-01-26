-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INFO GUI

-- dependencies
local event = require('lualib/event')
local gui = require('lualib/gui')

-- locals
local string_lower = string.lower
local table_insert = table.insert
local table_remove = table.remove

-- objects
local self = {}
local pages = {}
for _,category in ipairs(categories) do
  pages[category] = require('scripts/gui/info-pages/'..category)
end

-- -----------------------------------------------------------------------------
-- GUI DATA

-- declare this so members of the table can reference other members
local handlers = {}

-- actually populate the table
handlers = {
  close_button = {
    on_gui_click = function(e)
      self.close(game.get_player(e.player_index), global.players[e.player_index].gui)
    end
  },
  nav_backward_button = {
    on_gui_click = function(e)
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
  },
  nav_forward_button = {
    on_gui_click = function(e)
      local player_table = global.players[e.player_index]
      local session_history = player_table.history.session
      local forward_obj = session_history[session_history.position-1]
      session_history.position = session_history.position - 1
      -- update content
      self.update_content(game.get_player(e.player_index), player_table, forward_obj.category, forward_obj.name, nil, nil, true)
    end
  },
  pin_button = {
    on_gui_click = function(e)
      local player = game.get_player(e.player_index)
      local player_table = global.players[e.player_index]
      local gui_data = player_table.gui.info
      gui_data.pinned = not gui_data.pinned
      if gui_data.pinned then
        e.element.style = 'fe_close_button_active'
        player.opened = nil
      else
        e.element.style = 'close_button'
        player.opened = gui_data.base.window
      end
    end
  },
  search_button = {
    on_gui_click = function(e)
      event.raise(open_search_gui_event, {player_index=e.player_index})
    end
  },
  window = {
    on_gui_closed = function(e)
      local player_table = global.players[e.player_index]
      if not player_table.gui.info.pinned then
        self.close(game.get_player(e.player_index), player_table.gui)
      end
    end
  }
}

gui.add_handlers('info', handlers)

gui.add_templates{
  pushers = {
    horizontal = {type='empty-widget', style={horizontally_stretchable=true}},
    vertical = {type='empty-widget', style={vertically_stretchable=true}}
  }
}

-- -----------------------------------------------------------------------------
-- OBJECT

function self.open(player, category, name, source, player_table)
  player_table = player_table or global.players[player.index]
  local dictionary = player_table.dictionary
  local translations = dictionary[category].translations

  -- CREATE BASE GUI STRUCTURE
  local gui_data = gui.create(player.gui.screen, 'info', player.index,
    {type='frame', style='dialog_frame', direction='vertical', handlers='window', save_as=true, children={
      -- titlebar
      {type='flow', style='fe_titlebar_flow', children={
        {type='sprite-button', style='close_button', sprite='fe_nav_backward', hovered_sprite='fe_nav_backward_dark', clicked_sprite='fe_nav_backward_dark',
          handlers='nav_backward_button', save_as=true},
        {type='sprite-button', style='close_button', sprite='fe_nav_forward', hovered_sprite='fe_nav_forward_dark', clicked_sprite='fe_nav_forward_dark',
          handlers='nav_forward_button', save_as=true},
        {type='label', style={name='frame_title', left_padding=7}, caption='TEMP', save_as='window_title'},
        {type='empty-widget', style='fe_titlebar_draggable_space', save_as='titlebar_drag_handle'},
        {type='sprite-button', style='close_button', sprite='fe_pin', hovered_sprite='fe_pin_dark', clicked_sprite='fe_pin_dark', tooltip={'fe-gui.keep-open'},
          handlers='pin_button'},
        {type='sprite-button', style='close_button', sprite='fe_search', hovered_sprite='fe_search_dark', clicked_sprite='fe_search_dark',
          tooltip={'gui.search'}, handlers='search_button'},
        {type='sprite-button', style='close_button', sprite='utility/close_white', hovered_sprite='utility/close_black', clicked_sprite='utility/close_black',
          handlers='close_button'}
      }},
      {type='frame', style='window_content_frame_packed', direction='vertical', children={
        -- info bar
        {type='frame', style='fe_toolbar_frame', direction='horizontal', children={
          {type='sprite', style='fe_object_icon', sprite=category..'/'..name, save_as='info_sprite'},
          {type='label', style='subheader_caption_label', caption=translations[name], save_as='info_name'},
          {template='pushers.horizontal'}
        }},
        -- content scrollpane
        {type='scroll-pane', style={name='scroll_pane_under_subheader', width=478}, horizontal_scroll_policy='never', save_as='content_scrollpane'},
        -- action bar
        {type='frame', style='subfooter_frame', direction='horizontal', children={
          {template='pushers.horizontal'}
        }}
      }}
    }}
  )

  -- SET BASE STATE
  -- drag target
  gui_data.titlebar_drag_handle.drag_target = gui_data.window
  -- center window and set opened
  gui_data.window.force_auto_center()
  player.opened = gui_data.window
  -- export data
  gui_data.pinned = false
  player_table.gui.info = {base=gui_data}
  
  -- POPULATE CONTENT
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
  -- destroy content / deregister handlers
  pages[gui_data.info.category].destroy(player, gui_data.info.base.content_scrollpane)
  -- destroy base
  gui.destroy(gui_data.info.base.window, 'info', player.index)
  -- remove data from global
  gui_data.info = nil
end

function self.toggle(player, category, name, source)
  local gui_data = global.players[player.index].gui
  if gui_data.info then
    self.close(player, gui_data)
  else
    self.protected_open(player, category, name, source)
  end
end

-- updates the content of the window and navigation buttons. also manages the search history
function self.update_content(player, player_table, category, name, source, initial_content, nav_button)
  local gui_data = player_table.gui.info
  local base_elems = gui_data.base
  local dictionary = player_table.dictionary

  -- UPDATE SEARCH HISTORY
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

  -- UPDATE TITLEBAR
  local forward_button = base_elems.nav_forward_button
  if session_history.position > 1 then
    forward_button.enabled = true
    local forward_obj = session_history[session_history.position-1]
    forward_button.tooltip = {'fe-gui.forward-to', string_lower(dictionary[forward_obj.category].translations[forward_obj.name] or forward_obj.name)}
  else
    forward_button.enabled = false
    forward_button.tooltip = ''
  end
  local back_button = base_elems.nav_backward_button
  local back_obj = session_history[session_history.position+1]
  if back_obj.source then
    back_button.tooltip = {'fe-gui.back-to', {'fe-remote-interface.history-source-name-'..back_obj.source}}
  else
    back_button.tooltip = {'fe-gui.back-to', string_lower(dictionary[back_obj.category].translations[back_obj.name] or back_obj.name)}
  end
  base_elems.window_title.caption = {'fe-gui.category-'..category}

  -- UPDATE INFO BAR
  base_elems.info_sprite.sprite = category..'/'..name
  base_elems.info_name.caption = dictionary[category].translations[name]

  -- UPDATE MAIN CONTENT
  -- destroy previous content if it's there
  local content_scrollpane = base_elems.content_scrollpane
  if not initial_content then
    pages[gui_data.category].destroy(player, content_scrollpane)
  end
  -- build new content
  gui_data.page = pages[category].create(player, player_table, content_scrollpane, name)

  -- UPDATE GLOBAL DATA
  gui_data.category = category
  gui_data.name = name

end

-- -----------------------------------------------------------------------------

return self