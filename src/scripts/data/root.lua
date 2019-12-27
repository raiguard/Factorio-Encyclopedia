-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATA ROOT SCRIPTING
-- Entry point for the data structure

-- dependencies
local dictionary = require('lualib/dictionary')
local event = require('lualib/event')

-- library
local data = {}

-- build encyclopedia data in preparation for translation
local function build_translation_data(serialise_localised_string)
  local build = {}
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
  build.achievement = generic_setup('achievement')
  build.entity = generic_setup('entity')
  build.equipment = generic_setup('equipment')
  build.fluid = generic_setup('fluid')
  build.item = generic_setup('item')
  build.recipe = generic_setup('recipe')
  build.technology = generic_setup('technology')
  build.tile = generic_setup('tile')
  global.__build = build
end

return data