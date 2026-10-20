--!strict

local History = {}
History.__index = History

export type History = typeof(setmetatable(
	{} :: {
		_entries: { string },
		_index: number,
		_limit: number,
	},
	History
))

function History.new(initial: string, limit: number?): History
	return setmetatable({
		_entries = { initial },
		_index = 1,
		_limit = math.max(limit or 100, 1),
	}, History)
end

function History.Current(self: History): string
	return self._entries[self._index]
end

function History.Peek(self: History, delta: number): string?
	return self._entries[self._index + delta]
end

function History.CanGo(self: History, delta: number): boolean
	return self._entries[self._index + delta] ~= nil
end

function History.Push(self: History, url: string)
	for index = #self._entries, self._index + 1, -1 do
		self._entries[index] = nil
	end
	table.insert(self._entries, url)
	self._index = #self._entries
	while #self._entries > self._limit do
		table.remove(self._entries, 1)
		self._index -= 1
	end
end

function History.Replace(self: History, url: string)
	self._entries[self._index] = url
end

function History.Go(self: History, delta: number): string?
	local target = self._entries[self._index + delta]
	if target == nil then
		return nil
	end
	self._index += delta
	return target
end

return History
