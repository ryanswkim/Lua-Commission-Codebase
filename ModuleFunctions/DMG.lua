local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModuleFunctions = ServerStorage:WaitForChild("ModuleData")
local ModuleData = ServerStorage:WaitForChild("ModuleData")

local MobData = require(ModuleData:WaitForChild("MobData"))
local RegMod = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RegionModule"))
local EquipsData = require(ModuleData:WaitForChild("Equips"))
local SESSION_DATA = require(ServerStorage:WaitForChild("Data"))
local Bonuses = SESSION_DATA["Bonuses"]

-- Config:

local DMG = {}
DMG["MAX_MELEE_RANGE"] = 20

local function AddStatus(Mob, Name, Value)
	local StatusTags = Mob:FindFirstChild("StatusTags")
	if not StatusTags then return end
	local DurationValue = 1 or Value
	local StatusTag = Instance.new("IntValue")
	StatusTag.Name = Name
	StatusTag.Value = Value
	StatusTag.Parent = StatusTags
	return StatusTag
end

DMG.CalculateDamage = function(Player, Base, Scalings, MaxRange, LuckProbability, LuckScaling)
	local ID = Player.UserId
	local Damage = Base
	local playerStats = SESSION_DATA[ID]["Stats"]
	
	--print("Base Damage: " .. Damage)
	
	for Stat, Scaling in pairs(Scalings) do
		local TotalStat = playerStats[Stat]
		if Bonuses[ID] and Bonuses[ID][Stat] then
			TotalStat = TotalStat + Bonuses[ID][Stat]
		end
		Damage = Damage + math.floor(TotalStat * Scaling)
	end
	
	--print("Damage after stats: " .. Damage)
	
	Damage = math.max(Damage + math.random(-MaxRange,MaxRange), 1)
	
	--print("Damage after randomizing: " .. Damage)
	
	local Lucky = false
	if LuckProbability and LuckScaling and math.random(0, 1000) * playerStats["Fortune"] > LuckProbability then
		Lucky = true
		Damage = math.floor(Damage * LuckScaling)
	end
	
	--print("Damage after calculating lucky hit: " .. Damage)
	
	return math.floor(Damage), Lucky
end

DMG.Soak = function(HitModels, Duration)
	if type(HitModels) ~= "table" then
		HitModels = {HitModels}
	end
	for i, Target in pairs(HitModels) do
		coroutine.resume(coroutine.create(function()
			local StatusTags = Target:FindFirstChild("StatusTags", true)
			local HitModelHRP = Target:FindFirstChild("HumanoidRootPart", true)
			if StatusTags and HitModelHRP then
				local BurnTags = 0
				for i,Tag in pairs(StatusTags:GetChildren()) do
					if string.find(string.lower(Tag.Name), "burn") then
						BurnTags = BurnTags + 1
						Tag:Destroy()
					end
				end
				if BurnTags > 0 then
					AddStatus(Target, "Smoke", 1)
				else
					if StatusTags:FindFirstChild("Soak", true) then
						StatusTags:FindFirstChild("Soak", true).Value = math.max(StatusTags:FindFirstChild("Soak", true).Value, Duration)
					else
						AddStatus(Target, "Soak", Duration)
					end
				end
			end
		end))
	end
end

