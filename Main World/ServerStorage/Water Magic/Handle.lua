local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Character = script.Parent.Parent.Parent
local Torso = Character:WaitForChild("Torso")
local RightArm = Character:WaitForChild("RightArm")
local LeftArm = Character:WaitForChild("LeftArm")
local Player = Players:GetPlayerFromCharacter(Character)
local Equipped = Player:WaitForChild("Gameplay"):WaitForChild("Equipped")
local Attacking = Player:WaitForChild("Gameplay"):WaitForChild("Attacking")

local Spellbook = script.Parent.Parent
local RightDecor = Spellbook:WaitForChild("RightDecor")
local LeftDecor = Spellbook:WaitForChild("LeftDecor")


--Initialize
Attacking.Value = false
Equipped.Value = false

Spellbook:SetPrimaryPartCFrame(Torso.CFrame)
Spellbook:WaitForChild("Anchor"):WaitForChild("Weld").Part0 = Torso

RightDecor:SetPrimaryPartCFrame(RightArm.CFrame)
RightDecor:WaitForChild("Weld").Part0 = RightArm

LeftDecor:SetPrimaryPartCFrame(LeftArm.CFrame)
LeftDecor:WaitForChild("Weld").Part0 = LeftArm

local CTag = Instance.new("ObjectValue")
CTag.Name = "MagicEquip"

local ETag = Instance.new("BoolValue")
ETag.Name = "Equipped"

local WeaponRemote = script.Parent:WaitForChild("WeaponRemote")
WeaponRemote.OnServerEvent:Connect(function(Player, Argument)
	if Argument == "Equipped" then
		Equipped.Value = true
		local CTagClone = CTag:Clone()
		CTagClone.Value = Character
		
		local ETagClone = ETag:Clone()
		ETagClone.Value = true
		ETagClone.Parent = CTagClone
		
		CTagClone.Parent = workspace:WaitForChild("Junk")
		Debris:AddItem(CTagClone, .1)
		return
	end
	if Argument == "Unequipped" then
		Equipped.Value = false
		local CTagClone = CTag:Clone()
		CTagClone.Value = Character
		
		local ETagClone = ETag:Clone()
		ETagClone.Value = false
		ETagClone.Parent = CTagClone
		
		CTagClone.Parent = workspace:WaitForChild("Junk")
		Debris:AddItem(CTagClone, .1)
		return
	end	
end)