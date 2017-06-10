local mt = {__index = {}}

local image_block = love.graphics.newImage('assets/images/block.png')
image_block:setFilter('nearest', 'nearest')

function mt.new()
	return setmetatable({
	}, mt)
end

function mt.__index:unpack(data)
	self.px = data[1]
	self.py = data[2]
	self.vy = data[4]
end

function mt.__index:draw()
	love.graphics.setColor(100, 150, 200)
	love.graphics.draw(image_block, self.px, self.py, 0, 2)
	love.graphics.setColor(255, 255, 255)
end

return mt
