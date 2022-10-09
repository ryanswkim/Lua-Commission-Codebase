-- Services:
local PS = game:GetService("PhysicsService")
local UIS = game:GetService("UserInputService")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local ts = game:GetService("TweenService")

-- Player instances:
local player = players.LocalPlayer
local zxcv = player:WaitForChild("PlayerGui"):WaitForChild("ZXCV") 
local attacking = player:WaitForChild("Gameplay"):WaitForChild("Attacking")
local health = player:WaitForChild("Values"):WaitForChild("Health")

-- Character instances:
while not player.Character do wait() end
local character = player.Character
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")
local playerParts = {character:WaitForChild("LeftLeg", 5), 
	character:WaitForChild("RightLeg", 5), character:WaitForChild("Torso", 5), 
	character:WaitForChild("Head", 5), character:WaitForChild("HumanoidRootPart", 5), 
	character.Head:WaitForChild("RightEye", 5), character.Head:WaitForChild("LeftEye", 5)
}

-- Modules:
local replicatedModules = replicatedStorage:WaitForChild("Modules")
local Clock = require(replicatedStorage:WaitForChild("Clock"))
local SharedWeaponScripts = require(replicatedModules:WaitForChild("SharedWeaponScripts"))
local AbilitySequence = require(replicatedModules:WaitForChild("AbilitySequence"))

-- Events:
local StartHitbox = replicatedStorage:WaitForChild("Events"):WaitForChild("StartHitbox")
local Connector = script:WaitForChild("Connector")

-- Anims:
local Buildup = Instance.new("Animation")
Buildup.AnimationId = "rbxassetid://04587117889"
local PlayBuildup = humanoid:LoadAnimation(Buildup)

local SkillAnimation = Instance.new("Animation")
SkillAnimation.AnimationId = "rbxassetid://04593163477"
local PlaySkill = humanoid:LoadAnimation(SkillAnimation)

local LoopAnim = Instance.new("Animation")
LoopAnim.AnimationId = "rbxassetid://04593161524"
local PlayLoop = humanoid:LoadAnimation(LoopAnim)

-- Main function
local function onKey(Input, GPE)
	if Input.KeyCode.Value ~= Enum.KeyCode.R.Value or zxcv.Enabled or GPE then return end
	if not SharedWeaponScripts:ClientCheck(player, script.Parent.Name) then return end
	
	Connector:FireServer(Clock:GetTime())
	PlayBuildup:Play()
	attacking.Value = true
	coroutine.wrap(function() AbilitySequence.AgileSwipe(player, 0) end)()
	wait(.295)
	for _, part in pairs(playerParts) do
		if part then
			PS:SetPartCollisionGroup(part, "Rigparts")
		end
	end
	StartHitbox:Fire("Start")
	
	wait(.05)
	PlaySkill:Play()

	local detectionRay = Ray.new(root.Position, root.CFrame.LookVector * 18)
	local hit, pos = workspace:FindPartOnRayWithWhitelist(detectionRay, {workspace:WaitForChild("Map"):WaitForChild("Collidable")})
	local magnitude = math.max(0, (pos - root.Position).Magnitude - 3)
	if magnitude > 7.5 then
		ts:Create(root, TweenInfo.new(0.125), {CFrame = root.CFrame * CFrame.new(0,0,-magnitude)}):Play()
	else
		local AgileImpulse = Instance.new("BodyVelocity")
		AgileImpulse.Name = "AgileImpulse"
		AgileImpulse.Velocity = Vector3.new(root.CFrame.LookVector.X * 100, 0, root.CFrame.LookVector.Z * 100)
		AgileImpulse.MaxForce = Vector3.new(1750000,0,1750000)
		AgileImpulse.Parent = root
		debris:AddItem(AgileImpulse, 0.1)
	end
	
	coroutine.wrap(function()
		wait(.05)
		PlayLoop:Play()
	end)()
	wait(.125)
	
	local Count = 0
	while health.Value > 0 and humanoid:GetState() == Enum.HumanoidStateType.Freefall and Count < 300 do 
		wait() 
		Count = Count + 1 
	end
	StartHitbox:Fire("End")
	
	for _, part in pairs(playerParts) do
		if part then
			PS:SetPartCollisionGroup(part, "Default")
		end
	end
	wait(.075)
	PlayLoop:Stop()
	wait(.225)
	attacking.Value = false
	Connector:FireServer()
end

-- init:
UIS.InputBegan:Connect(onKey)