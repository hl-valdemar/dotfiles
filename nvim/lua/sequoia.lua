local M = {}

local config = {
  indent = 4,
  padding = 2,
}

local ns_id = vim.api.nvim_create_namespace("sequoia")
local prompt_win = nil
local tree_win = nil

local function gather_files()
  local result = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
  if vim.v.shell_error == 0 and result:match("true") then
    local output = vim.fn.system("git ls-files --cached --others --exclude-standard")
    if vim.v.shell_error == 0 then
      local files = {}
      for line in output:gmatch("[^\n]+") do
        table.insert(files, line)
      end
      return files
    end
  end

  -- fallback: glob
  local all = vim.fn.glob("**/*", false, true)
  local files = {}
  for _, f in ipairs(all) do
    if vim.fn.isdirectory(f) == 0 then
      table.insert(files, f)
    end
  end
  return files
end

local function build_tree(paths)
  local root = { children = {} }
  for _, path in ipairs(paths) do
    local node = root
    local segments = {}
    for seg in path:gmatch("[^/]+") do
      table.insert(segments, seg)
    end
    for i, seg in ipairs(segments) do
      if not node.children[seg] then
        node.children[seg] = { children = (i < #segments) and {} or nil }
      elseif i < #segments and not node.children[seg].children then
        node.children[seg].children = {}
      end
      if i == #segments then
        node.children[seg].full_path = path
      end
      if node.children[seg].children then
        node = node.children[seg]
      end
    end
  end
  return root
end

local function render_tree(root)
  local lines = {}
  local line_map = {}
  local highlights = {}

  local function render(children, prefix)
    local sorted = {}
    for name, child in pairs(children) do
      table.insert(sorted, { name = name, node = child })
    end
    table.sort(sorted, function(a, b)
      local a_dir = a.node.children ~= nil
      local b_dir = b.node.children ~= nil
      if a_dir ~= b_dir then return a_dir end
      return a.name < b.name
    end)

    for i, entry in ipairs(sorted) do
      local is_last = (i == #sorted)
      local pad = string.rep(" ", config.indent - 2)
      local connector = is_last and "└─" .. pad or "├─" .. pad
      local child_prefix = prefix .. (is_last and string.rep(" ", config.indent) or "│" .. string.rep(" ", config.indent - 1))

      local display = entry.name
      local is_dir = entry.node.children ~= nil
      if is_dir then
        display = display .. "/"
      end

      local line_text = prefix .. connector .. display
      table.insert(lines, line_text)
      local buf_line = #lines

      local name_start = #prefix + #connector
      local name_end = #line_text
      if is_dir then
        table.insert(highlights, { buf_line, name_start, name_end, "SequoiaDirectory" })
      end

      if entry.node.full_path then
        line_map[buf_line] = entry.node.full_path
      end

      if is_dir then
        render(entry.node.children, child_prefix)
      end
    end
  end

  local pad = string.rep(" ", config.padding)
  table.insert(lines, pad .. ".")
  table.insert(highlights, { 1, config.padding, config.padding + 1, "SequoiaDirectory" })
  render(root.children, pad)
  return lines, line_map, highlights
end

local function find_first_file(line_map)
  local keys = {}
  for k, _ in pairs(line_map) do
    table.insert(keys, k)
  end
  table.sort(keys)
  return keys[1]
end

local function update_highlight(tree_buf, state)
  vim.api.nvim_buf_clear_namespace(tree_buf, ns_id, 0, -1)
  if state.selected then
    vim.api.nvim_buf_add_highlight(tree_buf, ns_id, "Visual", state.selected - 1, 0, -1)
  end
end

local function scroll_to_selection(state)
  if state.selected and tree_win and vim.api.nvim_win_is_valid(tree_win) then
    vim.api.nvim_win_call(tree_win, function()
      vim.api.nvim_win_set_cursor(0, { state.selected, 0 })
    end)
  end
end

local function move_selection(state, tree_buf, direction)
  if not state.selected then return end

  local keys = {}
  for k, _ in pairs(state.line_map) do
    table.insert(keys, k)
  end
  table.sort(keys)

  if #keys == 0 then return end

  local cur_idx = nil
  for i, k in ipairs(keys) do
    if k == state.selected then
      cur_idx = i
      break
    end
  end

  if not cur_idx then
    state.selected = keys[1]
  else
    local new_idx = cur_idx + direction
    if new_idx >= 1 and new_idx <= #keys then
      state.selected = keys[new_idx]
    end
  end

  update_highlight(tree_buf, state)
  scroll_to_selection(state)
end

local function filter_and_render(tree_buf, all_files, query, state)
  state.updating = true

  local filtered
  if query == "" then
    filtered = all_files
  else
    filtered = vim.fn.matchfuzzy(all_files, query)
  end

  if #filtered == 0 then
    vim.api.nvim_buf_set_lines(tree_buf, 0, -1, false, { "  (no matches)" })
    state.line_map = {}
    state.selected = nil
    update_highlight(tree_buf, state)
    state.updating = false
    return
  end

  local tree = build_tree(filtered)
  local lines, line_map, highlights = render_tree(tree)

  vim.api.nvim_buf_set_lines(tree_buf, 0, -1, false, lines)
  state.line_map = line_map
  state.selected = find_first_file(line_map)
  update_highlight(tree_buf, state)
  scroll_to_selection(state)

  local hl_ns = vim.api.nvim_create_namespace("sequoia_syntax")
  vim.api.nvim_buf_clear_namespace(tree_buf, hl_ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(tree_buf, hl_ns, hl[4], hl[1] - 1, hl[2], hl[3])
  end

  state.updating = false
end

local closing = false

local function close_floats()
  if closing then return end
  closing = true
  if prompt_win and vim.api.nvim_win_is_valid(prompt_win) then
    vim.api.nvim_win_close(prompt_win, true)
  end
  if tree_win and vim.api.nvim_win_is_valid(tree_win) then
    vim.api.nvim_win_close(tree_win, true)
  end
  prompt_win = nil
  tree_win = nil
  vim.cmd("stopinsert")
  closing = false
end

local function open_selected(state)
  local path = state.line_map[state.selected]
  if not path then return end
  close_floats()
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

function M.open()
  if prompt_win and vim.api.nvim_win_is_valid(prompt_win) then
    vim.api.nvim_set_current_win(prompt_win)
    return
  end

  local all_files = gather_files()

  -- dimensions
  local columns = vim.o.columns
  local lines = vim.o.lines
  local width = math.floor(columns * 0.75)
  local total_height = math.floor(lines * 0.8)
  local row = math.floor((lines - total_height) / 2)
  local col = math.floor((columns - width) / 2)

  -- prompt buffer + window
  local prompt_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[prompt_buf].bufhidden = "wipe"
  vim.bo[prompt_buf].buftype = "nofile"
  vim.bo[prompt_buf].swapfile = false
  vim.api.nvim_buf_set_name(prompt_buf, "Sequoia")

  prompt_win = vim.api.nvim_open_win(prompt_buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = 1,
    style = "minimal",
    border = "double",
  })

  -- tree buffer + window
  local tree_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[tree_buf].bufhidden = "wipe"
  vim.bo[tree_buf].buftype = "nofile"
  vim.bo[tree_buf].swapfile = false

  tree_win = vim.api.nvim_open_win(tree_buf, false, {
    relative = "editor",
    row = row + 3,
    col = col,
    width = width,
    height = total_height - 3,
    style = "minimal",
    border = "double",
    focusable = true,
  })

  -- transparent bg
  local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
  local dir_hl = vim.api.nvim_get_hl(0, { name = "Directory" })
  vim.api.nvim_set_hl(0, "SequoiaNormal", { bg = normal_bg })
  vim.api.nvim_set_hl(0, "SequoiaBorder", { bg = normal_bg })
  vim.api.nvim_set_hl(0, "SequoiaDirectory", { fg = dir_hl.fg, bg = normal_bg, bold = dir_hl.bold })
  vim.wo[prompt_win].winhighlight = "Normal:SequoiaNormal,FloatBorder:SequoiaBorder"
  vim.wo[tree_win].winhighlight = "Normal:SequoiaNormal,FloatBorder:SequoiaBorder"

  -- state
  local state = {
    line_map = {},
    selected = nil,
    updating = false,
  }

  -- prompt
  local prompt_pad = string.rep(" ", config.padding)
  local prompt_prefix = prompt_pad .. "> "
  local prefix_len = #prompt_prefix
  vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, { prompt_prefix })

  -- initial render
  filter_and_render(tree_buf, all_files, "", state)

  -- keymaps (on prompt buf)
  vim.keymap.set("i", "<C-j>", function()
    move_selection(state, tree_buf, 1)
  end, { buffer = prompt_buf })

  vim.keymap.set("i", "<C-k>", function()
    move_selection(state, tree_buf, -1)
  end, { buffer = prompt_buf })

  vim.keymap.set("i", "<CR>", function()
    open_selected(state)
  end, { buffer = prompt_buf })

  vim.keymap.set("i", "<Esc>", function()
    close_floats()
  end, { buffer = prompt_buf })

  vim.keymap.set("n", "<Esc>", function()
    close_floats()
  end, { buffer = prompt_buf })

  vim.keymap.set("n", "q", function()
    close_floats()
  end, { buffer = prompt_buf })

  -- protect prompt prefix
  vim.keymap.set("i", "<BS>", function()
    local c = vim.fn.col(".")
    if c > prefix_len + 1 then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, false, true), "n", false)
    end
  end, { buffer = prompt_buf })

  -- filter on keypress
  vim.api.nvim_create_autocmd("TextChangedI", {
    buffer = prompt_buf,
    callback = function()
      if state.updating then return end
      local line = vim.api.nvim_buf_get_lines(prompt_buf, 0, 1, false)[1]
      local query = line:sub(prefix_len + 1)
      filter_and_render(tree_buf, all_files, query, state)
    end,
  })

  -- close on leave
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = prompt_buf,
    callback = function()
      close_floats()
    end,
  })

  vim.cmd("startinsert!")
end

function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})
end

return M
