local SignalMod = require(game:GetService("ReplicatedStorage").Shared.Util.Signal)

local BiBFSUtil = {}
BiBFSUtil.__index = BiBFSUtil

export type UpdateCallback = {
	LeftVisited: {Object},     -- table: nodes visited from the start
	RightVisited: {Object},       -- table: nodes visited from the goal
	CurrentParentNode: Object, -- the current node being expanded,
	CurrentNeighbourNode: Object, -- the current neighbour node that was expanded from the parent node
	Side: "L" | "R",   -- String: which side
	
}

export type DoneCallback = {
	Result: {Object},
	Intersection: Object,
	Source: Object,
	Destination: Object,
	Elapsed: number
}

local function reverse(t) : nil
	local i, j = 1, #t
	while i < j do
		t[i], t[j] = t[j], t[i]
		i += 1
		j -= 1
	end
end

function BiBFSUtil.new()
	local self = setmetatable({
		Done = SignalMod.new(),
		Update = SignalMod.new()
	}, BiBFSUtil)
	
	return self
end

function BiBFSUtil:Expand(queueSelf: {Object}, visitedSelf: {Object}, parentSelf: {[Object]: Object}, visitedOther: Object, side: "L" | "R") : Object?
	if #queueSelf == 0 then
		return nil
	end
	local currentNode: Object = table.remove(queueSelf, 1)
	local data: UpdateCallback
	if currentNode == nil then
		return nil
	end
	for _, neighbour in self._getNeighbourCallback(currentNode) do
		if not visitedSelf[neighbour] then
			table.insert(queueSelf, neighbour)
			visitedSelf[neighbour] = true
			parentSelf[neighbour] = currentNode
			
			data = {
				LeftVisited = self._visitedLeft,     
				RightVisited = self._visitedRight,       
				CurrentParentNode = currentNode,
				CurrentNeighbourNode = neighbour,
				Side = side
			}

			if visitedOther[neighbour] then
				self.Update:Fire(data)
				return neighbour
			end

			
			self.Update:Fire(data)
			
		end
	end

	return nil
end

function BiBFSUtil:constructPath() : {Object}
	local pathLeft = {}
	local node: Object = self._intersection
	while node ~= nil do
		table.insert(pathLeft, node)
		node = self._parentLeft[node]
	end
	reverse(pathLeft)
	node = self._parentRight[self._intersection]
	while node ~= nil do
		table.insert(pathLeft, node)
		node = self._parentRight[node]
	end
	return pathLeft
end

function BiBFSUtil:Traverse(getNeighbourCallback: (Object) -> {Object}, source: Object, dest: Object)
	self._queueLeft = {source}
	self._queueRight = {dest}

	self._visitedLeft = {[source] = true}
	self._visitedRight = {[dest] = true}

	self._parentLeft = {[source] = nil}
	self._parentRight = {[dest] = nil}

	self._source = source
	self._dest = dest

	self._getNeighbourCallback = getNeighbourCallback
	self._intersection = nil



	if self._source == self._dest then
		local data: DoneCallback = {
			Result = {self._source}, 
			Intersection = self._source,
			Source = self._source,
			Destination = self._dest
		}
		self.Done:Fire(data)
		return self
	end
	
	self._elapsed = tick()
	
	local traverseFunc = coroutine.wrap(function()
		while #self._queueLeft > 0 and #self._queueRight > 0 do
			local result = self:Expand(self._queueRight, self._visitedRight, self._parentRight, self._visitedLeft, "R")
			if result then
				self._intersection = result
				local data: DoneCallback = {
					Result = self:constructPath(), 
					Intersection = self._intersection,
					Source = self._source,
					Destination = self._dest,
					Elapsed = tick() - self._elapsed
				}
				self.Done:Fire(data)
				return
			end
			
			result = self:Expand(self._queueLeft, self._visitedLeft, self._parentLeft, self._visitedRight, "L")
			if result then
				self._intersection = result
				local data: DoneCallback = {
					Result = self:constructPath(), 
					Intersection = self._intersection,
					Source = self._source,
					Destination = self._dest,
					Elapsed = tick() - self._elapsed
				}
				self.Done:Fire(data)
				return 
			end
		end
		local data: DoneCallback = {
			Result = {},
			Intersection = nil,
			Source = self._source,
			Destination = self._dest,
			Elapsed = tick() - self._elapsed
		}
		self.Done:Fire(data)
	end)
	traverseFunc()
	return self
end

return BiBFSUtil
