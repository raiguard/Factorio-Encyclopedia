local styles = data.raw['gui-style'].default

-- -----------------------------------------------------------------------------
-- BUTTON STYLES

styles.fe_category_button = {
  type = 'button_style',
  horizontal_align = 'center',
  horizontally_stretchable = 'on'
}

styles.fe_button_selected = {
  type = 'button_style',
  parent = 'button',
  default_font_color = button_hovered_font_color,
  default_graphical_set = {
    base = {position = {34,17}, corner_size=8},
    shadow = default_dirt,
    -- glow = default_glow(default_glow_color, 0.5)
  }
}

styles.fe_button_active = {
  type = 'button_style',
  parent = 'button',
  -- graphical sets
  default_graphical_set = {
    base = {position={225,17}, corner_size=8},
    shadow = default_dirt
  },
  hovered_font_color = button_hovered_font_color,
  hovered_graphical_set = {
      base = {position={369,17}, corner_size=8},
      shadow = default_dirt
  },
  clicked_font_color = button_hovered_font_color,
  clicked_graphical_set = {
      base = {position={352,17}, corner_size=8},
      shadow = default_dirt
  }
}

-- styles.fe_button_active_selected = {
--   type = 'button_style',
--   parent = 'button',
--   default_font_color = button_hovered_font_color,
--   default_graphical_set = {
--       base = {position={369,17}, corner_size=8},
--       shadow = default_dirt
--   },
--   hovered_font_color = button_hovered_font_color,
--   hovered_graphical_set = {
--       base = {position={369,17}, corner_size=8},
--       shadow = default_dirt,
--       glow = default_glow(default_glow_color, 0.5)
--   },
--   clicked_font_color = button_hovered_font_color,
--   clicked_graphical_set = {
--       base = {position={352,17}, corner_size=8},
--       shadow = default_dirt
--   }
-- }

styles.fe_tool_button_selected = {
  type = 'button_style',
  parent = 'fe_button_selected',
  padding = 2,
  size = 28
}

styles.fe_tool_button_active = {
  type = 'button_style',
  parent = 'fe_button_active',
  padding = 2,
  size = 28
}

-- styles.fe_tool_button_active_selected = {
--   type = 'button_style',
--   parent = 'fe_button_active_selected',
--   padding = 2,
--   size = 28
-- }

-- --------------------------------------------------------------------------------
-- EMPTY WIDGET STYLES

styles.fe_horizontal_pusher = {
  type = 'empty_widget_style',
  horizontally_stretchable = 'on'
}

styles.fe_vertical_pusher = {
  type = 'empty_widget_style',
  vertically_stretchable = 'on'
}

styles.fe_titlebar_draggable_space = {
  type = 'empty_widget_style',
  parent = 'draggable_space_header',
  horizontally_stretchable = 'on',
  natural_height = 24,
  minimal_width = 24,
  right_margin = 7
}

-- -----------------------------------------------------------------------------
-- FRAME STYLES

styles.fe_toolbar_frame = {
  type = 'frame_style',
  parent = 'subheader_frame',
  horizontal_flow_style = {
    type = 'horizontal_flow_style',
    horizontally_stretchable = 'on',
    vertical_align = 'center'
  }
}

styles.fe_toolbar_left = {
  type = 'frame_style',
  graphical_set = {
    base = {
      right = {position={257,25}, size={8,1}},
      center = {position={256,25}, size={1,1}}
    },
    shadow = {
      right = {position={209,136}, size={8,1}},
      center = {position={208,136}, size={1,1}},
      tint = default_shadow_color,
      scale = 0.5,
      draw_type = 'outer'
    }
  },
  vertical_flow_style = {
    type = 'vertical_flow_style',
    vertically_stretchable = 'on',
    horizontal_align = 'center'
  },
  horizontal_align = 'center',
  left_padding = 4,
  right_padding = 1
}

styles.fe_empty_frame = { -- completely empty frame, purely to make drag_target work
  type = 'frame_style',
  margin = 0,
  padding = 0,
  graphical_set = {},
  background_graphical_set = {},
  use_header_filler = false
}

