-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SEARCH GUI

-- dependencies
local event = require('lualib/event')
local gui = require('lualib/gui')

-- locals
local string_match = string.match
local string_lower = string.lower
local table_sort = table.sort

-- objects
local self = {}

-- -----------------------------------------------------------------------------
-- GUI DATA

-- declare this here so the below function can access it
local handlers = {}

local function nav_up_down(e)
  local gui_data = global.players[e.player_index].gui.search
  -- set delta
  local delta
  if e.input_name:find('up') then delta = -1
  else delta = 1
  end
  -- apply delta
  if gui_data.state == 'select_category' then
    local children = gui_data.category_frame.children
    children[gui_data.selected_category].style = 'tool_button'
    gui_data.selected_category = util.clamp(gui_data.selected_category + delta, 1, #children)
    children[gui_data.selected_category].style = 'fe_tool_button_selected'
    e.element = children[gui_data.selected_category]
    e.used_keyboard_nav = true
    handlers.category_buttons.on_gui_click(e)
  elseif gui_data.state == 'select_result' then
    local listbox = gui_data.results_listbox
    listbox.selected_index = util.clamp(listbox.selected_index+delta, 1, #listbox.items)
    listbox.scroll_to_item(listbox.selected_index)
  end
end

-- actually populate the table
handlers = {
  choose_elem_button = {
    on_gui_elem_changed = function(e)
      local category = e.element.elem_type
      local object_name = e.element.elem_value
      self.close(game.get_player(e.player_index), global.players[e.player_index].gui)
      event.raise(open_info_gui_event, {player_index=e.player_index, category=category, object_name=object_name, source='fe_search'})
    end
  },
  category_buttons = {
    on_gui_click = function(e)
      if e.used_keyboard_nav == nil then e.used_keyboard_nav = false end
      local player_table = global.players[e.player_index]
      local gui_data = player_table.gui.search
      if not e.used_keyboard_nav then
        e.element.style = 'fe_tool_button_active'
        if not e.used_keyboard_confirm then
          gui_data.category_frame[gui_data.category..'_button'].style = 'tool_button'
        end
      end
      _,_,gui_data.category = e.element.name:find('(.*)_button')
      self.reset_search_pane(e.player_index, player_table, not e.used_keyboard_nav)
    end
  },
  history_listbox = {
    on_gui_selection_state_changed = function(e)
      local _,_,category,object_name = e.element.get_item(e.element.selected_index):find('^%[.*%].*%[img=(.*)/(.*)%].*$')
      self.close(game.get_player(e.player_index), global.players[e.player_index].gui)
      event.raise(open_info_gui_event, {player_index=e.player_index, category=category, object_name=object_name, source='fe_history'})
    end
  },
  navigation_shortcuts = {
    ['fe-nav-up'] = nav_up_down,
    ['fe-nav-down'] = nav_up_down,
    ['fe-nav-confirm'] = function(e)
      local gui_data = global.players[e.player_index].gui.search
      if gui_data.state == 'select_category' then
        e.element = gui_data.category_frame.children[gui_data.selected_category]
        e.used_keyboard_nav = false
        e.used_keyboard_confirm = true
        handlers.category_buttons.on_gui_click(e)
      elseif gui_data.state == 'select_result' then
        e.element = gui_data.results_listbox
        handlers.results_listbox.on_gui_selection_state_changed(e)
      end
    end
  },
  results_listbox = {
    on_gui_closed = function(e)
      e.closed_from_nav = true
      handlers.textfield.on_gui_click(e)
    end,
    on_gui_selection_state_changed = function(e)
      local gui_data = global.players[e.player_index].gui
      local _,_,category,object_name = e.element.get_item(e.element.selected_index):find('^%[img=(.*)/(.*)%].*$')
      self.close(game.get_player(e.player_index), gui_data)
      event.raise(open_info_gui_event, {player_index=e.player_index, category=category, object_name=object_name, source='fe_search'})
    end
  },
  tabbed_pane = {
    on_gui_selected_tab_changed = function(e)
      local gui_data = global.players[e.player_index].gui.search
      local state = gui_data.state
      local index = e.element.selected_tab_index
      if index == 1 then -- search
        if state == 'search' then -- refocus textfield
          gui_data.textfield.select_all()
          gui_data.textfield.focus()
        end
      else

      end
    end
  },
  textfield = {
    on_gui_click = function(e)
      local gui_data = global.players[e.player_index].gui.search
      if gui_data.state == 'select_result' or gui_data.state == 'select_category' then
        -- deregister navigation handlers
        gui.deregister_handlers('search', 'navigation_shortcuts', e.player_index)
        -- unset selected index
        gui_data.results_listbox.selected_index = 0
        if gui_data.selected_category then
          gui_data.category_frame.children[gui_data.selected_category].style = 'fe_tool_button_active'
          gui_data.selected_category = nil
        end
        -- set GUI state
        gui_data.state = 'search'
        game.get_player(e.player_index).opened = gui_data.textfield
        -- focus textfield if needed
        if e.closed_from_nav then
          gui_data.textfield.focus()
        end
      end
    end,
    on_gui_closed = function(e)
      local gui_data = global.players[e.player_index].gui.search
      if gui_data.state == 'search' then
        -- defocus textfield
        gui_data.category_frame.focus()
        -- set initial selected index
        for i,elem in ipairs(gui_data.category_frame.children) do
          if elem.style.name:find('active') then
            gui_data.selected_category = i
            elem.style = 'fe_tool_button_selected'
            break
          end
        end
        -- keyboard navigation
        gui.register_handlers('search', 'navigation_shortcuts', {name='nav_shortcuts', player_index=e.player_index})
        -- set GUI state
        gui_data.state = 'select_category'
        game.get_player(e.player_index).opened = gui_data.window
      end
    end,
    on_gui_confirmed = function(e)
      local gui_data = global.players[e.player_index].gui.search
      -- keyboard navigation
      gui.register_handlers('search', 'navigation_shortcuts', {name='nav_shortcuts', player_index=e.player_index})
      -- set initial selected index
      gui_data.results_listbox.selected_index = 1
      -- set GUI state
      gui_data.state = 'select_result'
      -- set open GUI
      game.get_player(e.player_index).opened = gui_data.results_listbox
    end,
    on_gui_text_changed = function(e)
      local player_table = global.players[e.player_index]
      local gui_data = player_table.gui.search
      local query = string_lower(e.text)
      local category = gui_data.category
      local search_table = player_table.dictionary[category].searchable
      local results_listbox = gui_data.results_listbox
      local add_item = results_listbox.add_item
      local set_item = results_listbox.set_item
      local remove_item = results_listbox.remove_item
      local items_length = #results_listbox.items
      local i = 0
      for i1=1,#search_table do
        local t = search_table[i1]
        local translated = t.translated
        if string_match(string_lower(translated), query) then
          local caption = '[img='..category..'/'..t.internal..']  '..translated
          i = i + 1
          if i <= items_length then
            set_item(i, caption)
          else
            add_item(caption)
          end
        end
      end
      for i=#results_listbox.items,i+1,-1 do
        remove_item(i)
      end
    end
  },
  window = {
    on_gui_closed = function(e)
      local gui_data = global.players[e.player_index].gui
      local search_data = gui_data.search
      if search_data.state == 'select_category' then
        self.close(game.get_player(e.player_index), gui_data)
      end
    end
  }
}

gui.add_handlers('search', handlers)

-- -----------------------------------------------------------------------------
-- OBJECT

function self.open(player, options, player_table)
  options = options or {}
  player_table = player_table or global.players[player.index]

  -- CREATE GUI STRUCTURE
  local gui_data = gui.create(player.gui.screen, 'search', player.index,
    {type='frame', style='fe_empty_frame', handlers='window', save_as=true, children={
      {type='tabbed-pane', style='fe_search_tabbed_pane', save_as='tabbed_pane', children={
        -- search tab
        {type='tab-and-content', tab={type='tab', style='fe_search_tab', caption={'gui.search'}}, content=
          {type='frame', style='window_content_frame_packed', direction='horizontal', children={
            {type='frame', style='fe_toolbar_left', direction='vertical', save_as='category_frame'},
            {type='flow', style='fe_search_flow', direction='vertical', children={
              {type='flow', style='fe_search_input_flow', direction='horizontal', children={
                {type='flow', style='fe_paddingless_flow', save_as='choose_elem_button_container', children={
                  {type='choose-elem-button', style='quick_bar_slot_button', elem_type=options.default_category or 'item', handlers='choose_elem_button',
                    save_as=true}
                }},
                {type='textfield', style='fe_search_textfield', clear_and_focus_on_right_click=true, lose_focus_on_confirm=true, handlers='textfield',
                  save_as=true}
              }},
              {type='frame', style='fe_search_results_listbox_frame', children={
                {type='list-box', style='fe_listbox_for_keyboard_nav', handlers='results_listbox', save_as=true}
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
              {type='list-box', style='fe_listbox', handlers='history_listbox', save_as=true}
            }}
          }}
        }
      }}
    }}
  )

  -- SET INITIAL STATE
  -- populate categories and set active category
  local category_frame = gui_data.category_frame
  local category_buttons = {}
  for category,_ in pairs(global.encyclopedia) do
    category_buttons[#category_buttons+1] = category_frame.add{type='sprite-button', name=category..'_button', style='tool_button',
      sprite='fe_category_'..category, tooltip={'fe-gui.category-'..category..'-plural'}}.index
  end
  category_frame[(options.category or 'item')..'_button'].style = 'fe_tool_button_active'
  -- register handler for category switching
  gui.register_handlers('search', 'category_buttons', {name='category_buttons', player_index=player.index, gui_filters=category_buttons})
  -- set active tab
  if options.active_tab and options.active_tab == 'history' then
    -- open tab
    gui_data.tabbed_pane.selected_tab_index = 2
    player.opened = gui_data.window
  else
    -- set textfield text and focused state
    local textfield = gui_data.textfield
    textfield.text = options.search_text or player_table.dictionary.other.translations.search..' '
      ..player_table.dictionary.category.translations[(options.category or 'item')..'-plural']..'...'
    textfield.select_all()
    textfield.focus()
    player.opened = textfield
  end
  -- center GUI
  gui_data.window.force_auto_center()
  -- gui data
  gui_data.state = 'search'
  gui_data.category = options.category or 'item'
  -- add data to global table
  player_table.gui.search = gui_data
  -- populate results listbox
  handlers.textfield.on_gui_text_changed{player_index=player.index, text=options.search_text or ''}
  -- populate history listbox
  local history = player_table.history.overall
  local add_item = gui_data.history_listbox.add_item
  for i=1,#history do
    local entry = history[i]
    add_item('[img=fe_category_'..entry.category..'_yellow]  [img='..entry.category..'/'..entry.name..']  '
      ..(player_table.dictionary[entry.category].translations[entry.name] or entry.name))
  end
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
  gui.destroy(gui_data.search.window, 'search', player.index)
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

function self.reset_search_pane(player_index, player_table, used_mouse)
  local gui_data = player_table.gui.search
  gui_data.choose_elem_button_container.clear()
  gui_data.choose_elem_button = gui_data.choose_elem_button_container.add{type='choose-elem-button', style='quick_bar_slot_button', elem_type=gui_data.category}
  gui_data.results_listbox.selected_index = 0
  gui_data.textfield.text = player_table.dictionary.other.translations.search..' '..player_table.dictionary.category.translations[gui_data.category]..'...'
  handlers.textfield.on_gui_text_changed{player_index=player_index, text=''}

  -- set GUI state and focus textfield
  if used_mouse then
    gui_data.state = 'search'
    gui_data.textfield.select_all()
    gui_data.textfield.focus()
    game.get_player(player_index).opened = gui_data.textfield
  end
end

return self