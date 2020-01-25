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
    {type='frame', style='dialog_frame', direction='vertical', save_as='window', children={
      -- titlebar
      {type='flow', style='fe_titlebar_flow', children={
        {type='sprite-button', style='close_button', sprite='fe_nav_backward', hovered_sprite='fe_nav_backward_dark', clicked_sprite='fe_nav_backward_dark',
          save_as='nav_backward_button'},
        {type='sprite-button', style='close_button', sprite='fe_nav_forward', hovered_sprite='fe_nav_forward_dark', clicked_sprite='fe_nav_forward_dark',
          save_as='nav_forward_button'},
        {type='label', style={name='frame_title', left_padding=7}, caption='TEMP', save_as='window_title'},
        {type='empty-widget', style='fe_titlebar_draggable_space', save_as='titlebar_drag_handle'},
        {type='sprite-button', style='close_button', sprite='fe_search', hovered_sprite='fe_search_dark', clicked_sprite='fe_search_dark',
          tooltip={'gui.search'}},
        {type='sprite-button', style='close_button', sprite='utility/close_white', hovered_sprite='utility/close_black', clicked_sprite='utility/close_black'}
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
  player_table.gui.info = {common=gui_data}
  
  -- POPULATE CONTENT
  self.update_content(player, player_table, category, name, source, true)
end

-- will prevent opening the GUI if dictionary translation is not finished
function self.protected_open(player, category, name, source)
  local player_table = global.players[player.index]
  if player_table.flags.allow_open_gui then
    self.open(player, category, name, source, player_table)
  else
    player.print{'fe-chat-message.translation-not-finished'}
    player_table.flags.tried_to_open_gui = true
  end
end

function self.close(player, gui_data)
  gui.destroy(gui_data.search.window, 'info', player.index)
  gui_data.search = nil
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
  local common_elems = gui_data.common
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
  local forward_button = common_elems.nav_forward_button
  if session_history.position > 1 then
    forward_button.enabled = true
    local forward_obj = session_history[session_history.position-1]
    forward_button.tooltip = {'fe-gui.forward-to', string_lower(dictionary[forward_obj.category].translations[forward_obj.name] or forward_obj.name)}
  else
    forward_button.enabled = false
    forward_button.tooltip = ''
  end
  local back_button = common_elems.nav_backward_button
  local back_obj = session_history[session_history.position+1]
  if back_obj.source then
    back_button.tooltip = {'fe-gui.back-to', {'fe-remote-interface.history-source-name-'..back_obj.source}}
  else
    back_button.tooltip = {'fe-gui.back-to', string_lower(dictionary[back_obj.category].translations[back_obj.name] or back_obj.name)}
  end
  common_elems.window_title.caption = {'fe-gui.category-'..category}

  -- UPDATE INFO BAR
  common_elems.info_sprite.sprite = category..'/'..name
  common_elems.info_name.caption = dictionary[category].translations[name]

  -- UPDATE MAIN CONTENT
  -- destroy previous content if it's there
  local content_scrollpane = common_elems.content_scrollpane
  if not initial_content then
    -- clear content and deregister handlers
    game.print('CLEAR CONTENT')
  end
  -- build new content
  

end

-- -----------------------------------------------------------------------------

return self