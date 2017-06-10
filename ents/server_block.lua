local mt = {__index = {}}

function mt.__index:pack()
	return { -- everything that should be network synced
		self.px, self.py,
		self.vx, self.vy,
	}
end

function mt.__index:server_tick(dt, state)
	self.vy = self.vy + dt * 500 -- gravity

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
	end
end

return mt
