-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FACTORIO ENCYCLOPEDIA CONTROL SCRIPTING

 -- debug adapter
pcall(require,'__debugadapter__/debugadapter.lua')

-- dependencies
local event = require('lualib/event')
local mod_gui = require('mod-gui')
local util = require('lualib/util')

-- modules
local data = require('scripts/data/root')
local search_gui = require('scripts/gui/search')

-- INSPECT GLOBAL (DEBUG ADAPTER)
event.register('debug-inspect-global', function(e)
  local foo = 'bar' -- set a breakpoint here. inspect global by hitting Control + Shift + Enter!
end)

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

local function setup_player(player)
  global.players[player.index] = {
    gui = {}
  }
  local button = mod_gui.get_button_flow(player).add{type='button', name='fe_mod_gui_button', style=mod_gui.button_style,
                                                     caption={'gui-general.mod-gui-button-caption'}}
  global.players[player.index].gui.mod_gui = {top_button=button}
end

event.on_init(function()
  global.players = {}
  for _,player in pairs(game.players) do
    setup_player(player)
  end
  data.build_encyclopedia()
end)

event.on_configuration_changed(function()
  global.encyclopedia = nil
  data.build_encyclopedia()
end)

event.on_player_created(function(e)
  setup_player(game.get_player(e.player_index))
end)

event.register('fe-search', function(e)
  search_gui.toggle(game.get_player(e.player_index), true)
end)

event.on_gui_click(function(e)
  search_gui.toggle(game.get_player(e.player_index))
end, {gui_filters='fe_mod_gui_button'})