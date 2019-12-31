-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMMONLY USED GUI ELEMENTS OR SETS OF ELEMENTS

local self = {}

-- return the most commonly used GUI elements first, then a table of all of them

-- listbox with a label above it, contained in a vertical flow
function self.listbox_with_label(parent, name, frame_height, label_caption)
  local flow = parent.add{type='flow', name='fe_'..name..'_flow', direction='vertical'}
  local label = flow.add{type='label', name='fe_listbox_label', style='fe_listbox_label', caption=label_caption}
  local listbox_frame = flow.add{type='frame', name='fe_listbox_frame', style='fe_listbox_frame'}
  if frame_height then
    listbox_frame.style.height = frame_height
  end
  local listbox = listbox_frame.add{type='list-box', name='fe_'..name..'_listbox', style='fe_listbox'}
  return listbox, label, {flow=flow, label=label, listbox_frame=listbox_frame, listbox=listbox}
end

-- the standard "cell content" for info pages - contains a label and a lower flow
function self.standard_cell(parent, name, label_caption, flow_direction, flow_style)
  local cell_flow = parent.add{type='flow', name='fe_'..name..'_cell_flow', direction='vertical'}
  local label = cell_flow.add{type='label', name='fe_cell_title', style='caption_label', caption=label_caption}
  if not label_caption then label.visible = false end -- hide the label altogether if it doesn't have text
  local content_flow = cell_flow.add{type='flow', name='fe_cell_content_flow', direction=flow_direction or 'horizontal'}
  return content_flow, {cell_flow=cell_flow, content_flow=content_flow, label=label}
end

return self