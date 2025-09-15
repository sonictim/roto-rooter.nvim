local M = {}

local autocmd_id = nil
local is_enabled = true

local function find_project_root(start_dir, patterns)
	local dir = start_dir

	while dir ~= "/" do
		for _, pattern in ipairs(patterns) do
			local path = dir .. "/" .. pattern
			if vim.fn.isdirectory(path) == 1 or vim.fn.filereadable(path) == 1 then
				return dir
			end
		end
		dir = vim.fn.fnamemodify(dir, ":h")
	end

	return nil
end

local function create_autocmd(cmd, patterns, fallback)
	return vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter", "BufWinEnter" }, {
		callback = function()
			if not is_enabled then
				return
			end
			local buftype = vim.bo.buftype
			local bufname = vim.api.nvim_buf_get_name(0)
			-- local filetype = vim.bo.filetype
			-- Must be a normal buffer (no special buftype)
			if buftype ~= "" then
				return
			end

			-- Must have a real file path (starts with /)
			if bufname == "" or not bufname:match("^/") then
				return
			end

			-- Must be a readable file
			if vim.fn.filereadable(bufname) == 0 then
				return
			end
			local current_dir = vim.fn.getcwd()
			local file_dir = vim.fn.expand("%:p:h")
			if file_dir == "" then
				return
			end

			vim.cmd(cmd .. " " .. vim.fn.fnameescape(file_dir))

			local project_root = find_project_root(file_dir, patterns)

			if project_root then
				vim.cmd(cmd .. " " .. vim.fn.fnameescape(project_root))
			elseif fallback then
				vim.cmd(cmd .. " " .. vim.fn.fnameescape(current_dir))
			end
		end,
	})
end

function M.setup(opts)
	opts = opts or {}
	local cmd = opts.global and "cd" or "lcd"
	local fallback = opts.fallback_to_current

	local default_patterns = { ".git", "package.json", "Cargo.toml", "go.mod", "Makefile", "pyproject.toml" }
	local patterns = opts.patterns or default_patterns

	if opts.extend_defaults then
		patterns = vim.tbl_extend("force", default_patterns, opts.extend_defaults)
	end

	-- Create the autocmd
	autocmd_id = create_autocmd(cmd, patterns, fallback)

	-- Create user commands
	vim.api.nvim_create_user_command("RREnable", function()
		is_enabled = true
		print("Roto-Rooter enabled")
	end, {})

	vim.api.nvim_create_user_command("RRDisable", function()
		is_enabled = false
		print("Roto-Rooter disabled")
	end, {})

	vim.api.nvim_create_user_command("RRToggle", function()
		is_enabled = not is_enabled
		print("Roto-Rooter " .. (is_enabled and "enabled" or "disabled"))
	end, {})
end

return M
