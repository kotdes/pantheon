--!strict

local Types = require(script.Parent.Types)

local Define = {}

local function isList(input: { [any]: any }): boolean
	return input[1] ~= nil or next(input) == nil
end

function Define.routes(input: { [any]: any }?): { Types.RouteRecord }
	local out: { Types.RouteRecord } = {}
	if input == nil then
		return out
	end

	local function add(record: any, path: string?)
		local copy: any = table.clone(record)
		if path ~= nil then
			if copy.Path ~= nil and copy.Path ~= path then
				error(
					`Pantheon Router: "{path}" has its own Path "{copy.Path}". Leave Path out.`,
					0
				)
			end
			copy.Path = path
		end
		if copy.Path == nil then
			error("Pantheon Router: a route needs a Path", 0)
		end
		copy.Children = if copy.Children ~= nil then Define.routes(copy.Children) else nil
		table.insert(out, copy)
	end

	if isList(input) then
		for _, record in input do
			add(record, nil)
		end
		return out
	end

	local paths = {}
	for path in input do
		table.insert(paths, path)
	end
	table.sort(paths)
	for _, path in paths do
		local value = input[path]
		if typeof(value) == "function" then
			add({ Render = value }, path)
		elseif typeof(value) == "table" then
			add(value, path)
		else
			error(`Pantheon Router: the route "{path}" must be a function or a table`, 0)
		end
	end
	return out
end

return Define
