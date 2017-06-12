local util = require 'lib.util'
local checkcollision = util.checkcollision

local mt = {__index = {}}

function mt.__index:pack()
	return { -- everything that should be network synced
		self.px, self.py,
		self.vx, self.vy,
	}
end

local function stop_flying(self, x, other, state)
	if self.hit > 0 then
		if self.stop < 0 then
			self.hit = self.hit - 1
			self.stop = 0.1
			-- fire shake
			other:destroy(state)
		end
	else
		self.vx = 0
		self.vy = 0
		self.state = 'falling'
		self.px = x
		-- fire shake
	end
end

function mt.__index:server_tick(dt, state)
	if self.state == 'falling' or self.state == 'static' then
		self.life = self.life - dt
		self.vy = self.vy + dt * 500 -- gravity
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
					if self.state == 'falling' then
						self.state = 'static'
						-- fireShake
					end
				end
			end
		end

		if self.life > 0 then
			if self.py > state.field_height - 50 then
				self.py = state.field_height - 50
				self.vy = 0
			end
		elseif self.py >= state.field_height then
			state.remove_entity(state)
		end
	else
		self.stop = self.stop - dt

		if self.stop < 0 then
			self.px = self.px + dt * self.vx
		end

		for id, entity in pairs(state.entities) do
			if self ~= entity and entity.type_def == self.type_def then
				if checkcollision(self.px, self.py, 50, 50, entity.px, entity.py, 50, 50) then
					if entity.state ~= 'bullet' then
						if self.px < entity.px then
							stop_flying(self, entity.px - 50, entity, state)
						else
							stop_flying(self, entity.px + 50, entity, state)
						end
					else
						if math.random() > 0.5 then
							-- block explosion
						end
						entity:destroy(state)
					end
					break
				end
			end
		end

		if self.x < 0 then
			self:destroy(state)
			-- trigger left bound
		elseif self.x > state.field_width - 50 then
			self:destroy(state)
			-- trigger right bound
		end
	end

	--[[ should be on client
	if self.fadefx then
		self.fadefx = math.min(self.fadefx + dt, 1)
	else
		self.fadefx = 1
	end
	]]
end

function mt.__index:destroy(state)
	-- particle explosion
	state.remove_entity(self)
	-- play block_destroy sound
end

return mt
