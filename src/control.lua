-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENCYCLOPEDIA CONTROL SCRIPTING

 -- debug adapter
pcall(require,'__debugadapter__/debugadapter.lua')

-- dependencies
local event = require('lualib/event')
local mod_gui = require('mod-gui')
local translation = require('lualib/translation')

-- globals
open_info_gui_event = event.generate_id('open_info_gui') -- used internally and for the remote interface
open_search_gui_event = event.generate_id('open_search_gui') -- used internally by the mod only
reopen_source_event = event.generate_id('reopen_source') -- used internally and for the remote interface
categories = {'entity', 'fluid', 'item', 'recipe', 'tile'}

-- modules
local info_gui = require('scripts/gui/info')
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
  },
  technology = {
    iteration = function(name, prototype, iteration_data, encyclopedia)
      for _,modifier in ipairs(prototype.effects) do
        if modifier.type == 'unlock-recipe' then
          local recipe = encyclopedia.recipe[modifier.recipe]
          if not recipe.unlocked_by then recipe.unlocked_by = {} end
          recipe.unlocked_by[#recipe.unlocked_by+1] = name
        end
      end
      return {prototype=prototype}
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
    local i = 0
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
      i = i + 1
      translation_data[i] = {localised=prototype.localised_name, internal=name}
    end
    return encyclopedia_data, translation_data
  end

  local translation_data = {category={}}
  for _,category in ipairs(categories) do
    -- prototypes
    encyclopedia[category], translation_data[category] = setup(category)
    -- category
    translation_data.category[#translation_data.category+1] = {localised={'fe-gui.category-'..category}, internal=category}
    translation_data.category[#translation_data.category+1] = {localised={'fe-gui.category-'..category..'-plural'}, internal=category..'-plural'}
  end
  -- other
  translation_data.other = {
    {localised={'gui.search'}, internal='search'}
  }
  global.__lualib.translation.translation_data = translation_data
end

local function translate_whole(player)
  for name,data in pairs(global.__lualib.translation.translation_data) do
    translation.start(player, name, data)
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
    dictionary = {},
    flags = {
      allow_open_gui = false
    },
    history = {
      overall = {},
      session = {}
    },
    gui = {}
  }
  local button = mod_gui.get_button_flow(player).add{type='sprite-button', name='enc_mod_gui_button', style=mod_gui.button_style, sprite='enc_logo',
                                                     tooltip={'fe-gui.encyclopedia'}}
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
  player_table.dictionary[e.dictionary_name] = {
    lookup = e.lookup,
    translations = e.translations,
    searchable = e.searchable
  }
  if table_size(player_table.dictionary) == #categories + 2 then
    player_table.flags.allow_open_gui = true
    if player_table.flags.tried_to_open_gui then
      player_table.flags.tried_to_open_gui = nil
      game.get_player(e.player_index).print{'fe-chat-message.translation-finished'}
    end
  end
end)

event.register('fe-search', function(e)
  search_gui.toggle(game.get_player(e.player_index))
end)

event.on_gui_click(function(e)
  search_gui.toggle(game.get_player(e.player_index))
end, {gui_filters='enc_mod_gui_button'})

event.register(open_search_gui_event, function(e)
  search_gui.protected_open(game.get_player(e.player_index), e.options)
end)

event.register(open_info_gui_event, function(e)
  info_gui.protected_open(game.get_player(e.player_index), e.category, e.object_name, e.source)
end)

event.register(reopen_source_event, function(e)
  if e.source == 'enc_search' then
    -- reopen search GUI
    search_gui.protected_open(game.get_player(e.player_index))
  elseif e.source == 'enc_history' then
    -- reopen history GUI
    search_gui.protected_open(game.get_player(e.player_index), {open_to_history=true})
  end
end)

-- DEBUGGING
if __DebugAdapter then
  event.register('DEBUG-INSPECT-GLOBAL', function(e)
    local breakpoint -- put breakpoint here to inspect global at any time
  end)
end