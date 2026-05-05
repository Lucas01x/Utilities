--// Lucas Utilities

export type Destroyable =
	Instance |
	RBXScriptConnection |
	{ Destroy: (self: any) -> () } |
	{ Disconnect: (self: any) -> () }

-- destroy
local function destroy(obj: Destroyable?): ()
	if not obj then return end

	local t = typeof(obj)

	if t == "Instance" then
		(obj :: Instance):Destroy()
		return
	elseif t == "RBXScriptConnection" then
		(obj :: RBXScriptConnection):Disconnect()
		return
	end

	local anyObj = obj :: any
	local fn = anyObj.Destroy or anyObj.Disconnect


	if type(fn) == "function" then
		fn(anyObj)
	else
		warn(`[destroy] unsupported type: {t}`)
	end
end

-- ensure
local function ensure<T>(
	self: {[any]: T},
	key: any,
	value: T,
	discard: boolean?
): T
	assert(type(self) == "table", `bad arg #1 (table expected, got {type(self)})`)
	assert(key ~= nil, "bad arg #2 (nil key)")
	assert(value ~= nil, "bad arg #3 (nil value)")

	local existing = self[key]

	if existing ~= nil then
		if discard then
			destroy(value)
		end
		return existing
	end

	self[key] = value
	return value
end

--// assign
local function assign<T>(
	self: {[any]: T},
	key: any,
	value: T
): T
	assert(type(self) == "table", `bad arg #1 (table expected, got {type(self)})`)
	assert(key ~= nil, "bad arg #2 (nil key)")
	assert(value ~= nil, "bad arg #3 (nil value)")

	local prev = self[key]

	if prev ~= nil then
		destroy(prev)
	end

	self[key] = value
	return value
end

return ensure, assign
