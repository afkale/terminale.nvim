_G.floating = require("utils.floating")

local M = {}

M.setup = function()
	-- WARN: this is only for testing purposes
	floating.create({
		win_config = {
			relative = "editor",
			row = 10,
			col = 10,
			width = 120,
			height = 40,
			style = "minimal",
			border = "rounded",
		},
		on_enter = function(window)
			vim.cmd("startinsert")
			vim.fn.termopen("lazygit", { on_exit = function() window:close() end, })
		end
	})
end

return M
