local Character = script.Parent.Parent 
local Player = game.Players:GetPlayerFromCharacter(Character) 
local ZXCV = Player.PlayerGui:WaitForChild("ZXCV") 
local Humanoid = Character:WaitForChild("Humanoid")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService") 
local SharedWeaponScripts = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SharedWeaponScripts"))
local RaycastHitbox = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RaycastHitbox"))
local Dagger = script.Parent
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
local equipAnim = Instance.new("Animation") equipAnim.Name = "Equip" equipAnim.AnimationId = "rbxassetid://04500885410" local pEquip = Humanoid:LoadAnimation(equipAnim)
local slash1 = Instance.new("Animation") slash1.Name = "Slash" slash1.AnimationId = "rbxassetid://04500944381" local s1 = Humanoid:LoadAnimation(slash1)
local slash2 = Instance.new("Animation") slash2.Name = "Slash" slash2.AnimationId = "rbxassetid://04500956788" local s2 = Humanoid:LoadAnimation(slash2)
local slash1Walking = Instance.new("Animation") slash1Walking.Name = "Slash1" slash1Walking.AnimationId = "rbxassetid://04511369268" 
local slash2Walking = Instance.new("Animation") slash2Walking.Name = "Slash1" slash2Walking.AnimationId = "rbxassetid://04511395459" 
local daggerIdle = Instance.new("Animation") daggerIdle.Name = "Idle" daggerIdle.AnimationId = "rbxassetid://04500902723" local pIdle = Humanoid:LoadAnimation(daggerIdle) 
--------------------------------------------------------------Damage register
local NewHitbox1 = RaycastHitbox:Initialize(Dagger:WaitForChild("Handle1"))
local NewHitbox2 = RaycastHitbox:Initialize(Dagger:WaitForChild("Handle2"))
NewHitbox1.OnHit:Connect(function(Target, HitPos)
	SharedWeaponScripts:HBCheck(Player, Target, HitPos, 245, 600, script.Parent.Name)
end) 
NewHitbox2.OnHit:Connect(function(Target, HitPos)
	SharedWeaponScripts:HBCheck(Player, Target, HitPos, 245, 600, script.Parent.Name)
end) 
--------------------------------------------------------------Animation resetter
local EQUIP_CD = false
local ATTACK_COUNT = 0 
local ATTACK_TIMER = 0
spawn (function()
	while wait() do
		ATTACK_TIMER = ATTACK_TIMER + 1
		if ATTACK_TIMER >= 30 then
			ATTACK_COUNT = 0
		end
	end
end)
--------------------------------------------------------------Bind
local Holding = false
UIS.InputBegan:Connect(function(Input, GPE)
	if GPE or ZXCV.Enabled or Player:WaitForChild("Values"):WaitForChild("Health").Value <= 0 then return end
	
	if Input.KeyCode == Enum.KeyCode.Q then
		if Attacking.Value or EQUIP_CD then return end
		Holding = false
		Attacking.Value = true
		EQUIP_CD = true
		if not Equipped.Value then
			WeaponRemote:FireServer("Equipped", Clock:GetTime())
		else
			WeaponRemote:FireServer("Unequipped", Clock:GetTime())
			ATTACK_COUNT = 0
		end
		Equipped.Value = not Equipped.Value
		pEquip:Play()
		wait(.11)
		Attacking.Value = false
		wait(0.25) 
		EQUIP_CD = false
	end
	
	

	if Input.UserInputType == Enum.UserInputType.MouseButton1 and Equipped.Value then
		Holding = true
		if Attacking.Value then
			repeat wait() until not Attacking.Value
		end
		Attacking.Value = true
		while Holding and not ZXCV.Enabled and Player:WaitForChild("Values"):WaitForChild("Health").Value > 0 do
			NewHitbox1:HitStart()
			NewHitbox2:HitStart()
			if ATTACK_COUNT == 0 then
				ATTACK_TIMER = 0 
				ATTACK_COUNT = 1 
				s1:Play()
			else
				ATTACK_COUNT = 0 
				s2:Play()
			end
			wait(.035) 
			Woosh:Play()
			wait(.235)
			NewHitbox1:HitStop()
			NewHitbox2:HitStop()
			wait(.037)
		end
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
		NewHitbox1:HitStart()
		NewHitbox2:HitStart()
	else
		NewHitbox1:HitStop()
		NewHitbox2:HitStop()
	end
end)