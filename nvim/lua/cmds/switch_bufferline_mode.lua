return function()
	if buffer_current_tabmode == 'tabs' then
		print('switching to buffer mode')
		require('cmds/setup_bufferline').setup('buffers')
		buffer_current_tabmode = 'buffers'
	else
		print('switching to tab mode')
		require('cmds/setup_bufferline').setup('tabs')
		buffer_current_tabmode = 'tabs'
	end
end
