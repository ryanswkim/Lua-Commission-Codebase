--This should include all combat interactions, spawnpoints, drops, etc.

local DefaultHumanoidDisables = {
	Enum.HumanoidStateType.Dead, 
	Enum.HumanoidStateType.Climbing, 
	Enum.HumanoidStateType.FallingDown, 
	Enum.HumanoidStateType.Flying,
	Enum.HumanoidStateType.Swimming,
	Enum.HumanoidStateType.PlatformStanding,
	--Enum.HumanoidStateType.Landed,
	Enum.HumanoidStateType.Jumping, 
	Enum.HumanoidStateType.Ragdoll, 
	--Enum.HumanoidStateType.Freefall,
	Enum.HumanoidStateType.GettingUp, 
	Enum.HumanoidStateType.Seated, 
	Enum.HumanoidStateType.StrafingNoPhysics,
}

local Enemies = {

--[[
	Mob = {
	--Stats/Drops
	MaxHealth = 50,
	Experience = 10,
	Drops = {SlooberCap = {Chance = 1000, MaxCount = 1}, Slimeball = {Chance = 1000, MaxCount = 40}},
	
	--Spawning
	SocialDistance = 8,
	MaxCount = 2,
	SpawnPoints = {{0, 20, 0}, {10, 20, 0}, {0, 20, 10}, {10, 20, 10}},
	
	--Dying
	DeathAnimation = "rbxassetid://4554632595",
	PreFadeTime = 2,
	FadeTime = 1.5,
	DeathParticleRate = 20,
	
	--Movement
	WanderDistance = 10,
	Movement = "Linear",
	Behavior = "Hostile",
	
	--Tracking/Attacking
	TrackingRange = 5, --Only applicable if hostile 
	MinTrackInterval = 2,
	MaxTrackInterval = 5,
	Attack = function() --Main attack
		
	end,
	AttackCooldown = 3,
	AttackRange = 2,
	
	--Misc
	DisabledHumanoidStates = DefaultHumanoidDisables,
	UncollidableParts = {"RightArm", "LeftArm"},
	Knockable = true
	},
]]-- 

	Sloober = {
	--Stats/Drops
	MaxHealth = 100,
	Experience = 10,
	Drops = {SlooberCap = {Chance = 1000, MaxCount = 1}, Slimeball = {Chance = 1000, MaxCount = 40}},
	
	--Spawning
	SocialDistance = 8,
	MaxCount = 2,
	SpawnPoints = {{0, 20, 0}, {10, 20, 0}, {0, 20, 10}, {10, 20, 10}},
	
	--Dying
	DeathAnimation = "rbxassetid://4554632595",
	PreFadeTime = 2,
	FadeTime = 1.5,
	DeathParticleRate = 20,
	
	--Movement
	MinDistance = 8,
	MaxDistance = 14,
	WanderDistance = 125, --How far from spawnpoint it can go before it walks back to it
	Movement = "Linear",
	Behavior = "Hostile",
	
	--Tracking/Attacking
	TrackingRange = 15, --Only applicable if hostile 
	TargetedTrackingRange = 35,
	MinTrackInterval = 2,
	MaxTrackInterval = 5,
	Attack = function(Mob) --Main attack
		local Humanoid = Mob:FindFirstChild("Humanoid")
		local HRP = Mob:FindFirstChild("HumanoidRootPart")
		local Target = Mob:FindFirstChild("Target")
		
		if not Target or not Target.Value 
		or not Target.Value:FindFirstChild("HumanoidRootPart") 
		or not HRP or not Humanoid then return end
		
		
		--Mob:SetPrimaryPartCFrame(CFrame.new(HRP.Position, Target.Value.HumanoidRootPart.Position))
		wait(4)
	end,
	AttackCooldown = 0.5,
	AttackRange = 6,
	
	--Misc
	DisabledHumanoidStates = DefaultHumanoidDisables,
	UncollidableParts = {"RightArm", "LeftArm"},
	Knockable = true
	},
	
	
	
	NommTerra = {
	--Stats/Drops
	MaxHealth = 100,
	Experience = 10,
	Drops = {SlooberCap = {Chance = 1000, MaxCount = 1}, Slimeball = {Chance = 1000, MaxCount = 40}},
	
	--Spawning
	MaxCount = 5,
	SocialDistance = 5,
	SpawnPoints = {{0, 20, 0}, {10, 20, 0}, {0, 20, 10}, {10, 20, 10}},
	
	--Dying
	DeathAnimation = "rbxassetid://4554632595",
	PreFadeTime = 2,
	FadeTime = 1.5,
	DeathParticleRate = 20,
	
	--Movement
	MinDistance = 7,
	MaxDistance = 10,
	WanderDistance = 250,
	Movement = "Linear",
	Behavior = "Hostile",
	
	--Tracking/Attacking(Only if hostile)
	TrackingRange = 20,  
	TargetedTrackingRange = 30,
	MinTrackInterval = 2,
	MaxTrackInterval = 4,
	Attack = function(Mob) --Main attack
		local Humanoid = Mob:FindFirstChild("Humanoid")
		local HRP = Mob:FindFirstChild("HumanoidRootPart")
		local Target = Mob:FindFirstChild("Target")
		
		if not Target or not Target.Value 
		or not Target.Value:FindFirstChild("HumanoidRootPart") 
		or not HRP or not Humanoid then return end
		
		--Mob:SetPrimaryPartCFrame(CFrame.new(HRP.Position, Target.Value.HumanoidRootPart.Position))
		wait(4)
	end,
	AttackCooldown = 1,
	AttackRange = 3.5,
	
	--Misc
	DisabledHumanoidStates = DefaultHumanoidDisables,
	UncollidableParts = { "LeftForearm", "RightForearm", "LeftBackarm", "RightBackarm", "RRPincer", "RLPincer", "LLPincer", "LRPincer", "TailA", "TailB", "TailC", "TailA", "TailA"},
	Knockable = true
	}
	
}
return Enemies
