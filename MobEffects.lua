local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EffectsFolder = ReplicatedStorage:WaitForChild("Effects")
local SharedEffects = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SharedEffects"))
local Player = Players.LocalPlayer
while not Player.Character do wait() end
local Character = Player.Character
local HRP = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

--** Mostly just passive FX for mobs and players

spawn(function()
	while true do
		for i,Player in pairs(workspace:WaitForChild("Players"):GetChildren()) do
			if Player:FindFirstChild("HumanoidRootPart", true) and (HRP.Position - Player.HumanoidRootPart.Position).Magnitude < 500 and Player:FindFirstChild("RightEye", true) and Player:FindFirstChild("LeftEye", true) then
				local RE = Player:FindFirstChild("RightEye", true):WaitForChild("Mesh")
				local LE = Player:FindFirstChild("LeftEye", true):WaitForChild("Mesh")
				spawn(function()
					wait(math.random(1,4))
					for i = 1,math.random(1,3) do
						TS:Create(RE, TweenInfo.new(.075), {Scale = Vector3.new(1, 0, 1)}):Play()
						TS:Create(LE, TweenInfo.new(.075), {Scale = Vector3.new(1, 0, 1)}):Play()
						wait(.075)
						TS:Create(RE, TweenInfo.new(.075), {Scale = Vector3.new(1, 1, 1)}):Play()
						TS:Create(LE, TweenInfo.new(.075), {Scale = Vector3.new(1, 1, 1)}):Play()
						wait(.075)
					end
				end)
			end
		end
		wait(math.random(8, 12))
	end
end)

local Targetable = workspace:WaitForChild("Targetable")

local CurHP = {}
local function InitializeHP(Mob)
	local Health = Mob:WaitForChild("Health")
	CurHP[Mob] = Health.Value
	local MaxHealth = Mob:WaitForChild("MaxHealth")
	local HRP = Mob:WaitForChild("HumanoidRootPart")
	local HPGui = HRP:WaitForChild("HPGui")
	local HPBar = HPGui:WaitForChild("MainBar"):WaitForChild("Value")
	local SizeReference = HPGui:WaitForChild("MainBar"):WaitForChild("SizeReference")
	Health.Changed:Connect(function(NH)
		if NH < CurHP[Mob] then
			for i,v in pairs(HPGui:GetDescendants()) do
				spawn(function()
					local Color
					if v.Name == "MainBar" then
						Color = Color3.fromRGB(56,56,56)
					else
						Color = Color3.fromRGB(23, 158, 14)
					end
					v.BackgroundColor3 = Color3.new(1,1,1)
					wait(.05)
					TS:Create(v, TweenInfo.new(.12), {BackgroundColor3 = Color}):Play()
				end)
			end
		end
		CurHP[Mob] = NH
		local NX = NH/MaxHealth.Value
		local NewMainBar = UDim2.new(NX * SizeReference.Size.X.Scale, 0, SizeReference.Size.Y.Scale, 0)
		TS:Create(HPBar, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = NewMainBar}):Play()
	end)
end

local function BurnMob(Mob)
	for i,x in pairs(Mob:GetDescendants()) do
		if x:IsA("BasePart") and x.Transparency < 1 and x:FindFirstAncestor("Bodyparts") then
			local xSize = math.max(x.Size.X, x.Size.Y, x.Size.Z)
			SharedEffects.MakeBlob("Fire", x, math.max(math.floor(xSize/5), 1), xSize * 1.5, 0.1, 400)
		end
	end
end

local function SmokeMob(Mob)
	for i,x in pairs(Mob:GetDescendants()) do
		if x:IsA("BasePart") and x.Transparency < 1 and x:FindFirstAncestor("Bodyparts") then
			local xSize = math.max(x.Size.X, x.Size.Y, x.Size.Z)
			SharedEffects.MakeBlob("Smoke", x, math.max(math.floor(xSize/5), 1), xSize * 1.5, 0.1)
		end
	end
end

local function SoakMob(Mob)
	local SoakParticles = {}
	for i,x in pairs(Mob:GetDescendants()) do
		if x:IsA("BasePart") and x.Transparency < 1 and x:FindFirstAncestor("Bodyparts") then
			local SoakParticle = EffectsFolder:WaitForChild("Soak"):Clone()
			SoakParticle.Parent = x
			SoakParticle.Rate = 40
			SoakParticle.Enabled = true
			table.insert(SoakParticles, SoakParticle)
		end
	end
	return SoakParticles
end

--ElectrocuteMob

local function InitializeStatusEffects(Tag, Mob)
	local Health = Mob:WaitForChild("Health")
	if string.find(string.lower(Tag.Name), "burn") then	
		Tag.Changed:Connect(function(NV)
			if not Tag then return end
			BurnMob(Mob)
		end)
	elseif Tag.Name == "Smoke" then
		SmokeMob(Mob)
	elseif Tag.Name == "Soak" then
		local SoakParticles = SoakMob(Mob)
		spawn(function()
			repeat wait() until not Tag.Parent or Health.Value <= 0
			for i,SoakParticle in pairs(SoakParticles) do
				SoakParticle.Enabled = false
				Debris:AddItem(SoakParticle, 0.5)
			end
		end)
	end
end

local function InitializeStatusTags(Mob)
	local StatusTags = Mob:WaitForChild("StatusTags")
	for i,Tag in pairs(StatusTags:GetChildren()) do
		InitializeStatusEffects(Tag, Mob)
	end
	StatusTags.ChildAdded:Connect(function(Tag)
		InitializeStatusEffects(Tag, Mob)
	end)
end

local function InitializeMob(Mob)
	InitializeHP(Mob)
	InitializeStatusTags(Mob)
end

for i,v in pairs(Targetable:GetChildren()) do
	InitializeMob(v)
end
Targetable.ChildAdded:Connect(function(v)
	InitializeMob(v)
end)
