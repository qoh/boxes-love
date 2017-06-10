local enet = require 'enet'
local inspect = require 'lib.inspect'
local mp = require 'lib.msgpack'
local entity_types = require 'ents.all'
local player_server = require 'ents.server_player'

local M = {}

local host
local clients
local last_entity_id
local entities

local state = {
	field_width = 3200,
	field_height = 1000,
}

local function add_entity(entity)
	assert(entity.id == nil)
	local type_def = entity_types.from_server(entity)
	if type_def == nil then return end
	last_entity_id = last_entity_id + 1
	local id = last_entity_id
	entity.id = id
	entity.type_def = type_def
	entities[id] = entity
	for i = 1, host:peer_count() do
		local peer = host:get_peer(i)
		peer:send(mp.pack {
			type = 'add',
			id = id,
			typeid = type_def.id,
			pack = entity:pack(true)
		})
	end
end

local function remove_entity(entity)
	local id = entity.id
	assert(id ~= nil)
	assert(entities[id] == entity)
	entities[id] = nil
	entity.id = nil
	for i = 1, host:peer_count() do
		local peer = host:get_peer(i)
		peer:send(mp.pack {
			type = 'remove',
			id = id,
		})
	end
end

function M.start()
	if host ~= nil then
		M.stop()
	end
	host = assert(enet.host_create('*:8450'))
	clients = {}
	last_entity_id = 0
	entities = {}
	state.entities = entities

	for i = 1, 40 do
		if math.random() < 0.2 then
			add_entity(setmetatable({
				px = i * 50 - 50,
				py = 0,
				vx = 0,
				vy = 0,
			}, require('ents.server_block')))
		end
	end
end

function M.stop()
	-- TODO: disconnect clients
	last_entity_id = nil
	entities = nil
	clients = nil
	host = nil
	collectgarbage()
end

function M.is_running()
	return host ~= nil
end

function M.update(dt)
	if host == nil then
		return
	end

	local event = host:service()

	while event do
		local index = event.peer:index()

		if event.type == 'receive' then
			local _, data = mp.unpack(event.data)
			-- print('receive', event.peer:index(), inspect(data))
			if data.type == 'move' then
				clients[index].input_seq = data.seq
				local entity = entities[clients[index].control_id]
				entity:tick(data.dt, state, data.input)
			end
		elseif event.type == 'connect' then
			print('connect', event.peer:index())
			for id, entity in pairs(entities) do
				event.peer:send(mp.pack {
					type = 'add',
					id = id,
					typeid = entity.type_def.id,
					pack = entity:pack(true)
				})
			end
			local entity = setmetatable({
				id = id,
				px = 100,
				py = 100,
				vx = 0,
				vy = 0,
				dir = 1,
				jumps = 0,
			}, player_server)
			add_entity(entity)
			clients[index] = {
				control_id = entity.id,
				input_seq = 0,
			}
			event.peer:send(mp.pack {
				type = 'hello',
				control_id = entity.id
			})
		elseif event.type == 'disconnect' then
			print('disconnect', event.peer:index())
			local client = clients[index]
			local id = client.control_id
			remove_entity(entities[id])
			clients[index] = nil
		end

		event = host:service()
	end

	for id, entity in pairs(entities) do
		if entity.server_tick then
			entity:server_tick(dt, state)
		end
	end

	local pack_data = {}

	for id, entity in pairs(entities) do
		pack_data[id] = entity:pack(false)
	end

	for i = 1, host:peer_count() do
		local peer = host:get_peer(i)
		local client = clients[i]
		
		if client then
			peer:send(mp.pack {
				type = 'update',
				last_seq = client.input_seq,
				pack_data = pack_data,
			})
		end
	end
end

return M
