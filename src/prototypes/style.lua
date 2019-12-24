local styles = data.raw['gui-style'].default

-- -----------------------------------------------------------------------------
-- BUTTON STYLES

styles.fe_category_button = {
  type = 'button_style',
  horizontal_align = 'center',
  horizontally_stretchable = 'on'
}

styles.fe_tool_button_selected = {
  type = 'button_style',
  parent = 'tool_button',
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
  vertically_stretchable = 'on',
  width = 200
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