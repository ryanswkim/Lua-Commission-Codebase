local Players = game:GetService("Players")
Players.CharacterAutoLoads = true
local DataStoreService  = game:GetService("DataStoreService")
local TPService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CubeQuestData = DataStoreService:GetDataStore("TestData2")

local SESSION_DATA = {}
local DATA_TEMPLATE = { 
			Level = 1; 
			Experience = 0; 
			Cubelins = 500;
			
			Stats = {SP = 0, UsedSP = 0, Attack = 0, Wisdom = 0, Intelligence = 0, Vitality = 0, Defense = 0, Stamina = 0, Fortune = 0};
			
			Slots = {Slot1 = "None", Slot2 = "None", Slot3 = "None", Slot4 = "None", Slot5 = "None"};
			  
			Equips = {Head = {Item = "None", Count = 0}, Body = {Item = "None", Count = 0}, Feet = {Item = "None", Count = 0}, Back = {Item = "None", Count = 0}, 
				Neck = {Item = "None", Count = 0}, Misc1 = {Item = "None", Count = 0}, Misc2 = {Item = "None", Count = 0}, Weapon = {Item = "None", Count = 0}};
			Vanity = {Head = {Item = "None", Count = 0}, Body = {Item = "None", Count = 0}, Feet = {Item = "None", Count = 0}, Back = {Item = "None", Count = 0}, 
				Neck = {Item = "None", Count = 0}, Misc1 = {Item = "None", Count = 0}, Misc2 = {Item = "None", Count = 0}};
			
			Character = {BodyColor = "Dark stone grey", EyeColor = "Really black", 
				HairColor = "Really black", HairType = 0, PrimaryFacialHairType = 0, SecondaryFacialHairType = 0};
			
	 		Quests = {}; --Name, description, gold, experience, and always make the quests require a number to complete
			CompletedQuests = {};
			TitlesInventory = {};
			--EquippedTitleIndex = 1;
			
			SkillsInventory = {"None", "None", "None", "None", 
				"None", "None", "None", "None", "None", "None", "None", "None", 
				"None", "None", "None", "None"
			};
			
			CollectibleInventory = {{Item = "None", Count = 0}, {Item = "None", Count = 0}, {Item = "None", Count = 0}, {Item = "None", Count = 0},
				{Item = "None", Count = 0}, {Item = "None", Count = 0}, {Item = "None", Count = 0}, {Item = "None", Count = 0}, {Item = "None", Count = 0},
				{Item = "None", Count = 0}, {Item = "None", Count = 0}, {Item = "None", Count = 0}, {Item = "None", Count = 0}, {Item = "None", Count = 0}, 
				{Item = "None", Count = 0}, {Item = "None", Count = 0}
			};
			EquipmentInventory = {{Item = "Sword", Count = 1}, {Item = "Hammer", Count = 1}, {Item = "Daggers", Count = 1}, {Item = "None", Count = 0},
				{Item = "CopperChestplate", Count = 1}, {Item = "CopperBoots", Count = 1}, {Item = "PaladinHammer", Count = 1}, {Item = "WaterMagic", Count = 1}, {Item = "None", Count = 0},
				{Item = "None", Count = 0}, {Item = "None", Count = 0}, {Item = "None", Count = 0}, {Item = "None", Count = 0}, {Item = "None", Count = 0}, 
				{Item = "None", Count = 0}, {Item = "None", Count = 0}
			}; 
			
			MobKills = {Total = 0};
			
			SpawnPlace = 4480680115;
			Houses = {};
}


local function load_data(ID)
	local success
	local data
	local count = 0
	repeat
		success, data = pcall(function()
			return CubeQuestData:GetAsync(ID)
		end)
		count = count + 1
		
		if success then
			return data or nil
		end
		wait(7)
	until success or count > 30
	
	if not success then return {DATA_TEMPLATE, DATA_TEMPLATE, DATA_TEMPLATE} end
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

game:BindToClose(function()
	for i,v in pairs(Players) do
		local ID = v.UserId
		save_data(ID, SESSION_DATA[ID])
	end
end)

Players.PlayerAdded:Connect(function(Player)
	local ID = Player.UserId
	SESSION_DATA[ID] = load_data(ID)
	
	Player.CharacterAdded:Connect(function()
		Player.Character:WaitForChild("HumanoidRootPart").Anchored = true
	end)
end)

Players.PlayerRemoving:Connect(function(Player)
	local ID = Player.UserId
	save_data(ID, SESSION_DATA[ID])
end)

ReplicatedStorage:WaitForChild("GetData").OnServerInvoke = (function(Player)
	return SESSION_DATA[Player.UserId]
end)

local RSClothes = ReplicatedStorage:WaitForChild("Clothes")
local RSShoes = ReplicatedStorage:WaitForChild("Shoes")
local RSHairs = ReplicatedStorage:WaitForChild("Hairs")
local RSFacials = ReplicatedStorage:WaitForChild("FacialHairs")
ReplicatedStorage:WaitForChild("TP").OnServerEvent:Connect(function(Player, Info)
	local ID = Player.UserId
	
	if Info and type(Info) == "table" then
		local NewSave = DATA_TEMPLATE
		NewSave["Character"]["BodyColor"] = tostring(Info["BodyColor"]) or "Dark stone grey"
		NewSave["Character"]["EyeColor"] = tostring(Info["EyeColor"]) or "Really black"
		NewSave["Character"]["HairColor"] = tostring(Info["HairColor"]) or "Really black"
		if type(Info["HairType"]) ~= "number" or Info["HairType"] < 0 or Info["HairType"] > #RSHairs:GetChildren() then
			Info["HairType"] = 0
		end
		if type(Info["PrimaryFacialHairType"]) ~= "number" or Info["PrimaryFacialHairType"] < 0 or Info["PrimaryFacialHairType"] > #RSFacials:GetChildren() then
			Info["PrimaryFacialHairType"] = 0
		end
		if type(Info["SecondaryFacialHairType"]) ~= "number" or Info["SecondaryFacialHairType"] < 0 or Info["SecondaryFacialHairType"] > #RSFacials:GetChildren() then
			Info["SecondaryFacialHairType"] = 0
		end
		
		NewSave["Character"]["HairType"] = Info["HairType"]
		NewSave["Character"]["PrimaryFacialHairType"] = Info["PrimaryFacialHairType"]
		NewSave["Character"]["SecondaryFacialHairType"] = Info["SecondaryFacialHairType"]
		
		if ReplicatedStorage:WaitForChild("Clothes"):FindFirstChild(Info["ClothingType"]) 
		and ReplicatedStorage:WaitForChild("Clothes")[Info["ClothingType"]]:FindFirstChild(Info["ClothingColor"]) then
			NewSave["Equips"]["Body"] = {Item = Info["ClothingColor"] .. "Clothing" .. tostring(Info["ClothingType"]), Count = 1}
		end
		
		if ReplicatedStorage:WaitForChild("Shoes"):FindFirstChild(Info["ShoeType"]) 
		and ReplicatedStorage:WaitForChild("Shoes")[Info["ShoeType"]]:FindFirstChild(Info["ShoeColor"]) then
			NewSave["Equips"]["Feet"] = {Item = Info["ShoeColor"] .. "Shoes" .. tostring(Info["ShoeType"]), Count = 1}
		end
		
		SESSION_DATA[ID] = NewSave
	end
	
	if not SESSION_DATA[ID] then return end
	save_data(ID, SESSION_DATA[ID])
	TPService:Teleport(SESSION_DATA[ID]["SpawnPlace"], Player)
end)
