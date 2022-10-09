local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RepModules = ReplicatedStorage:WaitForChild("Modules")

local ServerStorage = game:GetService("ServerStorage")
local ServerModuleData = ServerStorage:WaitForChild("ModuleData")
local ServerModuleFunctions = ServerStorage:WaitForChild("ModuleFunctions")
local Equips = ServerStorage:WaitForChild("Equips")

local ResetAnimation = Remotes:WaitForChild("ResetAnimation")
local PS = game:GetService("PhysicsService")

local EquipsData = require(ServerModuleData:WaitForChild("Equips"))
local SESSION_DATA = require(ServerStorage:WaitForChild("Data"))
local SharedEffects = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SharedEffects"))
local DisplayInfo = require(RepModules:WaitForChild("DisplayInfo"))

local G = {}

G.SetModelCollisionGroup = function(Model, CollisionGroupName)
	for i,v in pairs(Model:GetDescendants()) do
		if v:IsA("BasePart") then
			PS:SetPartCollisionGroup(v, CollisionGroupName)
		end
	end
end

G.Walkspeed = function(Player)
	if Player:WaitForChild("Gameplay"):WaitForChild("Sprinting").Value then
		return (9 + SESSION_DATA[Player.UserId]["Stats"]["Stamina"] * 0.075) + 6
	else
		return 9 + SESSION_DATA[Player.UserId]["Stats"]["Stamina"] * 0.075
	end
end

G.CalculateLuck = function(Min, Max, Player)
	return math.random(Min,Max) < SESSION_DATA[Player.UserId]["Stats"]["Fortune"]
end

G.CheckCharacter = function(Player)
	if Player.Character and Player.Character:FindFirstChild("Head") 
	and Player.Character:FindFirstChild("HumanoidRootPart")
	and Player.Character:FindFirstChild("Torso")
	and Player.Character:FindFirstChild("RightLeg")
	and Player.Character:FindFirstChild("LeftLeg")
	and Player.Character:FindFirstChild("RightArm")
	and Player.Character:FindFirstChild("LeftArm") then
		return true
	else
		return false
	end
end


local DeathAnimation = Instance.new("Animation")
DeathAnimation.AnimationId = "rbxassetid://04465208823"
G.MainDeathFunction = function(Player)
	repeat wait() until Player.Character
	local Character = Player.Character
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	if not Player:WaitForChild("Gameplay"):WaitForChild("Reset").Value and Humanoid then
		Humanoid:LoadAnimation(DeathAnimation):Play()
	end
	if Character:FindFirstChild("HumanoidRootPart") then
		Character.HumanoidRootPart.Anchored = true
	end
	
	wait(.25)
	SharedEffects.MakeDeathParticle(Character, .75, 8)
	wait(3.5)
	G.load_player(Player)
end

local Facials = ServerStorage:WaitForChild("Customizables"):WaitForChild("FacialHairs")
local Hairs = ServerStorage:WaitForChild("Customizables"):WaitForChild("Hairs")
AddHair = function(Player)
	local ID = Player.UserId
	while not Player.Character do wait() end
	local Character = Player.Character
	local Head = Character:WaitForChild("Head")
	if Character:FindFirstChild("HairTag", true) then
		Character:FindFirstChild("HairTag", true).Parent:Destroy()
	end
	
	if SESSION_DATA[ID]["Character"]["HairType"] and Hairs:FindFirstChild(SESSION_DATA[ID]["Character"]["HairType"]) then
		local HairClone = Hairs:WaitForChild(SESSION_DATA[ID]["Character"]["HairType"]):Clone()
		for i,v in pairs(HairClone:GetDescendants()) do
			if v:IsA("BasePart") then
				PS:SetPartCollisionGroup(v, "Uncollidable")
				v.CanCollide = false
				v.Anchored = false
			end
		end
		local HairTag = Instance.new("StringValue")
		HairTag.Name = "HairTag"
		HairTag.Parent = HairClone
		HairClone:SetPrimaryPartCFrame(Head.CFrame)
		HairClone:WaitForChild("Anchor"):WaitForChild("Weld").Part0 = Head
		HairClone:WaitForChild("Model").BrickColor = BrickColor.new(SESSION_DATA[ID]["Character"]["HairColor"] or "Really black")
		HairClone.Parent = Character
	end
