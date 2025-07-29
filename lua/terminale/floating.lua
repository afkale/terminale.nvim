local buffer = require("terminale.buffer")
local theme = require("terminale.theme")

--- @class terminale.floating.Floating
--- @field windows terminale.floating.Window[]
--- @field last_index number
--- @field create fun(config: terminale.floating.FloatingConfig): terminale.floating.Window
--- @field get_last_index_window fun(): terminale.floating.Window|nil
--- @field is_window_valid fun(index: number): boolean
--- @field hide_window fun(index: number|nil)
--- @field close_window fun(index: number|nil)
--- @field toggle_window fun(index: number|nil)
--- @field show_window fun(index: number|nil)
--- @field toggle_or_setup fun(window: terminale.floating.Window)

--- @class terminale.floating.FloatingConfig
--- @field buf? number
--- @field win? number
--- @field hidden? boolean
--- @field focus? boolean
--- @field command? string
--- @field window_theme vim.api.keyset.win_config|string
--- @field on_enter? fun(window: terminale.floating.Window):nil
--- @field on_create? fun(window: terminale.floating.Window):nil

--- @class terminale.floating.Window
--- @field buf? number
--- @field win? number
--- @field index? number
--- @field focus boolean
--- @field hidden boolean
--- @field created boolean
--- @field win_config vim.api.keyset.win_config
--- @field on_enter fun(self):nil
--- @field on_create fun(self):nil
--- @field hide fun(self):nil
--- @field toggle fun(self):nil
--- @field show fun(self):nil
--- @field close fun(self):nil
--- @field setup fun(self):nil
--- @field exists fun(self):boolean

---@type terminale.floating.Floating
local M = { windows = {}, last_index = -1 }

-- This will remove the unavailable instances of windows stored in the windows state.
setmetatable(M.windows, { __mode = "v" })

--- This method should create a floating window.
--- @param config terminale.floating.FloatingConfig
--- @return terminale.floating.Window
function M.create(config)
	config.focus = config.focus == nil and true or config.focus
	config.hidden = config.hidden == nil and false or config.hidden

	return {
		buf = config.buf,
		focus = config.focus,
		hidden = config.hidden,
		created = not config.hidden,
		win_config = theme.get_window_theme(config.window_theme),
		on_create = config.on_create or function(self)
			vim.fn.jobstart(config.command, {
				term = true, on_exit = function() self:close() end
			})

			vim.api.nvim_create_autocmd("BufLeave", {
				buffer = self.buf,
				callback = function()
					if self.index ~= nil then self:hide() end
				end,
			})
		end,
		on_enter = config.on_enter or function() end,
		exists = function(self)
			return self.index ~= nil and M.windows[self.index] ~= nil
		end,
		hide = function(self)
			-- Check if the buffer is already hidden, if is hidden just drop it.
			if self.hidden then return end

			-- Hide the window if its valid.
			if vim.api.nvim_win_is_valid(self.win) then
				vim.api.nvim_win_hide(self.win)
			end

			self.hidden = true
		end,
		show = function(self)
			-- Check if the buffer is hidden, if is not hidden just drop it.
			if not self.hidden then return end

			-- Check if the buffer associated with the window is still valid
			if vim.api.nvim_buf_is_valid(self.buf) then
				-- If the window is not already created (e.g., hidden and never shown), open it with the saved configuration
				self.win = vim.api.nvim_open_win(self.buf, self.focus, self.win_config)

				-- If the window was never shown before (meaning 'created' is false), we will execute on_create callback
				if not self.created then
					self.on_create(self) -- Execute the user-defined or default 'on_create' function
					self.created = true -- Mark that the window has been created (so 'on_create' doesn't run again)
				end

				-- Perform actions when the user enters the floating window by calling the 'on_enter' callback
				self.on_enter(self)

				-- Change the 'hidden' status to false since the window is now visible
				self.hidden = false
			end
		end,
		toggle = function(self)
			if self.hidden then self:show() else self:hide() end
		end,
		close = function(self)
			-- Remove window from M.windows using the provided index
			if M.windows[self.index] == self then
				table.remove(M.windows, self.index)
			end

			-- Update last_index
			if M.last_index == self.index then
				if #M.windows == 0 then
					M.last_index = -1 -- No windows left
				else
					-- Update last_index to point to a valid window
					M.last_index = math.min(M.last_index, #M.windows)
				end
			end

			-- Destroy window index.
			self.index = nil

			-- Close the window and delete the buffer
			buffer.close_win(self.win)
			buffer.close_buf(self.buf, true)
		end,
		setup = function(self)
			-- Add the window to the list and get its index
			self.index = #M.windows + 1

			-- Create buffer and window.
			self.buf = buffer.create(self.buf)
			self.win = not self.hidden and vim.api.nvim_open_win(self.buf, true, self.win_config) or -1

			-- Execute on_enter and on_create methods
			if self.created then
				self.on_create(self)
				self.on_enter(self)
			end

			-- Save the window state and the the index as last_index_index
			M.last_index = self.index
			M.windows[self.index] = self
		end
	}
end

--- Function to validate a window index.
--- @param index number
--- @return boolean
function M.is_window_valid(index)
	local window = M.windows[index]

	if window and vim.api.nvim_buf_is_valid(window.buf) then
		return true
	else
		vim.notify(
			"ERROR: Invalid window state!",
			vim.log.levels.ERROR,
			{ title = "Floating Window Error", timeout = 5000 }
		)
		return false
	end
end

--- Return the last_index window used.
--- @return terminale.floating.Window|nil
function M.get_last_index_window()
	if not M.is_window_valid(M.last_index) then return end

	return M.windows[M.last_index]
end

--- Function to toggle a window by default this method should toggle the last_index window opened.
--- @param index? number
function M.toggle_window(index)
	index = index or M.last_index

	if not M.is_window_valid(index) then return end
	M.windows[index]:toggle()
end

--- Function to close a window by default this method should close the last_index window opened.
--- @param index? number
function M.close_window(index)
	index = index or M.last_index

	if not M.is_window_valid(index) then return end
	M.windows[index]:close()
end

--- Function to hide a window by default this method should hide the last_index window opened.
--- @param index? number
function M.hide_window(index)
	index = index or M.last_index

	if not M.is_window_valid(index) then return end
	M.windows[index]:hide()
end

--- Function to show a window by default this method should show the last_index window opened.
--- @param index? number
function M.show_window(index)
	index = index or M.last_index

	if not M.is_window_valid(index) then return end
	M.windows[index]:show()
end

--- Function to toggle or setup a window.
--- @param window terminale.floating.Window
function M.toggle_or_setup(window)
	if window:exists() then
		window:toggle()
	else
		window:setup()
		window:show()
	end
end

return M
