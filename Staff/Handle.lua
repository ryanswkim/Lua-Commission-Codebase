local Staff = script.Parent.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Character = script.Parent.Parent.Parent
local Player = Players:GetPlayerFromCharacter(Character)
local StaffTrail = Staff:WaitForChild("StaffTrail")


local function Trail()
	local TrailColor = Character:WaitForChild("Head"):WaitForChild("RightEye").Color
	local ColorSum = Character:WaitForChild("Head"):WaitForChild("RightEye").Color.r +  Character:WaitForChild("Head"):WaitForChild("RightEye").Color.g + Character:WaitForChild("Head"):WaitForChild("RightEye").Color.b
	if ColorSum <= 0.25 then
		TrailColor = Color3.new(1,1,1)
	end
	StaffTrail.Color = ColorSequence.new(TrailColor)
end


Player:WaitForChild("Gameplay"):WaitForChild("Attacking").Value = false
Player:WaitForChild("Gameplay"):WaitForChild("Equipped").Value = false

Trail()
Character:WaitForChild("Head"):WaitForChild("RightEye"):GetPropertyChangedSignal("Color"):Connect(function()
	Trail()
end)

local Clock = require(ReplicatedStorage:WaitForChild("Clock"))
local EQUIP_TIME = 0.11
script.Parent:WaitForChild("WeaponRemote").OnServerEvent:Connect(function(Player, Argument, Time)
	local Delay = Clock:GetTime() - Time
	if Argument == "Equipped" then
		Player:WaitForChild("Gameplay").Equipped.Value = true
		if Delay < EQUIP_TIME - .03 then
			wait(EQUIP_TIME - Delay)
		end
		StaffTrail.Enabled = true
	
		local NewWeld = Staff:WaitForChild("Weld"):Clone() 
		NewWeld.Part0 = Character:WaitForChild("RightArm") 
		Staff:WaitForChild("Weld"):Destroy()
		Staff:SetPrimaryPartCFrame(Character:WaitForChild("RightArm").CFrame * CFrame.Angles(math.rad(90),math.rad(-90),math.rad(0)) * CFrame.new(0.05,.696,0))
		NewWeld.Parent = Staff
	end
	if Argument == "Unequipped" then
		Player:WaitForChild("Gameplay").Equipped.Value = false
		if Delay < EQUIP_TIME then
			wait(EQUIP_TIME - Delay)
		end
		StaffTrail.Enabled = false
	
		local NewWeld = Staff:WaitForChild("Weld"):Clone() 
		NewWeld.Part0 = Character:WaitForChild("Torso") 
		Staff:WaitForChild("Weld"):Destroy()
		Staff:SetPrimaryPartCFrame(Character:WaitForChild("Torso").CFrame * CFrame.Angles(math.rad(-70),math.rad(270),math.rad(180)) * CFrame.new(0.1,0.146,0.468))
		NewWeld.Parent = Staff
	end	
end)