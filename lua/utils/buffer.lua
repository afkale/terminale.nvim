--- @class terminale.utils.buffer.Buffer
--- @field create fun(buf: number|nil): number

--- @type terminale.utils.buffer.Buffer
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

return M
