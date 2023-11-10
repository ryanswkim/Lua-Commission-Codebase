local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedEffects = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SharedEffects"))
local TS = game:GetService("TweenService")
local DI = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DisplayInfo"))

local SharedWeaponScripts = {}

local function packV3(v3)
	return tostring(v3.X) .. ", " .. tostring(v3.Y) .. ", " .. tostring(v3.Z)
end

function SharedWeaponScripts:HBCheck(Player, Target, HitPos, ScreenshakeSum, ScreenshakeMax, Weapon)
	local Screenshake = Player:WaitForChild("Gameplay"):WaitForChild("Screenshake")
	while true do
		if Target:FindFirstChildOfClass("Humanoid") then break end
		Target = Target.Parent
	end
	
	if Target:FindFirstAncestor("Players") then return end
	
	if not Target:FindFirstChild("Health") or not Target:FindFirstChild("MaxHealth") 
	or not Target:FindFirstChild("Debounces", true) or Target.Health.Value <= 0 or Target.Humanoid.Health <= 0 then return end
	
	local Valid = true
	if string.find(string.lower(Weapon), "dagger") then
		local DaggerDebounceCount = 0
		for i,v in pairs(Target:FindFirstChild("Debounces", true):GetChildren()) do
			if v.Name == tostring(Player.UserId)..Weapon.."Debounce" then
				DaggerDebounceCount = DaggerDebounceCount + 1
			end
			if DaggerDebounceCount >= 2 then
				Valid = false
				break
			end
		end
	else
		if Target:FindFirstChild("Debounces", true):FindFirstChild(tostring(Player.UserId)..Weapon.."Debounce") then 
			Valid = false
		end
	end
	if not Valid then return end
	
	local Debounce = Instance.new("StringValue")
	Debounce.Name = tostring(Player.UserId)..Weapon.."Debounce"
	Debounce.Parent = Target:FindFirstChild("Debounces", true)
	game:GetService("Debris"):AddItem(Debounce, 0.1)
	
	ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DamageRemote"):FireServer(Target, packV3(HitPos))

	if Target:IsDescendantOf(workspace.Targetable) and Player.Character then
		SharedEffects.MakeBlood(HitPos)
		local SoundToClone = DI["Sounds"][tostring(Weapon)]
		if SoundToClone then
			local TargetSound = SoundToClone:Clone()
			TargetSound.Parent = Target 
			TargetSound:Play()
			game:GetService("Debris"):AddItem(TargetSound, TargetSound.TimeLength * 1.25) 
		end 
		
		if Screenshake.Value + ScreenshakeSum > ScreenshakeMax then
			ScreenshakeSum = ScreenshakeMax - Screenshake.Value
		end
		if ScreenshakeSum < 0 then
			ScreenshakeSum = 0
		end
		Screenshake.Value = Screenshake.Value + ScreenshakeSum
	end
end

function SharedWeaponScripts:ClientCheck(Player, SkillName)
	local Values = Player:WaitForChild("Values")
	local Mana = Values:WaitForChild("Mana")
	local Health = Values:WaitForChild("Health")
	
	local Cooldowns = Player:WaitForChild("Cooldowns")
	
	local Gameplay = Player:WaitForChild("Gameplay")
	local Equipped = Gameplay:WaitForChild("Equipped")
	local Attacking = Gameplay:WaitForChild("Attacking")
	
	local Skill = DI["Skills"][SkillName]
	if Skill and not Attacking.Value and ((Skill["RequiresEquip"] and Equipped.Value) 
	or not Skill["RequiresEquip"]) and Mana.Value > Skill["ManaCost"] 
	and Health.Value > 0 
	and not Cooldowns:FindFirstChild(SkillName.."Cooldown") then
		return true
	else
		return false
	end
end

function SharedWeaponScripts:FireProjectile()
	
end

return SharedWeaponScripts
