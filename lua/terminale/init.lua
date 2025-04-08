local M = {}

M.setup = function(user_opts)
	local opts = user_opts or {}

	-- Default options with a flexible configuration for multiple commands
	opts = vim.tbl_deep_extend("force", {
		lazygit = {
			hidden = true,
			window_theme = require("terminale.theme").default_window_theme(),
			command = "lazygit",
			user_command = "Lazygit",
			on_create = function(window)
				local lazygit_config_dir = vim.fn.stdpath("config") .. "/lazygit"
				local lazygit_command = "lazygit --use-config-dir " .. lazygit_config_dir

				vim.fn.termopen(lazygit_command, { on_exit = function() window:close() end })
			end,
			on_enter = function() vim.cmd("startinsert") end,
			keymap = {
				{
					cmd = "<leader>gg",
					mode = { "n", "t" },
					key = "<CMD>Lazygit<CR>",
				},
			},
		},
		btop = {
			hidden = true,
			window_theme = require("terminale.theme").default_window_theme(),
			command = "btop",
			user_command = "Btop",
			on_create = function(window)
				vim.fn.termopen("btop", { on_exit = function() window:close() end })
			end,
			on_enter = function() vim.cmd("startinsert") end,
			keymap = {
				{
					cmd = "<A-b>",
					mode = { "n", "t" },
					key = "<CMD>Btop<CR>",
				},
			},
		},
		term = {
			hidden = true,
			window_theme = require("terminale.theme").default_window_theme(),
			user_command = "Term",
			on_create = function(window)
				vim.fn.termopen("fish", { on_exit = function() window:close() end })
			end,
			on_enter = function() vim.cmd("startinsert") end,
			keymap = {
				{
					cmd = "<A-1>",
					mode = { "n", "t" },
					key = "<CMD>Term<CR>",
				},
			},
		},
	}, opts)

	local floating = require("terminale.floating")

	for _, config in pairs(opts) do
		local window = floating.create({
			hidden = config.hidden,
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
