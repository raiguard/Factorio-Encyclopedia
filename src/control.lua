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
local search_gui = require('scripts/gui/search')

-- -----------------------------------------------------------------------------
-- ENCYCLOPEDIA DATA

local build_functions = {
  recipe = {
    setup = function()
      local crafting_machines = game.get_filtered_entity_prototypes{
        {filter='type', type='assembling-machine'},
        {filter='type', type='furnace'}
      }
      local output = {}
      for name,prototype in pairs(crafting_machines) do
        output[name] = prototype.crafting_categories
      end
      return {crafting_machines=output}
    end,
    iteration = function(name, prototype, iteration_data, encyclopedia)
      -- made in
      local category = prototype.category
      local made_in = {}
      for name,categories in pairs(iteration_data.crafting_machines) do
        if categories[category] then
          made_in[#made_in+1] = name
        end
      end
      -- ingredients
      local ingredients = prototype.ingredients
      for i=1,#ingredients do
        local ingredient = ingredients[i]
        local entry = encyclopedia[ingredient.type][ingredient.name]
        if entry then
          if not entry.as_ingredient then entry.as_ingredient = {} end
          entry.as_ingredient[#entry.as_ingredient+1] = name
        end
      end
      -- products
      local products = prototype.products
      for i=1,#products do
        local product = products[i]
        local entry = encyclopedia[product.type][product.name]
        if entry then
          if not entry.as_product then entry.as_product = {} end
          entry.as_product[#entry.as_product+1] = name
        end
      end
      return {made_in=made_in, prototype=prototype}
    end
  }
}

-- builds encyclopedia data
local function build_encyclopedia()
  global.encyclopedia = {}
  local encyclopedia = global.encyclopedia
  local function setup(key)
    local encyclopedia_data = {}
    local translation_data = {}
    local translation_strings = {}
    local translation_strings_len = 0
    local iteration_data
    if build_functions[key] and build_functions[key].setup then
      iteration_data = build_functions[key].setup()
    end
    local iteration_function
    if build_functions[key] and build_functions[key].iteration then
      iteration_function = build_functions[key].iteration
    else
      iteration_function = function(name, prototype, iteration_data, encyclopedia) return {prototype=prototype} end
    end
    for name,prototype in pairs(game[key..'_prototypes']) do
      -- encyclopedia data
      encyclopedia_data[name] = iteration_function(name, prototype, iteration_data, encyclopedia)
      -- translation data
      translation_data[serialise_localised_string(prototype.localised_name)] = name
      translation_strings_len = translation_strings_len + 1
      translation_strings[translation_strings_len] = prototype.localised_name
    end
    return encyclopedia_data, {data=translation_data, strings=translation_strings}
  end
  local translation_data = {}
  for _,type in ipairs{'achievement', 'entity', 'equipment', 'fluid', 'item', 'recipe', 'technology', 'tile'} do
    encyclopedia[type], translation_data[type] = setup(type)
  end
  global.__translation.translation_data = translation_data
end

local function translate_whole(player, ignore_error)
  for name,t in pairs(global.__translation.translation_data) do
    translation.start(player, name, t.data, t.strings, {convert_to_lowercase=true, ignore_error=ignore_error})
  end
end

local function translate_for_all_players(ignore_error)
  for _,player in ipairs(game.connected_players) do
    translate_whole(player, ignore_error)
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
  local button = mod_gui.get_button_flow(player).add{type='sprite-button', name='fe_mod_gui_button', style=mod_gui.button_style, sprite='fe_logo',
                                                     tooltip={'fe-gui-general.mod-gui-button-tooltip'}}
  global.players[player.index].gui.mod_gui = {top_button=button}
end

event.on_init(function()
  global.players = {}
  for _,player in pairs(game.players) do
    setup_player(player)
  end
  build_encyclopedia()
  translate_for_all_players()
  event.register(translation.retranslate_all_event, translate_for_all_players)
end)

event.on_load(function()
  event.register(translation.retranslate_all_event, translate_for_all_players)
end)

event.on_configuration_changed(function()
  global.encyclopedia = nil
  build_encyclopedia()
  translate_for_all_players(true)
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
  if player_table.gui.search then
    search_gui.toggle(game.get_player(e.player_index))
  end
end)

event.register(translation.finish_event, function(e)
  local player_table = global.players[e.player_index]
  player_table.search[e.dictionary_name] = e.dictionary
  local encyclopedia = global.encyclopedia[e.dictionary_name]
  for localised,internal in pairs(e.dictionary) do
    for i=1,#internal do
      encyclopedia[internal[i]].translated_name = localised
    end
  end
  if table_size(player_table.search) == 8 then
    player_table.flags.allow_open_gui = true
    if player_table.flags.tried_to_open_gui then
      player_table.flags.tried_to_open_gui = nil
      game.get_player(e.player_index).print{'fe-chat-message.translation-finished'}
    end
  end
end)

event.register('fe-search', function(e)
  search_gui.toggle(game.get_player(e.player_index), true)
end)

event.on_gui_click(function(e)
  search_gui.toggle(game.get_player(e.player_index))
end, {gui_filters='fe_mod_gui_button'})

-- DEBUGGING
if __DebugAdapter then
  event.register('DEBUG-INSPECT-GLOBAL', function(e)
    local breakpoint -- put breakpoint here to inspect global at any time
  end)
end