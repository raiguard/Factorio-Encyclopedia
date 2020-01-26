-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMMONLY USED GUI ELEMENTS OR SETS OF ELEMENTS

local self = {}

-- return the most commonly used GUI elements first, then a table of all of them

-- listbox with a label above it, contained in a vertical flow
function self.listbox_with_label(parent, frame_height, label_caption)
  local flow = parent.add{type='flow', direction='vertical'}
  local label = flow.add{type='label', style='enc_listbox_label', caption=label_caption}
  local listbox_frame = flow.add{type='frame', style='enc_listbox_frame'}
  if frame_height then
    listbox_frame.style.height = frame_height
  end
  local listbox = listbox_frame.add{type='list-box', style='enc_listbox'}
  return listbox, label, {flow=flow, label=label, listbox_frame=listbox_frame, listbox=listbox}
end

-- the standard "cell content" for info pages - contains a label and a lower flow
function self.standard_cell(parent, label_caption, flow_direction, flow_style)
  local cell_flow = parent.add{type='flow', direction='vertical'}
  local label = cell_flow.add{type='label', style='caption_label', caption=label_caption}
  if not label_caption then label.visible = false end -- hide the label altogether if it doesn't have text
  local content_flow = cell_flow.add{type='flow', direction=flow_direction or 'horizontal'}
  return content_flow, {cell_flow=cell_flow, content_flow=content_flow, label=label}
end

-- standard object info table entry
function self.info_table_entry(parent, name, value)
  include_pusher = include_pusher or true
  local flow = parent.add{type='flow', style='enc_vertically_centered_flow', direction='horizontal'}
  local label = flow.add{type='label', style='enc_table_label', caption={'fe-gui.'..name:gsub('_', '-')}}
  flow.add{type='empty-widget', style='enc_horizontal_pusher'}
  local value_label
  if value then
     value_label = flow.add{type='label', style='enc_table_value', caption=value}
  end
  return flow, {flow=flow, label=label, value_label=value_label}
end

return self