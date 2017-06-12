local menu = {}
local server = require 'server'
local gamestate = require 'lib.hump.gamestate'
local gamefactory = require 'states.game'

local text = [[Press Q to quit
Press W to host a game
Press E to join a game]]

function menu:keypressed(key)
	if key == 'q' then
		love.event.quit()
	elseif key == 'w' then
		server.start()
		gamestate.switch(gamefactory('localhost:8450'))
	elseif key == 'e' then
		gamestate.switch(gamefactory('nssm.me:8450'))
	end
end

function menu:draw()
	love.graphics.printf(text, 50, 50, love.graphics.getWidth() - 100)
end

return menu
