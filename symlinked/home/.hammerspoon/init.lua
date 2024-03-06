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

local open_neovide = function()
	local app = hs.application.get('Neovide')

	if app == nil then
		hs.application.open('Neovide')
		return
	end

	if app:isFrontmost() then
		app:hide()
	else
		app:activate()
	end
end

hs.hotkey.bind({}, 'f14', open_neovide)
hs.hotkey.bind({ 'ctrl' }, 'space', open_terminal)

hs.hotkey.bind({}, 'f15', function()
	hs.caffeinate.lockScreen()
end)
