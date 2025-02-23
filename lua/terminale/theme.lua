--- @class terminale.theme.Theme
--- @field default_window_theme fun(): terminale.theme.WindowTheme

--- @class terminale.theme.WindowTheme
--- @field win_config vim.api.keyset.win_config

--- @type terminale.theme.Theme
local M = {}

--- Default window theme
--- @return terminale.theme.WindowTheme
M.default_window_theme = function()
	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.75)
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
			border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
		}
	}
end


return M
