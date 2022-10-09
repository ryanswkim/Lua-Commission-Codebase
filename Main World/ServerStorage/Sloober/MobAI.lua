local MobCharacter = script.Parent 
local Humanoid = MobCharacter:WaitForChild("Humanoid") 
local HRP = MobCharacter:WaitForChild("HumanoidRootPart")
local Origin = HRP.Position
local HPGui = MobCharacter:WaitForChild("HumanoidRootPart"):WaitForChild("HPGui")
local Health = MobCharacter:FindFirstChild("Health")
local MaxHealth = MobCharacter:FindFirstChild("MaxHealth")
local CurrentHealth = Health.Value
local RegenCalculator = 0

HRP.AncestryChanged:Connect(function()
	if HRP.Parent == nil then
		MobCharacter:Destroy()
	end
end)

local DeathAnim = script:FindFirstChildWhichIsA("Animation")
local PlayDead = Humanoid:LoadAnimation(DeathAnim)

----------------------------------------------------------Mob Character
local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")
local TS = game:GetService("TweenService")
local SharedEffects = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("SharedEffects"))
local SharedMobAI = require(SS:WaitForChild("ModuleFunctions"):WaitForChild("SharedMobScripts"))

----------------------------------------------------------Services
local MaxDistanceFromOrigin = 50
local MinWalkDistance = 7
local MaxWalkDistance = 8
local MinWalkWait = 5
local MaxWalkWait = 7
local SightRange = 30
local LoseInterestDistance = 60
local MinimumDistance = 5
local DeathAnimationTime = 2
local DeathParticleRate = 20
local FadeDelay = 1.5

local ExperienceDrop = 1
local ItemDrops = {SlooberCap = {Chance = 1000, MaxCount = 1}, Slimeball = {Chance = 1000, MaxCount = 40}}
---------------------------------------------------------
local function Die()
	for i,v in pairs(Humanoid:GetPlayingAnimationTracks()) do
		v:Stop()
	end
	MobCharacter:WaitForChild("Anchor").Anchored = true
	PlayDead:Play()
	wait(FadeDelay)
	
	SharedMobAI.DistributeDrops(MobCharacter, MaxHealth.Value, ItemDrops)
	
	spawn(function() SharedEffects.MakeDeathParticle(MobCharacter, DeathAnimationTime, DeathParticleRate) end)
	wait(DeathAnimationTime * 2)
	MobCharacter:Destroy()
end

Humanoid.HealthChanged:Connect(function()
	Health.Value = Humanoid.Health/Humanoid.MaxHealth * MaxHealth.Value
end)

Health.Changed:Connect(function(NewHealth)
	if CurrentHealth > NewHealth then
		RegenCalculator = 0
	end
	CurrentHealth = NewHealth
	if NewHealth == 0 then
		Die()
	end
end)

local ClosestCharacter
local function CheckAndAttack()
	ClosestCharacter = nil
	local ClosestCharacterMagnitude = math.huge
	for i,v in pairs(workspace:WaitForChild("Players"):GetChildren()) do
		if v:FindFirstChild("HumanoidRootPart") and Players:GetPlayerFromCharacter(v):FindFirstChild("Values") 
		and Players:GetPlayerFromCharacter(v).Values:FindFirstChild("Health")
		and Players:GetPlayerFromCharacter(v).Values.Health.Value > 0 and (v.HumanoidRootPart.Position - HRP.Position).magnitude < SightRange then
			local SightDistance = (v.HumanoidRootPart.Position - HRP.Position).magnitude
			if ClosestCharacterMagnitude > SightDistance then
				ClosestCharacterMagnitude = SightDistance
				ClosestCharacter = v
			end
		end
	end
end


spawn(function()
	while Health.Value > 0 do
		Humanoid:MoveTo(HRP.Position + Vector3.new(SharedMobAI.GetAxis(MinWalkDistance,MaxWalkDistance), 0 ,SharedMobAI.GetAxis(MinWalkDistance,MaxWalkDistance)))
		wait(math.random(MinWalkWait,MaxWalkWait))
	end
end)

while Health.Value > 0 do
	RegenCalculator = RegenCalculator + 4
	if RegenCalculator > 20 and Health.Value > 0 then
		local Add = MaxHealth.Value * 0.05
		if Health.Value + Add > MaxHealth.Value then
			Add = MaxHealth.Value - Health.Value
		end
		Health.Value = Health.Value + Add
	end
	wait(4)
end