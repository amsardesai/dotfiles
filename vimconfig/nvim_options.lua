-- Neovim plugin configurations
-- Loaded from main.vim via luafile

local vim = vim ---@diagnostic disable-line: undefined-global

-- Get the directory of this file for relative imports
local current_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')

local NvimTreeApi = require('nvim-tree.api')
local Snacks = require('snacks')
local context_menu = dofile(current_dir .. '/helpers/context_menu.lua')

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Auto-reload files when changed externally
vim.o.autoread = true

-- Setup nvim-tree
require("nvim-tree").setup({
  view = {
    width = 30,
  },
  renderer = {
    add_trailing = true,
    group_empty = true,
    highlight_modified = "name",
    icons = {
      show = {
        hidden = true,
      },
    },
  },
})

-- Integrate snacks.nvim rename with nvim-tree
-- When files are renamed in nvim-tree, notify LSP to update imports/references
local prev_rename = { new_name = "", old_name = "" }
vim.api.nvim_create_autocmd("User", {
  pattern = "NvimTreeSetup",
  callback = function()
    local events = NvimTreeApi.events
    events.subscribe(events.Event.NodeRenamed, function(data)
      if prev_rename.new_name ~= data.new_name or prev_rename.old_name ~= data.old_name then
        prev_rename = data
        Snacks.rename.on_rename_file(data.old_name, data.new_name)
      end
    end)
  end,
})

require("lualine").setup({
  theme = "tokyonight",
  sections = {
    lualine_x = {'encoding', 'fileformat', 'filetype', 'lsp_status'},
  },
})

require("gitsigns").setup({
  current_line_blame = true,
  current_line_blame_opts = {
    ignore_whitespace = true,
  },
})

require("bufferline").setup({
  options = {
    diagnostics = "nvim_lsp",
    show_tab_indicators = true,
    separator_style = "slant",
    color_icons = false,
    hover = {
      enabled = true,
      delay = 50,
      reveal = {'close'},
    },
    offsets = {
      filetype = "NvimTree",
      text = "File Explorer",
      separator = true,
    },
  },
})

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = require('telescope.actions').close,
      },
    },

    -- Preview: render on selection, fail fast if slow
    preview = {
      timeout = 200,
      filesize_limit = 1,
      treesitter = false,
    },

    -- Cache picker results for instant re-open
    cache_picker = {
      num_pickers = 10,
      limit_entries = 1000,
    },

    -- Layout
    layout_strategy = 'horizontal',
    layout_config = {
      horizontal = { preview_width = 0.5 },
      width = 0.8,
      height = 0.8,
    },

    -- Reduce UI overhead
    dynamic_preview_title = false,
  },

  pickers = {
    find_files = {
      -- fd is faster than git ls-files, respects .gitignore
      find_command = { 'fd', '--type', 'f', '--strip-cwd-prefix', '--hidden', '--exclude', '.git' },
    },
    live_grep = {
      additional_args = function()
        return { '--hidden', '--glob', '!.git/*', '--smart-case' }
      end,
    },
  },

  extensions = {
    -- fzf-native: 10-100x faster sorting
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({
        layout_config = { width = 0.6, height = 0.5 },
      })
    }
  }
})

-- Load extensions (order matters: fzf must load for speed gains)
require("telescope").load_extension("fzf")
require("telescope").load_extension("ui-select")

require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'bash',
    'comment',
    'css',
    'dockerfile',
    'git_config',
    'git_rebase',
    'gitignore',
    'gitcommit',
    'go',
    'html',
    'jsdoc',
    'json',
    'lua',
    'markdown',
    'markdown_inline',
    'typescript',
    'tsx',
    'tsv',
    'vim',
    'vimdoc',
    'yaml',
  },
  highlight = {
    enable = true,
  },
})

require("scrollbar").setup()

-- LSP Lens - show references/implementations above functions and types
local SymbolKind = vim.lsp.protocol.SymbolKind
require("lsp-lens").setup({
  enable = true,
  include_declaration = false,
  -- Show on functions, methods, interfaces, classes, types
  target_symbol_kinds = {
    SymbolKind.Function,
    SymbolKind.Method,
    SymbolKind.Interface,
    SymbolKind.Class,
    SymbolKind.Struct,
    SymbolKind.TypeParameter,
  },
  wrapper_symbol_kinds = { SymbolKind.Class, SymbolKind.Struct, SymbolKind.Module },
  sections = {
    definition = false,
    references = function(count)
      return " " .. count
    end,
    implements = function(count)
      return " " .. count
    end,
    git_authors = function(latest_author, count)
      if count > 1 then
        return " " .. latest_author .. " +" .. (count - 1)
      end
      return " " .. latest_author
    end,
  },
})

