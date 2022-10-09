-- Services:
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Character instances:
local Character = script.Parent.Parent.Parent
local head = Character:WaitForChild("Head")
local rightEye = head:WaitForChild("RightEye")
local rightArm = Character:WaitForChild("RightArm")
local torso = Character:WaitForChild("Torso")

-- Player instances:
local Player = Players:GetPlayerFromCharacter(Character)
local attacking = Player:WaitForChild("Gameplay"):WaitForChild("Attacking")
local equipped = Player:WaitForChild("Gameplay"):WaitForChild("Equipped")

-- Weapon instances:
local Sword = script.Parent.Parent
local SwordTrail = Sword:WaitForChild("SwordTrail")
local weaponRemote = script.Parent:WaitForChild("WeaponRemote")

-- Clock:
local Clock = require(ReplicatedStorage:WaitForChild("Clock"))

-- Config:
local EQUIP_TIME = 0.157

-- Functions:
local function Trail()
	local TrailColor = rightEye.Color
	local ColorSum = rightEye.Color.r +  rightEye.Color.g + rightEye.Color.b
	if ColorSum <= 0.25 then
		TrailColor = Color3.new(1,1,1)
	end
	SwordTrail.Color = ColorSequence.new(TrailColor)
end

weaponRemote.OnServerEvent:Connect(function(Player, Argument, Time)
	local Delay = Clock:GetTime() - Time
	if Delay < 0 or Delay > 40 then return end
	
	if Argument == "Equipped" then
		equipped.Value = true
		if Delay + .03 <= EQUIP_TIME - .03 then
			wait(EQUIP_TIME - Delay)
		end
		
		SwordTrail.Enabled = true
	
		local NewWeld = Sword:WaitForChild("Weld"):Clone() 
		NewWeld.Part0 = rightArm
		Sword:WaitForChild("Weld"):Destroy()
		Sword:SetPrimaryPartCFrame(rightArm.CFrame * CFrame.Angles(math.rad(270),math.rad(180),math.rad(90)) * CFrame.new(-0.025,0,.075))
		NewWeld.Parent = Sword
	end
	if Argument == "Unequipped" then
		equipped.Value = false
		if Delay + .03 <= EQUIP_TIME then
			wait(EQUIP_TIME - Delay)
		end
		SwordTrail.Enabled = false
	
		local NewWeld = Sword:WaitForChild("Weld"):Clone() 
		NewWeld.Part0 = torso
		Sword:WaitForChild("Weld"):Destroy()
		Sword:SetPrimaryPartCFrame(torso.CFrame * CFrame.Angles(math.rad(270),math.rad(135),math.rad(180)) * CFrame.new(1.175,0.335,0))
		NewWeld.Parent = Sword
	end	
end)

-- Init:
attacking.Value = false
equipped.Value = false
Trail()
rightEye:GetPropertyChangedSignal("Color"):Connect(Trail)