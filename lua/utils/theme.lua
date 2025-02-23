--- @class terminale.utils.theme.Theme
--- @field default_window_theme fun(): terminale.utils.theme.WindowTheme

--- @class terminale.utils.theme.WindowTheme
--- @field win_config vim.api.keyset.win_config

--- @type terminale.utils.theme.Theme
local M = {}

--- Default window theme
--- @return terminale.utils.theme.WindowTheme
M.default_window_theme = function()
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.7)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	return {
		win_config = {
			title = "Terminale",
			width = width,
			height = height,
			row = row,
			col = col,
			relative = "editor",
			style = "minimal",
			border = "rounded",
		}
	}
end


return M
