local util = require 'lib.util'
local checkcollision = util.checkcollision

local M = {}

local PL_WIDTH = 50 -- 30
local PL_HEIGHT = 50 -- 30

local function grab(self, state)
	if self.holding or self.dead then
		return
	end

	for id, entity in pairs(state.entities) do
		local dx = (entity.px - (self.px + 50 * self.dir)) * self.dir
		local dy = math.abs(entity.py - self.py)

		if dx >= 0 and dx < 50 and dy < 25 then
			if entity.state ~= 'bullet' then
				self.holding = true
				self:on_grab(entity)
			end
		end
	end
end

function M:tick(dt, state, input, replay)
	self.vx = 500 * input.x -- left/right
	self.vy = self.vy + dt * 3000 -- gravity

	if input.x < 0 then
		self.dir = -1
	elseif input.x > 0 then
		self.dir = 1
	end

	if input.jump and self.jumps >= 1 then
		self.vy = -1200
		self.jumps = self.jumps - 1
		if not replay then
			self:on_jump()
		end
	end

	local mx = self.px + dt * self.vx
	local my = self.py + dt * self.vy

	local function checkvert(v)
		if checkcollision(self.px, my, PL_WIDTH, PL_HEIGHT, v.px, v.py, 50, 50) then
			self.vy = 0
			if my > self.py then
				self.jumps = 3
				-- surfing
			end
			if my > v.py then
				my = v.py + 50
			elseif my < v.py then
				my = v.py - PL_HEIGHT
			end
		end
	end

	local function checkhor(v)
		if checkcollision(mx, self.py, PL_WIDTH, PL_HEIGHT, v.px, v.py, 50, 50) then
			self.vx = 0
			if mx > v.px then
				mx = v.px + 50
			else
				mx = v.px - PL_WIDTH
			end
		end
	end

	local function checknew(v)
		local acx = mx + 25
		local acy = my + 25
		local bcx = v.px + 25
		local bcy = v.py + 25
		local dx = bcx - acx
		local dy = bcy - acy
		if math.abs(dx) >= 50 or math.abs(dy) >= 50 then
			return
		end
		if math.abs(dx) > math.abs(dy) then
			self.vx = 0
			if dx > 0 then
				mx = v.px - 50
			else
				mx = v.px + 50
			end
		else
			self.vy = 0
			if dy > 0 then
				my = v.py - 50
				self.jumps = 3
			else
				my = v.py + 50
			end
		end
	end

	for id, entity in pairs(state.entities) do
		if entity ~= self then
			checkhor(entity)
			checkvert(entity)
			--checknew(entity)
		end
	end

	self.px = mx
	self.py = my

	if self.px < 0 then
		self.px = 0
		self.vx = 0
	elseif self.px >= state.field_width - PL_WIDTH then
		self.px = state.field_width - PL_WIDTH
		self.vx = 0
	end

	if self.py > state.field_height - PL_HEIGHT then
		self.py = state.field_height -PL_HEIGHT
		self.vy = 0
		self.jumps = 3
	end

	if input.grab and input.grab_now then
		grab(self, state)
	end

	if self.holding and not input.grab then
		self.holding = false
		-- fire block
	end
end

return M
