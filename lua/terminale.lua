local M = {}

M.setup = function()
	-- WARN: this is only for testing purposes
	_G.floating = require("utils.floating")
	local theme = require("utils.theme")

	local window = floating.create({
		hidden = true,
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

	local toggle_lazyvim = function()
		if window:exists() then
			window:toggle()
		else
			window:build()
			window:show()
		end
	end

	vim.api.nvim_create_user_command("Lazygit2", toggle_lazyvim, {})
	vim.keymap.set({ "i", "n", "t" }, "<A-t>", "<CMD>Lazygit2<CR>", { noremap = true, silent = true })
end

return M