end

AddFacialHair = function(Player, Type)
	local ID = Player.UserId
	while not Player.Character do wait() end
	local Character = Player.Character
	local Head = Character:WaitForChild("Head")
	local Tag = Type.."Tag"
	if Character:FindFirstChild(Tag, true) then
		Character:FindFirstChild(Tag, true).Parent:Destroy()
	end
	
	if SESSION_DATA[ID]["Character"][Type] and Facials:FindFirstChild(SESSION_DATA[ID]["Character"][Type]) then
		local FacialHairClone = Facials:WaitForChild(SESSION_DATA[ID]["Character"][Type]):Clone()
		for i,v in pairs(FacialHairClone:GetDescendants()) do
			if v:IsA("BasePart") then
				PS:SetPartCollisionGroup(v, "Uncollidable")
				v.CanCollide = false
				v.Anchored = false
			end
		end
		local FacialHairTag = Instance.new("StringValue")
		FacialHairTag.Name = Tag
		FacialHairTag.Parent = FacialHairClone
		FacialHairClone:SetPrimaryPartCFrame(Head.CFrame)
		FacialHairClone:WaitForChild("Anchor"):WaitForChild("Weld").Part0 = Head
		FacialHairClone:WaitForChild("Model").BrickColor = BrickColor.new(SESSION_DATA[ID]["Character"]["HairColor"] or "Really black")
		FacialHairClone.Parent = Character
	end
end

G.load_player = function(Player)
	if Player:WaitForChild("Gameplay"):WaitForChild("Loading").Value then return end
	Player:WaitForChild("Gameplay"):WaitForChild("Loading").Value = true
	local ID = Player.UserId
	repeat wait() until SESSION_DATA[ID]
	local BodyColor = BrickColor.new(tostring(SESSION_DATA[ID]["Character"]["BodyColor"]) or "Medium stone grey")
	local EyeColor = BrickColor.new(tostring(SESSION_DATA[ID]["Character"]["EyeColor"]) or "Really black")
	
	Player:WaitForChild("Values"):WaitForChild("Health").Value = Player.Values:WaitForChild("MaxHealth").Value
	Player:WaitForChild("Values"):WaitForChild("Mana").Value = Player.Values:WaitForChild("MaxMana").Value
	Player:WaitForChild("Values"):WaitForChild("Hunger").Value = Player.Values:WaitForChild("MaxHunger").Value
	Player:WaitForChild("Gameplay"):WaitForChild("Reset").Value = false
	Player:WaitForChild("Gameplay"):WaitForChild("Sprinting").Value = false
	Player:WaitForChild("Gameplay"):WaitForChild("Screenshake").Value = 0
	Player:WaitForChild("Gameplay"):WaitForChild("Attacking").Value = false
	Player:WaitForChild("Gameplay"):WaitForChild("Equipped").Value = false
	
	for i,SkillCooldown in pairs(Player:WaitForChild("PlayingSkills"):GetChildren()) do
		SkillCooldown.Value = false
	end

	Player:LoadCharacter() 
	
	repeat wait() until Player.Character local c = Player.Character
	c.Parent = workspace:WaitForChild("Players")
	local Humanoid = c:WaitForChild("Humanoid")
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	
	local HumanoidRootPart = c:WaitForChild("HumanoidRootPart")
	local Sprinting = Player:WaitForChild("Gameplay"):WaitForChild("Sprinting")
	local Health = Player:WaitForChild("Values"):WaitForChild("Health")
	local MaxHealth = Player:WaitForChild("Values"):WaitForChild("MaxHealth")
	
	c:WaitForChild("Humanoid").WalkSpeed = G.Walkspeed(Player)
	c.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	c.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	
	c:WaitForChild("LeftArm").BrickColor = BodyColor
	c:WaitForChild("RightArm").BrickColor = BodyColor
	c:WaitForChild("Head").BrickColor = BodyColor
	c:WaitForChild("Torso").BrickColor = BodyColor
	c:WaitForChild("LeftLeg").BrickColor = BodyColor 
	c:WaitForChild("RightLeg").BrickColor = BodyColor 
	
	c.Head:WaitForChild("RightEye").BrickColor = EyeColor
	c.Head:WaitForChild("LeftEye").BrickColor = EyeColor
	
	PS:SetPartCollisionGroup(c:WaitForChild("LeftArm"), "Rigparts")
	PS:SetPartCollisionGroup(c:WaitForChild("RightArm"), "Rigparts")
	
	AddHair(Player)
	AddFacialHair(Player, "PrimaryFacialHairType")
	AddFacialHair(Player, "SecondaryFacialHairType")
	
	G.UpdateCharacter(Player)
	
	Health.Changed:Connect(function(NH)
		if NH == 0 then
			G.MainDeathFunction(Player)
		end
	end)
	Player:WaitForChild("Gameplay"):WaitForChild("Loading").Value = false
