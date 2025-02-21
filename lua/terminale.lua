local M = {}

M.setup = function()
	-- WARN: this is only for testing purposes
	_G.floating = require("utils.floating")
	local theme = require("utils.theme")

	local window = floating.create({
		window_theme = theme.default_window_theme(),
		on_create = function(window)
			vim.keymap.set({ "n", "i" }, "<C-h>", function() window:hide() end,
				{ buffer = window.buf, noremap = true, silent = true })
			vim.keymap.set({ "n", "i" }, "<C-x>", function() window:close() end,
				{ buffer = window.buf, noremap = true, silent = true })

			vim.fn.termopen("lazygit", { on_exit = function() window:close() end })
		end,
		on_enter = function() vim.cmd("startinsert") end
	})

	local toggle_lazvim = function()

	end
end

return M