DMG.Burn = function(Player, HitMobs, Intensity, MaxTimes, Interval)
	if type(HitMobs) ~= "table" then
		HitMobs = {HitMobs}
	end
	for i,Target in pairs(HitMobs) do
		coroutine.resume(coroutine.create(function()
			local Health = Target:FindFirstChild("Health", true)
			local StatusTags = Target:FindFirstChild("StatusTags", true)
			if Health and Target:FindFirstChild("HumanoidRootPart", true) and StatusTags and Health.Value > 0 then
				local HRP = Target:FindFirstChild("HumanoidRootPart", true)
				if StatusTags:FindFirstChild("Soak") then
					for i,SoakTag in pairs(StatusTags:GetChildren()) do
						if SoakTag.Name == "Soak" then
							SoakTag:Destroy()
						end
					end
					AddStatus(Target, "Smoke", 1)
				else
					if StatusTags:FindFirstChild(tostring(Player.UserId).."Burn") then
						StatusTags:FindFirstChild(tostring(Player.UserId).."Burn").Value = math.max(StatusTags:FindFirstChild(tostring(Player.UserId).."Burn").Value, MaxTimes)
					else	
						local StatusTag = AddStatus(Target, tostring(Player.UserId).."Burn", MaxTimes)			
						local CurrentValue = StatusTag.Value
						StatusTag.Changed:Connect(function(NewValue)
							if CurrentValue > NewValue and Health.Value > 0 then
								local Damage = math.min(Health.Value, math.max(1, Intensity + math.random(-3,3)))		
								Health.Value = Health.Value - Damage
								DMG.CheckTags(Player, Target, Damage)
							end
							CurrentValue = NewValue
						end)
					end
				end
			end
		end))
	end
end

DMG.CreateGUI = function(Damage, Color, Target)
	local HRP = Target:FindFirstChild("HumanoidRootPart", true)
	if HRP then
		local GUI = ReplicatedStorage:WaitForChild("Effects"):WaitForChild("BaseGUI"):Clone() 
		GUI.Position = Target:FindFirstChild("HumanoidRootPart", true).Position + Vector3.new(math.random(-1,1), math.random(1.2,2.4), math.random(-1,1))
		local GUIText = GUI:WaitForChild("B"):WaitForChild("L")
		GUIText.Text = Damage
		GUIText.TextColor3 = Color
		GUI.Parent = workspace:WaitForChild("Junk")
		Debris:AddItem(GUI, 1)
	end
end

DMG.Knockback = function(InitialPosition, HitModels, Range, X, Y, Z, Persistence, Optional)
	for i,HitModel in pairs(HitModels) do
		if HitModel:FindFirstChild("HumanoidRootPart", true) and MobData[HitModel.Name] and MobData[HitModel.Name]["Knockable"] then
			local HitModelHRP = HitModel:FindFirstChild("HumanoidRootPart", true)
			if HitModelHRP then
				local VelocityMagnitude = (Range - (HitModelHRP.Position - InitialPosition).Magnitude)/Range
				local Impulse = Instance.new("BodyVelocity")
				local ImpulseDirection = CFrame.new(InitialPosition, HitModelHRP.Position).LookVector
				
				Impulse.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				Impulse.Velocity = Vector3.new(ImpulseDirection.X/math.abs(ImpulseDirection.X) * X,Y,ImpulseDirection.Z/math.abs(ImpulseDirection.Z) * Z) * VelocityMagnitude
				Impulse.Parent = HitModelHRP
				game:GetService("Debris"):AddItem(Impulse, Persistence)
			end	
		end
	end
end

DMG.EnemiesInHB = function(HBSize,HBPosition)
	local HB = Instance.new("Part")
	HB.Size = Vector3.new(HBSize,HBSize,HBSize)
	HB.Position = HBPosition
	HB.Anchored = true
	HB.Transparency = 1
	HB.CanCollide = false
	local HBRegion = RegMod.FromPart(HB)
	local HBTable = HBRegion.Cast(HBRegion)
	local HitModels = {}
	for i,BodyPart in pairs(HBTable) do
		if BodyPart:FindFirstAncestorWhichIsA("Model") and BodyPart:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Health", true) 
		and BodyPart:IsA("BasePart") then
			local InHitModels = false
			for i,HitModel in pairs(HitModels) do
				if HitModel == BodyPart:FindFirstAncestorWhichIsA("Model") then
					InHitModels = true
					break
				end
			end
			if not InHitModels and BodyPart:FindFirstAncestor("Targetable") then
				table.insert(HitModels, BodyPart:FindFirstAncestorWhichIsA("Model"))
			end
		end
	end
	return HitModels
