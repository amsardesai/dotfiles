-- Zoom Window Mode-Aware Border Colors
-- Updates zoomed floating window border color based on current Vim mode

local M = {}
local setup_done = false

-- Tokyonight palette colors (matching lualine mode colors)
local COLORS = {
	normal = "#7aa2f7", -- blue
	insert = "#9ece6a", -- green
	visual = "#bb9af7", -- magenta
	replace = "#f7768e", -- red
	command = "#e0af68", -- yellow
	terminal = "#9ece6a", -- green (same as insert)
}

-- Define highlight groups for each mode
local function setup_highlights()
	vim.api.nvim_set_hl(0, "ZoomBorderNormal", { fg = COLORS.normal })
	vim.api.nvim_set_hl(0, "ZoomBorderInsert", { fg = COLORS.insert })
	vim.api.nvim_set_hl(0, "ZoomBorderVisual", { fg = COLORS.visual })
	vim.api.nvim_set_hl(0, "ZoomBorderReplace", { fg = COLORS.replace })
	vim.api.nvim_set_hl(0, "ZoomBorderCommand", { fg = COLORS.command })
	vim.api.nvim_set_hl(0, "ZoomBorderTerminal", { fg = COLORS.terminal })
end

-- Map vim mode to highlight group name
local function get_border_hl_for_mode(mode)
	if mode:match("^i") then
		return "ZoomBorderInsert"
	elseif mode:match("^R") then
		return "ZoomBorderReplace"
	elseif mode:match("^[vVsS\x16]") then
		return "ZoomBorderVisual"
	elseif mode:match("^c") then
		return "ZoomBorderCommand"
	elseif mode:match("^t") then
		return "ZoomBorderTerminal"
	else
		return "ZoomBorderNormal"
	end
end

-- Get winhighlight string for current mode
function M.get_winhighlight()
	local mode = vim.fn.mode()
	local hl = get_border_hl_for_mode(mode)
	return "Normal:NormalFloat,FloatBorder:" .. hl
end

-- Update border color for all zoomed windows
function M.update_border()
	local mode = vim.fn.mode()
	local hl = get_border_hl_for_mode(mode)

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.w[win].is_zoomed then
			local config = vim.api.nvim_win_get_config(win)
			if config.relative ~= "" then -- It's a floating window
				vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:" .. hl
			end
		end
	end
end

-- Check if any zoomed window exists
function M.has_zoomed_window()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.w[win].is_zoomed then
			return true
		end
	end
	return false
end

-- Setup module (idempotent)
function M.setup()
	if setup_done then
		return
	end
	setup_done = true

	setup_highlights()

	-- Create autocommand group
	local group = vim.api.nvim_create_augroup("ZoomBorderColors", { clear = true })

	-- Update border on mode change
	vim.api.nvim_create_autocmd("ModeChanged", {
		group = group,
		pattern = "*",
		callback = function()
			if M.has_zoomed_window() then
				M.update_border()
			end
		end,
		desc = "Update zoom window border color on mode change",
	})

	-- Re-apply highlights after colorscheme change
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function()
			setup_highlights()
			if M.has_zoomed_window() then
				M.update_border()
			end
		end,
		desc = "Redefine zoom border highlights after colorscheme change",
	})
end

return M
