hs.application.enableSpotlightForNameSearches(true)

local open_terminal = function()
	local app = hs.application.get('kitty')

	if app == nil then
		hs.application.open('kitty')
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
hs.hotkey.bind({ 'alt' }, 'space', open_chatgpt_prompt)
hs.hotkey.bind({ 'ctrl' }, 'space', open_terminal)

hs.hotkey.bind({}, 'f15', function()
	hs.caffeinate.lockScreen()
end)
