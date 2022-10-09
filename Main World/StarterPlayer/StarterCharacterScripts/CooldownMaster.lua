--Services:
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
--Player instances:
local Player = Players.LocalPlayer
while not Player.Character do wait() end
local Character = Player.Character
--GUI instances:
local PG = Player.PlayerGui
local Main = PG:WaitForChild("Main")

--Cooldown instances:
local Cooldowns = Player:WaitForChild("Cooldowns")

local CooldownFrame = Instance.new("Frame")
CooldownFrame.BackgroundColor3 = Color3.new(0,0,0)
CooldownFrame.Transparency = 0.35
CooldownFrame.Name = "CooldownFrame"
CooldownFrame.ZIndex = 100

local function PlayCooldown(Frame, Time)
	local CDF = CooldownFrame:Clone()
	CDF.AnchorPoint = Vector2.new(0, 1)
	CDF.Size = UDim2.new(0, Frame.AbsoluteSize.X, 0, Frame.AbsoluteSize.Y) 
	CDF.Position = UDim2.new(0, Frame.AbsolutePosition.X, 0, Frame.AbsolutePosition.Y + CDF.Size.Y.Offset)
	if Main:FindFirstChild("CooldownFrame") then
		Main:FindFirstChild("CooldownFrame"):Destroy()
	end
	CDF.Parent = Main
	TS:Create(CDF, TweenInfo.new(Time), {Size = UDim2.new(0, CDF.Size.X.Offset, 0, 0)}):Play()
	Debris:AddItem(CDF, Time)
end

local CurrentWeapon
local WeaponAbilityFrame = Main:WaitForChild("WeaponAbility"):WaitForChild("Display")
if Character:FindFirstChild("WeaponTag", true) then
	CurrentWeapon = Character:FindFirstChild("WeaponTag", true).Parent
end

Character.ChildAdded:Connect(function(Weapon)
	if Weapon:WaitForChild("WeaponTag", 1) then
		CurrentWeapon = Weapon
		if Cooldowns:FindFirstChild(Weapon.Name.."Cooldown") then
			PlayCooldown(WeaponAbilityFrame, Cooldowns:FindFirstChild(Weapon.Name.."Cooldown").Value)
		end
	end
end)

Character.ChildRemoved:Connect(function(Child)
	if Child == CurrentWeapon then
		CurrentWeapon = nil
		if Main:FindFirstChild("CooldownFrame") then
			Main.CooldownFrame:Destroy()
		end
	end
end)

Cooldowns.ChildAdded:Connect(function(CooldownTag)
	if tonumber(CooldownTag.Name) then
		
	else
		PlayCooldown(WeaponAbilityFrame, CooldownTag.Value)
	end
	while CooldownTag do
		CooldownTag.Value = CooldownTag.Value - .25
		wait(.25)
	end
end)

--Weapon abilities



--Skills (TBA)





---------------------------Drag & Drop---------------------------
