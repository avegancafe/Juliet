hs.application.enableSpotlightForNameSearches(true)

local open_terminal = function()
	local app = hs.application.get('ghostty')

	if app == nil then
		hs.application.open('ghostty')
		return
	end

	if not app:mainWindow() then
		app:selectMenuItem({ 'Shell', 'New OS Window' })
	elseif app:isFrontmost() then
		app:hide()
	else
		app:activate()
	end
end

local open_chatgpt_prompt = function()
	local app = hs.application.get('ChatGPT')

	if app == nil then
		hs.application.open('ChatGPT')
	end

	hs.eventtap.event.newKeyEvent(hs.keycodes.map.alt, true):post()
	hs.eventtap.event.newKeyEvent(hs.keycodes.map.shift, true):post()
	hs.eventtap.event.newKeyEvent(hs.keycodes.map.space, true):post()
	hs.eventtap.event.newKeyEvent(hs.keycodes.map.space, false):post()
	hs.eventtap.event.newKeyEvent(hs.keycodes.map.shift, true):post()
	hs.eventtap.event.newKeyEvent(hs.keycodes.map.alt, false):post()
end

hs.hotkey.bind({}, 'f14', open_chatgpt_prompt)
hs.hotkey.bind({ 'option' }, 'space', open_chatgpt_prompt)
hs.hotkey.bind({ 'ctrl' }, 'space', open_terminal)

local focus_waiting_claude = function()
	local app = hs.application.get('ghostty')
	if app == nil then return end

	local menuItems = app:getMenuItems()
	if menuItems == nil then return end

	for _, menu in ipairs(menuItems) do
		if menu.AXTitle == "Window" and menu.AXChildren and menu.AXChildren[1] then
			for _, item in ipairs(menu.AXChildren[1]) do
				local title = item.AXTitle or ""
				if title:lower():find("claude") and title:find("\u{2733}") then
					app:activate()
					app:selectMenuItem({ "Window", title })
					return
				end
			end
		end
	end
end

hs.hotkey.bind({ 'option' }, 'c', focus_waiting_claude)

hs.hotkey.bind({}, 'f15', function()
	hs.caffeinate.lockScreen()
end)
