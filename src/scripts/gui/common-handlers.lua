-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMMONLY USED GUI EVENT HANDLERS

local self = {}

function self.open_listbox_content(e)
  local _,_,category,object_name = e.element.get_item(e.element.selected_index):find('^%[img=(.*)/(.*)%].*$')
  script.raise_event(open_info_gui_event, {player_index=e.player_index, category=category, object_name=object_name})
end

return self