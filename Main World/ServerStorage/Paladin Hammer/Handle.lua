-- Services:
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Character instances:
local Character = script.Parent.Parent.Parent
local torso = Character:WaitForChild("Torso") 
local rightArm = Character:WaitForChild("RightArm")

-- Player instances:
local Player = Players:GetPlayerFromCharacter(Character)
local attacking = Player:WaitForChild("Gameplay"):WaitForChild("Attacking")
local equipped = Player:WaitForChild("Gameplay"):WaitForChild("Equipped")

-- Weapon instances:
local Hammer = script.Parent.Parent
local HammerTrail = script:WaitForChild("HammerTrail")
local attachment1 = Hammer:WaitForChild("Head"):WaitForChild("Trail1")
local attachment2 = Hammer:WaitForChild("Head"):WaitForChild("Trail2")
local weaponRemote = script.Parent:WaitForChild("WeaponRemote")

-- Clock:
local Clock = require(ReplicatedStorage:WaitForChild("Clock"))

-- Config:
local EQUIP_TIME = 0.235

-- Functions:
weaponRemote.OnServerEvent:Connect(function(Player, Argument, Time)
	local Delay = Clock:GetTime() - Time
	if Delay < 0 or Delay > 40 then return end
	
	if Argument == "Equipped" then
		attachment1.Position = Vector3.new(0,1.1, 0.65)
		attachment2.Position = Vector3.new(0,1.1, -0.19)
		if Delay + .03 <= EQUIP_TIME then
			wait(EQUIP_TIME - Delay)
		end
		HammerTrail.Enabled = true
	
		local NewWeld = Hammer:WaitForChild("Weld"):Clone() 
		NewWeld.Part0 = rightArm
		Hammer:WaitForChild("Weld"):Destroy()
		Hammer:SetPrimaryPartCFrame(rightArm.CFrame * CFrame.Angles(math.rad(270),math.rad(180),math.rad(90)) * CFrame.new(-0.2,0,.08))
		NewWeld.Parent = Hammer
		wait(.2)
		equipped.Value = true 
	end
	if Argument == "Unequipped" then
		attachment1.Position = Vector3.new(0,-1.1, 0.65)
		attachment2.Position = Vector3.new(0,-1.1, -0.19)
		if Delay + .03 <= EQUIP_TIME then
			wait(EQUIP_TIME - Delay)
		end
		HammerTrail.Enabled = false
		equipped.Value = false
		
		local NewWeld = Hammer:WaitForChild("Weld"):Clone() 
		NewWeld.Part0 = torso
		Hammer:WaitForChild("Weld"):Destroy()
		Hammer:SetPrimaryPartCFrame(torso.CFrame * CFrame.Angles(math.rad(90),math.rad(198),math.rad(180)) * CFrame.new(0.76,-0.45,0.385))
		NewWeld.Parent = Hammer
	end	
end)

-- Init:
attacking.Value = false
equipped.Value = false