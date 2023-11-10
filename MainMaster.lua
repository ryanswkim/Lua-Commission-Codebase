----------------------------------------------------------------Services
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local PS = game:GetService("PhysicsService")


----------------------------------------------------------------Player stuff
local Player = Players.LocalPlayer

----------------------------------------------------------------GUI Stuff
local Main = script.Parent
local Sidebar = Main:WaitForChild("Sidebar")
local Values = Main:WaitForChild("Values")

local Experience = Values.Experience.MainBar
local ExperienceX = 0.998 local ExperienceY = 0.8

local MaxHealth = Player:WaitForChild("Values"):WaitForChild("MaxHealth")
local Health = Player:WaitForChild("Values"):WaitForChild("Health")
local HealthBar = Values.Health.MainBar
local HealthX = 0.996 local HealthY = 0.9

local MaxMana = Player:WaitForChild("Values"):WaitForChild("MaxMana")
local Mana = Player:WaitForChild("Values"):WaitForChild("Mana") 
local ManaBar = Values.Mana.MainBar
local ManaX = 0.992 local ManaY = 0.8

local MaxHunger = Player:WaitForChild("Values"):WaitForChild("MaxHunger")
local Hunger = Player:WaitForChild("Values"):WaitForChild("Hunger")
local HungerBar = Values.Hunger.MainBar
local HungerX = 0.992 local HungerY = 0.8

