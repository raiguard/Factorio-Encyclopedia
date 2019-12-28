local function recursive_prototype_table(t, parent, subtable_count)
  subtable_count = subtable_count or 0
  local table = parent.add{type='table', name='fe_subtable_'..subtable_count, style='bordered_table', column_count=2}
  table.add{type='label', name='fe_prototype_table_header_label', style='caption_label', caption='key'}
  table.add{type='label', name='fe_prototype_table_header_value', style='caption_label', caption='value'}
  for k,v in pairs(t) do
    table.add{type='label', name='fe_prototype_table_label_'..k, caption=k}
    local value_type = type(v)
    if value_type == 'table' then
      subtable_count = subtable_count + 1
      recursive_prototype_table(v, table, subtable_count)
    elseif value_type == 'userdata' then
      table.add{type='label', name='fe_prototype_table_value_'..k, caption=serpent.line(v)}.style.horizontally_stretchable = true
    else
      table.add{type='label', name='fe_prototype_table_value_'..k, caption=v}.style.horizontally_stretchable = true
    end
  end
  return table
end

local self = {}

function self.create(player, parent, data)
  game.print('create prototype dialog!')
end

  -- -- HARDCODED PROTOTYPE INFO FOR NOW
  -- local content_pane = window.add{type='scroll-pane', name='fe_modal_content_pane', style='fe_prototype_data_scroll_pane'}
  -- content_pane.style.maximal_width = 800
  -- content_pane.style.maximal_height = 800
  -- local prototype = encyclopedia[name].prototype
  -- local initial_table = {}
  -- for n,_ in pairs(lua_object_members['LuaItemPrototype']) do
  --   local v = prototype[n]
  --   if v ~= nil then
  --     initial_table[n] = v
  --   end
  -- end
  -- recursive_prototype_table(initial_table, content_pane)
  -- -- END HARDCODED

  return self