return function ()
	if buffer_current_tabmode == "tabs" then
		require("cmds/setup_bufferline").setup("buffers")
		buffer_current_tabmode = "buffers"
	else
		require("cmds/setup_bufferline").setup("tabs")
		buffer_current_tabmode = "tabs"
	end
end
