local M = {}

M.setup = function()
	-- WARN: this is only for testing purposes
	local floating = require("utils.floating")
	local theme = require("utils.theme")

	floating.create({
		window_theme = theme.default_window_theme(),
		on_enter = function(window)
			vim.cmd("startinsert")
			vim.fn.termopen("lazygit", { on_exit = function() window:close() end, })
		end
	})
end

return M