styles.fe_listbox_frame = {
  type = 'frame_style',
  padding = 0,
  width = 225,
  graphical_set = { -- inset from a light frame, but keep the dark background
    base = {
      position = {85,0},
      corner_size = 8,
      draw_type = 'outer',
      center = {position={42,8}, size=1}
    },
    shadow = default_inner_shadow
  },
  background_graphical_set = { -- rubber grid
    position = {282,17},
    corner_size = 8,
    overall_tiling_vertical_size = 20,
    overall_tiling_vertical_spacing = 8,
    overall_tiling_vertical_padding = 4,
    overall_tiling_horizontal_padding = 4
  },
  vertically_stretchable = 'on'
}

styles.fe_search_results_listbox_frame = {
  type = 'frame_style',
  parent = 'fe_listbox_frame',
  height = 196
}

styles.fe_history_listbox_frame = {
  type = 'frame_style',
  parent = 'fe_listbox_frame',
  height = 224,
  width = 279,
  graphical_set = {
    base = {
      position = {17,0},
      corner_size = 8,
      center = {position={42,8}, size=1},
      top = {},
      left_top = {},
      right_top = {},
      draw_type = 'outer'
    },
    shadow = default_inner_shadow
  }
}

-- -----------------------------------------------------------------------------
-- FLOW STYLES

styles.fe_titlebar_flow = {
  type = 'horizontal_flow_style',
  direction = 'horizontal',
  horizontally_stretchable = 'on',
  vertical_align = 'center',
  top_margin = -3
}

styles.fe_vertically_centered_flow = {
  type = 'horizontal_flow_style',
  vertical_align = 'center'
}

styles.fe_search_flow = {
  type = 'vertical_flow_style',
  padding = 8,
  vertical_spacing = 8
}

styles.fe_search_input_flow = {
  type = 'horizontal_flow_style',
  parent = 'fe_vertically_centered_flow',
  horizontal_spacing = 6
}

styles.fe_paddingless_flow = {
  type = 'horizontal_flow_style',
  margin = 0,
  padding = 0
}

-- -----------------------------------------------------------------------------
-- IMAGE STYLES

styles.fe_object_icon = {
  type = 'image_style',
  stretch_image_to_widget_size = true,
  size = 28,
  padding = 2
}

-- -----------------------------------------------------------------------------
-- LABEL STYLES

styles.fe_listbox_label = {
  type = 'label_style',
  parent = 'caption_label',
  left_padding = 2
}

-- -----------------------------------------------------------------------------
-- LIST BOX STYLES

styles.fe_listbox_item = {
  type = 'button_style',
  parent = 'list_box_item',
  horizontally_stretchable = 'on',
  left_padding = 4,
  right_padding = 4
}

styles.fe_listbox = {
  type = 'list_box_style',
  parent = 'list_box',
  scroll_pane_style = { -- invisible scroll pane
    type = 'scroll_pane_style',
    parent = 'list_box_scroll_pane',
    graphical_set = {},
    background_graphical_set = {},
    vertically_stretchable = 'on'
  },
  item_style = {
    type = 'button_style',
    parent = 'fe_listbox_item'
  }
}

styles.fe_listbox_for_keyboard_nav = {
  type = 'list_box_style',
  parent = 'fe_listbox',
  item_style = {
    type = 'button_style',
    parent = 'fe_listbox_item',
    selected_graphical_set = {
      base = {position = {34,17}, corner_size=8},
      shadow = default_dirt
    }
  }
}

-- -----------------------------------------------------------------------------
-- SCROLL PANE STYLES



-- -----------------------------------------------------------------------------
-- TABBED PANE STYLES

styles.fe_search_tabbed_pane = {
  type = 'tabbed_pane_style',
  vertical_spacing = 0,
  padding = 0,
  tab_content_frame = {
    type = 'frame_style',
    parent = 'dialog_frame',
    top_padding = 8
  },
  tab_container = {
    type = 'horizontal_flow_style',
    left_padding = 0,
    right_padding = 0,
    horizontal_spacing = 0
  }
}

styles.fe_search_tab = {
  type = "tab_style",
  parent = "tab",
  height = 32,
  top_padding = 6,
  bottom_padding = 6,
  selected_graphical_set = {
    base={position={448,103}, corner_size=8},
    shadow = tab_glow(default_shadow_color, 0.5)
  }
}

-- -----------------------------------------------------------------------------
-- TEXTFIELD STYLES

styles.fe_search_textfield = {
  type = 'textbox_style',
  width = 180
}