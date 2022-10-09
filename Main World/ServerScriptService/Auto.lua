-- Services:
local players = game:GetService("Players")
local serverStorage = game:GetService("ServerStorage")

-- Player workspace:
local playerWorkspace = workspace:WaitForChild("Players")

-- Wait times:
local HEALTH_INTERVAL = 10
local MANA_INTERVAL = 5
local HUNGER_INTERVAL = 10
local MAX_WAIT = 10

-- Regen ratios:
local HEALTH_RATIO = 0.01
local MANA_RATIO = 0.01
local BASE_HUNGER_RATIO = 0.01
local SPRINTING_HUNGER_RATIO = 0.025

-- Functions:
local function isRunning(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	
	local velocity = root.Velocity
	return math.abs(velocity.X) + math.abs(velocity.Z) > 0
end

-- Main initializer:
playerWorkspace.ChildAdded:Connect(function(character)
	-- Check if player:
	local player = players:GetPlayerFromCharacter(character)
	if not player then return end
	
	-- Check instances:
	local values = player:WaitForChild("Values", MAX_WAIT)
	local gameplay = player:WaitForChild("Gameplay", MAX_WAIT)
	if not values or not gameplay then return end
	
	-- Check value instances:
	local health = values:WaitForChild("Health", MAX_WAIT)
	local maxHealth = values:WaitForChild("MaxHealth", MAX_WAIT)
	local mana = values:WaitForChild("Mana", MAX_WAIT)
	local maxMana = values:WaitForChild("MaxMana", MAX_WAIT)
	local hunger = values:WaitForChild("Hunger", MAX_WAIT)
	local maxHunger = values:WaitForChild("MaxHunger", MAX_WAIT)
	if not health or not maxHealth or not mana or not maxMana
		or not hunger or not maxHunger then return end
	
	-- Check gameplay instances
	local sprinting = gameplay:WaitForChild("Sprinting", MAX_WAIT)
	local reset = gameplay:WaitForChild("Reset", MAX_WAIT)
	if not sprinting or not reset then return end
	
	
	-- Health:
	spawn(function()
		while wait(HEALTH_INTERVAL) do
			if health.Value <= 0 or not character then return end
			health.Value = health.Value + math.min(maxHealth.Value * HEALTH_RATIO, maxHealth.Value - health.Value)
		end
	end)
	
	-- Mana:
	spawn(function()
		while wait(MANA_INTERVAL) do
			if health.Value <= 0 or not character then return end
			mana.Value = mana.Value + math.min(maxMana.Value * MANA_RATIO, maxMana.Value - mana.Value)
		end
	end)
	
	
	-- Hunger:
	spawn(function()
		while wait(HUNGER_INTERVAL) do
			if health.Value <= 0 or not character then return end
			if not sprinting.Value then
				-- Base decay:
				hunger.Value = hunger.Value - math.min(hunger.Value, BASE_HUNGER_RATIO)
			else
				-- Sprinting decay:
				hunger.Value = hunger.Value - math.min(hunger.Value, SPRINTING_HUNGER_RATIO)
			end
		end
	end)
end)