end

DMG.PlayerAreaDamage = function(Player, DamageTable, HitMobs, SkillTag)
	for i,Target in pairs(HitMobs) do
		if Target:FindFirstChild("Debounces", true) 
		and not Target:FindFirstChild("Debounces", true):FindFirstChild(SkillTag) then
			local DebounceTag = Instance.new("StringValue")
			DebounceTag.Name = SkillTag
			DebounceTag.Parent = Target:FindFirstChild("Debounces", true)
			Debris:AddItem(DebounceTag, 0.03)
			if Target:FindFirstChild("Health", true) and Target:FindFirstChild("Health", true).Value > 0 then
				local Damage = DMG.CalculateDamage(Player, DamageTable["Base"], DamageTable["Scalings"], DamageTable["Range"], DamageTable["LuckProbability"], DamageTable["LuckScaling"])
				local Health = Target:FindFirstChild("Health", true)
				Damage = math.min(Health.Value, Damage)
				
				Health.Value = Health.Value - Damage
				DMG.CheckTags(Player, Target, Damage)
			end
		end
	end
end

DMG.CheckTags = function(Player, Target, Damage)
	if not Target:FindFirstChild("PlayerTags", true) then
		local PlayerTags = Instance.new("Folder")
		PlayerTags.Name = "PlayerTags"
		PlayerTags.Parent = Target
	end
	if Target:WaitForChild("PlayerTags"):FindFirstChild(tostring(Player.UserId)) then
		Target.PlayerTags[tostring(Player.UserId)].Value = Target.PlayerTags[tostring(Player.UserId)].Value + Damage
	else
		local NewPlayerTag = Instance.new("IntValue")
		NewPlayerTag.Name = tostring(Player.UserId)
		NewPlayerTag.Value = Damage
		NewPlayerTag.Parent = Target.PlayerTags
	end
end

DMG.PlayerDamage = function(Player, Target, Position)
	if not Target:FindFirstAncestor("Targetable") 
	or not Player.Character 
	or not Player.Character:FindFirstChild("WeaponTag", true) then return end
	
	if not Player.Character:FindFirstChild("HumanoidRootPart") 
	or not Target:FindFirstChild("HumanoidRootPart") 
	or (Player.Character.HumanoidRootPart.Position - Position).Magnitude > DMG["MAX_MELEE_RANGE"] then return end
	
	local BasicAttackTag = Instance.new("ObjectValue")
	BasicAttackTag.Name = "BasicAttack"
	BasicAttackTag.Value = Target
	
	local PositionTag = Instance.new("Vector3Value")
	PositionTag.Name = "Position"
	PositionTag.Value = Position
	PositionTag.Parent = BasicAttackTag

	local WeaponTag = Instance.new("StringValue")
	WeaponTag.Name = "Weapon"
	WeaponTag.Value = Player.Character:FindFirstChild("WeaponTag", true).Parent.Name
	WeaponTag.Parent = BasicAttackTag

	local IDTag = Instance.new("NumberValue")
	IDTag.Name = "ID"
	IDTag.Value = Player.UserId
	IDTag.Parent = BasicAttackTag
	
	BasicAttackTag.Parent = workspace:WaitForChild("Junk")
	
	local ID = Player.UserId
	if not Target:FindFirstChild("Health") or not EquipsData[Player.Character:FindFirstChild("WeaponTag", true).Parent.Name] then return end
	local Weapon = EquipsData[Player.Character:FindFirstChild("WeaponTag", true).Parent.Name]
	
	local Damage, Lucky = DMG.CalculateDamage(Player, Weapon["Damage"], {Attack = 1}, Weapon["DamageRange"], 0, 950)
	local Health = Target.Health
	
	Damage = math.min(Health.Value, Damage)
	Target.Health.Value = Health.Value - Damage
	DMG.CheckTags(Player, Target, Damage)
	Debris:AddItem(BasicAttackTag, .25)
end
	
return DMG