-- Diagnostic keybindings (global, not LSP-specific)
vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', { desc = 'Show diagnostic' })
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', { desc = 'Next diagnostic' })
vim.keymap.set('n', 'gL', '<cmd>LspLensToggle<cr>', { desc = 'Toggle LSP lens' })

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = function(desc)
      return { buffer = event.buf, desc = desc }
    end

    -- LSP keybindings (buffer-local, only active when LSP is attached)
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts('Hover documentation'))
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts('Go to definition'))
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts('Go to declaration'))
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts('Go to implementation'))
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts('Go to type definition'))
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts('Find references'))
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts('Signature help'))
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts('Rename symbol'))
    vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts('Format document'))
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts('Code actions'))
    vim.keymap.set('n', 'gh', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, opts('Toggle inlay hints'))
  end
})

-- Strike through deprecated variables
vim.api.nvim_set_hl(0, 'DiagnosticDeprecated', { strikethrough = true, fg = '#5c6370' })

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = false,
  float = true,
})

-- Auto-show diagnostics on cursor hold
vim.o.updatetime = 250
vim.api.nvim_create_autocmd('CursorHold', {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local default_setup = function(server)
  require('lspconfig')[server].setup({
    capabilities = capabilities,
  })
end
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    'eslint',
    'cssls',
    'docker_compose_language_service',
    'docker_language_server',
    'dockerls',
    'html',
    'jsonls',
    'lua_ls',
    'pylsp',
    'vimls',
    'yamlls',
  },
  automatic_enable = true,
  handlers = { default_setup },
})

-- TypeScript support via typescript-tools.nvim (direct tsserver communication)
-- This bypasses typescript-language-server and talks directly to tsserver
require("typescript-tools").setup({
  capabilities = capabilities,
  settings = {
    -- Spawn additional tsserver instance for diagnostics (better performance)
    separate_diagnostic_server = true,
    -- Memory limit (16GB)
    tsserver_max_memory = 16384,
    -- Auto-close JSX tags
    jsx_close_tag = {
      enable = true,
      filetypes = { "javascriptreact", "typescriptreact" },
    },
    -- Code lens disabled (using lensline.nvim instead)
    code_lens = "off",
    -- Inlay hints configuration
    tsserver_file_preferences = {
      includeInlayParameterNameHints = "all",
      includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = true,
      includeInlayVariableTypeHintsWhenTypeMatchesName = false,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    },
  },
})

local cmp = require('cmp')
cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = cmp.mapping.preset.insert({
    -- Enter key confirms completion item
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl + space triggers completion menu
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})

-- Snacks.nvim - Collection of small QoL plugins
Snacks.setup({
  -- Better buffer deletion (preserves window layout)
  bufdelete = { enabled = true },
  -- Optimizations for large files
  bigfile = { enabled = true },
  -- Quick file picker from recent files
  quickfile = { enabled = true },
  -- Notifications
  notifier = {
    enabled = true,
    timeout = 3000,
  },
  -- Better LSP rename (shows preview)
  rename = { enabled = true },
  -- Highlight words under cursor
  words = { enabled = true },
  -- Git browse (open file in GitHub)
  gitbrowse = { enabled = true },
  -- Input UI improvement
  input = { enabled = true },
  -- Scope-based animations/dimming
  scope = {
    enabled = true
  },
  -- Smooth scrolling
  scroll = {
    enabled = true,
    animate = {
      duration = { step = 10, total = 100 },
    },
    animate_repeat = {
      duration = { step = 10, total = 80 },
    },
  },
  -- Indent guides
  indent = {
    enabled = true,
    char = "│",
    scope = { char = "│" },
    animate = {
      duration = { step = 10, total = 250 },
    },
  },
  -- Dashboard (startup screen)
  dashboard = {
    sections = {
      { section = "header" },
      { section = "keys", gap = 1 },
      { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = { 2, 2 } },
      { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2 },
    },
  }, -- disable if you prefer empty buffer
  -- Terminal (replaces vimconfig/terminal.vim functions)
  terminal = {
    enabled = true,
    win = {
      position = "bottom",
      height = 0.3,  -- 30% height (matches previous behavior)
    },
  },
})

