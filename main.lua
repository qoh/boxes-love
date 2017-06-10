local gamestate = require 'lib.hump.gamestate'
local menu = require 'states.menu'
local server = require 'server'

function love.load()
	gamestate.registerEvents()
	gamestate.switch(menu)
end

function love.update(dt)
	server.update(dt)
end

function love.draw()
	if server.is_running() then
		love.graphics.push('all')
		love.graphics.setColor(0, 255, 0)
		local w, h = love.graphics.getDimensions()
		local fh = love.graphics.getFont():getHeight()
		love.graphics.printf('server active',
			5, h - fh - 5, w - 10, 'right')
		love.graphics.pop()
	end
end

function love.quit()
	server.stop()
end
