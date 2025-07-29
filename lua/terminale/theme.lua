--- @class terminale.theme.Theme
--- @field themes vim.api.keyset.win_config[]
--- @field default_window_theme fun(): vim.api.keyset.win_config
--- @field bottom_window_theme fun(): vim.api.keyset.win_config
--- @field get_window_theme fun(theme: vim.api.keyset.win_config | string): vim.api.keyset.win_config

--- @type terminale.theme.Theme
local M = {}

--- @return vim.api.keyset.win_config
M.default_window_theme = function()
	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.75)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	return {
		title = "Terminale",
		width = width,
		height = height,
		row = row,
		col = col,
		relative = "editor",
		style = "minimal",
		border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
	}
end

M.bottom_window_theme = function()
	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.25)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = vim.o.lines - height - 4

	return {
		title = "Terminale",
		width = width,
		height = height,
		row = row,
		col = col,
		relative = "editor",
		style = "minimal",
		border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
	}
end

M.get_window_theme = function(theme)
	if type(theme) == "string" then
		return M.themes[theme]
	end
	return theme
end

M.themes = {
	default = M.default_window_theme(),
	bottom = M.bottom_window_theme()
}

return M
