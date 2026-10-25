--!strict

local Translate = {}

local translator: ((key: string, default: string) -> string?)? = nil

--- Sets the function that translates the text Pantheon draws itself, such as the tabs of the colour
--- picker. The function gets a key and the English text, and returns the translation, or nil to
--- keep the English text.
function Translate.set(fn: ((key: string, default: string) -> string?)?)
	translator = fn
end

--- The text for `key`. Without a translator, or when it has no text for the key, this is `default`.
function Translate.t(key: string, default: string): string
	local fn = translator
	if fn == nil then
		return default
	end
	local ok, result = pcall(fn, key, default)
	if ok and type(result) == "string" and result ~= "" then
		return result
	end
	return default
end

return Translate
