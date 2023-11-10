local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ZXCV = Player.PlayerGui:WaitForChild("ZXCV") 
repeat wait() until Player.Character
local Character = Player.Character
local HRP = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Attacking = Player:WaitForChild("Gameplay"):WaitForChild("Attacking")

local Buildup = Instance.new("Animation")
Buildup.AnimationId = "rbxassetid://04569388859"
local PlayBuildup = Humanoid:LoadAnimation(Buildup)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedWeaponScripts = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SharedWeaponScripts"))
local SharedEffects = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SharedEffects"))
local Clock = require(ReplicatedStorage:WaitForChild("Clock"))
local Connector = script:WaitForChild("Connector")

local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(Input, GPE)
	if Input.KeyCode.Value ~= Enum.KeyCode.R.Value or ZXCV.Enabled or GPE then return end
	if not SharedWeaponScripts:ClientCheck(Player, script.Parent.Name) then return end
	
	local Head = Character:FindFirstChild("WeaponTag", true).Parent:FindFirstChild("Head", true)
	if not Head then return end
	
	Connector:FireServer(Clock:GetTime())
	Attacking.Value = true
	SharedEffects.MakeBlob("Smoke", Head, 1, 2, .95, 800)
	SharedEffects.MakeBlob("Fire", Head, 1, 2, .95, 300)
	CAS:BindAction("Freeze", function() return Enum.ContextActionResult.Sink end, false, unpack(Enum.PlayerActions:GetEnumItems()))
	PlayBuildup:Play()
	wait(1.9)
	Attacking.Value = false
	CAS:UnbindAction("Freeze")
end)