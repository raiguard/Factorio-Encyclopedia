-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FACTORIO ENCYCLOPEDIA PROTOTYPES

data:extend{
  {
    type = 'custom-input',
    name = 'fe-search',
    key_sequence = 'CONTROL + E'
  }
}

require('prototypes/sprite')
require('prototypes/style')

-- DEBUGGING TOOL
if mods['debugadapter'] then
  data:extend{
    {
      type = 'custom-input',
      name = 'DEBUG-INSPECT-GLOBAL',
      key_sequence = 'CONTROL + SHIFT + ENTER'
    }
  }
end