local MaxExperience = Player.Values.MaxExperience
local Experience = Player.Values.Experience
local ExperienceBar = Values.Experience.MainBar
local ExperienceX = .998 local ExperienceY = 0.8
----------------------------------------------------------------Initialize
ExperienceBar:TweenSize(UDim2.new(Experience.Value/MaxExperience.Value*ExperienceX, 0, ExperienceY, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
HealthBar:TweenSize(UDim2.new(HealthX * Health.Value/MaxHealth.Value, 0, HealthY, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
ManaBar:TweenSize(UDim2.new(ManaX * Mana.Value/MaxMana.Value, 0, ManaY, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
HungerBar:TweenSize(UDim2.new(HungerX * Hunger.Value/MaxHunger.Value, 0, HungerY, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)

----------------------------------------------------------------HEALTH
local CurrentHealth = Health.Value
local Lighting = game:GetService("Lighting")
local DamageColor = Lighting:WaitForChild("DamageColor")
local DamageBlur = Lighting:WaitForChild("DamageBlur")

Health.Changed:Connect(function(NewHealth)
	if NewHealth < CurrentHealth then
		local HPDiff = (CurrentHealth - NewHealth)/MaxHealth.Value
		local FadeInTime = .175 - 0.025 * HPDiff
		TS:Create(DamageBlur, TweenInfo.new(FadeInTime), {Size = 10 + 35 * HPDiff}):Play()
		TS:Create(DamageColor, TweenInfo.new(FadeInTime), {Brightness = math.max(-0.825, -0.15 - .9*HPDiff), Contrast = 2 * HPDiff, Saturation = HPDiff, TintColor = Color3.new(1,.5 - 2/3*HPDiff,.5 - 2/3*HPDiff)}):Play()
		
		local FadeOutTime = 2 * HPDiff + .5
		spawn(function()
			wait(FadeInTime)
			TS:Create(DamageBlur, TweenInfo.new(FadeOutTime), {Size = 0}):Play()
			TS:Create(DamageColor, TweenInfo.new(FadeOutTime), {Brightness = 0, Saturation = 0, Contrast = 0, TintColor = Color3.new(1,1,1)}):Play()
		end)
	else
		TS:Create(DamageBlur, TweenInfo.new(.75), {Size = 0}):Play()
		TS:Create(DamageColor, TweenInfo.new(.75), {Brightness = 0, Saturation = 0, Contrast = 0, TintColor = Color3.new(1,1,1)}):Play()
	end
	
	local NewX = NewHealth/MaxHealth.Value * HealthX
	local NewY = HealthY
	if NewHealth <= 0 then
		HealthBar:TweenSize(UDim2.new(0,0,NewY, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.4, true)
	else
		HealthBar:TweenSize(UDim2.new(NewX, 0, NewY, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.4, true)
	end
	CurrentHealth = NewHealth
end)
---------------------------------------------------------------MANA AND HUNGER AND EXPERIENCE (GUI)
Mana.Changed:Connect(function(NewMana)
	local NewX = NewMana/MaxMana.Value*ManaX
	local NewY = ManaY
	local NewMainBar = UDim2.new(NewX, 0, NewY, 0)
	ManaBar:TweenSize(NewMainBar, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.4, true)
end)

Hunger.Changed:Connect(function(NewHunger)
	local NewX = NewHunger/MaxHunger.Value*HungerX
	local NewY = HungerY
	local NewMainBar = UDim2.new(NewX, 0, NewY, 0)
	HungerBar:TweenSize(NewMainBar, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.4, true)
end)


Experience.Changed:Connect(function(NewExperience)
	local NewX = NewExperience/MaxExperience.Value*ExperienceX
	local NewY = ExperienceY
	local NewMainBar = UDim2.new(NewX, 0, NewY, 0)
	ExperienceBar:TweenSize(NewMainBar, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.4, true)
end)

-------------------------------------------------------------Other players
for i,Player in pairs(Players:GetPlayers()) do
	Player:WaitForChild("Values"):WaitForChild("Health").Changed:Connect(function()
		if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart:FindFirstChild("GUI") then
			Player.Character.HumanoidRootPart.GUI.Health.Value:TweenSize(UDim2.new(Player:WaitForChild("Values"):WaitForChild("Health").Value/Player:WaitForChild("Values"):WaitForChild("MaxHealth").Value*.99, 0, .775, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .3, true)
		end
	end)
end

Players.PlayerAdded:Connect(function(Player)
	Player:WaitForChild("Values"):WaitForChild("Health").Changed:Connect(function()
		if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart:FindFirstChild("GUI") then
			Player.Character.HumanoidRootPart.GUI.Health.Value:TweenSize(UDim2.new(Player:WaitForChild("Values"):WaitForChild("Health").Value/Player:WaitForChild("Values"):WaitForChild("MaxHealth").Value*.99, 0, .775, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .3, true)
		end
	end)
end)

local LowHealthBlur = Lighting:WaitForChild("LowHealthBlur")
local LowHealthColor = Lighting:WaitForChild("LowHealthColor")
local Death = Main:WaitForChild("Death")
local DeathLabel = Death:WaitForChild("DeathLabel")
local Camera = workspace.CurrentCamera
local VPSize = Camera.ViewportSize
local XFrames = math.ceil(VPSize.X/100) - 1
local YFrames = math.ceil(VPSize.Y/100)
local function DoCouroutine(f)
	coroutine.resume(coroutine.create(f))
end

RS.Heartbeat:Connect(function()
	if Health.Value < MaxHealth.Value/4 then
		local Ratio = 1 - Health.Value/(MaxHealth.Value/4.5)
		local ColorRatio = 180 * Ratio
		TS:Create(LowHealthBlur, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 20 * (Ratio)}):Play()
		TS:Create(LowHealthColor, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Contrast = -0.3 * Ratio, Saturation = -Ratio, TintColor = Color3.fromRGB(255 - ColorRatio, 255 - ColorRatio, 255 - ColorRatio)}):Play()
	else
		TS:Create(LowHealthBlur, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 0}):Play()
		TS:Create(LowHealthColor, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Contrast = 0, Saturation = 0, TintColor = Color3.new(1,1,1)}):Play()
	end
end)
Health.Changed:Connect(function(NH)
	if NH == 0 then
		for x = 0,XFrames do
			for y = 0, YFrames do
				local DeathFrame = Instance.new("Frame")
				DeathFrame.ZIndex = 999999998
				DeathFrame.Size = UDim2.new(0,0,0,0)
				DeathFrame.AnchorPoint = Vector2.new(0.5,0.5)
				DeathFrame.BackgroundColor3 = Color3.new(0,0,0)
				DeathFrame.Position = UDim2.new(0, x*100 + 50 - math.fmod(VPSize.X,100), 0, y*100 - 50)
				DeathFrame.BorderSizePixel = 0
				DeathFrame.Name = x
				DeathFrame.Parent = Death
				
				
				if x > 0 or y > 0 then
					DoCouroutine(function()
						wait(.08 * (x+y))
						if x > math.ceil(3/4 * XFrames) and y > math.ceil(3/4 * YFrames) then
							TS:Create(DeathLabel, TweenInfo.new(.3), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
						end	
						TS:Create(DeathFrame, TweenInfo.new(.65), {Size = UDim2.new(0,100,0,100)}):Play()
					end)
				else
					TS:Create(DeathFrame, TweenInfo.new(.65), {Size = UDim2.new(0,100,0,100)}):Play()
				end
			end
		end
	end
end)

local XCenter
if math.fmod(XFrames, 2) == 0 then
	XCenter = (XFrames/2)
else
	XCenter = (math.ceil(XFrames/2))
end

local WorldBlur = Lighting:WaitForChild("WorldBlur")
Player.CharacterAdded:Connect(function()
	WorldBlur.Size = 35
	TS:Create(WorldBlur, TweenInfo.new(2.25), {Size = 1.75}):Play()
	TS:Create(DeathLabel, TweenInfo.new(.25), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	wait(.2)
	for i,v in pairs(Death:GetDescendants()) do
		if v ~= DeathLabel then
			local FinalPos
			if math.fmod(tonumber(v.Name), 2) == 0 then
				FinalPos = v.Position + UDim2.new(0,0,1.5,0)
			else
				FinalPos = v.Position - UDim2.new(0,0,1.5,0)
			end
			DoCouroutine(function()
				if math.abs(tonumber(v.Name) - XCenter) > 0 then
					wait((math.abs(tonumber(v.Name) - XCenter)) * .125)
				end
				TS:Create(v, TweenInfo.new(.4), {Position = FinalPos}):Play()
				wait(.45)
				v:Destroy()
			end)
		end
	end
end)