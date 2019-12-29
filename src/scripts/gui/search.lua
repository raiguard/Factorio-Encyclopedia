-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SEARCH GUI SCRIPTING

-- dependencies
local event = require('lualib/event')

-- object
local self = {}

-- -----------------------------------------------------------------------------
-- UTILITIES



-- -----------------------------------------------------------------------------
-- GUI EVENT HANDLERS



-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(player, options)
  local window = player.gui.screen.add{type='frame', name='fe_search_window', style='fe_empty_frame'} -- needed for drag_target to work
  local tabbed_pane = window.add{type='tabbed-pane', name='fe_search_window', style='fe_search_tabbed_pane'}
  local gui_data = {}
  --
  -- SEARCH
  --
  do
    local elems = {}
    local search_pane = tabbed_pane.add{type='frame', name='fe_search_pane', style='window_content_frame_packed', direction='horizontal'}
    -- CATEGORIES
    elems.category_frame = search_pane.add{type='frame', name='fe_category_frame', style='fe_toolbar_left', direction='vertical'}
    for category,_ in pairs(global.encyclopedia) do
      elems.category_frame.add{type='sprite-button', name='fe_category_button_'..category, style='tool_button', sprite='fe_category_'..category,
                               tooltip={'fe-gui-search.category-button-caption-'..category}}
    end
    -- SEARCH
    local search_flow = search_pane.add{type='flow', name='fe_search_flow', direction='vertical'}
    search_flow.style.padding = 8
    search_flow.style.vertical_spacing = 8
    -- input
    local input_flow = search_flow.add{type='flow', name='fe_input_flow', style='fe_vertically_centered_flow', direction='horizontal'}
    input_flow.style.horizontal_spacing = 6
    elems.choose_elem_button = input_flow.add{type='choose-elem-button', name='fe_search_choose_elem_button', style='quick_bar_slot_button', elem_type='item'}
    elems.textfield = input_flow.add{type='textfield', name='fe_search_textfield', style='fe_search_textfield'}
    -- results
    local results_scrollpane = search_flow.add{type='frame', name='fe_results_frame', style='fe_mock_listbox_frame'}
    .add{type='scroll-pane', name='fe_results_scrollpane', style='fe_mock_listbox_scrollpane'}
    -- ADD TAB
    tabbed_pane.add_tab(
      tabbed_pane.add{type='tab', name='fe_search_tab', style='fe_search_tab', caption={'fe-gui-search.search-tab-caption'}},
      search_pane
    )
    gui_data.search = elems
  end
  --
  -- HISTORY
  --
  do
    local elems = {}
    local history_pane = tabbed_pane.add{type='frame', name='fe_history_pane', style='window_content_frame_packed', direction='vertical'}
    -- TOOLBAR
    elems.delete_button = history_pane.add{type='frame', name='fe_toolbar_frame', style='fe_toolbar_frame', direction='horizontal'}
    .add{type='empty-widget', name='fe_pusher', style='fe_horizontal_pusher'}
    .parent.add{type='sprite-button', name='fe_delete_button', style='red_icon_button', sprite='utility/trash'}
    -- HISTORY
    elems.history_listbox = history_pane.add{type='list-box', name='fe_history_listbox', style='list_box_under_subheader'}
    for i=1,8 do
      elems.history_listbox.add_item{i, 'Foo'}
    end
    tabbed_pane.add_tab(
      tabbed_pane.add{type='tab', name='fe_history_tab', style='fe_search_tab', caption={'fe-gui-search.history-tab-caption'}},
      history_pane
    )
  end
  --
  -- THE REST
  --
  window.force_auto_center()
end

function self.destroy(player)

end

function self.toggle(player, options)
  local gui_data = global.players[player.index].gui
  if gui_data.search then
    self.destroy(player)
  else
    self.create(player, options)
  end
end

-- -----------------------------------------------------------------------------

return self