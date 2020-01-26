-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RECIPE INFO GUI

-- dependencies
local event = require('lualib/event')
local gui = require('lualib/gui')

local common_elems = require('scripts/gui/common-elements')
local common_handlers = require('scripts/gui/common-handlers')

-- locals
local table_sort = table.sort

local general_data = {
  
}

-- objects
local self = {}

-- -----------------------------------------------------------------------------
-- GUI DATA

gui.add_handlers('item', {
  generic_buttons = {
    on_gui_click = common_handlers.open_button_content
  },
  generic_listboxes = {
    on_gui_selection_state_changed = common_handlers.open_listbox_content
  }
})

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(player, player_table, content_scrollpane, name)
  local encyclopedia = global.encyclopedia
  local recipe_data = encyclopedia.recipe[name]
  local dictionary = player_table.dictionary

  local generic_buttons = {}
  local generic_listboxes = {}

  local gui_data = gui.create(content_scrollpane, 'recipe', player.index,
    {type='button', caption='demo button, please ignore'}
  )

  -- SET UP GENERIC HANDLERS
  gui.register_handlers('item', 'generic_buttons', {name='generic_buttons', player_index=player.index, gui_filters=generic_buttons})
  gui.register_handlers('item', 'generic_listboxes', {name='generic_listboxes', player_index=player.index, gui_filters=generic_listboxes})

  return gui_data
end

function self.destroy(player, content_scrollpane)
  gui.destroy(content_scrollpane.children[1], 'item', player.index)
end

return self

-- for row,cell in pairs{items={'ingredients', 'products'}, machines_techs={'made_in', 'unlocked_by'}} do
--   local content_flow = common_elems.standard_cell(table, row)
--   content_flow.style.horizontal_spacing = 8
--   for _,type in ipairs(cell) do
--     local listbox, label = common_elems.listbox_with_label(content_flow, type)
--     local add_item = listbox.add_item
--     local objects
--     if row == 'items' then
--       objects = recipe_data.prototype[type]
--     else
--       objects = recipe_data[type]
--     end
--     if objects then
--       for i=1,#objects do
--         local object = objects[i]
--         if type == 'made_in' then
--           add_item('[img=entity/'..object..']  '..dictionary.entity.translations[object] or object)
--         elseif type == 'unlocked_by' then
--           add_item('[img=technology/'..object..']  '..dictionary.technology.translations[object] or object)
--         else
--           add_item('[img='..object.type..'/'..object.name..']  '..object.amount..'x '..dictionary[object.type].translations[object.name] or object.name)
--         end
--       end
--     end
--     label.caption = {'fe-gui.'..type:gsub('_', '-'), objects and #objects or 0}
--     elems.listboxes[#elems.listboxes+1] = listbox
--   end
-- end