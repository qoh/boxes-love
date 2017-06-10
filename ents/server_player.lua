local player_shared = require 'ents.shared_player'
local mt = {__index = {}}

function mt.__index:pack()
	return { -- everything that should be network synced
		self.px, self.py,
		self.vx, self.vy,
		self.dir,
		self.jumps,
	}
end

function mt.__index:tick(dt, state, input)
	player_shared.tick(self, dt, state, input)
	-- anything else that should happen only on server
end

function mt.__index:on_jump()
end

return mt
