local colors = {
  bg      = '#222222',
  bg_dark = '#1c1c1c',
  fg      = '#d7c483',
  yellow  = '#c9a554',
  green   = '#5f875f',
  olive   = '#78834b',
  orange  = '#685742',
  red     = '#b36d43',
  brown   = '#bb7744',
  gray    = '#666666',
}

return {
  normal = {
    a = { fg = colors.bg, bg = colors.olive, gui = 'bold' },
    b = { fg = colors.fg, bg = colors.bg_dark },
    c = { fg = colors.fg, bg = colors.bg },
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
