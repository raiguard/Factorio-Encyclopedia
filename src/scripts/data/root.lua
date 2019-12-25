-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATA ROOT SCRIPTING
-- Entry point for the data structure

-- dependencies
local dictionary = require('lualib/dictionary')
local event = require('lualib/event')
local util = require('lualib/util')

-- library
local data = {}

-- build encyclopedia data in preparation for translation
dictionary.build_setup_function = function(serialise_localised_string)
  local __build = {}
  local function generic_setup(key)
    local iteration = {}
    local names = {}
    for name,prototype in pairs(game[key..'_prototypes']) do
      names[serialise_localised_string(prototype.localised_name)] = name
      table.insert(iteration, prototype.localised_name)
    end
    return {iteration=iteration, names=names}
  end
  __build.achievement = generic_setup('achievement')
  __build.entity = generic_setup('entity')
  __build.equipment = generic_setup('equipment')
  __build.fluid = generic_setup('fluid')
  __build.item = generic_setup('item')
  __build.recipe = generic_setup('recipe')
  __build.technology = generic_setup('technology')
  __build.tile = generic_setup('tile')
  return __build
end
-- translate encyclopedia data for the player
dictionary.player_setup_function = function(player, build_data)
  for category,t in pairs(build_data) do
    dictionary.build(player, category, t.names, t.iteration,
      function(e, name) -- translation function
        return string.lower(e.result), {name}
      end,
      function(e, name, cur_value) -- conflict function
        table.insert(cur_value, name)
        return cur_value
      end
    )
  end
end

function data.build_encyclopedia()
  
end

return data