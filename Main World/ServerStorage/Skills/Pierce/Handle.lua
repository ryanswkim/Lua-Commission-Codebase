local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local RegMod = require(SS:WaitForChild("ModuleFunctions"):WaitForChild("RegionModule"))
local DMG = require(SS:WaitForChild("ModuleFunctions"):WaitForChild("DMG"))
local Player = script.Parent.Parent.Parent
local Health = Player:WaitForChild("Values"):WaitForChild("Health")
local Mana = Player:WaitForChild("Values"):WaitForChild("Mana")
local Equipped = Player:WaitForChild("Gameplay"):WaitForChild("Equipped")
repeat wait() until Player.Character
local Character = Player.Character
local HRP = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

----------------------------------------------------------------------
local ManaCost = 1
local Cooldown = 5
----------------------------------------------------------------------
local Connector = script.Parent:WaitForChild("Connector")
local SharedEffects = require(RS:WaitForChild("Modules"):WaitForChild("SharedEffects"))
local G = require(SS:WaitForChild("G"))
local AS = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("AbilitySequence"))
local MAR = RS:WaitForChild("Remotes"):WaitForChild("MAR")
local Clock = require(RS:WaitForChild("Clock"))

local SkillAnimation = Instance.new("Animation")
SkillAnimation.AnimationId = "rbxassetid://04566674210"
local PlaySkill = Humanoid:LoadAnimation(SkillAnimation)

local OnCooldown = false
function DoCoroutine(F)
	coroutine.resume(coroutine.create(F))
end

function CheckDelay(WaitTime, Delay)
	if Delay < WaitTime then
		wait(WaitTime - Delay)
		return 0
	else
		return Delay - WaitTime
	end
end


Connector.OnServerEvent:Connect(function(Player, Time)
	if Health.Value <= 0 or Mana.Value < ManaCost or not Equipped.Value or OnCooldown or not Character:FindFirstChild("WeaponTag", true) or not G.CheckCharacter(Player) then return false end
	
end)