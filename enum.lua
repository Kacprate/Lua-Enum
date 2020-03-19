--[[
	Created by Kacprate
	Creation date: 19 March 2020
	
	Functions:
		enum.new(mode, data)
		created a new enum of mode 'mode' (described lower) from dataset data
		
		enum.Wrap(value) -- wraps a number or a string into the enum, so we can compare our enums to strings or numbers
		for example enum.new("values", {test = 1}).test == enum.wrap(1) will return true
		
		enum.GetAll() -- returns a table of all enum keys from an enum object
--]]

local enum = {}

--[[
	Modes:
		array - {"val1", "val2", ...}
		values - {val1 = 1, val2 = 2, val3 = 1, ...}
--]]
local modes = {"array", "values"}

local function isIn(el, tab)
	for i,v in pairs(tab) do
		if el == v then
			return true
		end
	end
	return false
end

function eq(a, b)
	if a.Wrapped then
		if a.WrappedType == "number" then
			return a.Value == b.Value
		elseif a.WrappedType == "string" then
			return a.Key == b.Key
		end
	end
	if b.Wrapped then
		if b.WrappedType == "number" then
			return a.Value == b.Value
		elseif b.WrappedType == "string" then
			return a.Key == b.Key
		end
	end
	return a.Key == b.Key or a.Value == b.Value
end;

local wrapTypes = {"string", "number"}

local enumPart = {}
function enumPart.new(key, value, wrapped, wrappedType) -- wrapBy: 1 - value, 2 - string
	if wrapped then
		assert(isIn(wrappedType, wrapTypes), "Cannot wrap a " .. wrappedType .. " object")
	end
	if wrapped == nil then
		wrapped = false
	end
	if wrappedType == nil then
		wrappedType = ""
	end
	  
	local data = {Key = key, Value = value, Wrapped = wrapped, WrappedType = wrappedType}
	local metatable = {
		__index = function(self, index)
			local tmp = data[index]
			if tmp == nil then
				error("Wrong use of EnumPart index, only Key or Value, index provided: " .. index)
			end
			return tmp	
		end;
		__newindex = function(self, index, val) error("Attempt to modify a read-only table") end;
		__eq = eq;
		__tostring = function(self)
			if data.Wrapped then
				if data.WrappedType == "string" then
					return '["' .. data.Key .. '"]'
				elseif data.WrappedType == "number" then
					return "[" .. data.Value .. "]"
				end
			end
			return '["' .. data.Key .. '", ' .. data.Value .. ']'
		end
	}
	
	local temp = newproxy(true)
	local meta = getmetatable(temp)
	meta.__metatable = false
	for i,v in pairs(metatable) do
		meta[i] = metatable[i]
	end
	
	return temp
end

local function keyCheck(key)
	if key == "GetAll" then
		error("Cannot create Enum key GetAll as it is a built-in Enum function")
	end
end

function enum.new(mode, data)
	assert(type(mode) == "string", "Enum mode must be a string")
	assert(type(data) == "table", "Enum data must be a table")
	assert(isIn(string.lower(mode), modes), "Mode " .. mode .. " is not recognized")
	
	mode = string.lower(mode)
	
	local enumData = {}
	enumData.data = {}
	enumData.mode = mode
	
	if mode == "array" then
		for i,v in ipairs(data) do
			keyCheck(v)
			if enumData.data[v] ~= nil then
				error("Enum key " .. v .. " is not unique")
			end
			enumData.data[v] = enumPart.new(v, i)
		end	
	elseif mode == "values" then
		for i,v in pairs(data) do
			keyCheck(i)
			enumData.data[i] = enumPart.new(i, v)
		end	
	end
	
	local metatable = {
		__index = function(self, index)
			if index == "GetAll" then
				return function() 
					local tmp = {}
					for i,v in pairs(enumData.data) do
						table.insert(tmp, i)
					end
					return tmp 
				end
			end
			
			local data = enumData.data[index]
			if not data then
				error("Enum key " .. index .. " does not exist")
			end
			return data
		end;
		__newindex = function() error("Attempt to modify a read-only table") end;
		__tostring = function(self)
			local result = "[";
			for i,v in pairs(self.GetAll()) do
				result = result .. ", " .. v
			end
			result = result .. "]"
			return string.gsub(result, "%[, ", "%[", 1)
		end
	}
	
	local temp = newproxy(true)
	local meta = getmetatable(temp)
	meta.__metatable = false
	for i,v in pairs(metatable) do
		meta[i] = metatable[i]
	end
	
	return temp
end

enum.Wrap = function(value)
	return enumPart.new(value, value, true, type(value))
end

return enum
