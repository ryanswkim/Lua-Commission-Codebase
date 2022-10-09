-- Services:
local players = game:GetService("Players")
local serverStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")

-- Modules:
local replicatedModules = replicatedStorage:WaitForChild("Modules")
local DMG = require(serverStorage:WaitForChild("ModuleFunctions"):WaitForChild("DMG"))
local projectileInfo = require(replicatedModules:WaitForChild("ProjectileInfo"))
local Clock = require(replicatedStorage:WaitForChild("Clock"))

-- Remotes:
local replicatedRemotes = replicatedStorage:WaitForChild("Remotes")
local damageRemote = replicatedRemotes:WaitForChild("DamageRemote")
local projectileRemote = replicatedRemotes:WaitForChild("ProjectileRemote")

-- Config:
local MAX_PROJECTILES_PER_SECOND = 3
local PROJECTILE_THRESHOLD = 5

-- Debouncing:
local projectileDebounces = {}
players.PlayerAdded:Connect(function(player)
	projectileDebounces[player.UserId] = 0
end)

players.PlayerRemoving:Connect(function(player)
	if projectileDebounces[player.UserId] ~= nil then
		table.remove(projectileDebounces, player.UserId)
	end
end) 

-- Melee damage:
local function onDamageRemote(player, target, pos)
	-- Player validation:
	if not player.Character or not player.Character:FindFirstChild("WeaponTag", true) then return end
	local playerHealth = player:WaitForChild("Values"):WaitForChild("Health")
	
	--Magnitude validation
	pos = Vector3.new(pos:match("(.+), (.+), (.+)"))
	if not player.Character:FindFirstChild("HumanoidRootPart") or not target:FindFirstChild("HumanoidRootPart") then return end
	if (player.Character.HumanoidRootPart.Position - pos).magnitude > DMG["MAX_MELEE_RANGE"] then return end
	
	-- Target validation: 
	if not target:IsDescendantOf(workspace:WaitForChild("Targetable")) then return end
	if not target:FindFirstChildWhichIsA("Humanoid") or not target:FindFirstChild("Health") then return end
	if target.Humanoid.Health <= 0 or target.Health.Value <= 0 or not target:FindFirstChild("PlayerTags") then return end
	
	DMG.PlayerDamage(player, target, pos)
end

damageRemote.OnServerEvent:Connect(onDamageRemote)

-- Projectile firing/collision:
local startTime = tick()
local function cacheProjectile(player, weapon)
	local projectileData = projectileInfo[weapon]
	if not projectileData then return end
	local lifetime = projectileData["Lifetime"]
	
	local id = player.UserId
	if not script:FindFirstChild(id) then
		local playerFolder = Instance.new("Folder")
		playerFolder.Name = id
		playerFolder.Parent = script
	end	
	
	local projectileTag = Instance.new("IntValue")
	projectileTag.Name = weapon
	projectileTag.Value = math.floor(tick() - startTime)
	projectileTag.Parent = script[id]
	debris:AddItem(projectileTag, lifetime)
end

local function onCollision(player, hit, weapon)
	-- Validate that the player has a projectile currently being fired 
	local id = player.userId
	if not script:FindFirstChild(id) then return end
	local minTag
	local minTimer = math.huge
	for _, weaponTag in pairs(script[id]:GetChildren()) do
		if weaponTag.Name == weapon and weaponTag.Value < minTimer then
			minTag = weaponTag
			minTimer = weaponTag.Value
		end
	end
	if not minTag then return end
	minTag:Destroy()
	
	-- Check if the weapon is valid
	local projectileData = projectileInfo[weapon]
	if not projectileData then return end
	
	-- Damaging
	projectileData["Damage"](player, hit)
end

local function onFire(player, origin, direction, timeStamp, weapon)
	local projectileData = projectileInfo[weapon]
	if not projectileData then return end
	local lifetimeValue = projectileData["Lifetime"]
	local speedValue = projectileData["Speed"]
	
	local projectileTag = Instance.new("NumberValue")
	projectileTag.Name = "ProjectileTag"
	projectileTag.Value = math.fmod(timeStamp, 40)
	
	local id = Instance.new("IntValue")
	id.Name = "ID"
	id.Value = player.UserId
	id.Parent = projectileTag
	
	local originTag = Instance.new("Vector3Value")
	originTag.Value = origin
	originTag.Name = "Origin"
	originTag.Parent = projectileTag
	
	local dirTag = Instance.new("Vector3Value")
	dirTag.Value = direction
	dirTag.Name = "Direction"
	dirTag.Parent = projectileTag 
	
	local speed = Instance.new("NumberValue")
	speed.Value = speedValue
	speed.Name = "Speed"
	speed.Parent = projectileTag
	
	local weaponTag = Instance.new("StringValue")
	weaponTag.Name = "Weapon"
	weaponTag.Value = weapon
	weaponTag.Parent = projectileTag
	
	local lifetime = Instance.new("NumberValue")
	lifetime.Value = lifetimeValue
	lifetime.Name = "Lifetime"
	lifetime.Parent = projectileTag
	
	projectileTag.Parent = workspace:WaitForChild("Junk")
	debris:AddItem(projectileTag, 0.5)
	cacheProjectile(player, weapon)
end

projectileRemote.OnServerEvent:Connect(function(player, origin, dir, timeStamp)
	if not player.Character or not player.Character:FindFirstChild("WeaponTag", true) then return end
	local weapon = player.Character:FindFirstChild("WeaponTag", true).Parent.Name
	local projectileData = projectileInfo[weapon]
	if not projectileData then return end
	
	if timeStamp then
		local id = player.UserId
		if projectileDebounces[id] > PROJECTILE_THRESHOLD then return end
		projectileDebounces[id] = projectileDebounces[id] + 1
		origin = Vector3.new(origin:match("(.+), (.+), (.+)"))
		dir = Vector3.new(dir:match("(.+), (.+), (.+)"))
		local delta = Clock:GetTime() - timeStamp
		if delta > projectileData["Lifetime"] or delta < 0 then return end
		onFire(player, origin, dir, timeStamp, weapon)
	else
		onCollision(player, origin, dir)	
	end
end)

while wait(1) do
	for id, value in pairs(projectileDebounces) do
		projectileDebounces[id] = math.max(0, value - MAX_PROJECTILES_PER_SECOND)
	end
end

