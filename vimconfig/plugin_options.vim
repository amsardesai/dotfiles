
" NERD Commenter
let NERDSpaceDelims=1

" Vim-only configuration
if !has('nvim')
  " CtrlP.vim
  let g:ctrlp_match_window = 'max:50'
  let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
  let g:ctrlp_dont_split = 'NERD'
  noremap <C-h> :CtrlPBuffer<CR>
  noremap <Leader>op :CtrlPClearAllCaches<CR>

  " Airline
  if !exists('g:airline_symbols')
      let g:airline_symbols = {}
  endif

  let g:airline_theme='tomorrow'
  let g:airline#extensions#hunks#non_zero_only = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#ycm#error_symbol = 'error:'
  let g:airline#extensions#ycm#warning_symbol = 'warning:'
  let g:airline_powerline_fonts = 1
  let g:airline_symbols.branch = ''
  let g:airline_symbols.colnr = ''
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ' :'
  let g:airline_symbols.maxlinenr = '☰ '
  let g:airline_symbols.dirty='⚡'

  " NERDTree configuration (Vim only)
  function! s:toggleNERD()
    execute 'NERDTreeToggle'
    if bufwinnr(t:NERDTreeBufName) != -1
      execute "normal \<C-w>\<C-w>"
    endif
  endfunction

  function! s:launchNERD()
    execute 'NERDTree'
    if bufwinnr(t:NERDTreeBufName) != -1
      execute "normal \<C-w>\<C-w>"
    endif
  endfunction

  let NERDTreeAutoCenterThreshold = 10
  let NERDTreeShowHidden = 1
  let NERDTreeAutoDeleteBuffer = 1
  let NERDTreeMouseMode = 2
  let NERDTreeMinimalUI = 1
  nnoremap <silent> <leader>m :call <SID>toggleNERD()<CR>
  nnoremap <silent> <leader>n :NERDTreeFind<CR>
  nnoremap <silent> <leader>b :call <SID>launchNERD()<CR>

  set pastetoggle=<Leader>u " Set paste toggle (Vim only)

  " Fugitive
  nnoremap <silent> <Leader>gl :silent Git log<CR>
  nnoremap <silent> <Leader>gb :Git blame<CR>

  " GitGutter (Vim only)
  nmap ) <Plug>GitGutterNextHunk
  nmap ( <Plug>GitGutterPrevHunk
  let g:gitgutter_realtime = 0
  let g:gitgutter_eager = 0
endif

" Nvim-tree configuration (Neovim only)
if has('nvim')
  lua << EOF
  -- Disable netrw
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1


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
      local events = require("nvim-tree.api").events
      events.subscribe(events.Event.NodeRenamed, function(data)
        if prev_rename.new_name ~= data.new_name or prev_rename.old_name ~= data.old_name then
          prev_rename = data
          Snacks.rename.on_rename_file(data.old_name, data.new_name)
        end
      end)
    end,
  })

  require("lualine").setup({
    theme = "tomorrow_night",
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
        delay = 200,
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
      -- Make ESC close immediately instead of needing two presses
      mappings = {
        i = {
          ["<esc>"] = require('telescope.actions').close,
        },
      },
    },
    pickers = {
      find_files = {
        -- Only show git-tracked files (excludes .git, node_modules, untracked files)
        find_command = { 'git', 'ls-files', '--cached', '--others', '--exclude-standard' },
      },
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown({
          layout_config = {
            width = 0.6,
            height = 0.5,
          },
        })
      }
    }
  })

  -- Load telescope-ui-select extension
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

  -- note: diagnostics are not exclusive to lsp servers
  -- so these can be global keybindings
  vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
  vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
  vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')

  vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
      local opts = {buffer = event.buf}

      -- these will be buffer-local keybindings
      -- because they only work if you have an active language server

      vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
      vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
      vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
      vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
      vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
      vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
      vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
      vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
      vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
      vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    end
  })

  vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = false,
    float = true,
  })

  local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
  local default_setup = function(server)
    require('lspconfig')[server].setup({
      capabilities = lsp_capabilities,
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
      'ts_ls',
      'vimls',
      'yamlls',
    },
    automatic_enable = true,
    handlers = { default_setup, },
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

  -- Minimap
  vim.opt.sidescrolloff = 36
  vim.g.neominimap = {
    current_line_position = "percent",
  }

  -- Snacks.nvim - Collection of small QoL plugins
  require("snacks").setup({
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
        duration = { step = 10, total = 200 },
      },
    },
    -- Dashboard (startup screen)
    dashboard = { enabled = false }, -- disable if you prefer empty buffer
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

  -- Snacks terminal keybindings (replaces vimconfig/terminal.vim functions)
  vim.keymap.set({'n', 'v'}, '<leader>z', function() Snacks.terminal.toggle() end, { desc = 'Toggle terminal' })
  vim.keymap.set('t', '<leader>z', function() Snacks.terminal.toggle() end, { desc = 'Toggle terminal' })
  vim.keymap.set({'n', 'v', 't'}, '<leader>x', function()
    for _, term in ipairs(Snacks.terminal.list()) do
      term:close()
    end
  end, { desc = 'Close terminal' })
EOF

  " NvimTree helper function to toggle without focusing
  function! s:toggleNvimTree()
    execute 'NvimTreeToggle'
    " Switch back to the previous window after opening
    execute "normal \<C-w>\<C-w>"
  endfunction

  " NvimTree helper function to open without focusing
  function! s:launchNvimTree()
    execute 'NvimTreeOpen'
    " Switch back to the previous window after opening
    execute "normal \<C-w>\<C-w>"
  endfunction

  " Fuzzy finder
  nnoremap <silent> <C-p> :Telescope find_files<CR>
  nnoremap <silent> <C-o> :Telescope live_grep<CR>
  nnoremap <silent> <C-i> :Telescope grep_string<CR>
  nnoremap <silent> <leader>l :Telescope find_files<CR>
  nnoremap <silent> <leader>k :Telescope live_grep<CR>
  nnoremap <silent> <leader>j :Telescope grep_string<CR>

  " Right-click context menu (implementation in helpers/context_menu.vim)
  nnoremap <RightMouse> <LeftMouse><Cmd>lua show_context_menu()<CR>
  vnoremap <RightMouse> <LeftMouse><Cmd>lua show_context_menu()<CR>

  " Nvim-tree keybindings
  nnoremap <silent> <leader>m :call <SID>toggleNvimTree()<CR>
  nnoremap <silent> <leader>n :NvimTreeFindFile<CR>
  nnoremap <silent> <leader>b :call <SID>launchNvimTree()<CR>

  " Gitsigns stuff
  nnoremap <silent> <leader>gb :Gitsigns blame_line<CR>
  nmap ) :Gitsigns next_hunk<CR>
  nmap ( :Gitsigns prev_hunk<CR>
endif

" ============================================================
" Shared Plugin Configuration (Vim + Neovim)
" ============================================================

" Latex
let g:tex_flavor = 'latex'

" vim-json
set conceallevel=2

" Vim markdown
let g:vim_markdown_folding_disabled = 1

" vim-sneak
let g:sneak#s_next = 1
let g:sneak#use_ic_scs = 1

" vim-jsx
let g:jsx_ext_required = 0

" vim-flow
let g:flow#autoclose = 1