end

G.INIT = function(Player)
	local ID = Player.UserId
	local Gameplay = Instance.new("Folder") Gameplay.Name = "Gameplay" Gameplay.Parent = Player
	local Loading = Instance.new("BoolValue") Loading.Name = "Loading" Loading.Value = false Loading.Parent = Gameplay
	local Sprinting = Instance.new("BoolValue") Sprinting.Name = "Sprinting" Sprinting.Value = false Sprinting.Parent = Gameplay
	local Equipped = Instance.new("BoolValue") Equipped.Name = "Equipped" Equipped.Value = false Equipped.Parent = Gameplay
	local Attacking = Instance.new("BoolValue") Attacking.Name = "Attacking" Attacking.Value = false Attacking.Parent = Gameplay
	local Reset = Instance.new("BoolValue") Reset.Name = "Reset" Reset.Value = false Reset.Parent = Gameplay
	local Screenshake = Instance.new("IntValue") Screenshake.Name = "Screenshake" Screenshake.Value = 0 Screenshake.Parent = Gameplay
	
	local PlayingSkills = Instance.new("Folder") PlayingSkills.Name = "PlayingSkills" PlayingSkills.Parent = Player
	local Weapon = Instance.new("BoolValue") Weapon.Name = "Weapon" Weapon.Value = false Weapon.Parent = PlayingSkills
	local One = Instance.new("BoolValue") One.Name = "1" One.Value = false One.Parent = PlayingSkills
	local Two = Instance.new("BoolValue") Two.Name = "2" Two.Value = false Two.Parent = PlayingSkills
	local Three = Instance.new("BoolValue") Three.Name = "3" Three.Value = false Three.Parent = PlayingSkills
	local Four = Instance.new("BoolValue") Four.Name = "4" Four.Value = false Four.Parent = PlayingSkills
	local Five = Instance.new("BoolValue") Five.Name = "5" Five.Value = false Five.Parent = PlayingSkills 
	
	local Values = Instance.new("Folder") Values.Name = "Values" Values.Parent = Player
	local MaxHealth = Instance.new("NumberValue") MaxHealth.Value = 100 + SESSION_DATA[ID]["Stats"]["Vitality"] * 10 MaxHealth.Name = "MaxHealth" MaxHealth.Parent = Values
	local Health = Instance.new("NumberValue") Health.Name = "Health" Health.Value = MaxHealth.Value Health.Parent = Values
	local MaxMana = Instance.new("NumberValue") MaxMana.Value = 100 + SESSION_DATA[ID]["Stats"]["Wisdom"] * 3 MaxMana.Name = "MaxMana" MaxMana.Parent = Values 
	local Mana = Instance.new("NumberValue") Mana.Name = "Mana" Mana.Value = MaxMana.Value Mana.Parent = Values
	local MaxHunger = Instance.new("NumberValue") MaxHunger.Value = 100 MaxHunger.Name = "MaxHunger" MaxHunger.Parent = Values
	local Hunger = Instance.new("NumberValue") Hunger.Name = "Hunger" Hunger.Value = MaxHunger.Value Hunger.Parent = Values
	local MaxExperience = Instance.new("IntValue") MaxExperience.Value = 20 + (math.pow(SESSION_DATA[ID]["Level"]-1,1.5) * 50) MaxExperience.Name = "MaxExperience" MaxExperience.Parent = Values
	local Experience = Instance.new("IntValue") Experience.Value = SESSION_DATA[ID]["Experience"] Experience.Name = "Experience" Experience.Parent = Values
	
	local Cooldowns = Instance.new("Folder") Cooldowns.Name = "Cooldowns" Cooldowns.Parent = Player
	
	local VoiceTone = Instance.new("NumberValue") VoiceTone.Name = "VoiceTone" VoiceTone.Value = SESSION_DATA[ID]["VoiceTone"] VoiceTone.Parent = Player
	
	G.load_player(Player)
	
	if SESSION_DATA[ID]["SpawnPosition"] then
		Player.Character:SetPrimaryPartCFrame(CFrame.new(Vector3.new(SESSION_DATA[ID]["SpawnPosition"]:match("(.+), (.+), (.+)"))))
	end
	
	Experience.Changed:Connect(function()
		if Experience.Value >= MaxExperience.Value then
			while Experience.Value >= MaxExperience.Value do
				SESSION_DATA[ID]["Level"] = SESSION_DATA[ID]["Level"] + 1
				SESSION_DATA[ID]["Stats"]["SP"] = SESSION_DATA[ID]["Stats"]["SP"] + 3
				Experience.Value = Experience.Value - MaxExperience.Value
				MaxExperience.Value = 20 + (math.pow(SESSION_DATA[ID]["Level"]-1,1.5) * 50)	
			end
		end
		SESSION_DATA[ID]["Experience"] = Experience.Value
	end)

	MaxHealth.Changed:Connect(function()
		Health.Value = MaxHealth.Value
	end)
	MaxMana.Changed:Connect(function()
		Mana.Value = MaxMana.Value
	end)
