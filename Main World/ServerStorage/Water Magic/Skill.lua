local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ZXCV = Player.PlayerGui:WaitForChild("ZXCV") 
local Attacking = Player:WaitForChild("Gameplay"):WaitForChild("Attacking")
repeat wait() until Player.Character
local Character = Player.Character
local HRP = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

--------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local SharedWeaponScripts = require(Modules:WaitForChild("SharedWeaponScripts"))
local AbilitySequence = require(Modules:WaitForChild("AbilitySequence"))
local Clock = require(ReplicatedStorage:WaitForChild("Clock"))
local Connector = script:WaitForChild("Connector")
local RunService = game:GetService("RunService")

local Buildup = Instance.new("Animation")
Buildup.AnimationId = "rbxassetid://04611672451"
local PlayBuildup = Humanoid:LoadAnimation(Buildup)

local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(Input, GPE)
	if Input.KeyCode.Value ~= Enum.KeyCode.R.Value or ZXCV.Enabled or GPE then return end
	if not SharedWeaponScripts:ClientCheck(Player, script.Parent.Name) then return end
	
	Attacking.Value = true
	Connector:FireServer(Clock:GetTime())
	PlayBuildup:Play()
	AbilitySequence.AquaPulse(Player, 0)
	Connector:FireServer()
	Attacking.Value = false
end)

HRP.ChildAdded:Connect(function(Child)
	if Child.Name == "AquaPulse" then
		game:GetService("Debris"):AddItem(Child, 0.2)
		Child.MaxForce = Vector3.new(500000,500000,500000)
		Child.Velocity = Vector3.new(-70 * HRP.CFrame.LookVector.X, 45, -70 * HRP.CFrame.LookVector.Z)
	end
end)