local M = {}

M.setup = function(user_opts)
	local opts = user_opts or {}

	-- Default options with a flexible configuration for multiple commands
	opts = vim.tbl_deep_extend("force", {
		term = {
			hidden = true,
			window_theme = "default",
			command = "fish -i",
			user_command = "Term",
			on_enter = function() vim.cmd("startinsert") end,
			keymap = {
				{
					cmd = "<A-1>",
					mode = { "n", "t" },
					key = "<CMD>Term<CR>",
				},
			},
		},
		boterm = {
			hidden = true,
			window_theme = "bottom",
			command = "fish -i",
			user_command = "Boterm",
			on_enter = function() vim.cmd("startinsert") end,
			keymap = {
				{
					cmd = "<A-2>",
					mode = { "n", "t" },
					key = "<CMD>Boterm<CR>",
				},
			},
		},
	}, opts)

	local floating = require("terminale.floating")

	for _, config in pairs(opts) do
		local window = floating.create({
			hidden = config.hidden,
			command = config.command,
			window_theme = config.window_theme,
			on_create = config.on_create,
			on_enter = config.on_enter
		})

		vim.api.nvim_create_user_command(config.user_command, function()
			floating.toggle_or_setup(window)
		end, {})

		for _, keymap in ipairs(config.keymap) do
			vim.keymap.set(keymap.mode, keymap.cmd, keymap.key, {
				noremap = true,
				silent = true,
			})
		end
	end
end

return M
