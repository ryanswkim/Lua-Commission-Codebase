-- Services:
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local PS = game:GetService("PhysicsService")

-- Modules:
local SESSION_DATA = require(ServerStorage:WaitForChild("Data"))
local G = require(ServerStorage:WaitForChild("G"))
local ItemInfo = require(ServerStorage:WaitForChild("ModuleData"):WaitForChild("Items"))
local cache = require(ServerStorage:WaitForChild("Cache"))

-- Remotes:
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RightClickItemOptions = Remotes:WaitForChild("RightClickItemOptions")
local Display = Remotes:WaitForChild("Display")
local TransferItem = Remotes:WaitForChild("TransferItem")
local Reset = Remotes:WaitForChild("Reset")
local Sprinting = Remotes:WaitForChild("Sprinting")
local itemDrop = Remotes:WaitForChild("ItemDrop")

-- Input debounce:
local MAX_CALLS_PER_SECOND = 3
local DEBOUNCE_THRESHOLD = 5
local DebounceTable = {}
Players.PlayerAdded:Connect(function(Player)
	DebounceTable[Player.UserId] = 0
end)

Players.PlayerRemoving:Connect(function(Player)
	if DebounceTable[Player.UserId] ~= nil then
		table.remove(DebounceTable, Player.UserId)
	end
end) 

-- Variables:
local playerWorkspace = workspace:WaitForChild("Players")

-- Functions:
local function packV3(v3)
	return tostring(v3.X) .. ", " .. tostring(v3.Y) .. ", " .. tostring(v3.Z)
end

local function initCharacter(character)
	local HRP = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")
	local Player = Players:GetPlayerFromCharacter(character)
	local Values = Player:WaitForChild("Values")
	HRP.AncestryChanged:Connect(function(_, Parent)
		if Parent then return end
		wait(1)
		if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") and Values:WaitForChild("Health").Value > 0 then
			Values.Health.Value = 0
		end
	end)
end

local function reset(player)
	local reset = player:WaitForChild("Gameplay"):WaitForChild("Reset")
	local health = player:WaitForChild("Values"):WaitForChild("Health")
	if not reset.Value then
		reset.Value = true
		health.Value = 0
	end
end

local function sprint(player)
	if not player.Character or not player.Character:FindFirstChildWhichIsA("Humanoid") then return end
	local sprinting = player:WaitForChild("Gameplay"):WaitForChild("Sprinting")
	sprinting.Value = not sprinting.Value
	
	local humanoid = player.Character.Humanoid
	humanoid.WalkSpeed = G.Walkspeed(player)
end

Display.OnServerInvoke = function(player, arguments)
	local id = player.UserId
	local returnTable = {}
	for i, argument in pairs(arguments) do
		table.insert(returnTable, SESSION_DATA[id][argument])
	end
	return unpack(returnTable)
end

TransferItem.OnServerInvoke = function(player, itemName, category, count)
	local ID = player.UserId
	if DebounceTable[ID] > DEBOUNCE_THRESHOLD then return nil, count end
	DebounceTable[ID] = DebounceTable[ID] + 1
	
	local cacheCount = cache:getCount(player, itemName)
	if count <= 0 or cacheCount < count then return nil, 0 end
	
	if category == "Equips" or category == "Vanity" then
		category = "EquipmentInventory"
	end
	
	local RemainingInCache = cacheCount - count
	for i,v in pairs(SESSION_DATA[ID][category]) do
		if count == 0 then break end
		if v["Item"] == "None" then
			local Sub = math.min(ItemInfo[itemName]["Stack"], count)
			count = count - Sub
			SESSION_DATA[ID][category][i] = {Item = itemName, Count = Sub}
		elseif v["Item"] == itemName and v["Count"] < ItemInfo[itemName]["Stack"] then
			local Sub = math.min(count, ItemInfo[itemName]["Stack"] - v["Count"])
			count = count - Sub
			SESSION_DATA[ID][category][i] = {Item = itemName, Count = v["Count"] + Sub}
		end
	end	
	
	cache:reduceCache(player, itemName, cacheCount - count - RemainingInCache)
	return SESSION_DATA[ID][category], count, category
end

