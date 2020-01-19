-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SEARCH GUI

-- dependencies
local event = require('lualib.event')
local gui = require('lualib.gui')

-- locals
local string_match = string.match
local string_lower = string.lower
local table_sort = table.sort

-- objects
local self = {}

-- -----------------------------------------------------------------------------
-- GUI DATA

gui.add_handlers('search', {
  choose_elem_button = {
    on_elem_changed = function(e)
      game.print(serpent.block(e))
    end
  }
})

-- -----------------------------------------------------------------------------
-- OBJECT

function self.open(player, options, player_table)
  options = options or {}
  player_table = player_table or global.players[player.index]
  -- create GUI structure
  local gui_data = gui.create(player.gui.screen, 'search', player.index,
    {type='frame', style='fe_empty_frame', save_as='window', children={
      {type='tabbed-pane', style='fe_search_tabbed_pane', children={
        -- search tab
        {type='tab-and-content', tab={type='tab', style='fe_search_tab', caption={'gui.search'}}, content=
          {type='frame', style='window_content_frame_packed', direction='horizontal', children={
            {type='frame', style='fe_toolbar_left', direction='vertical', save_as='category_frame'},
            {type='flow', style='fe_search_flow', direction='vertical', children={
              {type='flow', style='fe_search_input_flow', direction='horizontal', children={
                {type='flow', style='fe_paddingless_flow', save_as='choose_elem_button_container', children={
                  {type='choose-elem-button', style='filter_slot_button', elem_type=options.default_category or 'item', handlers='choose_elem_button',
                    save_as=true}
                }},
                {type='textfield', style='fe_search_textfield', clear_and_focus_on_right_click=true, lose_focus_on_confirm=true, save_as='textfield'}
              }},
              {type='frame', style='fe_search_results_listbox_frame', children={
                {type='list-box', style='fe_listbox_for_keyboard_nav', save_as='results_listbox'}
              }}
            }}
          }}
        },
        -- history tab
        {type='tab-and-content', tab={type='tab', style='fe_search_tab', caption={'fe-gui.history'}}, content=
          {type='frame', style='window_content_frame_packed', direction='vertical', children={
            {type='frame', style='fe_toolbar_frame', direction='horizontal', children={
              {type='empty-widget', style={horizontally_stretchable=true}},
              {type='sprite-button', style='red_icon_button', sprite='utility/trash', mods={enabled=false}, save_as='history_delete_button'}
            }},
            {type='frame', style='fe_history_listbox_frame', children={
              {type='list-box', style='fe_listbox', save_as='history_listbox'}
            }}
          }}
        }
      }}
    }}
  )
  -- populate categories and set active category
  local category_frame = gui_data.category_frame
  for category,_ in pairs(global.encyclopedia) do
    category_frame.add{type='sprite-button', name=category..'_button', style='tool_button', sprite='fe_category_'..category,
      tooltip={'fe-gui.category-'..category..'-plural'}}
  end
  category_frame[(options.category or 'item')..'_button'].style = 'fe_tool_button_active'
  -- set textfield text
  local textfield = gui_data.textfield
  textfield.text = player_table.dictionary.other.translations.search..' '
    ..player_table.dictionary.category.translations[(options.category or 'item')..'-plural']..'...'
  -- center GUI
  gui_data.window.force_auto_center()
  -- add data to global table
  player_table.gui.search = gui_data
end

-- will prevent opening the GUI if dictionary translation is not finished
function self.protected_open(player, options)
  local player_table = global.players[player.index]
  if player_table.flags.allow_open_gui then
    self.open(player, options, player_table)
  else
    player.print{'fe-chat-message.translation-not-finished'}
    player_table.flags.tried_to_open_gui = true
  end
end

function self.close(player, gui_data)
  gui.destroy(player.gui.screen, 'search', player.index)
  gui_data.search = nil
end

function self.toggle(player, options)
  local gui_data = global.players[player.index].gui
  if gui_data.search then
    self.close(player, gui_data)
  else
    self.protected_open(player, options)
  end
end

return self