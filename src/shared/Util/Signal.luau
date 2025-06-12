local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = setmetatable({}, Signal)
	self._connection = {}
	return self
end

function Signal:Connect(callback)
	local conn = {}
	conn.connected = true
	conn._parent = self

	function conn:Disconnect()
		if not self.connected then return end

		for i, entry in ipairs(self._parent._connection) do
			if entry.connection == self then
				table.remove(self._parent._connection, i)
				break
			end
		end

		self.connected = false
	end

	table.insert(self._connection, {callback = callback, connection = conn})

	return conn
end

function Signal:Fire(...)
	for _, entry in self._connection do
		if entry.connection.connected then
			coroutine.wrap(entry.callback)(...)
		end
	end
end

function Signal:DisconnectAll()
	for _, entry in self._connection do
		entry.connection.connected = false
	end
	self._connection = {}
end

return Signal
