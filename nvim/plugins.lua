-- Neovim Plugin Specifications (lazy.nvim)
-- All plugin configurations are inline for proper lazy-loading

-- Helper: get nvim config directory path
local function get_config_dir()
  return vim.fn.stdpath("config") .. "/nvim"
end

return {
  -- =============================================================================
  -- THEME (load immediately - no flicker)
  -- =============================================================================

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- =============================================================================
  -- DEPENDENCIES (loaded when needed by other plugins)
  -- =============================================================================

  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- =============================================================================
  -- SNACKS.NVIM (VeryLazy + keymaps)
  -- =============================================================================

  {
    "folke/snacks.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bd", function() require("snacks").bufdelete() end, desc = "Delete buffer" },
      { "<leader>go", function() require("snacks").gitbrowse() end, desc = "Open in GitHub" },
      { "<leader>rn", function() require("snacks").rename.rename_file() end, desc = "Rename file" },
      { "]]", function() require("snacks").words.jump(1) end, desc = "Next reference" },
      { "[[", function() require("snacks").words.jump(-1) end, desc = "Prev reference" },
      { "<leader>z", function() require("snacks").terminal.toggle() end, mode = { "n", "v", "t" }, desc = "Toggle terminal" },
      { "<leader>x", function()
        for _, term in ipairs(require("snacks").terminal.list()) do term:hide() end
      end, mode = { "n", "v", "t" }, desc = "Hide all terminals" },
      { "<leader>X", function()
        for _, term in ipairs(require("snacks").terminal.list()) do term:close() end
      end, mode = { "n", "v", "t" }, desc = "Kill all terminals" },
    },
    opts = {
      bufdelete = { enabled = true },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      rename = { enabled = true },
      words = { enabled = true },
      gitbrowse = { enabled = true },
      input = { enabled = true },
      scope = { enabled = true },
      scroll = {
        enabled = true,
        animate = { duration = { step = 15, total = 100 } },
        animate_repeat = { duration = { step = 15, total = 50 } },
      },
      indent = {
        enabled = true,
        -- NOTE: Use box-drawing vertical line (U+2502), NOT regular pipe (|)
        char = "│",
        scope = { char = "│" },
        animate = { duration = { step = 10, total = 250 } },
      },
      dashboard = { enabled = false },
      terminal = {
        enabled = true,
        win = { position = "bottom", height = 0.3 },
      },
    },
  },

  -- =============================================================================
  -- MINI.MISC (only for zoom, load on keymap)
  -- =============================================================================

  {
    "echasnovski/mini.misc",
    keys = {
      {
        "<C-S-CR>",
        function()
          local MiniMisc = require("mini.misc")
          MiniMisc.setup()
          MiniMisc.zoom(0, {
            width = vim.o.columns,
            height = vim.o.lines,
            row = 0,
            col = 0,
            border = "double",
            title_pos = "center",
          })
          local win = vim.api.nvim_get_current_win()
          vim.wo[win].winblend = 5
          vim.wo[win].winhighlight = "Normal:NormalFloat"
        end,
        mode = { "n", "v", "t" },
        desc = "Toggle window zoom",
      },
    },
  },

  -- =============================================================================
  -- NVIM-TREE (on keymap/command)
  -- =============================================================================

  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeOpen", "NvimTreeClose" },
    -- Load when opening a directory (e.g., `nvim .`)
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(data)
          -- Check if argument is a directory
          if vim.fn.isdirectory(data.file) == 1 then
            -- Load nvim-tree and open it
            require("lazy").load({ plugins = { "nvim-tree.lua" } })
            require("nvim-tree.api").tree.open()
            -- Open fzf file picker on top
            vim.schedule(function()
              require("lazy").load({ plugins = { "fzf-lua" } })
              local file_cache = dofile(get_config_dir() .. "/file_cache.lua")
              file_cache.setup()
              local files = file_cache.get()
              local fzf = require("fzf-lua")
              if files and #files > 0 then
                fzf.fzf_exec(files, {
                  prompt = "Files> ",
                  previewer = "builtin",
                  actions = fzf.defaults.actions.files,
                  file_icons = true,
                  color_icons = true,
                })
              else
                fzf.files()
              end
            end)
          end
        end,
      })
    end,
    keys = {
      {
        "<leader>m",
        function()
          require("nvim-tree.api").tree.toggle()
          vim.cmd.wincmd("w")
        end,
        mode = { "n", "v", "t" },
        desc = "Toggle NvimTree",
      },
      { "<leader>n", "<cmd>NvimTreeFindFile<cr>", mode = { "n", "v", "t" }, desc = "Find file in NvimTree" },
      {
        "<leader>b",
        function()
          require("nvim-tree.api").tree.open()
          vim.cmd.wincmd("w")
        end,
        desc = "Open NvimTree",
      },
    },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = {
          add_trailing = true,
          group_empty = true,
          highlight_modified = "name",
          icons = { show = { hidden = true } },
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(bufnr)
          -- Shift+Arrow navigation (matches global mappings)
          local opts = { buffer = bufnr, noremap = true, silent = true }
          vim.keymap.set("n", "<S-Up>", "<C-w><Up>", opts)
          vim.keymap.set("n", "<S-Down>", "<C-w><Down>", opts)
          vim.keymap.set("n", "<S-Left>", "<C-w><Left>", opts)
          vim.keymap.set("n", "<S-Right>", "<C-w><Right>", opts)
        end,
      })

      -- Integrate with snacks.nvim rename (notify LSP of file renames)
      local prev_rename = { new_name = "", old_name = "" }
      vim.api.nvim_create_autocmd("User", {
        pattern = "NvimTreeSetup",
        callback = function()
          local api = require("nvim-tree.api")
          api.events.subscribe(api.events.Event.NodeRenamed, function(data)
            if prev_rename.new_name ~= data.new_name or prev_rename.old_name ~= data.old_name then
              prev_rename = data
              -- Only call snacks if it's loaded
              local ok, snacks = pcall(require, "snacks")
              if ok then
                snacks.rename.on_rename_file(data.old_name, data.new_name)
              end
            end
          end)
        end,
      })
    end,
  },

  -- =============================================================================
  -- LUALINE (VeryLazy)
  -- =============================================================================

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "tokyonight" },
      sections = {
        lualine_x = { "encoding", "fileformat", "filetype", "lsp_status" },
      },
    },
  },

  -- =============================================================================
  -- BUFFERLINE (BufAdd - when buffers exist)
  -- =============================================================================

  {
    "akinsho/bufferline.nvim",
    event = "BufAdd",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        show_tab_indicators = true,
        separator_style = "slant",
        color_icons = false,
        hover = { enabled = true, delay = 50, reveal = { "close" } },
        offsets = { filetype = "NvimTree", text = "File Explorer", separator = true },
      },
    },
  },

  -- =============================================================================
  -- GITSIGNS (BufReadPre in git repos)
  -- =============================================================================

  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    cond = function()
      -- Only load if in a git repo
      local git_dir = vim.fn.finddir(".git", vim.fn.getcwd() .. ";")
      return git_dir ~= ""
    end,
    keys = {
      { "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Git blame line" },
      { ")", "<cmd>Gitsigns next_hunk<cr>", desc = "Next git hunk" },
      { "(", "<cmd>Gitsigns prev_hunk<cr>", desc = "Prev git hunk" },
    },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { ignore_whitespace = true },
    },
  },

  -- =============================================================================
  -- SCROLLBAR (VeryLazy)
  -- =============================================================================

  {
    "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    opts = {},
  },

  -- =============================================================================
  -- FZF-LUA (on keymap)
  -- =============================================================================

  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = "nvim-tree/nvim-web-devicons",
    keys = {
      {
        "<C-p>",
        function()
          local file_cache = dofile(get_config_dir() .. "/file_cache.lua")
          local fzf = require("fzf-lua")
          local files = file_cache.get()
          if files and #files > 0 then
            fzf.fzf_exec(files, {
              prompt = "Files> ",
              previewer = "builtin",
              actions = fzf.defaults.actions.files,
              file_icons = true,
              color_icons = true,
            })
          else
            vim.notify("File cache not ready, searching...", vim.log.levels.WARN)
            fzf.files()
          end
        end,
        mode = { "n", "i", "v", "t" },
        desc = "Find files",
      },
      { "<C-o>", function() require("fzf-lua").live_grep() end, mode = { "n", "i" }, desc = "Live grep" },
      { "<C-o>", function() require("fzf-lua").grep_visual() end, mode = "v", desc = "Grep visual selection" },
      {
        "<leader>ll",
        function()
          local file_cache = dofile(get_config_dir() .. "/file_cache.lua")
          local fzf = require("fzf-lua")
          local files = file_cache.get()
          if files and #files > 0 then
            fzf.fzf_exec(files, {
              prompt = "Files> ",
              previewer = "builtin",
              actions = fzf.defaults.actions.files,
              file_icons = true,
              color_icons = true,
            })
          else
            fzf.files()
          end
        end,
        desc = "Find files",
      },
      {
        "<leader>lr",
        function()
          local file_cache = dofile(get_config_dir() .. "/file_cache.lua")
          file_cache.force_refresh()
        end,
        desc = "Refresh file cache",
      },
      { "<leader>lk", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
      { "<leader>lj", function() require("fzf-lua").grep_cword() end, desc = "Grep word under cursor" },
    },
    config = function()
      local fzf = require("fzf-lua")
      fzf.setup({
        { "fzf-native", "hide" },
        fzf_bin = "fzf",
        previewers = { bat = { theme = "tokyonight_night" } },
        files = {
          cmd = "git ls-files --cached --others --exclude-standard 2>/dev/null || fd --type f --strip-cwd-prefix --hidden --exclude .git --exclude node_modules --exclude build",
          git_icons = false,
        },
        grep = {
          cmd = "rg --column --line-number --no-heading --color=always --smart-case --hidden -g '!.git' -g '!node_modules' -g '!build'",
        },
        winopts = {
          backdrop = 30,
          height = 0.8,
          width = 0.8,
          preview = { horizontal = "right:50%", delay = 250 },
          files = { file_icon_padding = "" },
        },
        oldfiles = { include_current_session = true },
      })

      -- Register for vim.ui.select
      fzf.register_ui_select()

      -- Setup file cache
      local file_cache = dofile(get_config_dir() .. "/file_cache.lua")
      file_cache.setup()
    end,
  },

  -- =============================================================================
  -- TREESITTER (BufReadPost)
  -- =============================================================================

  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash", "c", "comment", "cpp", "css", "dockerfile",
          "git_config", "git_rebase", "gitignore", "gitcommit", "go",
          "html", "jsdoc", "json", "lua", "markdown", "markdown_inline",
          "python", "ruby", "typescript", "tsx", "tsv", "vim", "vimdoc", "yaml",
        },
        highlight = { enable = true },
      })
    end,
  },

  -- =============================================================================
  -- LSP & MASON (BufReadPre)
  -- =============================================================================

  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Add Mason bin to PATH
      vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

      -- Diagnostic config
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = false,
        float = true,
      })

      -- Strike through deprecated
      vim.api.nvim_set_hl(0, "DiagnosticDeprecated", { strikethrough = true, fg = "#5c6370" })

      -- Auto-show diagnostics on cursor hold
      vim.o.updatetime = 250
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.diagnostic.open_float(nil, { focusable = false })
        end,
      })

      -- LSP keybindings
      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP actions",
        callback = function(event)
          local opts = function(desc)
            return { buffer = event.buf, desc = desc }
          end
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover documentation"))
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
          vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts("Go to type definition"))
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("Find references"))
          vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts("Signature help"))
          vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts("Rename symbol"))
          vim.keymap.set({ "n", "x" }, "<F3>", function() vim.lsp.buf.format({ async = true }) end, opts("Format"))
          vim.keymap.set("n", "<F4>", vim.lsp.buf.code_action, opts("Code actions"))
          vim.keymap.set("n", "gh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, opts("Toggle inlay hints"))
          vim.keymap.set("n", "<C-LeftMouse>", "<LeftMouse><cmd>lua vim.lsp.buf.definition()<cr>", opts("Go to definition"))
        end,
      })

      -- Mason setup
      require("mason").setup()

      -- Capabilities for completion
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local default_setup = function(server)
        require("lspconfig")[server].setup({ capabilities = capabilities })
      end

      require("mason-lspconfig").setup({
        ensure_installed = {
          "bashls", "clangd", "cssls", "docker_compose_language_service",
          "docker_language_server", "dockerls", "eslint", "html", "jsonls",
          "lua_ls", "pylsp", "terraformls", "vimls", "yamlls",
        },
        automatic_enable = true,
        handlers = { default_setup },
      })
    end,
  },

  { "mason-org/mason.nvim", lazy = true },
  { "mason-org/mason-lspconfig.nvim", lazy = true },

  -- =============================================================================
  -- TYPESCRIPT-TOOLS (filetype-specific)
  -- =============================================================================

  {
    "pmizio/typescript-tools.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("typescript-tools").setup({
        capabilities = capabilities,
        settings = {
          separate_diagnostic_server = true,
          tsserver_max_memory = 16384,
          jsx_close_tag = {
            enable = true,
            filetypes = { "javascriptreact", "typescriptreact" },
          },
          code_lens = "off",
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
    end,
  },

  -- =============================================================================
  -- LSP-LENS (LspAttach)
  -- =============================================================================

  {
    "VidocqH/lsp-lens.nvim",
    event = "LspAttach",
    keys = {
      { "gL", "<cmd>LspLensToggle<cr>", desc = "Toggle LSP lens" },
    },
    config = function()
      local SymbolKind = vim.lsp.protocol.SymbolKind
      require("lsp-lens").setup({
        enable = true,
        include_declaration = false,
        target_symbol_kinds = {
          SymbolKind.Function, SymbolKind.Method, SymbolKind.Interface,
          SymbolKind.Class, SymbolKind.Struct, SymbolKind.TypeParameter,
        },
        wrapper_symbol_kinds = { SymbolKind.Class, SymbolKind.Struct, SymbolKind.Module },
        sections = {
          definition = false,
          references = function(count) return " " .. count end,
          implements = function(count) return " " .. count end,
          git_authors = function(latest_author, count)
            if count > 1 then return " " .. latest_author .. " +" .. (count - 1) end
            return " " .. latest_author
          end,
        },
      })
    end,
  },

  -- =============================================================================
  -- NONE-LS (BufReadPre)
  -- =============================================================================

  {
    "nvimtools/none-ls.nvim",
    event = "BufReadPre",
    dependencies = { "nvim-lua/plenary.nvim", "nvimtools/none-ls-extras.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        -- debug = false (removed debug mode!)
        filetypes = {
          "css", "dockerfile", "html", "javascript", "javascriptreact",
          "json", "lua", "markdown", "sh", "terraform", "tf",
          "typescript", "typescriptreact", "yaml",
        },
        sources = {
          null_ls.builtins.diagnostics.hadolint,
          null_ls.builtins.diagnostics.markdownlint.with({
            extra_args = { "--disable", "MD013" },
          }),
          null_ls.builtins.diagnostics.yamllint,
          null_ls.builtins.diagnostics.actionlint,
          null_ls.builtins.formatting.terraform_fmt,
          null_ls.builtins.formatting.prettier.with({
            filetypes = {
              "css", "html", "javascript", "javascriptreact",
              "json", "markdown", "typescript", "typescriptreact", "yaml",
            },
            condition = function() return true end,
          }),
          null_ls.builtins.formatting.biome.with({
            filetypes = { "javascript", "javascriptreact", "json", "typescript", "typescriptreact" },
            condition = function(utils)
              return utils.root_has_file({ "biome.json", "biome.jsonc" })
            end,
          }),
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.shfmt,
        },
      })

      -- Register eslint_d
      null_ls.register(require("none-ls.diagnostics.eslint_d"))
      null_ls.register(require("none-ls.formatting.eslint_d"))

      -- Format on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.css", "*.html", "*.js", "*.json", "*.jsx", "*.lua", "*.md", "*.sh", "*.tf", "*.ts", "*.tsx", "*.yaml", "*.yml" },
        callback = function(args)
          vim.lsp.buf.format({
            bufnr = args.buf,
            filter = function(client) return client.name == "null-ls" end,
          })
        end,
      })
    end,
  },

  { "nvimtools/none-ls-extras.nvim", lazy = true },

  {
    "jay-babu/mason-null-ls.nvim",
    event = "BufReadPre",
    dependencies = { "mason-org/mason.nvim", "nvimtools/none-ls.nvim" },
    opts = {
      ensure_installed = {
        "actionlint", "biome", "eslint_d", "hadolint", "markdownlint",
        "prettier", "shellcheck", "shfmt", "stylua", "yamllint",
      },
      automatic_installation = true,
      handlers = {},
    },
  },

  -- =============================================================================
  -- COMPLETION (InsertEnter)
  -- =============================================================================

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "windwp/nvim-autopairs",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
      })

      -- Autopairs integration
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  { "hrsh7th/cmp-nvim-lsp", lazy = true },
  { "hrsh7th/cmp-buffer", lazy = true },
  { "hrsh7th/cmp-path", lazy = true },

  {
    "hrsh7th/cmp-cmdline",
    event = "CmdlineEnter",
  },

  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    build = "make install_jsregexp",
  },

  -- =============================================================================
  -- AUTOPAIRS (InsertEnter)
  -- =============================================================================

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true },
  },

  -- =============================================================================
  -- CLAUDECODE (on keymap/command)
  -- =============================================================================

  {
    "coder/claudecode.nvim",
    cmd = { "ClaudeCode", "ClaudeCodeSend", "ClaudeCodeAdd" },
    keys = {
      { "<leader>a", "<cmd>ClaudeCode<cr>", mode = { "n", "t" }, desc = "Toggle Claude Code" },
      { "<leader>a", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      { "<leader>sa", "<cmd>ClaudeCodeAdd<cr>", desc = "Add file to Claude" },
    },
    opts = {
      log_level = "warn",
      terminal = {
        split_side = "right",
        split_width_percentage = 0.40,
        provider = "snacks",
        snacks_win_opts = {
          width = function()
            local editor_width = vim.o.columns
            local percentage_width = math.floor(editor_width * 0.40)
            return math.min(percentage_width, 75)
          end,
        },
      },
      diff_opts = { vertical_split = false },
    },
  },

  -- =============================================================================
  -- IMAGE.NVIM (BufRead for image files)
  -- =============================================================================

  {
    "3rd/image.nvim",
    event = "BufReadPre *.png,*.jpg,*.jpeg,*.gif,*.webp,*.bmp,*.ico,*.svg",
    build = false,
    config = function()
      local ok, image = pcall(require, "image")
      if ok then
        image.setup({
          backend = "kitty",
          processor = "magick_cli",
          integrations = {
            markdown = { enabled = false },
            neorg = { enabled = false },
            typst = { enabled = false },
            html = { enabled = false },
            css = { enabled = false },
          },
          max_height_window_percentage = 80,
          max_width_window_percentage = 80,
          hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.bmp", "*.ico", "*.svg" },
        })
      end
    end,
  },

  -- =============================================================================
  -- HEADLINES (markdown)
  -- =============================================================================

  {
    "lukas-reineke/headlines.nvim",
    ft = "markdown",
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {},
  },

  -- =============================================================================
  -- SHARED PLUGINS (VimScript, already have good lazy triggers)
  -- =============================================================================

  {
    "preservim/nerdcommenter",
    keys = { { "<leader>c", mode = { "n", "v" } } },
  },

  {
    "mg979/vim-visual-multi",
    branch = "master",
    keys = { "<C-n>" },
    init = function()
      vim.g.VM_maps = {
        ["Select h"] = "",
        ["Select l"] = "",
      }
    end,
  },

  { "bronson/vim-trailing-whitespace", event = "BufWritePre" },
  { "tpope/vim-surround", event = "VeryLazy" },
  { "tpope/vim-sleuth", event = "BufReadPre" },
  { "tpope/vim-repeat", event = "VeryLazy" },
  { "jmcantrell/vim-virtualenv", ft = "python" },
  { "justinmk/vim-sneak", keys = { "s", "S" } },

  -- =============================================================================
  -- FILETYPE PLUGINS
  -- =============================================================================

  { "mattn/emmet-vim", ft = { "html", "css", "javascriptreact", "typescriptreact" } },
  { "vim-ruby/vim-ruby", ft = "ruby" },
  { "tpope/vim-rails", ft = "ruby" },
  { "derekwyatt/vim-scala", ft = "scala" },
  { "LaTeX-Box-Team/LaTeX-Box", ft = "tex" },
  { "vim-scripts/sql.vim--Stinson", ft = "sql" },
  { "vim-scripts/applescript.vim", ft = "applescript" },
  { "vim-scripts/mako.vim", ft = "html" },
  { "vim-scripts/nginx.vim", ft = "nginx" },
}
