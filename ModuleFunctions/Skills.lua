local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(game:GetService("ServerStorage"):WaitForChild("G"))
local Skills = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DisplayInfo"))["Skills"]

local function CreateCooldown(Player, SkillName)
	local SCD = Instance.new("NumberValue")
	SCD.Value = Skills[SkillName]["Cooldown"]
	SCD.Name = SkillName.."Cooldown"
	SCD.Parent = Player:WaitForChild("Cooldowns")
	Debris:AddItem(SCD, Skills[SkillName]["Cooldown"])
end

Skills.ServerCheck = function(Player, SkillName)
	local Values = Player:WaitForChild("Values")
	local Mana = Values:WaitForChild("Mana")
	local Health = Values:WaitForChild("Health")
	
	local Cooldowns = Player:WaitForChild("Cooldowns")
	
	local Equipped = Player:WaitForChild("Gameplay"):WaitForChild("Equipped")
	
	local Skill = Skills[SkillName]
	if ((Skill["RequiresEquip"] and Equipped.Value) 
	or not Skill["RequiresEquip"]) and Mana.Value > Skill["ManaCost"] 
	and Health.Value > 0 and G.CheckCharacter(Player)
	and not Cooldowns:FindFirstChild(SkillName.."Cooldown") then
		Mana.Value = Mana.Value - Skill["ManaCost"]
		CreateCooldown(Player, SkillName)
		return true
	else
		return false
	end
end

return Skills
