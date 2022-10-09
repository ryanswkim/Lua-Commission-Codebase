-- Services:
local players = game:GetService("Players")
local debris = game:GetService("Debris")

-- Variables:
local startUpTime = tick()
local CLEANUP_TIME = 90
local cache = {}

-- Functions:
local function init(player)
	local id = player.UserId
	if not script:FindFirstChild(id) then
		local playerFolder = Instance.new("Folder")
		playerFolder.Name = id
		playerFolder.Parent = script
	end
end

local function deinit(player)
	local id = player.UserId
	if script:FindFirstChild(id) then
		script[id]:Destroy()
	end
end

function cache:cacheItem(player, item, count)
	local id = player.UserId
	if not script:FindFirstChild(id) then
		local playerFolder = Instance.new("Folder")
		playerFolder.Name = id
		playerFolder.Parent = script
	end
	
	if not script[id]:FindFirstChild(item) then
		local itemFolder = Instance.new("Folder")
		itemFolder.Name = item
		itemFolder.Parent = script[id]
	end
	
	local newCache = Instance.new("IntValue")
	newCache.Name = math.floor(tick() - startUpTime)
	newCache.Value = count
	newCache.Parent = script[id][item]
	debris:AddItem(newCache, CLEANUP_TIME)
end

function cache:reduceCache(player, item, reduction)
	local id = player.UserId
	if not script:FindFirstChild(id) then
		init(player)
		return false 
	end
	if not script[id]:FindFirstChild(item) then return end
	
	while reduction > 0 and #script[id][item]:GetChildren() > 0 do
		local index = math.huge
		for i, cacheValue in pairs(script[id][item]:GetChildren()) do
			if tonumber(cacheValue.Name) < index then
				index = tonumber(cacheValue.Name)
			end
		end
		
		if not script[id][item][index] then return end
		local curCacheValue = script[id][item][index]
		local sub = math.min(reduction, curCacheValue.Value)
		reduction = reduction - sub
		curCacheValue.Value = curCacheValue.Value - sub
		if curCacheValue.Value <= 0 then
			curCacheValue:Destroy()
		end
	end
end

function cache:getCount(player, item)
	local id = player.UserId
	if not script:FindFirstChild(id) then
		local playerFolder = Instance.new("Folder")
		playerFolder.Name = id
		playerFolder.Parent = script
		return 0
	end
	
	if not script[id]:FindFirstChild(item) then
		return 0
	end
	
	local count = 0
	for i, cacheValue in pairs(script[id][item]:GetChildren()) do
		count = count + cacheValue.Value
	end
	return count
end

players.PlayerAdded:Connect(init)
players.PlayerRemoving:Connect(deinit)

return cache
