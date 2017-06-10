local M = {}

-- Collision detection function.
-- Checks if a and b overlap.
-- w and h mean width and height.
function checkcollision(ax1,ay1,aw,ah, bx1,by1,bw,bh)
  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
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
		if checkcollision(self.px, my, 50, 50, v.px, v.py, 50, 50) then
			if my > self.py then
				self.vy = 0
				self.jumps = 3
				-- surfing
			end
			if my > v.py then
				my = v.py + 50
				self.vy = 0
			elseif my ~= v.py then
				my = v.py - 50
				self.vy = 0
			end
		end
	end

	local function checkhor(v)
		if checkcollision(mx, self.py, 50, 50, v.px, v.py, 50, 50) then
			if mx > v.px then
				mx = v.px + 50
			else
				mx = v.px - 50
			end
		end
	end

	for id, entity in pairs(state.entities) do
		if entity ~= self then
			checkhor(entity)
			checkvert(entity)
		end
	end

	self.px = mx
	self.py = my

	if self.px < 0 then
		self.px = 0
		self.vx = 0
	elseif self.px >= state.field_width - 50 then
		self.px = state.field_width - 50
		self.vx = 0
	end

	if self.py > state.field_height - 50 then
		self.py = state.field_height - 50
		self.vy = 0
		self.jumps = 3
	end
end

return M
