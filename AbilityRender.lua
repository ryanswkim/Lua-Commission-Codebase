--Services
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Junk = workspace:WaitForChild("Junk")
local TS = game:GetService("TweenService")
local run = game:GetService("RunService")

-- Player instances:
local Player = Players.LocalPlayer
while not Player.Character do wait() end
local Character = Player.Character
local HRP = Character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Modules:
local replicatedModules = RS:WaitForChild("Modules")
local SharedEffects = require(replicatedModules:WaitForChild("SharedEffects"))
local DI = require(replicatedModules:WaitForChild("DisplayInfo"))
local AbilitySequence = require(replicatedModules:WaitForChild("AbilitySequence"))
local Clock = require(RS:WaitForChild("Clock"))

--Remotes
local remotes = RS:WaitForChild("Remotes")
local MAR = remotes:WaitForChild("MAR")
local projectileRemote = remotes:WaitForChild("ProjectileRemote")

-- Variables:
local renderDistance = Player:WaitForChild("PlayerScripts"):WaitForChild("Settings"):WaitForChild("RenderDistance")

-- Functions:
local function overMagnitude(pos)
	return (camera.CFrame.Position - pos).Magnitude > renderDistance.Value
end

local function invalidate(item, pos)
	if overMagnitude(pos) then
		run.Heartbeat:Wait()
		item:Destroy()
		return true
	end
	return false
end

local function packV3(v3)
	return tostring(v3.X) .. ", " .. tostring(v3.Y) .. ", " .. tostring(v3.Z)
end

--Calling players via remote
MAR.OnClientEvent:Connect(function(Caster, Ability, Delay, Time)
	if Caster == Player or not Caster.Character or not Caster.Character:FindFirstChild("HumanoidRootPart") 
	or overMagnitude(Caster.Character.HumanoidRootPart.Position) then return end
	
	local FinalDelay
	if Delay and Time then
		FinalDelay = Delay + Clock:GetTime() - Time
	else
		FinalDelay = 0
	end
	
	if Ability == "AgileSwipe" then
		AbilitySequence.AgileSwipe(Caster, FinalDelay)
	end
	if Ability == "AquaPulse" then
		AbilitySequence.AquaPulse(Caster, FinalDelay)
	end
end)

--Calling players via childadded event

Junk.ChildAdded:Connect(function(child)
	if child.Name == "ProjectileTag" then
		local ID = child:WaitForChild("ID").Value
		local origin = child:WaitForChild("Origin").Value
		if ID == Player.UserId or overMagnitude(origin) then return end
		
		local timeStamp = child.Value
		local direction = child:WaitForChild("Direction").Value
		local speed = child:WaitForChild("Speed").Value
		local weapon = child:WaitForChild("Weapon").Value
		local lifetime = child:WaitForChild("Lifetime").Value
		local delta = math.fmod(Clock:GetTime(), 40) - timeStamp
		
		origin = origin + direction * speed * delta
		local projectile = SharedEffects:Projectile(origin, direction, speed, weapon, lifetime)
	end
	
	if child.Name == "Projectile" then
		if invalidate(child, child.Position) then return end
		local velocity = child:WaitForChild("Velocity").Velocity
		local weapon = child:WaitForChild("Weapon").Value
		local ignore = {workspace:WaitForChild("Junk"), workspace:WaitForChild("Items"), workspace:WaitForChild("Players")}
		local travelling 
		local origin = child.Position + velocity.Unit * child.Size.X/2
		local cur = origin
		travelling = run.Heartbeat:Connect(function(dt)
			local ray = Ray.new(cur, velocity * dt)
			local hit, pos, normal = workspace:FindPartOnRayWithIgnoreList(ray, ignore)		
			cur = pos
			
			if hit and (hit.Transparency < 1 or hit.Name == "Hitbox") then
				if hit:IsDescendantOf(workspace:WaitForChild("Targetable")) then
					if child:FindFirstChild("IsFirer") then
						projectileRemote:FireServer(hit, weapon)
					end
					SharedEffects.MakeBlood(pos)
				end
				SharedEffects:CollideProjectile(child, weapon, hit, pos, normal)
				travelling:Disconnect()
			end
		end)
	end
	
	if child.Name == "HammerSmashSequence" then
		local CasterCharacter = child.Value
		local WeaponTag = CasterCharacter:FindFirstChild("WeaponTag", true)
		if not WeaponTag then return end
		local Head = WeaponTag.Parent:FindFirstChild("Head", true)
		if not Head or overMagnitude(Head.Position) then return end
		
		local HitPos = child:WaitForChild("HitPos").Value
		local HitPart = child:WaitForChild("HitPart").Value
		
		AbilitySequence.HammerSmash(Head, HRP, HitPos, HitPart)
	end
end)