end

--Character stuff from here
AddStats = function(Player)
	local ID = Player.UserId
	SESSION_DATA["Bonuses"][ID] = {}	
	
	for i,v in pairs(SESSION_DATA[ID]["Equips"]) do
		if v["Item"] ~= "None" and EquipsData[v["Item"]] and EquipsData[v["Item"]]["StatBonuses"] then
			for Stat, Bonus in pairs(EquipsData[v["Item"]]["StatBonuses"]) do
				if not SESSION_DATA["Bonuses"][ID][Stat] then
					SESSION_DATA["Bonuses"][ID][Stat] = 0
				end
				SESSION_DATA["Bonuses"][ID][Stat] = SESSION_DATA["Bonuses"][ID][Stat] + Bonus
			end
		end
		if v["Item"] ~= "None" and EquipsData[v["Item"]] and EquipsData[v["Item"]["SkillBonuses"]] then
			for i, Skill in pairs(EquipsData[v["Item"]]["SkillBonuses"]) do
				
			end
		end
	end
	print("--Stat Bonuses--")
	print(game:GetService("HttpService"):JSONEncode(SESSION_DATA["Bonuses"][ID]))
end

AddArmor = function(Player, Item, Type)
	if Equips:FindFirstChild(Item, true) then 
		repeat wait() until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		local Character = Player.Character
		local EquipCopy = Equips:FindFirstChild(Item, true):Clone()
		
		for i,v in pairs(EquipCopy:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("UnionOperation") then
				PS:SetPartCollisionGroup(v, "Uncollidable")
			end
		end
	
		local EquipTag = Instance.new("StringValue")
		EquipTag.Name = Type.."Tag"
		EquipTag.Parent = EquipCopy
		
		for i,v in pairs(EquipCopy:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Massless = true
			end
		end

		G.SetModelCollisionGroup(EquipCopy, "Uncollidable")
		
		EquipCopy.Parent = Character
		for i,v in pairs(EquipCopy:GetChildren()) do
			if v.ClassName == "Model" then
				local Weld = v:WaitForChild("Anchor"):WaitForChild("Weld")
				Weld.Part1 = v:WaitForChild("Anchor")
				v:SetPrimaryPartCFrame(Character:WaitForChild(v.Name).CFrame)
				Weld.Part0 = Character[v.Name]
			end
		end
	end
end

AddSkills = function(Player)
	for i,v in pairs(SESSION_DATA[Player.UserId]["Slots"]) do
		if v ~= "" and ServerStorage:WaitForChild("Skills"):FindFirstChild(v) then
			if Player:WaitForChild("Backpack"):FindFirstChild(v) then
				if Player.Backpack:FindFirstChild(v) then
					local KeyCode = Player.Backpack[v]:WaitForChild("KeyCode")
					if i == "Slot1" then
						KeyCode.Value = Enum.KeyCode.One.Value
					elseif i == "Slot2" then
						KeyCode.Value = Enum.KeyCode.Two.Value
					elseif i == "Slot3" then
						KeyCode.Value = Enum.KeyCode.Three.Value
					elseif i == "Slot4" then
						KeyCode.Value = Enum.KeyCode.Four.Value
					elseif i == "Slot5" then
						KeyCode.Value = Enum.KeyCode.Five.Value
					elseif i == "SlotR" then
						KeyCode.Value = Enum.KeyCode.R.Value
					elseif i == "SlotF" then
						KeyCode.Value = Enum.KeyCode.F.Value
					else
						KeyCode.Value = Enum.KeyCode.T.Value
					end
				end
			else
				local SkillCopy = ServerStorage.Skills[v]:Clone()
				SkillCopy.Parent = Player:WaitForChild("Backpack")
				local KeyCode = Instance.new("IntValue")
				KeyCode.Name = "KeyCode"
			
				if i == "Slot1" then
					KeyCode.Value = Enum.KeyCode.One.Value
				elseif i == "Slot2" then
					KeyCode.Value = Enum.KeyCode.Two.Value
				elseif i == "Slot3" then
					KeyCode.Value = Enum.KeyCode.Three.Value
				elseif i == "Slot4" then
					KeyCode.Value = Enum.KeyCode.Four.Value
				elseif i == "Slot5" then
					KeyCode.Value = Enum.KeyCode.Five.Value
				elseif i == "SlotR" then
					KeyCode.Value = Enum.KeyCode.R.Value
				elseif i == "SlotF" then
					KeyCode.Value = Enum.KeyCode.F.Value
				else
					KeyCode.Value = Enum.KeyCode.T.Value
				end
				KeyCode.Parent = SkillCopy
				SkillCopy.Disabled = false
				if SkillCopy:FindFirstChild("Handle") then
					SkillCopy.Handle.Disabled = false
				end
			end
		end
	end
end

AddWeapon = function(Player)
	local ID = Player.UserId
	while not Player.Character do wait() end
	local Character = Player.Character
		
	local EquipName = SESSION_DATA[ID]["Equips"]["Weapon"]["Item"]
	
	if not Equips:FindFirstChild(EquipName, true) or not EquipsData[EquipName] then return end
	local Equip = Equips:FindFirstChild(EquipName, true):Clone()
	local EquipTag = Instance.new("StringValue")
	EquipTag.Name = "WeaponTag"
	EquipTag.Parent = Equip

	G.SetModelCollisionGroup(Equip, "Uncollidable")
	for i,v in pairs(Equip:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Massless = true
		end
	end		
	Equip.Parent = Character
	
	Equip:WaitForChild("Main").Disabled = false
	Equip.Main:WaitForChild("Handle").Disabled = false
	if Equip:FindFirstChild("Skill") then
		Equip.Skill.Disabled = false
		Equip.Skill:WaitForChild("Handle").Disabled = false
	end
	
	Equip.AncestryChanged:Connect(function(Child, Parent)
		if Parent == nil then
			Player:WaitForChild("Gameplay"):WaitForChild("Attacking").Value = false
			Player:WaitForChild("Gameplay"):WaitForChild("Equipped").Value = false
			ResetAnimation:FireClient(Player)
		end
	end)
end

G.UpdateCharacter = function(Player)
	while not Player.Character do wait() end
	if G.CheckCharacter(Player) then
		local ID = Player.UserId
		
		local Character = Player.Character
		Character:WaitForChild("HumanoidRootPart"):WaitForChild("GUI"):WaitForChild("PlayerName").Text = tostring(Player)
		
		local EquippedTitleIndex = SESSION_DATA[ID]["EquippedTitleIndex"]
		if EquippedTitleIndex and type(EquippedTitleIndex) == "number" and SESSION_DATA[ID]["TitlesInventory"][EquippedTitleIndex] then
			Character:WaitForChild("HumanoidRootPart"):WaitForChild("GUI"):WaitForChild("Title").Text = SESSION_DATA[ID]["TitlesInventory"][EquippedTitleIndex]
		else
			Character.HumanoidRootPart.GUI.Title.Text = ""
		end
		
		for Type, Item in pairs(SESSION_DATA[ID]["Vanity"]) do
			if Item["Item"] ~= "None" then
				if Player.Character:FindFirstChild(tostring(Type).."Tag", true) 
				and Player.Character:FindFirstChild(tostring(Type).."Tag", true).Parent.Name ~= Item["Item"] then
					Player.Character:FindFirstChild(tostring(Type).."Tag", true).Parent:Destroy()
					AddArmor(Player, Item["Item"], Type)
				elseif not Player.Character:FindFirstChild(tostring(Type).."Tag", true) then
					AddArmor(Player, Item["Item"], Type)
				end
			else
				if SESSION_DATA[ID]["Equips"][Type]["Item"] ~= "None" then
					if Player.Character:FindFirstChild(tostring(Type).."Tag", true) 
					and Player.Character:FindFirstChild(tostring(Type).."Tag", true).Parent.Name ~= SESSION_DATA[ID]["Equips"][Type]["Item"] then
						Player.Character:FindFirstChild(tostring(Type).."Tag", true).Parent:Destroy()
						AddArmor(Player, SESSION_DATA[ID]["Equips"][Type]["Item"], Type)
					elseif not Player.Character:FindFirstChild(tostring(Type).."Tag", true) then
						AddArmor(Player, SESSION_DATA[ID]["Equips"][Type]["Item"], Type)
					end
				else
					if Player.Character:FindFirstChild(tostring(Type).."Tag", true) then
						Player.Character:FindFirstChild(tostring(Type).."Tag", true).Parent:Destroy()
					end
				end
			end
		end
		local WeaponAbility = Player.PlayerGui:WaitForChild("Main"):WaitForChild("WeaponAbility"):WaitForChild("Display"):WaitForChild("ImageHolder"):WaitForChild("Display")
		WeaponAbility.Image = DisplayInfo["Skills"][SESSION_DATA[ID]["Equips"]["Weapon"]["Item"]]["Image"] or "http://www.roblox.com/asset/?id=4535451740"
		
		if SESSION_DATA[ID]["Equips"]["Weapon"]["Item"] ~= "None" 
		and Equips:FindFirstChild(SESSION_DATA[ID]["Equips"]["Weapon"]["Item"], true) 
		and G.CheckCharacter(Player) then
			if Player.Character:FindFirstChild("WeaponTag", true) and Player.Character:FindFirstChild("WeaponTag", true).Parent.Name ~= SESSION_DATA[ID]["Equips"]["Weapon"]["Item"] then
				Player.Character:FindFirstChild("WeaponTag", true).Parent:Destroy()
				AddWeapon(Player)
			elseif not Player.Character:FindFirstChild("WeaponTag", true) then
				AddWeapon(Player)
			end
		elseif SESSION_DATA[ID]["Equips"]["Weapon"]["Item"] == "None" 
		and G.CheckCharacter(Player) and Player.Character:FindFirstChild("WeaponTag", true) then
			Player.Character:FindFirstChild("WeaponTag", true).Parent:Destroy()
		end
		AddSkills(Player)
		AddStats(Player)
	end
end

return G
