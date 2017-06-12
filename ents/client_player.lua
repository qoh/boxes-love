local player_shared = require 'ents.shared_player'
local util = require 'lib.util'

local mt = {__index = {}}

local sound_jump = love.audio.newSource('assets/sounds/player-jump.wav')
local image_player = love.graphics.newImage('assets/images/player.png')
image_player:setFilter('nearest', 'nearest')

-- this is a duplicate
local image_block = love.graphics.newImage('assets/images/block.png')
image_block:setFilter('nearest', 'nearest')

function mt.new()
	return setmetatable({
		glow = 0,
	}, mt)
end

function mt.__index:unpack(data, first)
	self.px = data[1]
	self.py = data[2]
	self.vx = data[3]
	self.vy = data[4]
	self.dir = data[5]
	self.jumps = data[6]
	self.holding = data[7]
	if first then
		self.hue = data.hue
		self.sat = data.sat
		self.val = data.val
	end
end

function mt.__index:tick(dt, state, input, replay)
	player_shared.tick(self, dt, state, input, replay)
end

function mt.__index:client_update(dt)
	self.glow = self.glow + 5 * dt
end

function mt.__index:on_jump()
	sound_jump:clone():play()
end

function mt.__index:on_grab()
end

function mt.__index:draw()
	local hue = self.hue
	local sat = self.sat
	local value = self.val
	local glow = math.max((math.sin(self.glow) + 0.5) * 20, 0)

	local px = self.px -- 10
	local py = self.py -- 10

	love.graphics.setColor(util.hsl(hue, sat, math.min(value + glow, 255)))
	love.graphics.draw(image_player, px, py, 0, 2)

	if self.holding then
		love.graphics.draw(image_block, self.px + 50 * self.dir, self.py, 0, 2)
	else
		love.graphics.circle('fill', px + 25 + 35 * self.dir, py + 25, 2)
	end

	love.graphics.setColor(255, 255, 255)
end

return mt
