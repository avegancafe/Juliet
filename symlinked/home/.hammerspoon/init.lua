hs.application.enableSpotlightForNameSearches(true)

-- Terminal preference for the ctrl+space toggle: bundle IDs, comma- or
-- space-separated, first installed one wins. Set JULIET_TERMINALS in
-- ~/.config/local/.env (an extension's .env.template can seed it).
local DEFAULT_TERMINALS = 'com.mitchellh.ghostty'

-- Hammerspoon is a GUI app, so it doesn't inherit fish's environment: fall
-- back to reading the one key from ~/.config/local/.env directly.
local read_local_env = function(key)
	local file = io.open(os.getenv('HOME') .. '/.config/local/.env', 'r')
	if file == nil then
		return nil
	end

	local value = nil
	for line in file:lines() do
		local found = line:match('^' .. key .. '=(.*)$')
		if found ~= nil and found ~= '' then
			value = found
		end
	end
	file:close()
	return value
end

local terminal_bundle_id = function()
	local list = os.getenv('JULIET_TERMINALS') or read_local_env('JULIET_TERMINALS') or DEFAULT_TERMINALS
	local first = nil

	for id in list:gmatch('[^%s,]+') do
		first = first or id
		if hs.application.infoForBundleID(id) ~= nil then
			return id
		end
	end

	return first
end

local toggle_terminal = function()
	local bundle_id = terminal_bundle_id()
	local app = hs.application.get(bundle_id)

	if app == nil then
		hs.application.launchOrFocusByBundleID(bundle_id)
		return
	end

	if app:mainWindow() and app:isFrontmost() then
		app:hide()
	else
		app:activate()
	end
end

hs.hotkey.bind({ 'ctrl' }, 'space', toggle_terminal)

hs.hotkey.bind({}, 'f15', function()
	hs.caffeinate.lockScreen()
end)
