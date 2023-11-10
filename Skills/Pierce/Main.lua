local ManaCost = 1
local Cooldown = 1
local OnCooldown = false
---------------------------------------------------
local PS = game:GetService("PhysicsService")
local Player = game.Players.LocalPlayer
local ZXCV = Player.PlayerGui:WaitForChild("ZXCV") 
local Health = Player:WaitForChild("Values"):WaitForChild("Health")
local Mana = Player:WaitForChild("Values"):WaitForChild("Mana")
local Attacking = Player:WaitForChild("Gameplay"):WaitForChild("Attacking")
local Equipped = Player:WaitForChild("Gameplay"):WaitForChild("Equipped")
repeat wait() until Player.Character
local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

---------------------------------------------------
local Clock = require(game:GetService("ReplicatedStorage"):WaitForChild("Clock"))
local StartHitbox = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("StartHitbox")
local KeyCode = script:WaitForChild("KeyCode")
local Connector = script:WaitForChild("Connector")

local Buildup = Instance.new("Animation")
Buildup.AnimationId = "rbxassetid://4632481331"
local PlayBuildup = Humanoid:LoadAnimation(Buildup)

local AbilitySequence = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("AbilitySequence"))
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(Input, GPE)
	if Input.KeyCode.Value ~= KeyCode.Value or ZXCV.Enabled or Health.Value <= 0 or GPE or Mana.Value < ManaCost or Attacking.Value or OnCooldown then return end
	Connector:FireServer(Clock:GetTime())
	PlayBuildup:Play()
	OnCooldown = true
	Attacking.Value = true
	spawn(function() wait(Cooldown) OnCooldown = false end)
	spawn(function() wait(.2) Attacking.Value = false end)
	AbilitySequence.Pierce(Player, 0)
end)
	
	