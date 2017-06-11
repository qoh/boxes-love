local util = require 'lib.util'
local checkcollision = util.checkcollision

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

	for id, entity in pairs(state.entities) do
		if self ~= entity and entity.type_def == self.type_def then
			if checkcollision(self.px, self.py, 50, 50, entity.px, entity.py, 50, 50) then -- and not a bullet
				if self.py > entity.py then
					self.py = entity.py + 50
				else
					self.py = entity.py - 50
				end
				self.vy = 0
				if false then -- falling
					-- set to static
					-- fireShake
				end
			end
		end
	end

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
