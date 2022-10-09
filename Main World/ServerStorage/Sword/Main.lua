-- Services: 
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local CAS = game:GetService("ContextActionService") 
local UIS = game:GetService("UserInputService")

-- Player instances:
local player = players.LocalPlayer
local zxcv = player:WaitForChild("PlayerGui"):WaitForChild("ZXCV")
local playerGameplay = player:WaitForChild("Gameplay")
local attacking = playerGameplay:WaitForChild("Attacking")
local equipped = playerGameplay:WaitForChild("Equipped")
local health = player:WaitForChild("Values"):WaitForChild("Health")

-- Character instances:
while not player.Character do wait() end
local character = player.Character
local HRP = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Modules:
local replicatedModules = replicatedStorage:WaitForChild("Modules")
local SharedWeaponScripts = require(replicatedModules:WaitForChild("SharedWeaponScripts"))
local RaycastHitbox = require(replicatedModules:WaitForChild("RaycastHitbox"))

-- Remote:
local DamageRemote = replicatedStorage:WaitForChild("Remotes"):WaitForChild("DamageRemote")
local WeaponRemote = script:WaitForChild("WeaponRemote") 

-- Event:
local hitboxEvent = replicatedStorage:WaitForChild("Events"):WaitForChild("StartHitbox")

-- Clock:
local Clock = require(replicatedStorage:WaitForChild("Clock"))

-- Sword instance:
local Sword = script.Parent

-- Sounds:
local Woosh = replicatedStorage:WaitForChild("Sounds"):WaitForChild("Woosh")

-- Init:
attacking.Value = false
equipped.Value = false
WeaponRemote:FireServer("Unequipped", Clock:GetTime())

-- Animations:
local equipAnim = Instance.new("Animation") 
equipAnim.AnimationId = "rbxassetid://4459671855" 

local slash1 = Instance.new("Animation")  
slash1.AnimationId = "rbxassetid://4460185095" 

local slash2 = Instance.new("Animation") 
slash2.AnimationId = "rbxassetid://4460289938" 

local pEquip = humanoid:LoadAnimation(equipAnim)
local s1 = humanoid:LoadAnimation(slash1)
local s2 = humanoid:LoadAnimation(slash2)

-- Variables:
local equipCD = false
local attackCount = 0 
local attackTimer = 0

-- Config:
local BASE_SCREENSHAKE = 550
local SCREENSHAKE_CAP = 800

-- Init hitbox:
local newHB = RaycastHitbox:Initialize(Sword)
newHB.OnHit:Connect(function(target, pos)
	SharedWeaponScripts:HBCheck(player, target, pos, BASE_SCREENSHAKE, SCREENSHAKE_CAP, script.Parent.Name)
end) 

hitboxEvent.Event:Connect(function(Action)
	if Action == "Start" then
		newHB:HitStart()
	else
		newHB:HitStop()
	end
end)

-- Input reading:
local holding = false
UIS.InputBegan:Connect(function(Input, GPE)
	if GPE or zxcv.Enabled or health.Value <= 0 then return end
	
	if Input.KeyCode == Enum.KeyCode.Q then
		if equipCD or attacking.Value then return end
		equipCD = true
		attacking.Value = true
		if not equipped.Value then
			WeaponRemote:FireServer("Equipped", Clock:GetTime())
		else		
			attackCount = 0
			WeaponRemote:FireServer("Unequipped", Clock:GetTime())
		end
		equipped.Value = not equipped.Value
		pEquip:Play() 
		wait(.15)
		attacking.Value = false
		wait(.2) 
		equipCD = false
	end

	if Input.UserInputType == Enum.UserInputType.MouseButton1 and equipped.Value then
		holding = true
		if attacking.Value then
			repeat wait() until not attacking.Value
		end
		attacking.Value = true
		while holding and not zxcv.Enabled and health.Value > 0 do
			if attackCount == 0 then
				attackTimer = 0 
				attackCount = 1 
				s1:Play()
				wait(.1)
				Woosh:Play()
				wait(.08)
				newHB:HitStart()
				wait(.17)
				newHB:HitStop()
			else
				attackCount = 0 
				s2:Play()
				wait()
				Woosh:Play()
				wait()
				newHB:HitStart()
				wait(.2)
				newHB:HitStop()
			end
		end
		attacking.Value = false
	end
end)

UIS.InputEnded:Connect(function(Input, GPE)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		holding = false
	end
end)

-- Animation handler:
while wait(.6) do
	attackTimer = attackTimer + 20
	if attackTimer >= 40 then
		attackCount = 0
	end
end