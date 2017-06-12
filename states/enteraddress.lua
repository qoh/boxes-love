return function(menu)
	local enteraddress = {}
	local gamestate = require 'lib.hump.gamestate'
	local gamefactory = require 'states.game'

	local text = [[Copy address to connect to and press Return

Press L to connect to localhost
Press N to connect to nssm.me

Press Escape to go back]]

	function enteraddress:keypressed(key)
		local address

		if key == 'escape' then
			gamestate.switch(menu)
		elseif key == 'return' then
			address = love.system.getClipboardText()
		elseif key == 'l' then
			address = 'localhost'
		elseif key == 'n' then
			address = 'nssm.me'
		end

		if address ~= nil then
			if string.find(address, ':') == nil then
				address = address .. ':8450'
			end
			gamestate.switch(gamefactory(address))
		end
	end

	function enteraddress:draw()
		love.graphics.printf(text, 50, 50, love.graphics.getWidth() - 100)
	end

	return enteraddress
end
