local last_type_id = 0
local type_by_id = {}
local type_by_server_mt = {}

local function register(name)
	last_type_id = last_type_id + 1

	local type_def = {
		id = last_type_id,
		name = name,
		server_mt = require('ents.server_' .. name),
		client_mt = require('ents.client_' .. name),
	}

	type_by_id[type_def.id] = type_def
	type_by_server_mt[type_def.server_mt] = type_def
end

register 'player'
register 'block'

local M = {}

function M.from_id(id)
	return type_by_id[id]
end

function M.from_server(instance)
	local mt = getmetatable(instance)
	if mt == nil then return end
	return type_by_server_mt[mt]
end

return M
