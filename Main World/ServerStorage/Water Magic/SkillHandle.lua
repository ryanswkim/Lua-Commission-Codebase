local BaseHBSize = 6.5
local HBScaling = 1/120
local DamageTable = {Base = 5, Scalings = {Wisdom = 3}, Range = 5, LuckProbability = 0, LuckScaling = 3}
----------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DMG = require(game:GetService("ServerStorage"):WaitForChild("ModuleFunctions"):WaitForChild("DMG"))
local Player = game:GetService("Players"):GetPlayerFromCharacter(script.Parent.Parent.Parent)
local WeaponSkillPlaying = Player:WaitForChild("PlayingSkills"):WaitForChild("Weapon")
repeat wait() until Player.Character
local Character = Player.Character
local LeftArm = Character:WaitForChild("LeftArm")
local HRP = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local SkillAnimation = Instance.new("Animation")
SkillAnimation.AnimationId = "rbxassetid://04612049611"
local PlaySkill = Humanoid:LoadAnimation(SkillAnimation)

----------------------------------------------------------------------
local Skills = require(game:GetService("ServerStorage"):WaitForChild("ModuleFunctions"):WaitForChild("Skills"))
local Connector = script.Parent:WaitForChild("Connector")
local Clock = require(game:GetService("ReplicatedStorage"):WaitForChild("Clock"))
local MAR = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("MAR")

Connector.OnServerEvent:Connect(function(Player, Time)
	if Time then
		if not Skills.ServerCheck(Player, script.Parent.Parent.Name) then return end
		local Delay = Clock:GetTime() - Time
		if Delay < 0 or Delay > 40 then return end
		
		WeaponSkillPlaying.Value = true
		MAR:FireAllClients(Player, "AquaPulse", Delay, Clock:GetTime())
		
		if Delay < 0.27 then
			wait(0.3 - Delay)
		else
			Delay = Delay - 0.3
		end
		
		local StopCharge = Instance.new("BoolValue")
		StopCharge.Name = "StopAquaPulseCharge"
		StopCharge.Parent = HRP
		
		if Delay < 0.27 then
			wait(0.3 - Delay)
		end
		StopCharge:Destroy()
		PlaySkill:Play()
		
		local velocity = Instance.new("BodyVelocity")
		velocity.MaxForce = Vector3.new(0,0,0)
		velocity.Name = "AquaPulse"
		velocity.Parent = HRP
	
		local ExplodePosition = LeftArm.Position
		local HitModels = DMG.EnemiesInHB(BaseHBSize, ExplodePosition)
		DMG.PlayerAreaDamage(Player, DamageTable, HitModels, (tostring(Player.UserId).."AquaPulse"))
		DMG.Soak(HitModels, 10)
	else
		WeaponSkillPlaying.Value = false
	end
end)