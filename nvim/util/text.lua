-- Shared text utilities for Neovim configuration
local M = {}

--- Center-truncate a string with ellipsis
--- @param str string|nil The string to truncate
--- @param max_len number Maximum length (default: 20)
--- @return string|nil
function M.truncate_middle(str, max_len)
	max_len = max_len or 20
	if not str or #str <= max_len then
		return str
	end
	local side_len = math.floor((max_len - 1) / 2)
	return str:sub(1, side_len) .. "…" .. str:sub(-side_len)
end

return M
