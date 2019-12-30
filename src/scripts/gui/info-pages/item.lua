-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ITEM INFO GUI

local self = {}
local handlers = {}

-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS

function handlers.iron_plate_button_clicked(e)
  script.raise_event(open_info_gui_event, {player_index=e.player_index, category='item', object_name='iron-plate'})
end

function handlers.copper_plate_button_clicked(e)
  script.raise_event(open_info_gui_event, {player_index=e.player_index, category='item', object_name='copper-plate'})
end

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(player, player_table, content_scrollpane, name)
  local elems = {}
  elems.iron_plate = content_scrollpane.add{type='button', name='fe_iron_plate_button', caption='Iron plate'}
  elems.copper_plate = content_scrollpane.add{type='button', name='fe_copper_plate_button', caption='Copper plate'}
  return elems, {
    {defines.events.on_gui_click, {name='iron_plate_button_clicked', gui_filters=elems.iron_plate}},
    {defines.events.on_gui_click, {name='copper_plate_button_clicked', gui_filters=elems.copper_plate}}
  }
end

self.handlers = handlers

return self