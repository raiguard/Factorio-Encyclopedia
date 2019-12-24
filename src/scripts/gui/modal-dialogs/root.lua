-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MODAL DIALOG ROOT

-- dependencies
local event = require('lualib/event')
local mod_gui = require('mod-gui')
local util = require('lualib/util')

local lua_object_members = require('scripts/data/lua-object-members')

local modal_dialog = {}

-- -----------------------------------------------------------------------------
-- LIBRARY

function modal_dialog.create(parent, category, name, action_type)
  local window = parent.add{type='frame', name='fe_modal_window', style='dialog_frame', direction='vertical'}
  local titlebar = window.add{type='flow', name='fe_modal_titlebar', style='fe_titlebar_flow', direction='horizontal'}
  titlebar.add{type='sprite-button', name='fe_modal_titlebar_button_nav_backward', style='close_button', sprite='fe_nav_backward',
               hovered_sprite='fe_nav_backward_dark', clicked_sprite='fe_nav_backward_dark'}
  titlebar.add{type='sprite-button', name='fe_modal_titlebar_button_nav_forward', style='close_button', sprite='fe_nav_forward',
               hovered_sprite='fe_nav_forward_dark', clicked_sprite='fe_nav_forward_dark'}
  titlebar.add{type='label', name='fe_modal_titlebar_label', style='frame_title',
               caption={'gui-modal.titlebar-label-caption-'..action_type, global.encyclopedia.entities[name].prototype.localised_name}}.style.left_padding = 7
  local pusher = titlebar.add{type='empty-widget', name='fe_modal_titlebar_pusher', style='draggable_space_header'}
  pusher.drag_target = window
  pusher.style.horizontally_stretchable = true
  pusher.style.natural_height = 24
  pusher.style.minimal_width = 24
  pusher.style.right_margin = 7
  titlebar.add{type='sprite-button', name='fe_modal_titlebar_button_close', style='close_button', sprite='utility/close_white',
               hovered_sprite='utility/close_black', clicked_sprite='utility/close_black'}
  local content_pane = window.add{type='frame', name='fe_modal_content_pane', style='window_content_frame'}
  content_pane.style.horizontally_stretchable = true
  -- HARDCODED PROTOTYPE INFO FOR NOW
  local table = content_pane.add{type='table', name='fe_modal_content_prototype_table', style='bordered_table', column_count=2}
  local prototype = global.encyclopedia.entities[name].prototype
  for n,_ in pairs(lua_object_members['LuaEntityPrototype']) do
    local v = prototype[n]
    if type(v) == 'table' then
      v = serpent.line(v)
    end
    local curtype = type(v)
    if type(v) ~= 'userdata' and v ~= nil then
      table.add{type='label', name='fe_modal_content_prototype_table_label_'..n, caption=n}
      table.add{type='label', name='fe_modal_content_prototype_table_value_'..n, caption=v}
    end
  end
  -- END HARDCODED

  -- force auto center
  if parent.name == 'screen' then
    window.force_auto_center()
  end

  return {window=window}
end

function modal_dialog.destroy(gui_data, player_index)
  
end

return modal_dialog