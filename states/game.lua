local enet = require 'enet'
local mp = require 'lib.msgpack'
local inspect = require 'lib.inspect'
local camera = require 'lib.hump.camera'
local entity_types = require 'ents.all'

local mt = {__index = {}}

local state = {
	field_width = 3200,
	field_height = 1000,
}

function mt.__index:collect_input()
	local x = 0
	if love.keyboard.isDown('left', 'a') then x = x - 1 end
	if love.keyboard.isDown('right', 'd') then x = x + 1 end
	--local jump_current = love.keyboard.isDown('up', 'space', 'w')
	--local jump = jump_current and not self.was_jumping
	--self.was_jumping = jump_current
	local jump = self.jump
	self.jump = false
	return {x = x, jump = jump}
end

function mt.__index:keypressed(key)
	if key == 'up' or key == 'space' or key == 'w' then
		self.jump = true
	end
end

function mt.__index:update(dt)
	local control_ent = self.entities[self.control_id]
	local event = self.host:service()

	while event do
		if event.type == 'receive' then
			local _, data = mp.unpack(event.data)
			-- print('client receive', inspect(data))
			if data.type == 'update' then
				-- data.last_seq
				for id, data in pairs(data.pack_data) do
					self.entities[id]:unpack(data, false)
				end
				local i = 1
				if control_ent then
					while i <= #self.predicted_moves do
						local move = self.predicted_moves[i]
						if data.last_seq >= move.seq then
							table.remove(self.predicted_moves, i)
						else
							i = i + 1
							control_ent:tick(
								move.dt,
								state,
								move.input,
								true)
						end
					end
				end
			elseif data.type == 'add' then
				local type_def = entity_types.from_id(data.typeid)
				local entity = type_def.client_mt.new()
				entity.id = data.id
				entity.type_def = type_def
				self.entities[data.id] = entity
				entity:unpack(data.pack, true)
			elseif data.type == 'remove' then
				self.entities[data.id] = nil
			elseif data.type == 'hello' then
				self.control_id = data.control_id
			end
		elseif event.type == 'connect' then
			print('client connect')
		elseif event.type == 'disconnect' then
			print('client disconnect')
		end

		event = self.host:service()
	end


	if self.peer:state() ~= 'connected' or not control_ent then
		return
	end

	local input = self:collect_input()
	self.input_sequence = self.input_sequence + 1
	self.peer:send(mp.pack {type = 'move', seq = self.input_sequence, dt = dt, input = input})
	if #self.predicted_moves < 50 then
		control_ent:tick(dt, state, input)
		self.predicted_moves[#self.predicted_moves + 1] = {
			seq = self.input_sequence,
			dt = dt,
			input = input,
		}
	end
end

function mt.__index:draw()
	-- update camera
	local control_ent = self.entities[self.control_id]
	if control_ent then

		local left = control_ent
		local right = control_ent
		local dest_x = (left.px + right.px) * 0.5 + 25
		dest_x = math.floor(dest_x + 0.5)
		local dest_scale = math.max(math.min((love.graphics.getWidth() - 200) / math.abs(left.px - right.px), 1), 0.5)

		self.camera:lockPosition(dest_x, state.field_height - (love.graphics.getHeight() * 0.3) / dest_scale)
		self.camera:zoomTo(dest_scale)
	end

	-- draw world
	self.camera:attach()

	love.graphics.setColor(100, 150, 200)
	love.graphics.rectangle('fill', 0, state.field_height, state.field_width, 100)
	love.graphics.setColor(255, 255, 255)

	for id, entity in pairs(self.entities) do
		entity:draw()
	end

	self.camera:detach()

	local peer_state = self.peer:state()

	if peer_state ~= 'connected' then
		love.graphics.print(peer_state, 5, 5)
	end
end

return function(address)
	local instance = setmetatable({}, mt)
	instance.host = assert(enet.host_create(nil, 1))
	instance.peer = instance.host:connect(address)
	instance.input_sequence = 0
	instance.predicted_moves = {}
	instance.control_id = 0
	instance.was_jumping = true
	instance.entities = {}
	instance.camera = camera(0, 0)
	instance.camera.smoother = camera.smooth.damped(5)
	return instance
end
