--- A status line for Yazi: the path of the hovered file on the left, and on the right the owner,
--- the modification time and, optionally, the output of `starship prompt` for the current folder.
---
--- Setup, in init.lua:
---
---   require("starship"):setup()
---   require("starship"):setup {
---     starship = true,                          -- run `starship prompt` for the folder, off by default
---     starship_config = "~/.config/starship/yazi.toml",  -- its own STARSHIP_CONFIG, optional
---     owner = true,                             -- the owner and the group
---     mtime = true,                             -- the modification time
---   }

local config = { starship = false, starship_config = nil, owner = true, mtime = true }

local set_state = ya.sync(function(state, data)
	for k, v in pairs(data) do
		state[k] = v
	end

	ui.render()
end)

local get_state = ya.sync(function(state)
	return state
end)



local expand_home = function(path)
	local home = os.getenv("HOME") or ""
	return (path:gsub("^~", home))
end

local emit_state = function(state)
	local cwd = cx.active.current.cwd
	state.cwd = cwd
	-- refresh the state
	ya.emit("plugin", {
		state._id,
		ya.quote(tostring(cwd), true),
	})
end

-- The code that runs async, as `entry` does, has a Lua state of its own, where `setup` has not run, so
-- it asks the main state for the option that it needs. `ya.sync` runs its function in the main state
local get_starship_config = ya.sync(function(state)
	return state.starship_config
end)

-- the prompt of starship for the folder, kept in the state
local load_state = function(cwd)
	local command = Command("starship")
		:stdin(Command.INHERIT)
		:env("STARSHIP_SHELL", "")
		:arg("prompt")
		:cwd(cwd)
	local starship_config = get_starship_config()
	if starship_config then
		command = command:env("STARSHIP_CONFIG", expand_home(starship_config))
	end

	local output = command:output()
	-- sanitize the output
	if output and output.status.success then
		set_state({ prompt = output.stdout:gsub("^%s+", ""):gsub("%s+$", "") })
	else
		set_state({ prompt = nil })
	end
end

local get_path = function(self)
	local home = os.getenv("HOME") or ""
	local file = self._current.hovered
	if not file then
		return ""
	end

	local prefix = " "
	local path = file.url
	-- make the path pretty
	if path:starts_with(home) then
		prefix = prefix .. "~/"
		path = path:strip_prefix(home)
	end

	return ui.Span(prefix .. ui.printable(tostring(path))):style(th.mgr.cwd)
end

local get_mtime = function(self)
	local file = self._current.hovered
	if not file then
		return ""
	end

	if not file.cha.mtime then
		return ""
	end

	local time = os.date("%Y-%m-%d %H:%M", file.cha.mtime // 1)
	return ui.printable(time .. " ")
end

local get_owner = function(self)
	local file = self._current.hovered
	if not file then
		return ""
	end

	if not file.cha.uid or not file.cha.gid then
		return ""
	end

	local user = ya.user_name(file.cha.uid) or file.cha.uid
	local group = ya.group_name(file.cha.gid) or file.cha.gid
	local owner = string.format("%s:%s", user, group)

	return ui.printable(" " .. owner .. " ")
end

local get_info = function()
	-- we need the state
	local state = get_state()
	local prompt = state["prompt"]
	-- return the prompt
	return ui.Line.parse(prompt or "")
end

return {
	setup = function(state, opts)
		for k, v in pairs(opts or {}) do
			config[k] = v
		end
		-- for the code that runs async, see get_starship_config
		state.starship_config = config.starship_config

		-- left status
		Status.name = get_path
		-- right status
		if config.owner then
			Status:children_add(get_owner, 1300, Status.RIGHT)
		end
		if config.mtime then
			Status:children_add(get_mtime, 1400, Status.RIGHT)
		end

		if not config.starship then
			return
		end
		Status:children_add(get_info, 1500, Status.RIGHT)

		-- the prompt only changes with the folder, so it is made again when the folder changes, and
		-- not on every hover
		local handle = function()
			local cwd = tostring(cx.active.current.cwd)
			if state.last == cwd then
				return
			end
			state.last = cwd
			emit_state(state)
		end
		ps.sub("cd", handle)
		ps.sub("tab", handle)
		ps.sub("hover", handle)
	end,
	entry = function(_, job)
		local cwd = job.args[1]
		-- load the state
		load_state(cwd)
	end,
}
