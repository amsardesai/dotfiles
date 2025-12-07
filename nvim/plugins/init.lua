-- Plugin Specifications Entry Point
-- Combines all plugin category files for lazy.nvim

-- Helper to merge plugin specs from multiple files
local function merge_specs(...)
	local result = {}
	for _, specs in ipairs({ ... }) do
		for _, spec in ipairs(specs) do
			table.insert(result, spec)
		end
	end
	return result
end

-- Load all plugin category files
local config_dir = vim.fn.stdpath("config") .. "/nvim/plugins"

return merge_specs(
	dofile(config_dir .. "/ui.lua"),
	dofile(config_dir .. "/editor.lua"),
	dofile(config_dir .. "/lsp.lua"),
	dofile(config_dir .. "/lang.lua"),
	dofile(config_dir .. "/tools.lua")
)
