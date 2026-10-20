--!strict

export type Params = { [string]: string }
export type Segment = { Kind: "static" | "param" | "splat", Value: string }
export type Pattern = {
	Source: string,
	Segments: { Segment },
	Score: number,
}

local SCORES = { static = 3, param = 2, splat = 1 }

local Path = {}

local function decode(text: string): string
	return (
		string.gsub(text, "%%(%x%x)", function(hex: string)
			return string.char(tonumber(hex, 16) :: number)
		end)
	)
end

local function encode(text: string): string
	return (
		string.gsub(text, "[^%w%-%._~]", function(char: string)
			return string.format("%%%02X", string.byte(char))
		end)
	)
end

local function split(path: string): { string }
	local parts = {}
	for part in string.gmatch(path, "[^/]+") do
		table.insert(parts, part)
	end
	return parts
end

function Path.normalise(path: string): string
	return "/" .. table.concat(split(path), "/")
end

function Path.join(parent: string, child: string): string
	return Path.normalise(parent .. "/" .. child)
end

function Path.compile(pattern: string): Pattern
	local source = Path.normalise(pattern)
	local segments: { Segment } = {}
	local score = 0
	local parts = split(source)
	for index, part in parts do
		local segment: Segment
		if part == "*" then
			if index ~= #parts then
				error(`Pantheon Router: "*" must be the last segment of "{source}"`, 0)
			end
			segment = { Kind = "splat", Value = "*" }
		elseif string.sub(part, 1, 1) == ":" then
			local name = string.sub(part, 2)
			if string.match(name, "^[%w_]+$") == nil then
				error(`Pantheon Router: invalid parameter name "{part}" in "{source}"`, 0)
			end
			segment = { Kind = "param", Value = name }
		else
			segment = { Kind = "static", Value = decode(part) }
		end
		score += SCORES[segment.Kind]
		table.insert(segments, segment)
	end
	return { Source = source, Segments = segments, Score = score }
end

function Path.match(pattern: Pattern, path: string): Params?
	local parts = split(path)
	local params: Params = {}
	for index, segment in pattern.Segments do
		if segment.Kind == "splat" then
			local rest = {}
			for i = index, #parts do
				table.insert(rest, decode(parts[i]))
			end
			params["*"] = table.concat(rest, "/")
			return params
		end
		local part = parts[index]
		if part == nil then
			return nil
		end
		if segment.Kind == "static" then
			if decode(part) ~= segment.Value then
				return nil
			end
		else
			params[segment.Value] = decode(part)
		end
	end
	if #parts ~= #pattern.Segments then
		return nil
	end
	return params
end

function Path.build(pattern: Pattern, params: Params?): (string?, string?)
	local given = params or {}
	local out = {}
	for _, segment in pattern.Segments do
		if segment.Kind == "static" then
			table.insert(out, encode(segment.Value))
		elseif segment.Kind == "param" then
			local value = given[segment.Value]
			if value == nil or value == "" then
				return nil, `missing parameter "{segment.Value}" for "{pattern.Source}"`
			end
			table.insert(out, encode(value))
		else
			for _, part in split(given["*"] or "") do
				table.insert(out, encode(part))
			end
		end
	end
	return "/" .. table.concat(out, "/"), nil
end

function Path.parse(url: string): (string, Params)
	local withoutFragment = string.match(url, "^[^#]*") :: string
	local path, queryText = string.match(withoutFragment, "^([^?]*)%??(.*)$")
	local query: Params = {}
	for pair in string.gmatch(queryText :: string, "[^&]+") do
		local key, value = string.match(pair, "^([^=]*)=?(.*)$")
		if key ~= nil and key ~= "" then
			local name = string.gsub(key, "%+", " ")
			local text = string.gsub(value :: string, "%+", " ")
			query[decode(name)] = decode(text)
		end
	end
	return Path.normalise(path :: string), query
end

function Path.format(path: string, query: Params?): string
	local given: Params = query or {}
	local keys = {}
	for key in given do
		table.insert(keys, key)
	end
	if #keys == 0 then
		return path
	end
	table.sort(keys)
	local fields = {}
	for _, key in keys do
		table.insert(fields, encode(key) .. "=" .. encode(given[key]))
	end
	return path .. "?" .. table.concat(fields, "&")
end

return Path
