--Services:
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")

--Player instances:
local Player = Players.LocalPlayer
repeat wait() until Player.Character 
local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

--Dying
local Dying = Instance.new("Animation") 
Dying.AnimationId = "rbxassetid://04465208823"
local PlayDying = Humanoid:LoadAnimation(Dying)

local Reset = Instance.new("BindableEvent")
local Health = Player:WaitForChild("Values"):WaitForChild("Health")

local SGCount = 0
local SG = game:GetService("StarterGui")
repeat success = pcall(function() 
		SG:SetCore("ResetButtonCallback", Reset) 
		SG:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
		SGCount = SGCount + 1
		wait(0.2) 
	end) 
until success or SGCount > 100

Reset.Event:connect(function()
	if not Player:WaitForChild("Gameplay"):WaitForChild("Reset").Value then
		Health.Value = 0
		PlayDying:Play()
    	ReplicatedStorage.Remotes.Reset:FireServer()
	end
end)

------------------------------------------------------------------------------------
local ResetAnimRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ResetAnimation")
ResetAnimRemote.OnClientEvent:Connect(function()
	for i,Anim in pairs(Humanoid:GetPlayingAnimationTracks()) do
		if Anim.Name == "HammerIdle" then
			Anim:Stop()
		end
	end
end)

local Sprinting = Player:WaitForChild("Gameplay"):WaitForChild("Sprinting")

function GetWalkspeed(BaseSpeed)
	if Sprinting.Value then
		return (9 + BaseSpeed or 0 * 0.075) + 6
	else
		return 9 + BaseSpeed or 0 * 0.075
	end
end

local SprintCD = false
UIS.InputBegan:Connect(function(Input, GPE)
	if not SprintCD and not GPE and Input.KeyCode == Enum.KeyCode.LeftControl then
		Sprinting.Value = not Sprinting.Value
		SprintCD = true
		ReplicatedStorage.Remotes.Sprinting:FireServer()
		Humanoid.WalkSpeed = GetWalkspeed(0)
		wait(.5)
		SprintCD = false
	end
end)

Character:WaitForChild("Health"):Destroy()