-- Services:
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- Data:
local CubeQuestData = DataStoreService:GetDataStore("TestData2")
local SESSION_DATA = require(ServerStorage:WaitForChild("Data"))
local G = require(ServerStorage:WaitForChild("G"))

local function packV3(v3)
	return tostring(v3.X) .. ", " .. tostring(v3.Y) .. ", " .. tostring(v3.Z)
end

local function load_data(ID)
	local success, data = pcall(function()
		return CubeQuestData:GetAsync(ID)
	end)
	if success then
		return data
	else
		warn("Can't access player's data!")
		return nil
	end
end

local function save_data(ID, NewSave)
    local success
	local err
	
    repeat
        success, err = pcall(function()
            CubeQuestData:SetAsync(ID, NewSave)
        end)
        if not success then print(err) wait(7) end
    until success

    if not success then
        print("Cannot save data for player!")
	else
		print("Success!")
    end
end

game:BindToClose(function() --Save on server shutdown
	for i, player in pairs(Players) do
		local ID = player.UserId
		save_data(ID, SESSION_DATA[ID])
	end
end)

Players.PlayerAdded:Connect(function(Player)
	while not SESSION_DATA and not G do wait() end
	
	local ID = Player.UserId
	SESSION_DATA[ID] = load_data(ID)
	SESSION_DATA["Bonuses"][ID] = {}
	
	if not SESSION_DATA[ID] then 
		Player:Kick("You don't have a saved account!")
	end
	
	G.INIT(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
	local ID = Player.UserId
	save_data(ID, SESSION_DATA[ID])
	if SESSION_DATA[ID] then
		table.remove(SESSION_DATA, ID)
	end
	if SESSION_DATA["Bonuses"][ID] then
		table.remove(SESSION_DATA["Bonuses"], ID)
	end
end)

spawn(function() -- Autosave
	while wait(300) do
		for i,v in pairs(Players:GetPlayers()) do
			local ID = v.UserId
			save_data(ID, SESSION_DATA[ID])
		end
	end
end)

spawn(function()
	while wait(5) do
		for i, player in pairs(Players:GetPlayers()) do
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local ID = player.UserId 
				local pos = player.Character.HumanoidRootPart.Position
				while not SESSION_DATA[ID] do wait() end
				SESSION_DATA[ID]["SpawnPosition"] = packV3(pos)
			end
		end
	end
end)