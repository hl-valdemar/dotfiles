-- OPTIONS

vim.opt.winborder = "double"
vim.opt.cursorcolumn = false
vim.opt.ignorecase = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.signcolumn = "yes"
vim.opt.list = true
vim.opt.listchars = {
  tab = "→ ",
  trail = "·",
}

-- PLUGINS

vim.pack.add({
  -- color schemes
  { src = "https://github.com/vague2k/vague.nvim" },
  { src = "https://github.com/sainnhe/gruvbox-material" },
  { src = "https://github.com/sainnhe/everforest" },
  { src = "https://github.com/morhetz/gruvbox" },
  { src = "https://github.com/xero/miasma.nvim" },
  { src = "https://github.com/rose-pine/neovim" },
  -- utility
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/chomosuke/typst-preview.nvim" },
  { src = "https://github.com/Wansmer/treesj" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/rktjmp/lush.nvim" },
  { src = "https://github.com/rktjmp/shipwright.nvim" },
  -- { src = "https://github.com/windwp/nvim-autopairs" },
  -- lsp
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
  { src = "https://github.com/Saghen/blink.cmp" },
})

require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '▓▒░', right = '░▒▓' }, -- cool separators: ("▓▒░", "░▒▓"), (, )
    globalstatus = true,
    always_show_tabline = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'lsp_status' },
    lualine_z = { 'progress', 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_a = {
      {
        'buffers',
        symbols = {
          modified = ' *',
          alternate_file = '#',
        },
      },
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {
      function() -- battery display
        local handle = io.popen('pmset -g batt | grep -Eo "\\d+%" | head -1', "r")
        if handle then
          local result = handle:read("a")
          handle:close()

          if result then
            result = result:match('%d+')
            if result then
              return "bat " .. result .. '%%'
            end
          end
        end
        return ''
      end
    },
  },
  winbar = {},
  inactive_winbar = {},
  extensions = {}
})

require("oil").setup()

local actions = require('telescope.actions')
require('telescope').setup({
  defaults = {
    borderchars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" },
    layout_config = {
      prompt_position = "top", -- or "bottom"
    },
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ["<C-h>"] = "which_key",
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<Esc>"] = actions.close,
      }
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
})

require('blink.cmp').setup({
  keymap = {
    preset = 'none', -- we'll define custom keymaps
    ['<C-j>'] = { 'select_next', 'fallback' },
    ['<C-k>'] = { 'select_prev', 'fallback' },
    ['<C-CR>'] = { 'accept', 'fallback' },
    ['<C-e>'] = { 'hide', 'fallback' },
    ['<C-l>'] = { 'show', 'fallback' },
  },

  completion = {
    menu = {
      auto_show = true,
    },
    documentation = {
      window = {
        border = 'double',
      },
    },
  },

  signature = {
    window = {
      border = 'double',
    },
  },

  sources = {
    default = { 'lsp', 'path', 'buffer', 'snippets' },
  },

  -- enable fuzzy matching with typo resistance
  fuzzy = {
    use_proximity = true,
  },
})

require("ibl").setup({
  indent = {
    char = "┋", -- "▏", "│", "╎", "╏", "┆", "┇", "┊", "┋"
  },
  scope = {
    enabled = false,
  }
})

require("treesj").setup({
  use_default_keymaps = false,
})

require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  ensure_installed = {
    "lua",
    "zig",
    "go",
    "rust",
    "asm",
    "svelte",
    "typescript",
    "javascript",
  },
  auto_install = true,
  sync_install = false,
  ignore_install = {},
  modules = {},
})

-- LSP

vim.diagnostic.config({ virtual_lines = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end
    if client.name == "ruff" then
      -- disable hover in favor of pyright
      client.server_capabilities.hoverProvider = false
    end
  end,
  desc = "LSP: Disable hover capability from Ruff",
})

-- Hook blink.cmp into the native LSP system
vim.lsp.config("*", {
  capabilities = require('blink.cmp').get_lsp_capabilities()
})

vim.lsp.enable({
  "lua_ls",
  "zls",
  "ols",
  "gopls",
  "clangd",
  "rust_analyzer",
  "svelte",
  "ts_ls",
  "tinymist",
  "ruff",
  "pyright",
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      }
    }
  }
})

vim.lsp.config("ols", {
  init_options = {
    checker_args = "-strict-style",
    collections = {
      { name = "shared", path = vim.fn.expand("$HOME/odin-lib") }
    },
  },
})

vim.lsp.config("ts_ls", {
  filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte" },
  init_options = {
    plugins = {
      {
        name = "@sveltejs/language-server",
        -- This allows the TS server to recognize Svelte files
        location = vim.fn.expand("$HOME/.bun/install/global/node_modules/svelte-language-server"),
      },
    },
  },
})

-- HELPER FUNCTIONS

