-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALIB GUI MODULE
-- GUI templating and event handling

-- dependencies
local event = require('lualib.event')
local util = require('__core__.lualib.util')

-- locals
local global_data
local string_gsub = string.gsub
local string_split = util.split
local table_deepcopy = table.deepcopy
local table_insert = table.insert
local table_merge = util.merge

-- settings
local handlers = {}
local templates = {}
local build_data = {}

-- objects
local self = {}

-- -----------------------------------------------------------------------------
-- LOCAL UTILITIES

local function get_subtable(s, t)
  local o = table_deepcopy(t)
  for _,key in pairs(string_split(s, '%.')) do
    o = o[key]
  end
  return o
end

local function register_handlers(gui_name, elem_handlers, options)
  local prefix = gui_name..'.'
  local path
  if type(elem_handlers) == 'string' then
    path = prefix..elem_handlers
    append_path=true
    elem_handlers = get_subtable(gui_name..'.'..elem_handlers, handlers)
  end
  for n,func in pairs(elem_handlers) do
    local t = table.deepcopy(options)
    t.name = gui_name..'_'..t.name..'_'..n
    if type(func) == 'string' then
      path = prefix..func
      func = get_subtable(prefix..func, handlers)
    end
    if defines.events[n] then n = defines.events[n] end
    event.register(n, func, t)
    if not global_data[gui_name] then global_data[gui_name] = {} end
    if not global_data[gui_name][t.player_index] then global_data[gui_name][t.player_index] = {} end
    global_data[gui_name][t.player_index][t.name] = {gui_filters=t.gui_filters, path=append_path and (path..'.'..n) or path}
  end
end

-- recursively load a GUI template
local function recursive_load(parent, t, output, name, player_index)
  -- load template(s)
  if t.template then
    local template = t.template
    if type(template) == 'string' then
      template = {template}
    end
    for i=1,#template do
      t = util.merge{get_subtable(template[i], templates), t}
    end
  end
  local elem
  -- skip all of this if it's a tab-and-content
  if t.type ~= 'tab-and-content' then
    -- format element table
    local elem_t = table_deepcopy(t)
    local style = elem_t.style
    local iterate_style = false
    if style and type(style) == 'table' then
      elem_t.style = style.name
      iterate_style = true
    end
    elem_t.children = nil
    elem_t.handlers = nil
    elem_t.save_as = nil
    -- create element
    elem = parent.add(elem_t)
    -- set runtime styles
    if iterate_style then
      for k,v in pairs(t.style) do
        if k ~= 'name' then
          elem.style[k] = v
        end
      end
    end
    -- apply modifications
    if t.mods then
      for k,v in pairs(t.mods) do
        elem[k] = v
      end
    end
    -- add to output table
    if t.save_as then
      if type(t.save_as) == 'boolean' then
        t.save_as = t.handlers
      end
      output[t.save_as] = elem
    end
    -- register handlers
    if t.handlers then
      register_handlers(name, t.handlers, {name=elem.index, player_index=player_index, gui_filters=elem.index})
    end
    -- add children
    local children = t.children
    if children then
      for i=1,#children do
        output = recursive_load(elem, children[i], output, name, player_index)
      end
    end
  else
    local tab, content
    output, tab = recursive_load(parent, t.tab, output, name, player_index)
    output, content = recursive_load(parent, t.content, output, name, player_index)
    parent.add_tab(tab, content)
  end
  return output, elem
end

-- -----------------------------------------------------------------------------
-- SETUP

event.on_init(function()
  global.__lualib.gui = {}
  global_data = global.__lualib.gui
end)

event.on_load(function()
  global_data = global.__lualib.gui
  local con_registry = global.__lualib.event
  for _,pl in pairs(global_data) do
    for _,el in pairs(pl) do
      for n,t in pairs(el) do
        local registry = con_registry[n]
        if registry then
          event.register(registry.id, get_subtable(t.path, handlers), {name=t.name, gui_filters=t.gui_filters})
        end
      end
      break
    end
  end
end)

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(parent, name, player_index, template)
  build_data = {}
  return recursive_load(parent, template, {}, name, player_index)
end

function self.destroy(parent, name, player_index)
  local gui_tables = global_data[name]
  local list = gui_tables[player_index]
  for i=1,#list do
    local t = list[i]
    local func = get_subtable(t.path, handlers)
    event.deregister_conditional(func, {name=t.name, player_index=player_index})
  end
  gui_tables[player_index] = nil
  if table_size(gui_tables) == 0 then
    global_data[name] = nil
  end
  parent.destroy()
end

function self.add_templates(...)
  local arg = {...}
  if #arg == 1 then
    for k,v in pairs(arg[1]) do
      templates[k] = v
    end
  else
    templates[arg[1]] = arg[2]
  end
  return self
end

function self.add_handlers(...)
  local arg = {...}
  if #arg == 1 then
    for k,v in pairs(arg[1]) do
      handlers[k] = v
    end
  else
    handlers[arg[1]] = arg[2]
  end
  return self
end

self.register_handlers = register_handlers

function self.deregister_handlers(name, handlers, player_index)

end

return self