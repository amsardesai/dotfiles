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
return merge_specs(
	require("plugins.ui"),
	require("plugins.editor"),
	require("plugins.lsp"),
	require("plugins.lang")
)
