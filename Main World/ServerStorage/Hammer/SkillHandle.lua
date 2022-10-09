local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local DMG = require(SS:WaitForChild("ModuleFunctions"):WaitForChild("DMG"))
local Player = game:GetService("Players"):GetPlayerFromCharacter(script.Parent.Parent.Parent)
local WeaponSkillPlaying = Player:WaitForChild("PlayingSkills"):WaitForChild("Weapon")
repeat wait() until Player.Character
local Character = Player.Character
local HRP = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

----------------------------------------------------------------------
local DAMAGE_TABLE = {Base = 20, Scalings = {Attack = 5}, Range = 5, LuckProbability = 0, LuckScaling = 3}
local HB_SIZE = 28
local DOT_DAMAGE = 6
local DOT_INTERVAL = 2.5
local DOT_TIMES = 6

----------------------------------------------------------------------
local Connector = script.Parent:WaitForChild("Connector")
local SharedEffects = require(RS:WaitForChild("Modules"):WaitForChild("SharedEffects"))
local Skills = require(SS:WaitForChild("ModuleFunctions"):WaitForChild("Skills"))
local MAR = RS:WaitForChild("Remotes"):WaitForChild("MAR")
local Clock = require(RS:WaitForChild("Clock"))
local G = require(SS:WaitForChild("G"))

local SkillAnimation = Instance.new("Animation")
SkillAnimation.AnimationId = "rbxassetid://04566674210"
local PlaySkill = Humanoid:LoadAnimation(SkillAnimation)

local FireSparks = RS:WaitForChild("Effects"):WaitForChild("FireSparks")
local SmokeAshes = RS:WaitForChild("Effects"):WaitForChild("SmokeAshes")

local HammerSmashTag = Instance.new("ObjectValue")
HammerSmashTag.Name = "HammerSmashSequence"

local HitPosTag = Instance.new("Vector3Value")
HitPosTag.Name = "HitPos"

local HitPartTag = Instance.new("ObjectValue")
HitPartTag.Name = "HitPart"

Connector.OnServerEvent:Connect(function(Player, Time)
	if not Skills.ServerCheck(Player, script.Parent.Parent.Name) then return end
	local Head = Character:FindFirstChild("WeaponTag", true).Parent:FindFirstChild("Head", true)
	if not Head then return end
	
	local ServerTime = Clock:GetTime()
	local DelayTime = ServerTime - Time
	if DelayTime < 0 or DelayTime > 40 then return end
	
	WeaponSkillPlaying.Value = true
	local MaxsizeRay = math.max(Head.Size.X, Head.Size.Y, Head.Size.Z)
	local FSClone = FireSparks:Clone()
	FSClone.Parent = Head
	FSClone.Enabled = true
	local SAClone = SmokeAshes:Clone()
	SAClone.Parent = Head
	SAClone.Enabled = true
	
	spawn(function()
		wait(.95)
		SAClone.Enabled = false
		FSClone.Enabled = false
		Debris:AddItem(FSClone, 2)
		Debris:AddItem(SAClone, 2)
	end)
	
	SharedEffects.MakeBlob("Smoke", Head, 1, 2, .95, 500)
	SharedEffects.MakeBlob("Fire", Head, 1, 2, .95)
	if DelayTime < 0.72 then
		wait(0.72)
	end
	
	PlaySkill:Play()
	local HitPart
	local HitPos
	local Count = 0
	while true do
		if Count > 15 then
			break
		end
		local ShockwaveRay = Ray.new(Head.Position, -Head.CFrame.UpVector * MaxsizeRay / 1.25)
		local Hit, Pos = workspace:FindPartOnRayWithIgnoreList(ShockwaveRay, {workspace:WaitForChild("Junk"), workspace:WaitForChild("Players"), workspace:WaitForChild("NPCs")})
		if not Hit then
			ShockwaveRay = Ray.new(Head.Position - HRP.CFrame.LookVector * MaxsizeRay*1.75, HRP.CFrame.LookVector * MaxsizeRay * 2.75)
			Hit, Pos = workspace:FindPartOnRayWithIgnoreList(ShockwaveRay, {workspace:WaitForChild("Junk"), workspace:WaitForChild("Players"), workspace:WaitForChild("NPCs")})
		end
		if Hit then
			HitPart = Hit
			HitPos = Pos
			break
		end
		Count = Count + 1
		wait()
	end
	
	
	if HitPart then
		if HRP then
			HRP.Anchored = true
			spawn(function()
				wait(.25)
				HRP.Anchored = false
				WeaponSkillPlaying.Value = false
			end)
		end
		local HammerSmashTagClone = HammerSmashTag:Clone()
		HammerSmashTagClone.Value = Character
		
		local HitPartClone = HitPartTag:Clone()
		HitPartClone.Value = HitPart
		HitPartClone.Name = "HitPart"
		HitPartClone.Parent = HammerSmashTagClone
		
		local HitPosClone = HitPosTag:Clone()
		HitPosClone.Value = HitPos
		HitPosClone.Name = "HitPos"
		HitPosClone.Parent = HammerSmashTagClone
		HammerSmashTagClone.Parent = workspace:WaitForChild("Junk")
		
		Debris:AddItem(HammerSmashTagClone, 1)
		
		local HitModels = DMG.EnemiesInHB(HB_SIZE, Head.Position)
		DMG.PlayerAreaDamage(Player, DAMAGE_TABLE, HitModels, (tostring(Player.UserId).."HammerSmash"), Color3.new(1,0,0))
		DMG.Burn(Player, HitModels, DOT_DAMAGE, DOT_TIMES, DOT_INTERVAL)
		DMG.Knockback(Head.Position, HitModels, HB_SIZE, 15, 20, 15, 0.3)
	else
		WeaponSkillPlaying.Value = false
	end
end)