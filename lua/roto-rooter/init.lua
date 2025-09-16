local M = {}
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

local function get_project_root(patterns, fallback)
	local buftype = vim.bo.buftype
	local bufname = vim.api.nvim_buf_get_name(0)
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
	local file_dir = vim.fn.expand("%:p:h")
	if file_dir == "" then
		return
	end

	local cwd = vim.fn.getcwd()
	local project_root = find_project_root(file_dir, patterns)
	if project_root then
		return project_root
	elseif fallback then
		return cwd
	else
		return file_dir
	end
end

local function get_relative_dir()
	local cwd = vim.fn.getcwd()
	local filepath = vim.fn.expand("%:p")

	local default = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	if filepath == "" then
		return default
	end
	local buftype = vim.bo.buftype
	local bufname = vim.api.nvim_buf_get_name(0)
	if buftype ~= "" then
		return default
	end
	-- Must have a real file path (starts with /)
	if bufname == "" or not bufname:match("^/") then
		return default
	end
	-- Must be a readable file
	if vim.fn.filereadable(bufname) == 0 then
		return default
	end

	-- Get the directory of the current file
	local filedir = vim.fn.fnamemodify(filepath, ":h")
	-- Use vim's built-in function to get relative path
	local relative_path = vim.fn.fnamemodify(filedir, ":~:.")
	-- If the file is in the cwd, return just the basename of cwd
	if relative_path == "." then
		return vim.fn.fnamemodify(cwd, ":t")
	end

	-- If relative_path starts with '~/', convert to absolute then back to relative from home
	if string.sub(relative_path, 1, 2) == "~/" then
		-- Convert cwd to relative from home
		local cwd_from_home = vim.fn.fnamemodify(cwd, ":~")
		if string.sub(cwd_from_home, 1, 2) == "~/" then
			cwd_from_home = string.sub(cwd_from_home, 3)
		else
			cwd_from_home = vim.fn.fnamemodify(cwd, ":t")
		end
		-- Remove ~/ from relative_path
		relative_path = string.sub(relative_path, 3)

		return cwd_from_home .. "/" .. relative_path
	end

	if relative_path == "" or relative_path == "." then
		return default
	else
		return relative_path
	end
end

local function create_autocmd(cmd, patterns, fallback)
	return vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter", "BufWinEnter" }, {
		callback = function()
			if not is_enabled then
				return
			end
			local root = get_project_root(patterns, fallback)
			if root then
				vim.cmd(cmd .. " " .. vim.fn.fnameescape(root))
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
	create_autocmd(cmd, patterns, fallback)
	-- Create user commands
	vim.api.nvim_create_user_command("RRlcd", function()
		local root = get_project_root(patterns, fallback)
		if root then
			vim.cmd("lcd " .. vim.fn.fnameescape(root))
		end
		print(root .. " detected as project root directory")
	end, {})
	vim.api.nvim_create_user_command("RRcd", function()
		local root = get_project_root(patterns, fallback)
		if root then
			vim.cmd("cd " .. vim.fn.fnameescape(root))
		end
		print(root .. " detected as project root directory")
	end, {})
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
	vim.api.nvim_create_user_command("GetRelativeDir", function()
		print(get_relative_dir())
	end, {})

	-- Make function globally available
	_G.RRget_relative_dir = get_relative_dir
end

-- Export the relative dir function for external use
M.RRget_relative_dir = get_relative_dir

return M
