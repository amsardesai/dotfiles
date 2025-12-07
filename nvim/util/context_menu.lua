-- Context-aware right-click menu for Neovim

local M = {}

-- Cache for git repo check
local git_repo_cache = {}

function M.show()
	local menu_items = {}
	local actions = {}

	-- Get current mode
	local mode = vim.fn.mode()
	local is_visual = mode == "v" or mode == "V" or mode == ""

	-- Check LSP attachment
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	local has_lsp = #clients > 0

	-- Check for diagnostics at cursor
	local line = vim.fn.line(".") - 1
	local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
	local has_diagnostics = #diagnostics > 0

	-- Check if in git repository (cached for performance)
	local cwd = vim.fn.getcwd()
	if git_repo_cache[cwd] == nil then
		local result = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
		git_repo_cache[cwd] = result:match("true") ~= nil
	end
	local in_git_repo = git_repo_cache[cwd]

	-- Build menu based on context

	-- LSP Actions (only if LSP is attached)
	if has_lsp then
		table.insert(menu_items, "──── LSP ────")
		table.insert(actions, function() end)

		table.insert(menu_items, "  Go to Definition")
		table.insert(actions, function()
			vim.lsp.buf.definition()
		end)

		table.insert(menu_items, "  Find References")
		table.insert(actions, function()
			vim.lsp.buf.references()
		end)

		table.insert(menu_items, "  Rename Symbol")
		table.insert(actions, function()
			vim.lsp.buf.rename()
		end)

		table.insert(menu_items, "  Code Actions")
		table.insert(actions, function()
			vim.lsp.buf.code_action()
		end)

		table.insert(menu_items, "  Show Hover Info")
		table.insert(actions, function()
			vim.lsp.buf.hover()
		end)
	end

	-- Diagnostic Actions (only if diagnostics present)
	if has_diagnostics then
		table.insert(menu_items, "──── Diagnostics ────")
		table.insert(actions, function() end)

		table.insert(menu_items, "  Show Diagnostic")
		table.insert(actions, function()
			vim.diagnostic.open_float()
		end)

		table.insert(menu_items, "  Next Diagnostic")
		table.insert(actions, function()
			vim.diagnostic.goto_next()
		end)

		table.insert(menu_items, "  Previous Diagnostic")
		table.insert(actions, function()
			vim.diagnostic.goto_prev()
		end)
	end

	-- Git Operations (only if in git repo)
	if in_git_repo then
		table.insert(menu_items, "──── Git ────")
		table.insert(actions, function() end)

		table.insert(menu_items, "  Blame Line")
		table.insert(actions, function()
			vim.cmd("Gitsigns blame_line")
		end)

		table.insert(menu_items, "  Preview Hunk")
		table.insert(actions, function()
			vim.cmd("Gitsigns preview_hunk")
		end)

		table.insert(menu_items, "  Stage Hunk")
		table.insert(actions, function()
			vim.cmd("Gitsigns stage_hunk")
		end)

		table.insert(menu_items, "  Reset Hunk")
		table.insert(actions, function()
			vim.cmd("Gitsigns reset_hunk")
		end)

		table.insert(menu_items, "  Diff This")
		table.insert(actions, function()
			vim.cmd("Gitsigns diffthis")
		end)
	end

	-- File Operations
	table.insert(menu_items, "──── File ────")
	table.insert(actions, function() end)

	table.insert(menu_items, "  Save")
	table.insert(actions, function()
		vim.cmd("write")
	end)

	table.insert(menu_items, "  Save All")
	table.insert(actions, function()
		vim.cmd("wall")
	end)

	table.insert(menu_items, "  Close Buffer")
	table.insert(actions, function()
		vim.cmd("bdelete")
	end)

	table.insert(menu_items, "  Find Files")
	table.insert(actions, function()
		require("fzf-lua").files()
	end)

	-- Editing Operations
	table.insert(menu_items, "──── Edit ────")
	table.insert(actions, function() end)

	if is_visual then
		-- Visual mode specific actions
		table.insert(menu_items, "  Cut Selection")
		table.insert(actions, function()
			vim.cmd('normal! "+d')
		end)

		table.insert(menu_items, "  Copy Selection")
		table.insert(actions, function()
			vim.cmd('normal! "+y')
		end)
	else
		-- Normal mode actions
		table.insert(menu_items, "  Copy Line")
		table.insert(actions, function()
			vim.cmd("normal! yy")
		end)

		table.insert(menu_items, "  Delete Line")
		table.insert(actions, function()
			vim.cmd("normal! dd")
		end)
	end

	table.insert(menu_items, "  Paste")
	table.insert(actions, function()
		vim.cmd("normal! p")
	end)

	table.insert(menu_items, "  Select All")
	table.insert(actions, function()
		vim.cmd("normal! ggVG")
	end)

	table.insert(menu_items, "  Undo")
	table.insert(actions, function()
		vim.cmd("undo")
	end)

	table.insert(menu_items, "  Redo")
	table.insert(actions, function()
		vim.cmd("redo")
	end)

	-- Show menu using vim.ui.select (will render via Telescope)
	vim.ui.select(menu_items, {
		prompt = "Context Menu",
		format_item = function(item)
			return item
		end,
	}, function(_, idx)
		if idx and actions[idx] then
			actions[idx]()
		end
	end)
end

return M
