-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RECIPE INFO GUI

local common_elems = require('scripts.gui.common-elements')
local common_handlers = require('scripts.gui.common-handlers')

-- locals
local table_sort = table.sort

-- objects
local self = {}
local handlers = {}

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS

handlers.listbox_selection_changed = common_handlers.open_listbox_content

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(player, player_table, content_scrollpane, name)
  local elems = {}
  elems.listboxes = {}
  local encyclopedia = global.encyclopedia
  local recipe_data = encyclopedia.recipe[name]
  local dictionary = player_table.dictionary
  local table = content_scrollpane.add{type='table', name='fe_table', style='fe_content_table', column_count=1}
  for row,cell in pairs{items={'ingredients', 'products'}, machines_techs={'made_in', 'unlocked_by'}} do
    local content_flow = common_elems.standard_cell(table, row)
    content_flow.style.horizontal_spacing = 8
    for _,type in ipairs(cell) do
      local listbox, label = common_elems.listbox_with_label(content_flow, type)
      local add_item = listbox.add_item
      local objects
      if row == 'items' then
        objects = recipe_data.prototype[type]
      else
        objects = recipe_data[type]
      end
      if objects then
        for i=1,#objects do
          local object = objects[i]
          if type == 'made_in' then
            add_item('[img=entity/'..object..']  '..dictionary.entity.translations[object] or object)
          elseif type == 'unlocked_by' then
            add_item('[img=technology/'..object..']  '..dictionary.technology.translations[object] or object)
          else
            add_item('[img='..object.type..'/'..object.name..']  '..object.amount..'x '..dictionary[object.type].translations[object.name] or object.name)
          end
        end
      end
      label.caption = {'fe-gui.'..type:gsub('_', '-'), objects and #objects or 0}
      elems.listboxes[#elems.listboxes+1] = listbox
    end
  end
  return elems, {
    {defines.events.on_gui_selection_state_changed, {name='listbox_selection_changed', gui_filters=elems.listboxes}}
  }
end

self.handlers = handlers

return self