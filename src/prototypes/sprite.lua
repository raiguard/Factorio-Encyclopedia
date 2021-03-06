data:extend{
  {
    type = 'sprite',
    name = 'enc_logo',
    filename = '__Encyclopedia__/graphics/gui/encyclopedia.png',
    size = 32,
    mipmap_count = 2,
    flags = {'icon'}
  },
  {
    type = 'sprite',
    name = 'enc_nav_forward',
    filename = '__Encyclopedia__/graphics/gui/nav-forward.png',
    size = 32,
    mipmap_count = 2,
    flags = {'icon'}
  },
  {
    type = 'sprite',
    name = 'enc_nav_forward_dark',
    filename = '__Encyclopedia__/graphics/gui/nav-forward-dark.png',
    size = 32,
    mipmap_count = 2,
    flags = {'icon'}
  },
  {
    type = 'sprite',
    name = 'enc_nav_backward',
    filename = '__Encyclopedia__/graphics/gui/nav-backward.png',
    size = 32,
    mipmap_count = 2,
    flags = {'icon'}
  },
  {
    type = 'sprite',
    name = 'enc_nav_backward_dark',
    filename = '__Encyclopedia__/graphics/gui/nav-backward-dark.png',
    size = 32,
    mipmap_count = 2,
    flags = {'icon'}
  },
  {
    type = 'sprite',
    name = 'enc_search',
    filename = '__Encyclopedia__/graphics/gui/search.png',
    size = 32,
    mipmap_count = 2,
    flags = {'icon'}
  },
  {
    type = 'sprite',
    name = 'enc_search_dark',
    filename = '__Encyclopedia__/graphics/gui/search-dark.png',
    size = 32,
    mipmap_count = 2,
    flags = {'icon'}
  },
  {
    type = 'sprite',
    name = 'enc_pin',
    filename = '__Encyclopedia__/graphics/gui/pin.png',
    size = 32,
    mipmap_count = 2,
    flags = {'icon'}
  },
  {
    type = 'sprite',
    name = 'enc_pin_dark',
    filename = '__Encyclopedia__/graphics/gui/pin-dark.png',
    size = 32,
    mipmap_count = 2,
    flags = {'icon'}
  }
}

for _,category in ipairs{'achievement', 'entity', 'equipment', 'fluid', 'item', 'recipe', 'technology', 'tile'} do
  data:extend{
    {
      type = 'sprite',
      name = 'enc_category_'..category,
      filename = '__Encyclopedia__/graphics/gui/search-category/'..category..'.png',
      size = 32,
      mipmap_count = 2,
      flags = {'icon'}
    },
    {
      type = 'sprite',
      name = 'enc_category_'..category..'_yellow',
      filename = '__Encyclopedia__/graphics/gui/search-category/'..category..'.png',
      y = 32,
      size = 32,
      mipmap_count = 2,
      flags = {'icon'}
    }
  }
end