-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FACTORIO ENCYCLOPEDIA CONTROL SCRIPTING

 -- debug adapter
pcall(require,'__debugadapter__/debugadapter.lua')

-- dependencies
local event = require('lualib/event')
local mod_gui = require('mod-gui')
local translation = require('lualib/translation')

local serialise_localised_string = translation.serialise_localised_string

-- modules
-- local data = require('scripts/data/root')
local search_gui = require('scripts/gui/search')

-- INSPECT GLOBAL (DEBUG ADAPTER)
event.register('debug-inspect-global', function(e)
  local breakpoint -- set a breakpoint here. inspect global by hitting Control + Shift + Enter!
end)

-- -----------------------------------------------------------------------------
-- ENCYCLOPEDIA DATA

-- builds translation data
local function build_translation_data()
  local translation_data = {}
  local function generic_setup(key)
    local data = {}
    local strings = {}
    local strings_len = 0
    for name,prototype in pairs(game[key..'_prototypes']) do
      data[serialise_localised_string(prototype.localised_name)] = name
      strings_len = strings_len + 1
      strings[strings_len] = prototype.localised_name
    end
    return {data=data, strings=strings}
  end
  translation_data.achievement = generic_setup('achievement')
  translation_data.entity = generic_setup('entity')
  translation_data.equipment = generic_setup('equipment')
  translation_data.fluid = generic_setup('fluid')
  translation_data.item = generic_setup('item')
  translation_data.recipe = generic_setup('recipe')
  translation_data.technology = generic_setup('technology')
  translation_data.tile = generic_setup('tile')
  global.__translation.translation_data = translation_data
end

local function translate_whole(player)
  -- global.players[player.index].search = nil -- remove table to prevent opening the GUI while translating
  for name,t in pairs(global.__translation.translation_data) do
    translation.start(player, name, t.data, t.strings)
  end
end

local function translate_for_all_players()
  for _,player in ipairs(game.connected_players) do
    translate_whole(player)
  end
end

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

local function setup_player(player)
  global.players[player.index] = {
    flags = {
      allow_open_gui = false
    },
    gui = {},
    search = {}
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
  build_translation_data()
  translate_for_all_players()
  event.register(translation.retranslate_all_event, translate_for_all_players)
end)

event.on_load(function()
  event.register(translation.retranslate_all_event, translate_for_all_players)
end)

event.on_configuration_changed(function()
  global.encyclopedia = nil
  build_translation_data()
  translate_for_all_players()
end)

event.on_player_created(function(e)
  setup_player(game.get_player(e.player_index))
end)

event.on_player_joined_game(function(e)
  -- TODO: close open GUIs
  translate_whole(game.get_player(e.player_index))
end)

event.register(translation.start_event, function(e)
  local player_table = global.players[e.player_index]
  player_table.flags.allow_open_gui = false
  if player_table.gui.search or player_table.gui.modal then
    -- TODO: close GUI
  end
end)

event.register(translation.finish_event, function(e)
  local player_table = global.players[e.player_index]
  player_table.search[e.dictionary_name] = e.dictionary
  if table_size(player_table.search) == 8 then
    player_table.flags.allow_open_gui = true
  end
end)

event.register('fe-search', function(e)
  search_gui.toggle(game.get_player(e.player_index))
end)

event.on_gui_click(function(e)
  search_gui.toggle(game.get_player(e.player_index))
end, {gui_filters='fe_mod_gui_button'})