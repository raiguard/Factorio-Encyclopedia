-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RECIPE BOOK CONTROL SCRIPTING

 -- debug adapter
pcall(require,'__debugadapter__/debugadapter.lua')

-- dependencies
local event = require('lualib/event')
local mod_gui = require('mod-gui')
local util = require('lualib/util')

-- INSPECT GLOBAL (DEBUG ADAPTER)
event.register('debug-inspect-global', function(e)
  local foo = 'bar' -- set a breakpoint here. inspect global by hitting Control + Shift + Enter!
end)

-- -----------------------------------------------------------------------------
-- PROTOTYPING

local handlers = {
  search_textfield_text_changed = search_textfield_text_changed
}

event.on_load(function()
  event.load_conditional_handlers(handlers)
end)

local function setup_player(player)
  global.players[player.index] = {}
  mod_gui.get_button_flow(player).add{type='button', name='rb_search_button', style=mod_gui.button_style, caption='Recipe Book'}
end

event.on_init(function()
  global.players = {}
  for _,player in pairs(game.players) do
    setup_player(player)
  end
  global.prototype_dictionaries = {}
end)

event.on_player_created(function(e)
  setup_player(game.get_player(e.player_index))
end)

event.on_gui_click(function(e)
  local player = game.get_player(e.player_index)
  local frame_flow = mod_gui.get_frame_flow(player)
  if not frame_flow.rb_window then -- create the window
    local window = frame_flow.add{type='frame', name='rb_window', style='dialog_frame', direction='vertical'}
    
  else -- destroy the window
    for name, handler in pairs(handlers) do
      event.deregister_conditional(handler, {name=name, player_index=player.index})
    end
    frame_flow.rb_window.destroy()
  end
end, {gui_filters='rb_search_button'})