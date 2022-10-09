local Hammer = script.Parent
local Character = Hammer.Parent 
local Player = game.Players:GetPlayerFromCharacter(Character) 
local ZXCV = Player.PlayerGui:WaitForChild("ZXCV") 
local Humanoid = Character:WaitForChild("Humanoid")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAS = game:GetService("ContextActionService") 
local UIS = game:GetService("UserInputService") 
local SharedWeaponScripts = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SharedWeaponScripts"))
local RaycastHitbox = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RaycastHitbox"))
local WeaponRemote = script:WaitForChild("WeaponRemote") 
local DamageRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DamageRemote")
local Clock = require(ReplicatedStorage:WaitForChild("Clock"))
local Equipped = Player:WaitForChild("Gameplay"):WaitForChild("Equipped")
local Attacking = Player:WaitForChild("Gameplay"):WaitForChild("Attacking")
local Woosh = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Woosh")

Attacking.Value = false
Equipped.Value = false
WeaponRemote:FireServer("Unequipped", Clock:GetTime())
--------------------------------------------------------------Animations
local equipAnim = Instance.new("Animation") equipAnim.Name = "Equip" equipAnim.AnimationId = "rbxassetid://04600154302" local pEquip = Humanoid:LoadAnimation(equipAnim)
local unequipAnim = Instance.new("Animation") unequipAnim.Name = "Unequip" unequipAnim.AnimationId = "rbxassetid://04600157046" local pUnequip = Humanoid:LoadAnimation(unequipAnim)
local slash1 = Instance.new("Animation") slash1.Name = "Slash1" slash1.AnimationId = "rbxassetid://4699519514" local s1 = Humanoid:LoadAnimation(slash1)
local slash2 = Instance.new("Animation") slash2.Name = "Slash2" slash2.AnimationId = "rbxassetid://4699523736" local s2 = Humanoid:LoadAnimation(slash2)
local hammerIdle = Instance.new("Animation") hammerIdle.Name = "HammerIdle" hammerIdle.AnimationId = "rbxassetid://04600151583" local pIdle = Humanoid:LoadAnimation(hammerIdle) 
--------------------------------------------------------------Damage register
local NewHitbox = RaycastHitbox:Initialize(Hammer)
NewHitbox.OnHit:Connect(function(Target, HitPos)
	SharedWeaponScripts:HBCheck(Player, Target, HitPos, 625, 1000, script.Parent.Name)
end) 
--------------------------------------------------------------Animation resetter
local EQUIP_CD = false
local ATTACK_COUNT = 0 
local ATTACK_TIMER = 0
spawn(function()
	while wait() do
		ATTACK_TIMER = ATTACK_TIMER + 1
		if ATTACK_TIMER >= 50 then
			ATTACK_COUNT = 0
		end
	end
end)
--------------------------------------------------------------Binds
local Holding = false
UIS.InputBegan:Connect(function(Input, GPE)
	if GPE or ZXCV.Enabled or Player:WaitForChild("Values"):WaitForChild("Health").Value <= 0 then return end
	
	if Input.KeyCode == Enum.KeyCode.Q then
		if Attacking.Value or EQUIP_CD then return end
		Attacking.Value = true
		EQUIP_CD = true
		if not Equipped.Value then
			pEquip:Play()
			WeaponRemote:FireServer("Equipped", Clock:GetTime())
			wait(0.535)
			pIdle:Play()
			Equipped.Value = true
		else
			Equipped.Value = false
			pIdle:Stop()
			pUnequip:Play() 
			WeaponRemote:FireServer("Unequipped", Clock:GetTime())
			ATTACK_COUNT = 0
			wait(.535)
		end
		Attacking.Value = false
		wait(0.2)
		EQUIP_CD = false
	end

	if Input.UserInputType == Enum.UserInputType.MouseButton1 and Equipped.Value then
		Holding = true
		if Attacking.Value then
			repeat wait() until not Attacking.Value
		end
		Attacking.Value = true
		CAS:BindAction("BasicHammerFreeze", function() return Enum.ContextActionResult.Sink end, false, unpack(Enum.PlayerActions:GetEnumItems()))
		while Holding and not ZXCV.Enabled and Player:WaitForChild("Values"):WaitForChild("Health").Value > 0 do
			if ATTACK_COUNT == 0 then
				ATTACK_TIMER = 0 
				ATTACK_COUNT = 1 
				s1:Play()
			else
				ATTACK_COUNT = 0 
				s2:Play()
			end
			wait(0.4)
			NewHitbox:HitStart()
			wait(.05)
			Woosh:Play()
			wait(0.17)
			NewHitbox:HitStop()
			wait(.28)
		end
		wait(.05)
		CAS:UnbindAction("BasicHammerFreeze")
		Attacking.Value = false  
	end
end)

UIS.InputEnded:Connect(function(Input, GPE)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		Holding = false
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