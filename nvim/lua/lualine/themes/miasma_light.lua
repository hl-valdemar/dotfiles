local colors = {
  bg      = '#eee6cf',
  bg_alt  = '#dfd7c3',
  fg      = '#685742',
  yellow  = '#c9a554',
  green   = '#5f875f',
  olive   = '#78834b',
  orange  = '#917a47',
  red     = '#b36d43',
  brown   = '#bb7744',
  gray    = '#9a8e7c',
}

return {
  normal = {
    a = { fg = colors.bg, bg = colors.olive, gui = 'bold' },
    b = { fg = colors.fg, bg = colors.bg_alt },
    c = { fg = colors.fg, bg = 'NONE' },
  },
  insert = {
    a = { fg = colors.bg, bg = colors.green, gui = 'bold' },
  },
  visual = {
    a = { fg = colors.bg, bg = colors.yellow, gui = 'bold' },
  },
  replace = {
    a = { fg = colors.bg, bg = colors.red, gui = 'bold' },
  },
  command = {
    a = { fg = colors.bg, bg = colors.brown, gui = 'bold' },
  },
  inactive = {
    a = { fg = colors.gray, bg = colors.bg },
    b = { fg = colors.gray, bg = colors.bg },
    c = { fg = colors.gray, bg = colors.bg },
  },
}
