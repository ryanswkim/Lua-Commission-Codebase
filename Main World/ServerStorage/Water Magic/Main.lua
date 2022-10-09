-- Services:
local TS = game:GetService("TweenService")
local CAS = game:GetService("ContextActionService") 
local UIS = game:GetService("UserInputService") 
local replicatedStorage = game:GetService("ReplicatedStorage")
local run = game:GetService("RunService")

-- Player instances: 
local player = game.Players.LocalPlayer
local playerGameplay = player:WaitForChild("Gameplay")
local attacking = playerGameplay:WaitForChild("Attacking")
local equipped = playerGameplay:WaitForChild("Equipped")
local zxcv = player:WaitForChild("PlayerGui"):WaitForChild("ZXCV") 

--Character instances:
while not player.Character do wait() end
local character = player.Character
local mouse = player:GetMouse()
local humanoid = character:WaitForChild("Humanoid")
local rightArm = character:WaitForChild("RightArm")
local leftArm = character:WaitForChild("LeftArm")
local cameraLocked = character:WaitForChild("Scripts"):WaitForChild("CameraScript"):WaitForChild("CameraLocked")

-- Remotes:
local replicatedRemotes = replicatedStorage:WaitForChild("Remotes")
local weaponRemote = script:WaitForChild("WeaponRemote") 
local projectileRemote = replicatedRemotes:WaitForChild("ProjectileRemote")

-- Spellbook instances:
local spellbook = script.Parent
local rightDecor = spellbook:WaitForChild("RightDecor"):WaitForChild("Decoration")
local leftDecor = spellbook:WaitForChild("LeftDecor"):WaitForChild("Decoration")

-- Modules:
local replicatedModules = replicatedStorage:WaitForChild("Modules")
local clock = require(replicatedStorage:WaitForChild("Clock"))
local sharedEffects = require(replicatedModules:WaitForChild("SharedEffects"))
local projectileInfo = require(replicatedModules:WaitForChild("ProjectileInfo"))[spellbook.Name]

-- Variables: 
local equipCD = false
local attackCount = 0 
local attackTimer = 0

-- Serializing:
local function packV3(v3)
	return tostring(v3.X) .. ", " .. tostring(v3.Y) .. ", " .. tostring(v3.Z)
end

-- Dealing with transparencies:
while #leftDecor:GetChildren() < 4 and #rightDecor:GetChildren() < 4 do run.Heartbeat:Wait() end
local BaseParts = {}
local BaseTransparencies = {}
for i,v in pairs(leftDecor:GetChildren()) do
	table.insert(BaseParts, #BaseParts + 1, v)
	table.insert(BaseTransparencies, #BaseTransparencies + 1, v.Name)
end
for i,v in pairs(rightDecor:GetChildren()) do
	table.insert(BaseParts, #BaseParts + 1, v)
	table.insert(BaseTransparencies, #BaseTransparencies + 1, v.Name)
end

function EquipMagic(On)
	if On then
		for i,v in pairs(BaseParts) do
			if v:FindFirstChildWhichIsA("ParticleEmitter") then
				v:FindFirstChildWhichIsA("ParticleEmitter").Enabled = true
			end
			v.Name = BaseTransparencies[i]
			TS:Create(v, TweenInfo.new(0.3), {Transparency = tonumber(v.Name)}):Play()
		end
	else
		for i,v in pairs(BaseParts) do
			if v:FindFirstChildWhichIsA("ParticleEmitter") then
				v:FindFirstChildWhichIsA("ParticleEmitter").Enabled = false
			end
			v.Name = 1
			TS:Create(v, TweenInfo.new(0.3), {Transparency = 1}):Play()
		end
	end
end

-- Input reading:
local holding = false
UIS.InputBegan:Connect(function(Input, GPE)
	if GPE or attacking.Value or zxcv.Enabled or player:WaitForChild("Values"):WaitForChild("Health").Value <= 0 then return end
	
	if Input.KeyCode == Enum.KeyCode.Q then
		if equipCD then return end
		attacking.Value = true
		equipCD = true
		if not equipped.Value then
			weaponRemote:FireServer("Equipped")
			EquipMagic(true, rightDecor)
			EquipMagic(true, leftDecor)
		else
			attackCount = 0
			weaponRemote:FireServer("Unequipped")
			EquipMagic(false, rightDecor)
			EquipMagic(false, leftDecor)
		end 
		wait(0.05)
		attacking.Value = false
		wait(0.3) 
		equipCD = false
	end
	
	if Input.UserInputType == Enum.UserInputType.MouseButton1 and equipped.Value then
		holding = true
		if attacking.Value then
			repeat wait() until not attacking.Value
		end
		attacking.Value = true
		while holding and not zxcv.Enabled and player:WaitForChild("Values"):WaitForChild("Health").Value > 0 do
			cameraLocked.Value = true
			local startPos
			if attackCount == 0 then
				attackCount = 1
				startPos = rightArm.Position 
			else
				startPos = leftArm.Position
				attackCount = 0
			end
			local dir = (mouse.Hit.Position - startPos).Unit
			sharedEffects:Projectile(startPos, dir, projectileInfo["Speed"], spellbook.Name, projectileInfo["Lifetime"], true) 
			projectileRemote:FireServer(packV3(startPos), packV3(dir), clock:GetTime())
			wait(1)
		end
		attacking.Value = false
	end
end)

UIS.InputEnded:Connect(function(Input, GPE)
	if not GPE and Input.UserInputType == Enum.UserInputType.MouseButton1 then
		holding = false
	end
end)

-- Init:
attacking.Value = false
equipped.Value = false
EquipMagic(false)