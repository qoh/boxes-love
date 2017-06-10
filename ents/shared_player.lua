local M = {}

local field_width = 400
local field_height = 400

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

	self.px = self.px + dt * self.vx
	self.py = self.py + dt * self.vy

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
