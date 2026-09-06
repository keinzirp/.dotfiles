local M = {}

local state = ya.sync(function()
	local selected = {}
	for _, file in pairs(cx.active.selected) do
		selected[#selected + 1] = file.url
	end
	return cx.active.current.cwd, selected
end)

local function repo_root(cwd)
	for _, command in ipairs({ { "git", { "rev-parse", "--show-toplevel" } }, { "jj", { "root" } } }) do
		local child = Command(command[1]):arg(command[2]):cwd(cwd):stdout(Command.PIPED):stderr(Command.PIPED):spawn()
		if child then
			local output = child:wait_with_output()
			if output and output.status.success then
				local root = output.stdout:gsub("%s+$", "")
				if root ~= "" then
					return root
				end
			end
		end
	end
	return cwd
end

function M:entry()
	ya.emit("escape", { visual = true })

	local cwd, selected = state()
	if cwd.spec.is_virtual then
		return ya.notify { title = "Repo fzf", content = "Not supported under virtual filesystems", timeout = 5, level = "warn" }
	end

	local root = Url(repo_root(tostring(cwd)))
	local permit = ui.hide()
	local output, err = M.run_with(root, selected)
	permit:drop()
	if not output then
		return ya.notify { title = "Repo fzf", content = tostring(err), timeout = 5, level = "error" }
	end

	local urls = M.split_urls(root, output)
	if #urls == 0 then
		return
	elseif #urls == 1 then
		local cha = #selected == 0 and fs.cha(urls[1])
		return ya.emit(cha and cha.is_dir and "cd" or "reveal", { urls[1], raw = true })
	end

	local files = {}
	for _, url in ipairs(urls) do
		files[#files + 1] = fs.file(url)
	end
	if #files > 0 then
		files.state = #selected > 0 and "off" or "on"
		ya.emit("toggle_all", files)
	end
end

function M.run_with(cwd, selected)
	local child, err = Command("fzf")
		:arg("-m")
		:cwd(tostring(cwd))
		:stdin(#selected > 0 and Command.PIPED or Command.INHERIT)
		:stdout(Command.PIPED)
		:spawn()
	if not child then
		return nil, Err("Failed to start `fzf`, error: %s", err)
	end

	for _, url in ipairs(selected) do
		child:write_all(string.format("%s\n", url))
	end
	if #selected > 0 then
		child:flush()
	end

	local output, output_err = child:wait_with_output()
	if not output then
		return nil, Err("Cannot read `fzf` output, error: %s", output_err)
	elseif not output.status.success and output.status.code ~= 130 then
		return nil, Err("`fzf` exited with error code %s", output.status.code)
	end
	return output.stdout, nil
end

function M.split_urls(cwd, output)
	local urls = {}
	for line in output:gmatch("[^\r\n]+") do
		local url = Url(line)
		urls[#urls + 1] = url.is_absolute and url or cwd:resolve(url)
	end
	return urls
end

return M
