-- Services:
local ServerStorage = game:GetService("ServerStorage")
local PS = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules:
local ModuleData = ServerStorage:WaitForChild("ModuleData")
local SESSION_DATA = require(ServerStorage:WaitForChild("Data"))
local ItemInfo = require(ModuleData:WaitForChild("Items"))
local cache = require(ServerStorage:WaitForChild("Cache"))
local MobData = require(ModuleData:WaitForChild("MobData"))
local SharedEffects = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SharedEffects"))

-- Remotes:
local ItemDrop = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemDrop")

-- Variables:
local Targetable = workspace:WaitForChild("Targetable")
local ExistingMobs = {}

-- Config:
local SPAWN_INTERVAL = 5
local TRACK_INTERVAL = .5
local TRACK_INTERVAL = 1
local DROP_THRESHOLD = 0.7
local ITEM_DECAY = 90

--Functions
local function packV3(v3)
	return tostring(v3.X) .. ", " .. tostring(v3.Y) .. ", " .. tostring(v3.Z)
end

local function DistributeDrops(Mob)
	local Info = MobData[Mob.Name]
	if not Info then return end
	local MaxHealth = Info["MaxHealth"]
	local ItemDrops = Info["Drops"]
	if not Mob:FindFirstChild("HumanoidRootPart") or not Mob:FindFirstChild("PlayerTags") then return end
	local HRP = Mob.HumanoidRootPart
	for i,IDTag in pairs(Mob:WaitForChild("PlayerTags"):GetChildren()) do
		local player = Players:GetPlayerByUserId(IDTag.Name)
		if player and IDTag.Value > (DROP_THRESHOLD * MaxHealth / (#Mob:FindFirstChild("PlayerTags"):GetChildren()))  then
			local id = player.UserId
			if SESSION_DATA[id]["MobKills"][Mob.Name] then
				SESSION_DATA[id]["MobKills"][Mob.Name] = SESSION_DATA[id]["MobKills"][Mob.Name] + 1
			else
				SESSION_DATA[id]["MobKills"][Mob.Name] = 1
			end
			SESSION_DATA[id]["MobKills"]["Total"] = SESSION_DATA[id]["MobKills"]["Total"] + 1
			
			for i,v in pairs(ItemDrops) do
				if math.random(0,1000) < v["Chance"] then
					local ItemCount = math.random(1, v["MaxCount"])
					local X = HRP.Position.X + math.random(math.floor(-HRP.Size.X), math.floor(HRP.Size.X)) * math.random(0,10)/10
					local Z = HRP.Position.Z + math.random(math.floor(-HRP.Size.Z), math.floor(HRP.Size.Z)) * math.random(0,10)/10
					local yRay = Ray.new(Vector3.new(X, HRP.Position.Y, Z), Vector3.new(0, -500, 0))
					local Hit, HitPos = workspace:FindPartOnRayWithWhitelist(yRay, {workspace:WaitForChild("Map")})
					local Y 
					if Hit then
						Y = HitPos.Y + math.random(45, 55)/100
					else
						Y = HRP.Position.Y + math.random(-30, 30)/100
					end
					
					cache:cacheItem(player, i, ItemCount)
					ItemDrop:FireClient(player, packV3(Vector3.new(X,Y,Z)), ItemInfo[i]["Category"], i, ItemCount)
				end
			end
		end
	end
end

local function DistributeExperience(Mob)
	local Info = MobData[Mob.Name]
	local PlayerTags = Mob:FindFirstChild("PlayerTags")
	if not PlayerTags or not Info then return end
	if #PlayerTags:GetChildren() == 0 then
		PlayerTags.ChildAdded:Wait(5)
	end
	for i, ID in pairs(PlayerTags:GetChildren()) do
		if Players:GetPlayerByUserId(ID.Name) then
			local PlayerXP = Players:GetPlayerByUserId(ID.Name):WaitForChild("Values"):WaitForChild("Experience")
			PlayerXP.Value = PlayerXP.Value + math.floor(ID.Value/Info["MaxHealth"] * Info["Experience"])	
		end
	end
end

local function Die(Mob)
	local Humanoid = Mob:FindFirstChildWhichIsA("Humanoid")
	if not Humanoid or not MobData[Mob.Name] then
		Mob:Destroy()
		ExistingMobs[Mob.Name] = ExistingMobs[Mob.Name] - 1
		return
	end
	local Info = MobData[Mob.Name]
	
	local DeathAnimation = Instance.new("Animation")
	DeathAnimation.AnimationId = Info["DeathAnimation"]
	local PlayDeath = Humanoid:LoadAnimation(DeathAnimation)
	
	for i,v in pairs(Humanoid:GetPlayingAnimationTracks()) do
		v:Stop()
	end
	Mob:WaitForChild("HumanoidRootPart").Anchored = true
	PlayDeath:Play()
	
	spawn(function() DistributeExperience(Mob) end)
	wait(Info["PreFadeTime"] or 3)
	DistributeDrops(Mob)
	
	spawn(function() SharedEffects.MakeDeathParticle(Mob, Info["FadeTime"] or 2, Info["DeathParticleRate"] or 20) end)
	wait((Info["FadeTime"] or 2) * 2)
	Mob:Destroy()
	ExistingMobs[Mob.Name] = ExistingMobs[Mob.Name] - 1
end

local function Spawn(MobName, SpawnIndex)
	local Data = MobData[MobName]
	local MobCopy = script[MobName]:Clone()
	local HRP = MobCopy:WaitForChild("HumanoidRootPart")
	
	local MH = Instance.new("IntValue")
	MH.Name = "MaxHealth"
	MH.Value = Data["MaxHealth"]
	
	local H = Instance.new("IntValue")
	H.Name = "Health"
	H.Value = MH.Value
	
	local D = Instance.new("Folder")
	D.Name = "Debounces"
	
	local PT = Instance.new("Folder")
	PT.Name = "PlayerTags"
	
	local ST = Instance.new("Folder")
	ST.Name = "StatusTags"
	
	local T = Instance.new("ObjectValue")
	T.Name = "Target"
	
	local L = Instance.new("BoolValue")
	L.Name = "Locked"
	L.Value = false

	T.Parent = MobCopy
	PT.Parent = MobCopy
	ST.Parent = MobCopy
	D.Parent = MobCopy
	MH.Parent = MobCopy
	H.Parent = MobCopy
	L.Parent = MobCopy
	
	local Humanoid = MobCopy:FindFirstChild("Humanoid", true)
	if Humanoid then
		for _,State in pairs(Data["DisabledHumanoidStates"]) do
			Humanoid:SetStateEnabled(State, false)
		end
	end
	
	Humanoid.HealthChanged:Connect(function()
		H.Value = Humanoid.Health/Humanoid.MaxHealth * MH.Value
	end)
	H.Changed:Connect(function(NewHealth)
		if NewHealth == 0 then
			Die(MobCopy)
		end
	end)
	
	HRP.AncestryChanged:Connect(function(_, Parent)
		wait(5)
		if not Parent then
			H.Value = 0
		end
	end)
	
	local TotalMass = 0
	for _, TemplatePart in pairs(MobCopy:GetChildren()) do
		if TemplatePart:IsA("BasePart") then
			PS:SetPartCollisionGroup(TemplatePart, "Rigparts")
		end
	end
	
	local Bodyparts = MobCopy:WaitForChild("Bodyparts", 3)
	local Decor = MobCopy:WaitForChild("Decor", 3)
	
	if Bodyparts then
		for _, ModelPart in pairs(Bodyparts:GetChildren()) do
			PS:SetPartCollisionGroup(ModelPart, "Mob")
		end
	end
	
	if Decor then
		for _, ModelPart in pairs(Decor:GetChildren()) do
			PS:SetPartCollisionGroup(ModelPart, "Mob")
		end
	end
	
	ST.ChildAdded:Connect(function(Tag)
		while Tag.Parent == ST do
			if Tag.Value <= 0 or H.Value <= 0 then
				game:GetService("RunService").Heartbeat:Wait()
				Tag:Destroy()
			end
			Tag.Value = Tag.Value - 1
			wait(1)
		end
	end)

	MobCopy:SetPrimaryPartCFrame(CFrame.new(Vector3.new(unpack(Data["SpawnPoints"][SpawnIndex]))))
	MobCopy.Parent = Targetable
	
	ExistingMobs[MobName] = ExistingMobs[MobName] + 1
	
	MobCopy:WaitForChild("Animate").Disabled = false
	if MobCopy:FindFirstChild("SpecificAI", true) then --Bosses
		MobCopy:FindFirstChild("SpecificAI", true).Disabled = false
	end
end

coroutine.wrap(function() --Spawning mobs
	while wait(SPAWN_INTERVAL) do
		for MobName, Data in pairs(MobData) do --For each mob, check if there is space to spawn any
			if not ExistingMobs[MobName] then
				ExistingMobs[MobName] = 0
			end
			if ExistingMobs[MobName] < Data["MaxCount"] and script:FindFirstChild(MobName) and script[MobName]:FindFirstChild("Animate") then
				local MaxCount = math.min(Data["MaxCount"] - ExistingMobs[MobName], #Data["SpawnPoints"])
				local Count = 0
				local Index = 1
				repeat
					local Spawnable = true
					for i,Mob in pairs(Targetable:GetChildren()) do
						if not Mob:FindFirstChild("HumanoidRootPart") then continue end
						if (Vector3.new(unpack(Data["SpawnPoints"][Index])) - Mob.HumanoidRootPart.Position).Magnitude < math.min(MobData[Mob.Name]["SocialDistance"], Data["SocialDistance"]) then
							Spawnable = false
							break
						end
					end
					
					if Spawnable then
						Spawn(MobName, Index)
						Count = Count + 1
					end
					Index = Index + 1
				until Count >= MaxCount or Index >= #Data["SpawnPoints"]
			end	
		end
	end
end)()

local function RunFrom(Mob, Character)
	
end

local function RunTo(Mob, Character)
	local Humanoid = Mob:FindFirstChildWhichIsA("Humanoid")
	local CharHRP = Character:FindFirstChild("HumanoidRootPart")
	if not CharHRP or not Humanoid then return end
	
	local Info = MobData[Mob.Name]
	Humanoid:MoveTo(CharHRP.Position)
end

local function RunRandom(Mob)
	local Humanoid = Mob:FindFirstChildWhichIsA("Humanoid")
	local HRP = Mob:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not HRP then return end
	
	local Info = MobData[Mob.Name]
	local MoveRay = Ray.new(HRP.Position, Vector3.new(math.random(-100,100)/100, 0, math.random(-100,100)/100) * math.random(Info["MinDistance"], Info["MaxDistance"]))
	local FinalPart, FinalLocation = workspace:FindPartOnRayWithWhitelist(MoveRay, {workspace:WaitForChild("NPCs"), workspace:WaitForChild("Map"):WaitForChild("Collidable")})
	Humanoid:MoveTo(FinalLocation)
end

Targetable.ChildAdded:Connect(function(Mob)
	--Generic values
	local Health = Mob:WaitForChild("Health")
	local Info = MobData[Mob.Name]
	local Target = Mob:WaitForChild("Target")
	local Locked = Mob:WaitForChild("Locked")
	
	--Physical character
	local MobHRP = Mob:WaitForChild("HumanoidRootPart")
	local MobHumanoid = Mob:WaitForChild("Humanoid")
	local SpawnPoint = MobHRP.Position
	local WanderDistance = Info["WanderDistance"]
	
	--Behavior values
	local Behavior = Info["Behavior"]
	local Movement = Info["Movement"]
	local TrackingRange = Info["TrackingRange"] 
	local TargetedTrackingRange = Info["TargetedTrackingRange"]
	local MinTrackInterval = Info["MinTrackInterval"]
	local MaxTrackInterval = Info["MaxTrackInterval"]
	
	--Attacking values
	local AttackRange = Info["AttackRange"]
	local AttackCooldown = Info["AttackCooldown"]
	local Attacked = false
	local AttackFunction = Info.Attack
	
	
	while not MobHRP:CanSetNetworkOwnership() do wait()end
	MobHRP:SetNetworkOwner(nil)
	
	local CurrentTrackingRange = TrackingRange
	coroutine.wrap(function()
		while Health.Value > 0 do
			local TargetDistance = math.huge
			for i,Character in pairs(workspace:WaitForChild("Players"):GetChildren()) do
				local CharHRP = Character:FindFirstChild("HumanoidRootPart")
				if not CharHRP then continue end
				local Distance = (CharHRP.Position - MobHRP.Position).Magnitude
				if Distance < CurrentTrackingRange and Distance < TargetDistance then
					TargetDistance = Distance
					Target.Value = Character
				end
			end
			if TargetDistance == math.huge and not Locked.Value then
				CurrentTrackingRange = TrackingRange
				Target.Value = nil
			else
				CurrentTrackingRange = TargetedTrackingRange
			end
			wait(TRACK_INTERVAL)
		end
	end)()
	
	while Health.Value > 0 do
		if (MobHRP.Position - SpawnPoint).Magnitude > WanderDistance then
			MobHumanoid:MoveTo(SpawnPoint)
			wait((MobHRP.Position - SpawnPoint).Magnitude/MobHumanoid.WalkSpeed/4)
			continue
		end
		
		if Target.Value and Target.Value:FindFirstChild("HumanoidRootPart") then --If interacting with a player
			if Behavior == "Passive" then
			
			elseif Behavior == "Neutral" then
			
			elseif Behavior == "Hostile" then
				if Movement == "Linear" then
					if (Target.Value.HumanoidRootPart.Position - MobHRP.Position).Magnitude < AttackRange and not Attacked then
						MobHumanoid:MoveTo(MobHRP.Position)
						Attacked = true
						AttackFunction(Mob)
						coroutine.wrap(function()
							wait(AttackCooldown)
							Attacked = false
						end)()
					elseif (Target.Value.HumanoidRootPart.Position - MobHRP.Position).Magnitude > AttackRange then
						RunTo(Mob, Target.Value)
					end
					wait(.2)
				end
			end
		else --Nothing interfering with the mob
			if Behavior == "Passive" then
			
			elseif Behavior == "Neutral" then
			
			elseif Behavior == "Hostile" then
				if Movement == "Linear" then
					RunRandom(Mob)
					for i = 1, math.random(MinTrackInterval, MaxTrackInterval) * 4 do
						if Target.Value then break end
						wait(0.25)
					end
				end
			end
		end
	end
end)