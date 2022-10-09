local Character = script.Parent.Parent 
local HRP = Character:WaitForChild("HumanoidRootPart")
local Player = game.Players:GetPlayerFromCharacter(Character)
local ZXCV = Player.PlayerGui:WaitForChild("ZXCV") 
local Humanoid = Character:WaitForChild("Humanoid")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAS = game:GetService("ContextActionService") 
local UIS = game:GetService("UserInputService") 
local SharedWeaponScripts = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SharedWeaponScripts"))
local RaycastHitbox = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RaycastHitbox"))
local Staff = script.Parent
local WeaponRemote = script:WaitForChild("WeaponRemote") 
local DamageRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DamageRemote")
local Clock = require(ReplicatedStorage:WaitForChild("Clock"))
local Attacking = Player:WaitForChild("Gameplay"):WaitForChild("Attacking")
local Equipped = Player:WaitForChild("Gameplay"):WaitForChild("Equipped")
local Woosh = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Woosh")

Attacking.Value = false
Equipped.Value = false
WeaponRemote:FireServer("Unequipped", Clock:GetTime())
--------------------------------------------------------------Animations
local equipAnim = Instance.new("Animation") equipAnim.Name = "Equip" equipAnim.AnimationId = "rbxassetid://04493939822" local pEquip = Humanoid:LoadAnimation(equipAnim)
local slash1 = Instance.new("Animation") slash1.Name = "Slash" slash1.AnimationId = "rbxassetid://04497412212" local s1 = Humanoid:LoadAnimation(slash1)
local slash2 = Instance.new("Animation") slash2.Name = "Slash" slash2.AnimationId = "rbxassetid://04497522996" local s2 = Humanoid:LoadAnimation(slash2)
local slash3 = Instance.new("Animation") slash3.Name = "Slash" slash3.AnimationId = "rbxassetid://4551342052" local s3 = Humanoid:LoadAnimation(slash3)

local slash1Sprinting = Instance.new("Animation") slash1Sprinting.Name = "Slash" slash1Sprinting.AnimationId = "rbxassetid://4550899993" 
local slash2Sprinting = Instance.new("Animation") slash2Sprinting.Name = "Slash" slash2Sprinting.AnimationId = "rbxassetid://04550905969" 
local slash3Sprinting = Instance.new("Animation") slash3Sprinting.Name = "Slash" slash3Sprinting.AnimationId = "rbxassetid://04551389509" 
--------------------------------------------------------------Animation resetter
local EQUIP_CD = false
local ATTACK_COUNT = 0 
local ATTACK_TIMER = 0
spawn (function()
	while wait() do
		ATTACK_TIMER = ATTACK_TIMER + 1
		if ATTACK_TIMER >= 40 then
			ATTACK_COUNT = 0
		end
	end
end)
--------------------------------------------------------------Hitbox
local NewHitbox = RaycastHitbox:Initialize(Staff)
NewHitbox.OnHit:Connect(function(Target, HitPos)
	SharedWeaponScripts.HBCheck(Player, Target, HitPos, 550, 800, "Staff")
end) 

--------------------------------------------------------------Binds
UIS.InputBegan:Connect(function(Input, GPE)
	if GPE or Attacking.Value or ZXCV.Enabled then return end
	
	if Input.KeyCode == Enum.KeyCode.Q then
		if EQUIP_CD then return end
		Attacking.Value = true
		EQUIP_CD = true
		if not Equipped.Value then
			WeaponRemote:FireServer("Equipped", Clock:GetTime())
		else
			ATTACK_COUNT = 0
			WeaponRemote:FireServer("Unequipped", Clock:GetTime())
		end
		Equipped.Value = not Equipped.Value
		pEquip:Play() 
		wait(.15)
		Attacking.Value = false
		wait(0.3) 
		EQUIP_CD = false
	end

	if Input.UserInputType == Enum.UserInputType.MouseButton1 and Equipped.Value then
		Attacking.Value = true
		if ATTACK_COUNT == 0 then
			ATTACK_TIMER = 0 
			ATTACK_COUNT = 1 
			s1:Play()
		elseif ATTACK_COUNT == 1 then
			ATTACK_COUNT = 2
			ATTACK_TIMER = 0 
			s2:Play()
		else
			ATTACK_TIMER = 0
			ATTACK_COUNT = 0
			s3:Play()
		end
		wait(.2) 
		Woosh:Play()
		wait(.05)
		NewHitbox:HitStart()
		wait(.265)
		NewHitbox:HitStop() 
		Attacking.Value = false 
	end
end)

local HitboxEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("StartHitbox")
HitboxEvent.Event:Connect(function(Action)
	if Action == "Start" then
		NewHitbox:HitStart()
	else
		NewHitbox:HitStop()
	end
end)