-- Snacks keybindings
vim.keymap.set('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = 'Delete buffer' })
vim.keymap.set('n', '<leader>go', function() Snacks.gitbrowse() end, { desc = 'Open in GitHub' })
vim.keymap.set('n', '<leader>rn', function() Snacks.rename.rename_file() end, { desc = 'Rename file' })
vim.keymap.set('n', ']]', function() Snacks.words.jump(1) end, { desc = 'Next reference' })
vim.keymap.set('n', '[[', function() Snacks.words.jump(-1) end, { desc = 'Prev reference' })

-- Snacks terminal keybindings

-- Bottom terminal (default shell)
local function toggleBottomTerminal()
  Snacks.terminal.toggle()
end

vim.keymap.set({'n', 'v'}, '<leader>z', toggleBottomTerminal, { desc = 'Toggle terminal' })
vim.keymap.set('t', '<leader>z', toggleBottomTerminal, { desc = 'Toggle terminal' })

-- Hide all terminals (preserves session)
vim.keymap.set({'n', 'v', 't'}, '<leader>x', function()
  for _, term in ipairs(Snacks.terminal.list()) do
    term:hide()
  end
end, { desc = 'Hide all terminals' })
-- Kill all terminals (terminates session)
vim.keymap.set({'n', 'v', 't'}, '<leader>X', function()
  for _, term in ipairs(Snacks.terminal.list()) do
    term:close()
  end
end, { desc = 'Kill all terminals' })

-- claudecode.nvim setup (editor context integration with Claude Code)
require("claudecode").setup({
  terminal = {
    split_side = "right",
    split_width_percentage = 0.40,
    provider = "snacks",
  },
})
-- Toggle Claude Code terminal (drawer behavior with editor context)
vim.keymap.set({'n', 'v'}, '<leader>a', ':ClaudeCode<CR>', { desc = 'Toggle Claude Code' })
vim.keymap.set('t', '<leader>a', '<C-\\><C-n>:ClaudeCode<CR>', { desc = 'Toggle Claude Code' })
-- Send visual selection to Claude
vim.keymap.set('v', '<leader>sa', ':ClaudeCodeSend<CR>', { desc = 'Send selection to Claude' })
-- Add current file to Claude context
vim.keymap.set('n', '<leader>sa', ':ClaudeCodeAdd<CR>', { desc = 'Add file to Claude context' })

-- Fuzzy finder (Telescope)
vim.keymap.set({'n', 'i'}, '<C-p>', ':Telescope find_files<CR>', { silent = true, desc = 'Find files' })
vim.keymap.set({'n', 'i'}, '<C-o>', ':Telescope live_grep<CR>', { silent = true, desc = 'Live grep' })
vim.keymap.set({'n', 'i'}, '<C-i>', ':Telescope grep_string<CR>', { silent = true, desc = 'Grep string under cursor' })
vim.keymap.set('n', '<leader>l', ':Telescope find_files<CR>', { silent = true, desc = 'Find files' })
vim.keymap.set('n', '<leader>k', ':Telescope live_grep<CR>', { silent = true, desc = 'Live grep' })
vim.keymap.set('n', '<leader>j', ':Telescope grep_string<CR>', { silent = true, desc = 'Grep string under cursor' })

-- Right-click context menu
local function showContextMenu()
  context_menu.show()
end
vim.keymap.set({'n', 'v'}, '<RightMouse>', showContextMenu, { desc = 'Context menu' })

local function toggleNvimTree()
  NvimTreeApi.tree.toggle()
  vim.cmd.wincmd('w')
end

local function launchNvimTree()
  NvimTreeApi.tree.open()
  vim.cmd.wincmd('w')
end

-- NvimTree keybindings
vim.keymap.set('n', '<leader>m', toggleNvimTree, { silent = true, desc = 'Toggle NvimTree' })
vim.keymap.set('n', '<leader>n', ':NvimTreeFindFile<CR>', { silent = true, desc = 'Find file in NvimTree' })
vim.keymap.set('n', '<leader>b', launchNvimTree, { silent = true, desc = 'Open NvimTree' })

-- Gitsigns keybindings
vim.keymap.set('n', '<leader>gb', ':Gitsigns blame_line<CR>', { silent = true, desc = 'Git blame line' })
vim.keymap.set('n', ')', ':Gitsigns next_hunk<CR>', { desc = 'Next git hunk' })
vim.keymap.set('n', '(', ':Gitsigns prev_hunk<CR>', { desc = 'Prev git hunk' })
