local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDrop = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemDrop")
local ItemInfo = require(ServerStorage:WaitForChild("ModuleData"):WaitForChild("Items"))
local SESSION_DATA = require(ServerStorage:WaitForChild("Data"))
local PlayerItemCache = require(ServerStorage:WaitForChild("ModuleData"):WaitForChild("PlayerItemCache"))

local MobScripts = {}

MobScripts.GetAxis = function(Min, Max)
	local Shift = math.random(Min,Max)
	local Direction
	if math.random(0,100) > 50 then
		Direction = -1
	else
		Direction = 1
	end
	return Shift * Direction
end

MobScripts.DistributeDrops = function(MobCharacter, MaxHealth, ItemDrops)
	if not MobCharacter:FindFirstChild("HumanoidRootPart") or not MobCharacter:FindFirstChild("PlayerTags") then return end
	local HRP = MobCharacter.HumanoidRootPart
	for i,IDTag in pairs(MobCharacter:WaitForChild("PlayerTags"):GetChildren()) do
		local IDKey = tonumber(IDTag.Name)
		if Players:GetPlayerByUserId(IDTag.Name) and IDTag.Value > (MaxHealth / (#MobCharacter:FindFirstChild("PlayerTags"):GetChildren() / 1.25)) / 1.5  then
			if SESSION_DATA[Players:GetPlayerByUserId(IDTag.Name).UserId]["MobKills"][MobCharacter.Name] then
				SESSION_DATA[Players:GetPlayerByUserId(IDTag.Name).UserId]["MobKills"][MobCharacter.Name] = SESSION_DATA[Players:GetPlayerByUserId(IDTag.Name).UserId]["MobKills"][MobCharacter.Name] + 1
			else
				SESSION_DATA[Players:GetPlayerByUserId(IDTag.Name).UserId]["MobKills"][MobCharacter.Name] = 1
			end
			SESSION_DATA[Players:GetPlayerByUserId(IDTag.Name).UserId]["MobKills"]["Total"] = SESSION_DATA[Players:GetPlayerByUserId(IDTag.Name).UserId]["MobKills"]["Total"] + 1
			
			if not PlayerItemCache[IDKey] then
				PlayerItemCache[IDKey] = {}
			end
			
			for i,v in pairs(ItemDrops) do
				if math.random(0,1000) < v["Chance"] then
					local ItemCount = math.random(1, v["MaxCount"])
					local X = HRP.Position.X + math.random(math.floor(-HRP.Size.X), math.floor(HRP.Size.X)) * math.random(0,10)/10
					local Y = HRP.Position.Y
					local Z = HRP.Position.Z + math.random(math.floor(-HRP.Size.Z), math.floor(HRP.Size.Z)) * math.random(0,10)/10
					ItemDrop:FireClient(Players:GetPlayerByUserId(IDTag.Name), X, Y, Z, ItemInfo[i]["Category"], i, ItemCount)
					
					if PlayerItemCache[IDKey][i] then
						PlayerItemCache[IDKey][i] = PlayerItemCache[IDKey][i] + ItemCount
					else
						PlayerItemCache[IDKey][i] = ItemCount
					end
				end
			end
		end
	end
end

return MobScripts