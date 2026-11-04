hs.application.enableSpotlightForNameSearches(true)

local REX_BUNDLE_ID = 'com.superlogical.rex'

local toggle_rex = function()
	local app = hs.application.get(REX_BUNDLE_ID)

	if app == nil then
		hs.application.launchOrFocusByBundleID(REX_BUNDLE_ID)
		return
	end

	if app:mainWindow() and app:isFrontmost() then
		app:hide()
	else
		app:activate()
	end
end

hs.hotkey.bind({ 'ctrl' }, 'space', toggle_rex)

hs.hotkey.bind({}, 'f15', function()
	hs.caffeinate.lockScreen()
end)
