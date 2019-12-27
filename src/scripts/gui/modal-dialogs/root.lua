-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MODAL DIALOG ROOT

-- dependencies
local event = require('lualib/event')
local mod_gui = require('mod-gui')

local lua_object_members = require('scripts/data/lua-object-members')

local modal_dialog = {}

-- -----------------------------------------------------------------------------
-- TITLEBAR EVENT HANDLERS

local function nav_backward_button_clicked(e)

end

local function nav_forward_button_clicked(e)

end

local function modal_dialog_closed(e)
  modal_dialog.destroy(global.players[e.player_index].gui, e.player_index)
end

local handlers = {
  nav_backward_button_clicked = nav_backward_button_clicked,
  nav_forward_button_clicked = nav_forward_button_clicked,
  modal_dialog_closed = modal_dialog_closed
}

event.on_load(function()
  event.load_conditional_handlers(handlers)
end)

-- -----------------------------------------------------------------------------
-- LIBRARY

local function recursive_prototype_table(t, parent, subtable_count)
  subtable_count = subtable_count or 0
  local table = parent.add{type='table', name='fe_subtable_'..subtable_count, style='bordered_table', column_count=2}
  table.add{type='label', name='fe_prototype_table_header_label', style='caption_label', caption='key'}
  table.add{type='label', name='fe_prototype_table_header_value', style='caption_label', caption='value'}
  for k,v in pairs(t) do
    table.add{type='label', name='fe_prototype_table_label_'..k, caption=k}
    local value_type = type(v)
    if value_type == 'table' then
      subtable_count = subtable_count + 1
      recursive_prototype_table(v, table, subtable_count)
    elseif value_type == 'userdata' then
      table.add{type='label', name='fe_prototype_table_value_'..k, caption=serpent.line(v)}.style.horizontally_stretchable = true
    else
      table.add{type='label', name='fe_prototype_table_value_'..k, caption=v}.style.horizontally_stretchable = true
    end
  end
  return table
end

function modal_dialog.create(player, parent, category, name, action_type)
  local window = parent.add{type='frame', name='fe_modal_window', style='dialog_frame', direction='vertical'}
  window.enabled = false
  local titlebar = window.add{type='flow', name='fe_modal_titlebar', style='fe_titlebar_flow', direction='horizontal'}
  titlebar.add{type='sprite-button', name='fe_modal_titlebar_button_nav_backward', style='close_button', sprite='fe_nav_backward',
               hovered_sprite='fe_nav_backward_dark', clicked_sprite='fe_nav_backward_dark'}
  titlebar.add{type='sprite-button', name='fe_modal_titlebar_button_nav_forward', style='close_button', sprite='fe_nav_forward',
               hovered_sprite='fe_nav_forward_dark', clicked_sprite='fe_nav_forward_dark'}
  titlebar.add{type='label', name='fe_modal_titlebar_label', style='frame_title',
               caption={'fe-gui-modal.titlebar-label-caption-'..action_type, global.encyclopedia.items[name].prototype.localised_name}}.style.left_padding = 7
  local pusher = titlebar.add{type='empty-widget', name='fe_modal_titlebar_pusher', style='draggable_space_header'}
  pusher.drag_target = window
  pusher.style.horizontally_stretchable = true
  pusher.style.natural_height = 24
  pusher.style.minimal_width = 24
  pusher.style.right_margin = 7
  local close_button = titlebar.add{type='sprite-button', name='fe_modal_titlebar_button_close', style='close_button', sprite='utility/close_white',
               hovered_sprite='utility/close_black', clicked_sprite='utility/close_black'}
  -- HARDCODED PROTOTYPE INFO FOR NOW
  local content_pane = window.add{type='scroll-pane', name='fe_modal_content_pane', style='fe_prototype_data_scroll_pane'}
  content_pane.style.maximal_width = 800
  content_pane.style.maximal_height = 800
  local prototype = global.encyclopedia.items[name].prototype
  local initial_table = {}
  for n,_ in pairs(lua_object_members['LuaItemPrototype']) do
    local v = prototype[n]
    if v ~= nil then
      initial_table[n] = v
    end
  end
  recursive_prototype_table(initial_table, content_pane)
  -- END HARDCODED

  -- screen
  if parent.name == 'screen' then
    window.force_auto_center()
    player.opened = window
  end
  -- register events
  event.register({defines.events.on_gui_click, defines.events.on_gui_closed}, modal_dialog_closed,
                 {name='modal_dialog_closed', player_index=player.index, gui_filters={window, close_button}})

  return {window=window, content_pane=content_pane}
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