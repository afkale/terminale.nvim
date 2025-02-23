--- @class terminale.buffer.Buffer
--- @field create fun(buf: number|nil): number
--- @field close_win fun(win: number): nil
--- @field close_buf fun(buf: number, force: boolean): nil

--- @type terminale.buffer.Buffer
local M = {}

--- This function validates a buffer. If the buffer is not valid, it returns a new valid buffer.
--- @param buf number|nil The buffer ID to validate (or nil to create a new one).
--- @return number buffer The validated or newly created buffer ID.
M.create = function(buf)
	buf = buf or -1

	-- Test if the buffer is valid.
	if buf and vim.api.nvim_buf_is_valid(buf) then
		return buf
	end

	-- If the buffer is not valid return a new one.
	return vim.api.nvim_create_buf(false, true)
end

--- Close window if valid.
--- @param win number
M.close_win = function(win)
	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
end

--- Close buffer if valid.
---@param buf number
---@param force boolean
M.close_buf = function(buf, force)
	if vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_buf_delete(buf, { force = force })
	end
end

return M