RightClickItemOptions.OnServerInvoke = function(Player, Argument, Item, Frame, ActiveLeft)
	local ID = Player.UserId
	while not SESSION_DATA[ID] do wait() end
	
	if not G.CheckCharacter(Player) then return nil end
	if DebounceTable[ID] > DEBOUNCE_THRESHOLD then return nil end
	DebounceTable[ID] = DebounceTable[ID] + 1
	
	local HRP = Player.Character.HumanoidRootPart
	local WeaponSkillPlaying = Player:WaitForChild("PlayingSkills"):WaitForChild("Weapon")

	if Argument == "Equip" then
		if ItemInfo[SESSION_DATA[ID][Frame][Item]["Item"]]["Type"] == "Weapon" and WeaponSkillPlaying.Value then return nil end
		local ItemName = SESSION_DATA[ID][Frame][Item]["Item"]
		if not ItemInfo[ItemName] then return end
		local ItemType = ItemInfo[ItemName]["Type"]
		if not ActiveLeft or not SESSION_DATA[ID] or not SESSION_DATA[ID][ActiveLeft] or not ItemType or ItemType == "None" then return nil end
		if ItemType == "Weapon" then
			ActiveLeft = "Equips"
		end
		if ItemName ~= "None" and ItemType ~= "Collectible" and SESSION_DATA[ID][Frame][Item]["Count"] >= 1 then 
			if SESSION_DATA[ID][ActiveLeft][ItemType]["Item"] == "None" then
				SESSION_DATA[ID][ActiveLeft][ItemType] = {Item = ItemName, Count = 1}
				SESSION_DATA[ID][Frame][Item] = {Item = "None", Count = 0}
			else
				SESSION_DATA[ID][Frame][Item] = SESSION_DATA[ID][ActiveLeft][ItemType]
				SESSION_DATA[ID][ActiveLeft][ItemType] = {Item = ItemName, Count = 1}
			end
			
			G.UpdateCharacter(Player)
			
			local ReturnTable = {}
			ReturnTable[Frame] = SESSION_DATA[ID][Frame]
			ReturnTable[ActiveLeft] = SESSION_DATA[ID][ActiveLeft]
			return ReturnTable
		end 
	end
	
	if Argument == "Unequip" then
		if ItemInfo[SESSION_DATA[ID][Frame][Item]["Item"]]["Type"] == "Weapon" and WeaponSkillPlaying.Value then return nil end
		if SESSION_DATA[ID][tostring(ActiveLeft)][tostring(Item)]["Item"] == "None" then return nil end
		local FreeSpaceIndex
		for i,v in pairs(SESSION_DATA[ID]["EquipmentInventory"]) do
			if v["Item"] == "None" then
				FreeSpaceIndex = i
				break
			end
		end
		if not FreeSpaceIndex then return nil end
		
		SESSION_DATA[ID]["EquipmentInventory"][FreeSpaceIndex] = SESSION_DATA[ID][ActiveLeft][Item]
		SESSION_DATA[ID][ActiveLeft][Item] = {Item = "None", Count = 0}
		 
		G.UpdateCharacter(Player)
		
		local ReturnTable = {}
		ReturnTable["EquipmentInventory"] = SESSION_DATA[ID]["EquipmentInventory"]
		ReturnTable[ActiveLeft] = SESSION_DATA[ID][ActiveLeft]
		return ReturnTable
	end
	
	
	if Argument == "Drop" then
		if ItemInfo[SESSION_DATA[ID][Frame][Item]["Item"]]["Type"] == "Weapon" and WeaponSkillPlaying.Value then return nil end
		local OriginalTable = SESSION_DATA[ID][Frame]
		if OriginalTable[Item]["Item"] == "None" or OriginalTable[Item]["Count"] <= 0 then return nil end
		
		local ItemName = OriginalTable[Item]["Item"]
		local ItemCount = OriginalTable[Item]["Count"]
	
		cache:cacheItem(Player, ItemName, ItemCount)

		local ReturnTable = {}
		OriginalTable[Item] = {Item = "None", Count = 0}
		
		SESSION_DATA[ID][Frame] = OriginalTable
		ReturnTable[Frame] = SESSION_DATA[ID][Frame]
		
		G.UpdateCharacter(Player)
		
		local pos = Vector3.new(HRP.Position.X + math.random(-15,15)/100, HRP.Position.Y + math.random(-15, 15)/100, HRP.Position.Z + math.random(-15,15)/100) + HRP.CFrame.LookVector * 1.4
		itemDrop:FireClient(Player, packV3(pos), Frame, ItemName, ItemCount)
		return ReturnTable
	end
end

-- Init:
playerWorkspace.ChildAdded:Connect(initCharacter)
Reset.OnServerEvent:Connect(reset)
Sprinting.OnServerEvent:Connect(sprint)

-- Debouncing:
while wait(1) do
	for id, value in pairs(DebounceTable) do
		DebounceTable[id] = math.max(0, value - MAX_CALLS_PER_SECOND)
	end
end