local colors_dark = "miasma"
local colors_light = "everforest"

local function load_color_mode(mode)
  local scheme = nil

  if mode == "dark" then
    vim.o.background = "dark"
    scheme = colors_dark
  else
    vim.o.background = "light"
    scheme = colors_light
  end

  -- Theme specific settings
  if scheme == "everforest" then
    vim.g.everforest_background = "soft"
  end

  -- Load the colorscheme
  vim.cmd("colorscheme " .. scheme)

  -- Common overrides
  vim.cmd("highlight StatusLine guibg=none")

  -- Lualine theme selection
  local lualine_theme = 'auto'
  if scheme == 'everforest' then
    lualine_theme = 'everforest'
  end

  require('lualine').setup({
    options = {
      theme = lualine_theme
    }
  })

  -- Common visual fixes
  vim.api.nvim_set_hl(0, "MiniPickMatchCurrent", { bg = "#2f2f2f", bold = true })
end

-- KEYBINDINGS

vim.g.mapleader = " "

-- close just the currently open buffer
vim.keymap.set('n', '<leader>q', ':bdelete<CR>', { desc = 'Close buffer' })

vim.keymap.set("n", "<leader>e", ":Oil<CR>")

-- telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', telescope.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>g', telescope.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>b', telescope.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>h', telescope.help_tags, { desc = 'Telescope help tags' })

vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>")

-- copy to system clipboard
vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y<CR>')
vim.keymap.set({ "n", "v", "x" }, "<leader>d", '"+d<CR>')

vim.keymap.set("n", "<ESC>", ":noh<CR>", { desc = "Disable highlight" })

-- lsp stuff
vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>lr", telescope.lsp_references)

-- split/join lists
vim.keymap.set("n", "<leader>m", require("treesj").toggle, { desc = "Toggle split/join" })
vim.keymap.set('n', '<leader>M', function() require('treesj').toggle({ split = { recursive = true } }) end)

-- navigate buffers in tabline
vim.keymap.set('n', '<A-h>', ':bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<A-l>', ':bnext<CR>', { desc = 'Next buffer' })

-- toggle virtual lines
vim.keymap.set("n", "<leader>ll", function()
  local new_config = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = new_config })
end, { desc = "Toggle diagnostic virtual lines" })

vim.keymap.set("n", "<leader>v", ":e $MYVIMRC<CR>")

-- snatch code snippet for image generation
vim.keymap.set("v", "<leader>c", function()
  local ext = vim.fn.expand("%:e")

  local lang_flag = ""
  if ext ~= "" then
    lang_flag = string.format("-l %s", ext)
  end

  return string.format(
    ":<C-u>'<,'>w !snatch --t miasma --no-chrome --no-decorations -o ~/Desktop/code.png -c %s<CR>",
    lang_flag)
end, { expr = true, desc = "Pipe to snatch" })

-- open remote github repo if remote found
vim.keymap.set("n", "<leader>og", function()
  -- run the git command and capture output
  local handle = io.popen("git remote get-url origin")
  if handle == nil then
    print("Failed to run command")
    return ":<CR>"
  end

  local git_url = handle:read("*a"):match("^%s*(.-)%s*$") -- trim whitespace
  handle:close()

  if git_url == nil or git_url == "" then
    print("No remote found")
    return ":<CR>"
  end

  -- convert ssh url to https url
  local repo_path
  if git_url:match("^git@github%.com:") then
    -- ssh format: git@github.com:user/repo.git
    repo_path = git_url:match("^git@github%.com:(.+)$")
  elseif git_url:match("^https://github%.com/") then
    -- already https format: https://github.com/user/repo.git
    repo_path = git_url:match("^https://github%.com/(.+)$")
  end

  -- construct the https url and return command
  local https_url = "https://github.com/" .. repo_path
  return string.format(":!open \"%s\"<CR>", https_url)
end, { expr = true, desc = "Open github repo if in repo workdir" })

-- toggle background
vim.keymap.set('n', '<leader>tt', function()
  if vim.o.background == 'dark' then
    load_color_mode("light")
  else
    load_color_mode("dark")
  end
end, { desc = 'Toggle background (light/dark)' })

-- COLORS

-- detect macos theme and set background on startup
local function set_background_from_system()
  local handle = io.popen('defaults read -g AppleInterfaceStyle 2>/dev/null')
  if handle then
    local result = handle:read('*a')
    handle:close()

    if result:match('Dark') then
      load_color_mode("dark")
    else
      load_color_mode("light")
    end
  else
    -- Default to light if detection fails or system is light
    load_color_mode("light")
  end
end

-- set correct background on startup
set_background_from_system()

-- AUTO COMMANDS

-- force redraw on mode change
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*",
  callback = function()
    vim.cmd("redraw")
  end,
})
