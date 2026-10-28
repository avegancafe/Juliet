hs.application.enableSpotlightForNameSearches(true)

local open_terminal = function()
	local app = hs.application.get('cmux')

	if app == nil then
		hs.application.open('cmux')
		return
	end

	if not app:mainWindow() then
		app:selectMenuItem({ 'File', 'New Window' })
	elseif app:isFrontmost() then
		app:hide()
	else
		app:activate()
	end
end

hs.hotkey.bind({ 'ctrl' }, 'space', open_terminal)

local focus_waiting_claude = function()
	print("[focus_waiting_claude] fired")
	local app = hs.application.get('cmux')
	if app == nil then
		print("[focus_waiting_claude] cmux app not found")
		return
	end

	local menuItems = app:getMenuItems()
	if menuItems == nil then
		print("[focus_waiting_claude] menuItems is nil")
		return
	end

	for _, menu in ipairs(menuItems) do
		if menu.AXTitle == "Window" and menu.AXChildren and menu.AXChildren[1] then
			for _, item in ipairs(menu.AXChildren[1]) do
				local title = item.AXTitle or ""
				print(string.format("[focus_waiting_claude] window title: %q", title))
				if title:lower():find("claude") and title:find("\u{2733}") then
					app:activate()
					app:selectMenuItem({ "Window", title })
					return
				end
			end
		end
	end
	print("[focus_waiting_claude] no matching window found")
end

hs.hotkey.bind({ 'option' }, 'c', focus_waiting_claude)

hs.hotkey.bind({}, 'f15', function()
	hs.caffeinate.lockScreen()
end)
