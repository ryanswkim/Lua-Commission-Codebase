-- Services:
local run = game:GetService("RunService")
local serverStorage

-- Modules:
local dmg
local mobData

-- Init only if server:
if run:IsServer() then
	serverStorage = game:GetService("ServerStorage")
	dmg = require(serverStorage:WaitForChild("ModuleFunctions"):WaitForChild("DMG"))
	mobData = require(serverStorage:WaitForChild("ModuleData"):WaitForChild("MobData"))
end

local function baseDamageFunction(player, mob, ...)
	local root = mob:FindFirstChild("HumanoidRootPart", true)
	local humanoid = mob:FindFirstChildWhichIsA("Humanoid")
	if not root then return end
	
	-- Validate that mob has remaining health
	local health = mob:FindFirstChild("Health")
	local target = mob:FindFirstChild("Target")
	local locked = mob:FindFirstChild("Locked")
	if not locked and not target or not health or health.Value <= 0 then return end
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
	
	-- Damage:
	local damage, lucky = dmg.CalculateDamage(player, ...)
	damage = math.min(health.Value, damage)
	health.Value = health.Value - damage
	dmg.CheckTags(player, mob, damage)
	dmg.Soak({mob}, 2)
	
	-- Lock target after being damaged
	local mobInfo = mobData[mob.Name]
	local trackingRange = mobInfo["TrackingRange"]
	if not trackingRange then
		trackingRange = 0
	end
	local distanceToTrackingRange = math.max(0, (player.Character.HumanoidRootPart.Position - root.Position).Magnitude - trackingRange)
	local timeToTrackingRange = distanceToTrackingRange/humanoid.WalkSpeed
	if timeToTrackingRange > 0.03 then
		locked.Value = true
		target.Value = player.Character
		
		-- Make sure it doesn't unlock
		local lockConnection = locked.Changed:Connect(function()
			if not locked.Value then
				locked.Value = true
			end
		end)
		
		local targetConnection = target.Changed:Connect(function()
			if not target.Value then
				target.Value = player.Character
			end
		end)
		
		-- Wait to disable:
		wait(timeToTrackingRange)
		lockConnection:Disconnect()
		targetConnection:Disconnect()
		locked.Value = false
	end
end

local projectile = {
	WaterMagic = {
		AnimationDelay = 0,
		Speed = 40, 
		Lifetime = 3, 
		Damage = function(player, hit)
			-- Check if hit is valid:
			if not hit:IsDescendantOf(workspace:WaitForChild("Targetable")) then return end
			
			-- Get parent mob:
			local mob = hit
			while not mob:FindFirstChildWhichIsA("Humanoid") do mob = mob.Parent end
			
			-- Damage/effects:
			dmg.Soak({mob}, 2)
			baseDamageFunction(player, mob, 10, {Intelligence = 1}, 2, 900, 3)
		end
	},
	
}

return projectile
