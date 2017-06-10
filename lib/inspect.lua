local function inspect(value)
	if type(value) == 'table' then
		local pieces = {}
		for key, inner in pairs(value) do
			pieces[#pieces+1] = tostring(key) .. '=' .. inspect(inner)
		end
		return '{' .. table.concat(pieces, ' ') .. '}'
	else
		return tostring(value)
	end
end

return inspect
