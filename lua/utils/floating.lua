local buffer = require("utils.buffer")

--- @class terminale.utils.floating.Floating
--- @field windows terminale.utils.floating.Window[]
--- @field last number
--- @field create fun(config: terminale.utils.floating.FloatingConfig): terminale.utils.floating.Window
--- @field get_last_window fun(): terminale.utils.floating.Window|nil
--- @field is_window_valid fun(index: number): boolean
--- @field hide_window fun(index: number|nil)
--- @field close_window fun(index: number|nil)
--- @field show_window fun(index: number|nil)

--- @class terminale.utils.floating.FloatingConfig
--- @field buf? number
--- @field win? number
--- @field hidden? boolean
--- @field window_theme terminale.utils.theme.WindowTheme
--- @field on_enter? fun(window: terminale.utils.floating.Window):nil
--- @field on_create? fun(window: terminale.utils.floating.Window):nil

--- @class terminale.utils.floating.Window
--- @field buf number
--- @field win number
--- @field index number
--- @field win_config vim.api.keyset.win_config
--- @field hide fun(self):nil
--- @field show fun(self):nil
--- @field close fun(self):nil

---@type terminale.utils.floating.Floating
local M = {
	windows = {},
	last = -1
}

--- This method should create a floating window.
--- @param config terminale.utils.floating.FloatingConfig
--- @return terminale.utils.floating.Window
M.create = function(config)
	-- Create window and buffer
	local buf = buffer.create(config.buf)
	local win = not config.hidden and vim.api.nvim_open_win(buf, true, config.window_theme.win_config) or -1
	local on_enter = config.on_enter or function() end
	local on_create = config.on_create or function() end

	-- Add the window to the list and get its index
	local index = #M.windows + 1

	--- @type terminale.utils.floating.Window
	local window = {
		buf = buf,
		win = win,
		index = index,
		hidden = config.hidden or false,
		created = not config.hidden,
		win_config = config.window_theme.win_config,
		hide = function(self)
			if vim.api.nvim_win_is_valid(self.win) then
				vim.api.nvim_win_hide(self.win)
				self.hidden = true
			end
		end,
		show = function(self)
			-- Check if the buffer associated with the window is still valid
			if vim.api.nvim_buf_is_valid(self.buf) then
				-- If the window is not already created (e.g., hidden and never shown), open it with the saved configuration
				self.win = vim.api.nvim_open_win(self.buf, true, self.win_config)

				-- If the window was never shown before (meaning 'created' is false), we will execute on_create callback
				if not self.created then
					on_create(self) -- Execute the user-defined or default 'on_create' function
					self.created = true -- Mark that the window has been created (so 'on_create' doesn't run again)
				end

				-- Perform actions when the user enters the floating window by calling the 'on_enter' callback
				on_enter(self)

				-- Change the 'hidden' status to false since the window is now visible
				self.hidden = false
			end
		end,

		toggle = function(self)
			if self.hidden then
				self:show()
			else
				self:hide()
			end
		end,
		close = function(self)
			-- Close the window and delete the buffer
			if vim.api.nvim_win_is_valid(self.win) then
				vim.api.nvim_win_close(self.win, true)
			end
			if vim.api.nvim_buf_is_valid(self.buf) then
				vim.api.nvim_buf_delete(self.buf, { force = true })
			end

			-- Remove window from M.windows using the provided index
			if M.windows[self.index] == self then
				table.remove(M.windows, self.index)
			end

			-- Update last
			M.last = #M.windows
		end
	}

	-- Execute on_enter method
	if window.created then
		on_create(window)
		on_enter(window)
	end

	-- Save the window state and the the index as last_index
	M.last = index
	M.windows[index] = window

	return window
end


--- Function to validate a window index.
--- @param index number
--- @return boolean
M.is_window_valid = function(index)
	local window = M.windows[index]

	if window and vim.api.nvim_buf_is_valid(window.buf) then
		return true
	else
		vim.notify(
			"Warning: Invalid window state!",
			vim.log.levels.WARN,
			{ title = "Floating Window Error", timeout = 5000 }
		)
		return false
	end
end

--- Return the last window used.
--- @return terminale.utils.floating.Window|nil
M.get_last_window = function()
	if not M.is_window_valid(M.last) then return end

	return M.windows[M.last]
end

--- Function to close a window by default this method should close the last window opened.
--- @param index number|nil
M.close_window = function(index)
	index = index or M.last

	if not M.is_window_valid(index) then return end
	M.windows[index]:close()
end

--- Function to hide a window by default this method should hide the last window opened.
--- @param index number|nil
M.hide_window = function(index)
	index = index or M.last

	if not M.is_window_valid(index) then return end
	M.windows[index]:hide()
end

--- Function to show a window by default this method should show the last window opened.
--- @param index number|nil
M.show_window = function(index)
	index = index or M.last

	if not M.is_window_valid(index) then return end
	M.windows[index]:show()
end

return M
