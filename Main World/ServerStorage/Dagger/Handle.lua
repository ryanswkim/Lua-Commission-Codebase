-- Services:
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Character instances
local Character = script.Parent.Parent.Parent
local head = Character:WaitForChild("Head")
local rightEye = head:WaitForChild("RightEye")
local rightArm = Character:WaitForChild("RightArm")
local leftArm = Character:WaitForChild("LeftArm")
local torso = Character:WaitForChild("Torso")

-- Player instances:
local Player = Players:GetPlayerFromCharacter(Character)
local attacking = Player:WaitForChild("Gameplay"):WaitForChild("Attacking")
local equipped = Player:WaitForChild("Gameplay"):WaitForChild("Equipped")

-- Weapon instances:
local Dagger = script.Parent.Parent
local DaggerTrail1 = Dagger:WaitForChild("DaggerTrail1")
local DaggerTrail2 = Dagger:WaitForChild("DaggerTrail2")
local weaponRemote = script.Parent:WaitForChild("WeaponRemote")

-- Clock:
local Clock = require(ReplicatedStorage:WaitForChild("Clock"))

-- Config:
local EQUIP_TIME = 0.1

-- Functions:
local function Trail()
	local TrailColor = rightEye.Color
	local ColorSum = rightEye.Color.r + rightEye.Color.g + rightEye.Color.b
	if ColorSum <= 0.25 then
		TrailColor = Color3.new(1,1,1)
	end
	DaggerTrail1.Color = ColorSequence.new(TrailColor)
	DaggerTrail2.Color = ColorSequence.new(TrailColor)
end

weaponRemote.OnServerEvent:Connect(function(Player, Argument, Time)
	local Delay = Clock:GetTime() - Time
	if Delay < 0 or Delay > 40 then return end
	
	if Argument == "Equipped" then
		equipped.Value = true
		if Delay + .03 <= EQUIP_TIME then
			wait(EQUIP_TIME - Delay)
		end
		DaggerTrail1.Enabled = true
		DaggerTrail2.Enabled = true
	
		local NewWeld1 = Dagger:WaitForChild("Weld1"):Clone() 
		NewWeld1.Part0 = rightArm
		Dagger:WaitForChild("Weld1"):Destroy()
		Dagger:WaitForChild("Handle1").CFrame = rightArm.CFrame * CFrame.Angles(math.rad(180),math.rad(90),math.rad(0)) * CFrame.new(0.035,0.05,0) * CFrame.Angles(math.rad(90), 0, 0)
		NewWeld1.Parent = Dagger 
	
		local NewWeld2 = Dagger:WaitForChild("Weld2"):Clone() 
		NewWeld2.Part0 = leftArm
		Dagger:WaitForChild("Weld2"):Destroy()
		Dagger:WaitForChild("Handle2").CFrame = leftArm.CFrame * CFrame.Angles(math.rad(180),math.rad(-90),math.rad(0)) * CFrame.new(0.035,0.05,0) * CFrame.Angles(math.rad(90), 0, 0)
		NewWeld2.Parent = Dagger 
	end
	if Argument == "Unequipped" then
		equipped.Value = false
		if Delay + .03 <= EQUIP_TIME then
			wait(EQUIP_TIME - Delay)
		end
		DaggerTrail1.Enabled = false
		DaggerTrail2.Enabled = false
	
		local NewWeld1 = Dagger:WaitForChild("Weld1"):Clone() 
		NewWeld1.Part0 = torso
		Dagger:WaitForChild("Weld1"):Destroy()
		Dagger:WaitForChild("Handle1").CFrame = torso.CFrame * CFrame.Angles(math.rad(0),math.rad(90),math.rad(196.5)) * CFrame.new(-0.25,0.175,0.47) * CFrame.Angles(math.rad(90), 0, 0)
		NewWeld1.Parent = Dagger 
	
		local NewWeld2 = Dagger:WaitForChild("Weld2"):Clone() 
		NewWeld2.Part0 = torso
		Dagger:WaitForChild("Weld2"):Destroy()
		Dagger:WaitForChild("Handle2").CFrame = torso.CFrame * CFrame.Angles(math.rad(0),math.rad(90),math.rad(196.5)) * CFrame.new(-0.25,0.175,-0.47) * CFrame.Angles(math.rad(90), 0, 0)
		NewWeld2.Parent = Dagger 
	end	
end)

-- Init:
attacking.Value = false
equipped.Value = false
Trail()
rightEye:GetPropertyChangedSignal("Color"):Connect(Trail)
