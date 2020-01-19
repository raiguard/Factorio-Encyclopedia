-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FACTORIO ENCYCLOPEDIA PROTOTYPES

data:extend{
  {
    type = 'custom-input',
    name = 'fe-search',
    key_sequence = 'CONTROL + E',
    order = 'a'
  },
  {
    type = 'custom-input',
    name = 'fe-nav-up',
    key_sequence = 'UP',
    order = 'ba'
  },
  {
    type = 'custom-input',
    name = 'fe-nav-down',
    key_sequence = 'DOWN',
    order = 'bb'
  },
  {
    type = 'custom-input',
    name = 'fe-nav-confirm',
    key_sequence = 'ENTER',
    order = 'bd'
  }
}

require('prototypes.sprite')
require('prototypes.style')

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