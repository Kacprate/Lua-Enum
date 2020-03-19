IMPORTANT: Uses newproxy function which is not available in Lua 5.2+, but still works in Roblox Lua.

# Lua-Enum
Lua Enum Library - provides Enum object creation with a bunch of useful functionalities

Created by Kacprate
Creation date: 19 March 2020
	
	Functions:
		enum.new(mode, data)
		created a new enum of mode 'mode' (described lower) from dataset data
		
		enum.Wrap(value) -- wraps a number or a string into the enum, so we can compare our enums to strings or numbers
		for example enum.new("values", {test = 1}).test == enum.wrap(1) will return true
		
		enum.GetAll() -- returns a table of all enum keys from an enum object
