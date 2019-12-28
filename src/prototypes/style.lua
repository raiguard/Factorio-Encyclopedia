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

styles.fe_button_active_selected = {
  type = 'button_style',
  parent = 'button',
  default_font_color = button_hovered_font_color,
  default_graphical_set = {
      base = {position={369,17}, corner_size=8},
      shadow = default_dirt
  },
  hovered_font_color = button_hovered_font_color,
  hovered_graphical_set = {
      base = {position={369,17}, corner_size=8},
      shadow = default_dirt,
      glow = default_glow(default_glow_color, 0.5)
  },
  clicked_font_color = button_hovered_font_color,
  clicked_graphical_set = {
      base = {position={352,17}, corner_size=8},
      shadow = default_dirt
  }
}

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

styles.fe_tool_button_active_selected = {
  type = 'button_style',
  parent = 'fe_button_active_selected',
  padding = 2,
  size = 28
}

styles.fe_recipe_nav_button = {
  type = 'button_style',
  parent = 'tool_button',
  padding = 0
}

-- --------------------------------------------------------------------------------
-- EMPTY WIDGET STYLES

styles.fe_invisible_horizontal_pusher = {
  type = 'empty_widget_style',
  horizontally_stretchable = 'on'
}

styles.fe_invisible_vertical_pusher = {
  type = 'empty_widget_style',
  vertically_stretchable = 'on'
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

styles.fe_search_content_pane = {
  type = 'frame_style',
  parent = 'inside_deep_frame',
  horizontal_flow_style = {
    type = 'horizontal_flow_style',
    horizontal_spacing = 0
  }
}

styles.fe_search_dialog_pane = {
  type = 'frame_style',
  parent = 'window_content_frame',
  vertically_stretchable = 'on'
}

styles.fe_light_listbox_pane = {
  type = 'frame_style',
  padding = 0,
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
  vertically_stretchable = 'on',
  horizontally_stretchable = 'on'
}

styles.fe_search_results_listbox_pane = {
  type = 'frame_style',
  parent = 'fe_light_listbox_pane',
  margin = 4
}

styles.fe_recipe_items_listbox_pane = {
  type = 'frame_style',
  parent = 'fe_light_listbox_pane',
  minimal_width = 225,
  minimal_height = 140,
  maximal_height = 280,
  vertically_stretchable = nil
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
  type='horizontal_flow_style',
  vertical_align = 'center'
}

-- -----------------------------------------------------------------------------
-- IMAGE STYLES

styles.fe_recipe_as_icon = {
  type = 'image_style',
  stretch_image_to_widget_size = true,
  size = 28,
  padding = 2
}

-- -----------------------------------------------------------------------------
-- LISTBOX STYLES

styles.fe_light_listbox = {
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
    parent = 'list_box_item',
    horizontally_stretchable = 'on'
  }
}

-- -----------------------------------------------------------------------------
-- SCROLL PANE STYLES

styles.fe_content_scroll_pane = {
  type = 'scroll_pane_style',
  parent = 'scroll_pane',
  background_graphical_set = {
    base = {
      center = {position={76,8}, size=1}
    }
  },
  vertical_flow_style = {
    type = 'vertical_flow_style',
    padding = 8
  }
}

-- -----------------------------------------------------------------------------
-- TEXTFIELD STYLES

styles.fe_search_textfield = {
  type = 'textbox_style',
  width = 180,
  right_margin = 4
}