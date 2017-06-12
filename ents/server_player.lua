local player_shared = require 'ents.shared_player'
local mt = {__index = {}}

function mt.__index:pack(first)
	local data = { -- everything that should be network synced
		self.px, self.py,
		self.vx, self.vy,
		self.dir,
		self.jumps,
		self.holding,
	}
	if first then
		data.hue = self.hue
		data.sat = self.sat
		data.val = self.val
	end
	return data
end

function mt.__index:tick(dt, state, input)
	player_shared.tick(self, dt, state, input)
	-- anything else that should happen only on server
end

function mt.__index:on_jump()
end

function mt.__index:on_grab(entity)
	-- remove entity
end

return mt
