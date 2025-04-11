if not game:IsLoaded() then 
	game.Loaded:Wait() 
	task.wait(1) 
end

messagebox("Script initialization complete", "Debug", 0)

local HttpService = cloneref(game:GetService("HttpService"))

local jsonApi = game:HttpGet("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/Full-API-Dump.json")
messagebox("Fetched Full-API-Dump.json", "Debug", 0)

local parsedJson = HttpService:JSONDecode(jsonApi)
jsonApi = nil
messagebox("Parsed JSON successfully", "Debug", 0)

local lastIndexedSignal, lastindexed
local originalIndex
local isHooked = false  

originalIndex = hookmetamethod(game, "__index", function(self, key, ...)
	if isHooked then
		return originalIndex(self, key, ...)
	end

	isHooked = true

	local cc = checkcaller()
	local idnt = getidentity()

	if cc and idnt >= 8 then
		local value = tostring(self[key])
		if value and string.find(value, "Signal") then
			lastIndexedSignal = key  
			lastindexed = self
			messagebox("Signal accessed: " .. tostring(key), "Signal Debug", 0)
		end
	end

	local result = originalIndex(self, key, ...)
	isHooked = false
	return result
end)

local signalCache = {}

getgenv().getsignalarguments = newcclosure(function(signalStr)
	signalStr = tostring(signalStr)
	if not lastindexed then 
		messagebox("No lastindexed instance for signal: " .. signalStr, "SignalArg Debug", 0)
		return {} 
	end

	signalCache[lastindexed] = signalCache[lastindexed] or {}

	if signalCache[lastindexed][signalStr] then
		return signalCache[lastindexed][signalStr]
	end

	local signalName = signalStr:match("^Signal%s+(%S+)")
	if not signalName then 
		signalCache[lastindexed][signalStr] = {}
		return {}
	end

	for _, class in ipairs(parsedJson.Classes) do
		if lastindexed:IsA(class.Name) then
			for _, member in ipairs(class.Members) do
				if member.MemberType == "Event" and member.Name == signalName then
					local paramTypes = {}
					if member.Parameters then
						for _, param in ipairs(member.Parameters) do
							local typeName = param.Type and param.Type.Name
							if typeName then
								table.insert(paramTypes, typeName)
							end
						end
					end
					messagebox("Signal matched: " .. signalName .. " | Args: " .. table.concat(paramTypes, ", "), "SignalArg Debug", 0)
					signalCache[lastindexed][signalStr] = paramTypes
					return paramTypes
				end
			end
		end
	end

	signalCache[lastindexed][signalStr] = {}
	return {}
end)

local old = clonefunction(replicatesignal)

getgenv().replicatesignal = newcclosure(function(scriptsignal, ...)
	local signalrequiredargs = getsignalarguments(scriptsignal)
	local passedArgs = { ... }

	if #passedArgs > #signalrequiredargs then
		for i = #passedArgs, #signalrequiredargs + 1, -1 do
			passedArgs[i] = nil
		end
	end

	if #passedArgs < #signalrequiredargs then
		local expectedIndex = #passedArgs + 1
		local expectedArg = signalrequiredargs[expectedIndex]
		local expectedType = expectedArg and (expectedArg or expectedArg.ClassName) or "value"
		messagebox(string.format("Missing argument #%d to 'replicatesignal' (%s expected, got nil)", expectedIndex, expectedType), "replicatesignal Error", 0)
		return error(string.format("missing argument #%d to '%s' (%s expected, got nil)", expectedIndex, "replicatesignal", expectedType))
	end

	for i, expected in ipairs(signalrequiredargs) do
		local arg = passedArgs[i]
		local actualType = type(arg)
		local actualTypeOf = typeof(arg)
		local actualClassName = arg and actualTypeOf == "Instance" and arg.ClassName or nil

		local numericLike = { int = true, int64 = true, float = true, double = true, number = true }
		local booleanLike = { bool = true, boolean = true }
		local isEnum = pcall(function() return typeof(arg) == "EnumItem" end)

		local isAllowed =
			actualType == expected or
			actualTypeOf == expected or
			(actualClassName and actualClassName == expected) or
			(numericLike[expected] and actualType == "number") or
			(booleanLike[expected] and actualType == "boolean")

		if isEnum then
			if string.find(tostring(arg), tostring(expected)) then
				isAllowed = true
			end
		end

		if not isAllowed then
			messagebox(string.format("Invalid argument #%d to 'replicatesignal': expected %s, got %s", i, expected, actualClassName or actualTypeOf), "replicatesignal Error", 0)
			return error(string.format(
				"invalid argument #%d to '%s' (%s expected, got %s)",
				i, "replicatesignal", expected,
				actualClassName or actualTypeOf
			))
		end
	end

	messagebox("replicatesignal validated and firing", "replicatesignal Debug", 0)
	return old(signalrequiredargs, scriptsignal, table.unpack(passedArgs))
end)
