-- Services:
local RS = game:GetService("RunService")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Player instances:
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGUI = Player.PlayerGui
local Cover = PlayerGUI:WaitForChild("Main"):WaitForChild("Cover")
local Screenshake = Player:WaitForChild("Gameplay"):WaitForChild("Screenshake")

-- Character instances:
while not Player.Character do wait() end
local Character = Player.Character
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Camera:
local camera = workspace.CurrentCamera

-- Workspace junk:
local Junk = workspace:WaitForChild("Junk")

-- Modules:
local replicatedModules = ReplicatedStorage:WaitForChild("Modules")
local R3 = require(replicatedModules:WaitForChild("RegionModule"))
local SharedEffects = require(replicatedModules:WaitForChild("SharedEffects"))
local DI = require(replicatedModules:WaitForChild("DisplayInfo"))

-- Configuration:
local renderDistance = Player:WaitForChild("PlayerScripts"):WaitForChild("Settings"):WaitForChild("RenderDistance")
local ITEM_CLEANUP = 90
local ITEM_VANISH_TIME = 5

-- Common funcs:
local function overMagnitude(pos)
	return (camera.CFrame.Position - pos).Magnitude > renderDistance.Value
end

local function invalidate(item, pos)
	if overMagnitude(pos) then
		swait()
		item:Destroy()
		return true
	end
	return false
end

local function RandomizeDirection(Number)
	if math.random(0,100) > 50 then
		return -Number
	else
		return Number
	end
end

local function FadeMob(Model, Time)
	for i,v in pairs(Model:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("UnionOperation") then
			TS:Create(v, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1, Color = Color3.new(29/255, 187/255, 255/255)}):Play()
		end
	end
end

local function EquipMagic(On, Group)
	if On then
		for i,v in pairs(Group:GetChildren()) do
			if v:FindFirstChildWhichIsA("ParticleEmitter") then
				v:FindFirstChildWhichIsA("ParticleEmitter").Enabled = true
			end
			TS:Create(v, TweenInfo.new(0.3), {Transparency = tonumber(v.Name)}):Play()
		end
	else
		for i,v in pairs(Group:GetChildren()) do
			if v:FindFirstChildWhichIsA("ParticleEmitter") then
				v:FindFirstChildWhichIsA("ParticleEmitter").Enabled = false
			end
			TS:Create(v, TweenInfo.new(0.3), {Transparency = 1}):Play()
		end
	end
end

local function SetParticles(Part, TimeRate, DR, WaitTime)
	local DeathParticle = ReplicatedStorage:WaitForChild("Effects"):WaitForChild("DeathParticle")
	local P1 = DeathParticle:WaitForChild("P1"):Clone()
	local P2 = DeathParticle:WaitForChild("P2"):Clone()
	local P3 = DeathParticle:WaitForChild("P3"):Clone()
	P1.Parent = Part
	P2.Parent = Part
	P3.Parent = Part
	P1.Enabled = true
	P2.Enabled = true
	P3.Enabled = true
	coroutine.wrap(function()
		for i = 1,TimeRate do
			P1.Rate = P1.Rate + DR
			P2.Rate = P1.Rate + DR
			P3.Rate = P1.Rate + DR
			wait(0.1)
		end
	end)()
	wait(WaitTime)
	P1.Enabled = false
	P2.Enabled = false
	P3.Enabled = false
end

function swait() 
	RS.Heartbeat:Wait() 
end

Junk.ChildAdded:Connect(function(child)
	if child.Name == "Blind" then
		local Position = child.Value
		if not Position or invalidate(child, Position) then return end
		
		local Range = child:WaitForChild("Range").Value
		local Intensity = child:WaitForChild("Intensity").Value
		
		local Magnitude = (camera.CFrame.Position - Position).Magnitude
		if Magnitude > Range then
			Magnitude = Range
		end
		local BlindRatio = (1 - Magnitude/Range)
		local AddBlindness = math.min(BlindRatio * Intensity, Cover.BackgroundTransparency)
		Cover.BackgroundTransparency = Cover.BackgroundTransparency - AddBlindness
		TS:Create(Cover, TweenInfo.new(1.7 * (1-Cover.BackgroundTransparency), Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
	end
	
	if child.Name == "DustEffect" then
		local Position = child:WaitForChild("Position").Value
		if invalidate(child, Position) then return end
		local Rate = child:WaitForChild("Rate").Value
		local Material = child:WaitForChild("Material").Value
		local Direction = child:WaitForChild("Direction").Value
		
		while child.Parent == Junk do
			for i = 1,Rate do
				local Dust = ReplicatedStorage.Effects.Dust:Clone() 
				Dust.Position = Position 
				Dust.Orientation = Vector3.new(math.random(0,360),math.random(0,360),math.random(0,360))
				local RandomSize = math.random(15,40)/100 
				Dust.Size = Vector3.new(RandomSize,RandomSize,RandomSize)
				Dust:WaitForChild("Up").Velocity = Vector3.new(Direction.X * 10 + math.random(-20,20), math.random(3,15), Direction.Z * 10 + math.random(-20,20))
				Dust.Color = Material.Color
				Dust.Parent = workspace.Junk
				if Dust:FindFirstChild("Up") then
					Debris:AddItem(Dust.Up, .1)
				end
				Debris:AddItem(Dust,.65)
			end
			swait()
		end
	end
	
	if child.Name == "DeathParticle" then
		local Mob = child:WaitForChild("MobTag").Value
		if not Mob:FindFirstChild("HumanoidRootPart") then return end 
		if invalidate(child, Mob.HumanoidRootPart.Position) then return end
		
		local AccelerationVector = child:WaitForChild("ParticleAcceleration").Value
		local WaitTime = child:WaitForChild("WaitTime").Value
		local ParticleRate = child:WaitForChild("ParticleRate").Value
		local TimeRate = math.ceil(WaitTime / 0.1)
		local DR = math.ceil(ParticleRate / TimeRate)
		
		for i,v in pairs(Mob:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("UnionOperation") then
				coroutine.wrap(function()
					SetParticles(v, TimeRate, DR,WaitTime)
				end)()
			end
		end
		if Mob:FindFirstChild("HPGui", true) then
			for i,v in pairs(Mob:FindFirstChild("HPGui", true):GetDescendants()) do
				TS:Create(v, TweenInfo.new(.85), {Transparency = 1}):Play()
				if v:IsA("ImageLabel") then
					TS:Create(v, TweenInfo.new(.85), {ImageTransparency = 1}):Play()
				end
			end
		end
		FadeMob(Mob, WaitTime)
	end
	
	if child.Name == "Shockwave" then
		if invalidate(child, child.Position) then return end
		local FS = child.Size.X * 47.5
		local Time = child:WaitForChild("Time").Value
		if child:FindFirstChild("Delay") then
			if child.Delay.Value > 0.03 then
				wait(child.Delay.Value)
			end
		end
		child.Transparency = 0
		TS:Create(child, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = Vector3.new(FS,FS,FS)}):Play()
		TS:Create(child, TweenInfo.new(Time * .9, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transparency = 1}):Play()
	end
	
	if child.Name == "Explosion" then
		if invalidate(child, child.Position) then return end
		local FS = child:WaitForChild("FinalSize").Value
		local Time = child:WaitForChild("Time").Value
		local TransparencyTime = child:WaitForChild("TransparencyTime").Value
		TS:Create(child, TweenInfo.new(Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = FS}):Play()
		wait(Time - TransparencyTime)
		TS:Create(child, TweenInfo.new(TransparencyTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1}):Play()
	end
	
	if child.Name == "Debris" then
		if invalidate(child, child.Value) then return end
		
		local Terrain = child:WaitForChild("HitPart").Value
		local DebrisCount = child:WaitForChild("Count").Value
		local DebrisType = child:WaitForChild("Type").Value
		local DebrisSize = child:WaitForChild("Size").Value
		local velocityRatio = 1
		if child:FindFirstChild("Ratio") then
			velocityRatio = child.Ratio.Value
		end
		for i = 1,DebrisCount do
			local DebrisPart = Instance.new("Part")
			DebrisPart.Size = Vector3.new(DebrisSize,DebrisSize,DebrisSize) * math.random(50,80)/100
			DebrisPart.Anchored = false
			DebrisPart.Massless = true
			DebrisPart.CanCollide = false
			DebrisPart.Material = "SmoothPlastic"
			if DebrisType == "Fire" then
				DebrisPart.Color = Terrain.Color
				
				local Force = Instance.new("BodyVelocity")
				Force.Name = "Force"
				Force.Velocity = Vector3.new(math.random(-120,120)/5, math.random(30,40), math.random(-120,120)/5) * 1.45 * velocityRatio
				Force.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				Force.Parent = DebrisPart
				Debris:AddItem(Force, .35)
			elseif DebrisType == "Water" then
				DebrisPart.Transparency = 1
				local DebrisBlob = SharedEffects.MakeBlob("Water", DebrisPart, DebrisPart.Size.X, nil, .5, 825)
				coroutine.wrap(function()
					while DebrisPart and DebrisBlob and DebrisBlob:FindFirstChild("SizeFactor") do
						DebrisBlob:WaitForChild("SizeFactor").Value = DebrisPart.Size.X
						wait(.1)
					end
				end)()
				Debris:AddItem(DebrisPart, .5)
				
				local Force = Instance.new("BodyVelocity")
				Force.Name = "Force"
				if child:FindFirstChild("Direction") then
					local direction = child.Direction.Value
					local x = direction.X
					local y = direction.Y
					local z = direction.Z
					if x == 0 then
						x = math.random(-100,100)/100
					end
					if y == 0 then
						y = math.random(-100, 100)/100
					end
					if z == 0 then
						z = math.random(-100, 100)/100
					end
					Force.Velocity = (Vector3.new(x * math.random(0, 100)/100, y * math.random(0, 100)/100, z * math.random(0, 100)/100)) * velocityRatio
				else
					Force.Velocity = Vector3.new(math.random(-70,70)/5, math.random(15,30), math.random(-70,70)/5) * velocityRatio
				end
				Force.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				Force.Parent = DebrisPart
				Debris:AddItem(Force, .125)
			end
			DebrisPart.Position = child.Value
			DebrisPart.Name = DebrisType.."DebrisPart"
			DebrisPart.Parent = Junk
		end
	end
	
	if child.Name == "WaterDebrisPart" then
		if invalidate(child, child.Position) then return end
		
		local Time = math.random(60,80)/100
		TS:Create(child, TweenInfo.new(Time), {Size = Vector3.new(0,0,0)})
		wait(Time)
		child:Destroy()
	end
	
	if child.Name == "FireDebrisPart" then
		if invalidate(child, child.Position) then return end
		
		while child.Parent == Junk and not overMagnitude(child.Position) do
			if math.random(0,100) > 75 and child.Size.X > .08 then
				local Blob = Instance.new("Part")
				Blob.Color = Color3.new(1, math.random(0,30)/100,0)
				local Size = child.Size.X * math.random(750,1350)/1000
				Blob.Size = Vector3.new(Size,Size,Size)
				Blob.Material = Enum.Material.Neon
				Blob.CastShadow = false
				Blob.Orientation = child.Orientation
				Blob.Position = child.Position + Vector3.new(math.random(-Size,Size)/2, math.random(-Size,Size)/2, math.random(-Size,Size)/2)
				Blob.CanCollide = false
				Blob.Anchored = true
				Blob.Name = "FireBlob"
				Blob.Parent = Junk
				Debris:AddItem(Blob, 2.5)
			end
			
			local SubG = 0.0041
			local SubR = 0.0041
			local SubB = 0.0041
			if child.Color.R - SubR <= 0 then
				SubR = child.Color.R
			end
			if child.Color.G - SubG <= 0 then
				SubG = child.Color.G
			end
			if child.Color.B - SubB <= 0 then
				SubB = child.Color.B
			end
			child.Color = Color3.new(child.Color.R - SubR, child.Color.G - SubG, child.Color.B - SubB)
			
			child.Size = child.Size * .9625
			if child.Size.X < .08 or child.Size.Y < .08 or child.Size.Z < .08 then
				child:Destroy()
			end
			swait()
		end
	end
	
	if child.Name == "TweenPosition" then
		local ToTween = child.Value
		if invalidate(child, child.Value.Position) then return end
		local FinalPosition = child:WaitForChild("Value").Value
		local Time = child:WaitForChild("Time").Value
		
		local Style = Enum.EasingStyle.Linear
		if child:FindFirstChild("Quad") then
			Style = Enum.EasingStyle.Quad
		end
		
		TS:Create(ToTween, TweenInfo.new(Time, Style, Enum.EasingDirection.Out), {Position = FinalPosition}):Play()
	end
	
	if child.Name == "SpiralPart" then
		if invalidate(child, child.Position) then return end
		local Parent = child:WaitForChild("Parent").Value
		local RotSpeed = child:WaitForChild("Rotation")
		
		if child:FindFirstChild("TweenSize") and child:FindFirstChild("TweenTime") then
			TS:Create(child, TweenInfo.new(child.TweenTime.Value), {Size = child.TweenSize.Value})
		end
		
		local rot = RotSpeed.Value
		local rotX = math.rad(rot.X)
		local rotY = math.rad(rot.Y)
		local rotZ = math.rad(rot.Z)
		
		while child.Parent == Junk and not overMagnitude(child.Position) do
			child.CFrame = (child.CFrame * CFrame.Angles(rotX, rotY, rotZ))
			child.Position = Parent.Position
			swait()
		end
	end
	
	if child.Name == "BlobEffect" then
		local EffectParent = child.Value
		if not EffectParent then return end
		local EffectSize = child:WaitForChild("SizeFactor")
		local EffectType = child:WaitForChild("EffectType").Value
		local Rate = child:WaitForChild("Rate")
		local ChildSize = EffectParent.Size
		local Probability
		if child:FindFirstChild("Probability", true) then
			Probability = child.Probability.Value
		end
		
		if child:FindFirstChild("ExpandRate") then
			local expand = child.ExpandRate.Value
			coroutine.wrap(function()
				while (child:FindFirstChild("ExpandRate")) do
					child:WaitForChild("SizeFactor").Value = child.SizeFactor.Value + expand
					wait()
				end
			end)()
		end
				
		while EffectParent and child.Parent == Junk do
			if overMagnitude(EffectParent.Position) then wait(.1) continue end
			for i = 1,Rate.Value do
				if not Probability or math.random(0,1000) > Probability then
					local Blob = Instance.new("Part")
					Blob.CanCollide = false
					Blob.Anchored = true
					Blob.Material = Enum.Material.Neon
					if EffectType == "Fire" then
						local Size = EffectSize.Value * math.random(785,1050)/1000
						Blob.Position = EffectParent.Position + Vector3.new(math.random(-Size,Size)/4.75, math.random(-Size,Size)/5.25, math.random(-Size,Size)/4.75)
						Blob.Size = Vector3.new(Size,Size,Size)
						Blob.Color = Color3.new(1, math.random(0,30)/100,0)
						
					elseif EffectType == "Water" then
						Blob.Position = EffectParent.Position + Vector3.new(EffectParent.Size.X/2.25,EffectParent.Size.Y/2.25,EffectParent.Size.Z/2.25) * math.random(0,10)/10
						local Size = EffectSize.Value * math.random(500,1100)/1000
						Blob.Size = Vector3.new(Size,Size,Size)
						Blob.Color = Color3.fromRGB(math.random(50,60),math.random(60,160),math.random(115,245))
			
					elseif EffectType == "Smoke" then
						local Size = EffectSize.Value * math.random(785,1050)/1000
						Blob.Position = EffectParent.Position + Vector3.new(math.random(-Size,Size)/4.75, math.random(-Size,Size)/5.25, math.random(-Size,Size)/4.75)
						Blob.Size = Vector3.new(Size,Size,Size)
						local Darkness = math.random(45, 105)
						Blob.Color = Color3.fromRGB(Darkness, Darkness, Darkness)
						
					elseif EffectType == "Energy" then
						local Size = EffectSize.Value * math.random(550,1100)/1000
						Blob.Position = EffectParent.Position + Vector3.new(EffectParent.Size.X/2.5,EffectParent.Size.Y/4,EffectParent.Size.Z/2.5) * math.random(0,10)/10
						local ColorOption = child:WaitForChild("Color").Value
						Blob.Size = Vector3.new(Size,Size,Size)
						
						local ColorRatio = math.random(3,10)/10
						Blob.Color = Color3.new(ColorOption.R * ColorRatio, ColorOption.G * ColorRatio, ColorOption.B * ColorRatio)

					end
					Blob.Orientation = EffectParent.Orientation + Vector3.new(math.random(-15,15), math.random(-15,15), math.random(-15,15))
					Blob.Name = EffectType.."Blob"
					Blob.Parent = Junk
					Debris:AddItem(Blob, 2.5)
				end
			end
			swait()
		end
	end
	
	if child.Name == "Ring" then
		if invalidate(child, child.Position) then return end
		local FS = child.Size.X * child:WaitForChild("FinalSize").Value
		local Time = child:WaitForChild("Time").Value
		local TransparencyTime = child:WaitForChild("TransparencyTime").Value
		TS:Create(child, TweenInfo.new(Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(FS,FS,FS)}):Play()
		TS:Create(child, TweenInfo.new(TransparencyTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1}):Play()
		
		local ShiftVector = Vector3.new(RandomizeDirection(2.5),RandomizeDirection(2.5),RandomizeDirection(2.5))
		while child.Transparency ~= 1 do
			if child.Orientation.X == 90 then
				ShiftVector = Vector3.new(-1,1,1)
			end
			if child.Orientation.X == -90 then
				ShiftVector = Vector3.new(1,1,1)
			end
			child.Orientation = child.Orientation + ShiftVector/2
			swait()
		end
	end
	
	if child.Name == "Screenshake" then
		local Position = child.Value
		if not Position or invalidate(child, Position) then return end
		local Range = child:WaitForChild("Range").Value
		if (HRP.Position - Position).Magnitude > Range then return end
		local Magnitude = child:WaitForChild("Magnitude").Value
		local MagnitudeRatio = 1 - (camera.CFrame.Position - Position).Magnitude/Range
		local FinalMagnitude = Magnitude * MagnitudeRatio
		Screenshake.Value = Screenshake.Value + FinalMagnitude
	end
	
	if child.Name == "WaterBlob" then
		if invalidate(child, child.Position) then return end
		local BlobSize = child.Size
		local ShiftVectorX = RandomizeDirection(math.random(23,32))
		local ShiftVectorY = math.random(35,45)
		local ShiftVectorZ = RandomizeDirection(math.random(23,32))
		local Time = math.random(35,70)/100
		
		TS:Create(child, TweenInfo.new(Time), {Size = Vector3.new(0,0,0)}):Play()
		coroutine.wrap(function()
			repeat swait() until child.Size.X < 0.075
			child:Destroy()
		end)()
		coroutine.wrap(function()
			wait(Time/2)
			ShiftVectorX = RandomizeDirection(math.random(23,32))
			ShiftVectorY = math.random(20,25)
			ShiftVectorZ = RandomizeDirection(math.random(23,32))
		end)()
		TS:Create(child, TweenInfo.new(Time * math.random(4,18)/6), {Color = Color3.new(1,1,1)}):Play()
		coroutine.wrap(function()
			wait(Time/10)
			TS:Create(child, TweenInfo.new(Time/2), {Orientation = child.Orientation + Vector3.new(math.random(-60,60),math.random(-60,60),math.random(-60,60))}):Play()
			wait(Time/2)
			TS:Create(child, TweenInfo.new(Time/2), {Orientation = child.Orientation + Vector3.new(math.random(-60,60),math.random(-60,60),math.random(-60,60))}):Play()
		end)()

		while child.Parent == Junk and not overMagnitude(child.Position) do
			child.Position = child.Position + Vector3.new(child.Size.X/ShiftVectorX, math.min(-child.Size.X/ShiftVectorY, -.0485), child.Size.X/ShiftVectorZ)
			swait()
		end
	end
	
	if child.Name == "FireBlob" or child.Name == "SmokeBlob" or child.Name == "EnergyBlob" then
		if invalidate(child, child.Position) then return end
		local BlobSize = child.Size
		local ShiftVectorX = RandomizeDirection(math.random(23,32))
		local ShiftVectorY = math.random(20,25)
		local ShiftVectorZ = RandomizeDirection(math.random(23,32))
		
		local Time = math.random(20,45)/100
		if child.Name == "EnergyBlob" then
			Time = math.random(25,65)/100
			TS:Create(child, TweenInfo.new(Time * math.random(6,25)/6), {Color = Color3.new(1,1,1)}):Play()
		elseif child.Name == "FireBlob" then
			Time = math.random(25,65)/100
			TS:Create(child, TweenInfo.new(Time * math.random(6,25)/6), {Color = Color3.new(1,math.random(30,100)/100,0)}):Play()
		elseif child.Name == "SmokeBlob" then
			Time = math.random(45,115)/100
			TS:Create(child, TweenInfo.new(Time * math.random(6,34)/6), {Color = Color3.new(0,0,0)}):Play()
		end
		TS:Create(child, TweenInfo.new(Time), {Size = Vector3.new(0,0,0)}):Play()
		coroutine.wrap(function()
			repeat swait() until child.Size.X < 0.075
			child:Destroy()
		end)()
		coroutine.wrap(function()
			wait(Time/10)
			TS:Create(child, TweenInfo.new(Time/2), {Orientation = child.Orientation + Vector3.new(math.random(-60,60),math.random(-60,60),math.random(-60,60))}):Play()
			wait(Time/2)
			TS:Create(child, TweenInfo.new(Time/2), {Orientation = child.Orientation + Vector3.new(math.random(-60,60),math.random(-60,60),math.random(-60,60))}):Play()
		end)()
		
		coroutine.wrap(function()
			wait(Time/2)
			ShiftVectorX = RandomizeDirection(math.random(23,32))
			ShiftVectorY = math.random(20,25)
			ShiftVectorZ = RandomizeDirection(math.random(23,32))
		end)()
		
		if child.Name == "SmokeBlob" then
			coroutine.wrap(function()
				wait(Time/2)
				TS:Create(child, TweenInfo.new(Time * math.random(6,18)/12), {Transparency = 1}):Play()
			end)()
		end
		
		while child.Parent == Junk and not overMagnitude(child.Position) do
			child.Position = child.Position + Vector3.new(child.Size.X/ShiftVectorX, math.max(child.Size.X/ShiftVectorY, 0.06), child.Size.X/ShiftVectorZ)
			swait()
		end
	end	
	
	if child.Name == "Glass" then
		if invalidate(child, child.Position) then return end
		local Time = (1-child.Transparency) / 1.25
		TS:Create(child, TweenInfo.new(Time), {Transparency = 1}):Play()
		wait(Time * 1.1)
		child:Destroy()
	end
	
	if child.Name == "GlassEffect" then
		local GlassModel = child.Value
		if not GlassModel:FindFirstChildWhichIsA("BasePart", true) then return end
		if not GlassModel:FindFirstChildWhichIsA("BasePart", true) or invalidate(child, GlassModel:FindFirstChildWhichIsA("BasePart", true).Position) then return end
		local Interval = child:WaitForChild("Interval").Value
		local Transparency = child:WaitForChild("Transparency").Value
		
		while child.Parent == Junk do
			for i,v in pairs(GlassModel:GetDescendants()) do
				if v:IsA("BasePart") and v.Name ~= "Anchor" and v.Name ~= "HumanoidRootPart" then
					local Glass = v:Clone()
					for i,Trash in pairs(Glass:GetDescendants()) do
						Trash:Destroy()
					end
					Glass.CFrame = v.CFrame
					Glass.CastShadow = false
					--Glass.Material = "Glass"
					Glass.Name = "Glass"
					Glass.Transparency = Transparency
					Glass.Anchored = true
					Glass.CanCollide = false
					Glass.Parent = Junk
				end
			end
			wait(Interval)
		end
	end
	
	if child.Name == "SparkEffect" then
		local Position = child.Value
		if invalidate(child, Position) then return end
		local Rate = child:WaitForChild("Rate").Value
		local Size = child:WaitForChild("Size").Value
		local Color = child:WaitForChild("Color").Value
		local StartDistance = child:WaitForChild("StartDistance").Value
		local EndDistance = child:WaitForChild("EndDistance").Value
		local TravelTime = child:WaitForChild("TravelTime").Value
		local TransparencyDelay = child:WaitForChild("TransparencyDelay").Value
		local EndSize = child:WaitForChild("EndSize").Value
		local Square = child:FindFirstChild("Square")
		local Linear = child:FindFirstChild("Linear")
		
		for i = 1,Rate do
			local Spark = Instance.new("Part")
			Spark.Anchored = true
			Spark.CanCollide = false
			Spark.Name = "Spark"
			Spark.Material = "Neon"
			if Square then
				Spark.Size = Size
			else
				Spark.Size = Vector3.new(Size.X * math.random(5,10)/10, Size.Y * math.random(5,10)/10, Size.Z * math.random(2,38)/15)
			end
			
			local Mesh = ReplicatedStorage:WaitForChild("Effects"):WaitForChild("Mesh"):Clone()
			Mesh.Parent = Spark
			
			Spark.Color = Color
			Spark.Orientation = Vector3.new(math.random(0,360), math.random(0,360), math.random(0,360))
			Spark.Position = Position
			Spark.CFrame = Spark.CFrame * CFrame.new(0, 0, (StartDistance + Spark.Size.Z) * math.random(10,20)/10)
			Spark.Parent = Junk
			
			local Style = Enum.EasingStyle.Quad
			if Linear then
				Style = Enum.EasingStyle.Linear
			end
			TS:Create(Spark, TweenInfo.new(TravelTime, Style, Enum.EasingDirection.Out), {CFrame = Spark.CFrame  * CFrame.new(0,0,EndDistance)}):Play()
			TS:Create(Mesh, TweenInfo.new(TravelTime, Style, Enum.EasingDirection.Out), {Scale = EndSize}):Play()
			coroutine.wrap(function()
				wait(TransparencyDelay)
				TS:Create(Spark, TweenInfo.new(TravelTime - TransparencyDelay, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1}):Play()
				Debris:AddItem(Spark, TravelTime * 1.1)
			end)()
		end
	end
	
	if child.Name == "BasicAttack" then
		local ID = child:WaitForChild("ID").Value
		if ID == Player.UserId then return end
		local Position = child:WaitForChild("Position").Value
		if invalidate(child, Position) then return end
		local Target = child.Value
		local Weapon = child:WaitForChild("Weapon").Value
		
		SharedEffects.MakeBlood(Position)
		local SoundToClone = DI["Sounds"][Weapon]
		if SoundToClone then
			local TargetSound = SoundToClone:Clone()
			TargetSound.Parent = Target 
			TargetSound:Play()
			Debris:AddItem(TargetSound, TargetSound.TimeLength * 1.25) 
		end 
	end
	
	if child.Name == "MagicEquip" then
		local CasterCharacter = child.Value
		if CasterCharacter == Character or not CasterCharacter:FindFirstChild("HumanoidRootPart") then return end
		if invalidate(child, CasterCharacter.HumanoidRootPart.Position) then return end
		local WeaponTag = CasterCharacter:FindFirstChild("WeaponTag", true)
		local Equipped = child:WaitForChild("Equipped")
		
		if not WeaponTag then return end
		local RD = WeaponTag.Parent:FindFirstChild("RightDecor")
		local LD = WeaponTag.Parent:FindFirstChild("LeftDecor")
		if not RD or not RD:FindFirstChild("Decoration") or not LD or not LD:FindFirstChild("Decoration") then return end
		
		local RightDecor = RD.Decoration
		local LeftDecor = LD.Decoration
		
		EquipMagic(Equipped.Value, RightDecor)
		EquipMagic(Equipped.Value, LeftDecor)
	end
end)

-- Rendering drops:
local drops = workspace:WaitForChild("Items"):WaitForChild("Drops")
local itemIdle = Instance.new("Animation")
itemIdle.AnimationId = "rbxassetid://05211082600"
drops.ChildAdded:Connect(function(Child)
	local Outer = Child:WaitForChild("Outer")
	local Inner = Child:WaitForChild("Inner")
	local P = Inner:WaitForChild("A"):WaitForChild("P")
	local PlayIdle = Child:WaitForChild("AnimationController"):LoadAnimation(itemIdle)
	
	Debris:AddItem(Child, ITEM_CLEANUP)
	coroutine.wrap(function()
		wait(ITEM_CLEANUP - ITEM_VANISH_TIME)
		TS:Create(Outer, TweenInfo.new(ITEM_VANISH_TIME), {Transparency = 1}):Play()
		TS:Create(Inner, TweenInfo.new(ITEM_VANISH_TIME), {Transparency = 1}):Play()
		TS:Create(P, TweenInfo.new(ITEM_VANISH_TIME), {Rate = 0}):Play()
	end)()
	
	if overMagnitude(Outer.Position) then
		repeat wait(5) until not Child.Parent or not overMagnitude(Outer.Position)
		if not Child.Parent then return end
	end
	
	PlayIdle:Play()
	wait(math.random(0, 100)/100)
	Outer.Transparency = 0
	Inner.Transparency = 0.7
	P.Enabled = true
end)

-- Rendering dust:
local whiteList = {workspace:WaitForChild('Map')}
local downVector = Vector3.new(0,-1.18,0)

function makeDust(cf, floor, scale)
	for i = 1, scale do
		-- Get size and offsets:
		local size = math.random(17,35)/100 
		local sizeV3 = Vector3.new(size, size, size)
		local cfOffset = CFrame.new(math.random(0,75)/100 * RandomizeDirection(1),0,.25)
		local orientationOffset = Vector3.new(math.random(-45,45), 0, math.random(-45,45))
		
		-- Instantiate velocity:
		local velocity = Vector3.new(math.random(-4,4), math.random(2,5) + math.random(2,3) * scale, math.random(-4,4))
		local up = Instance.new("BodyVelocity")
		up.MaxForce = Vector3.new(4000, math.huge, 4000)
		up.Velocity = velocity
		up.P = 1250
		
		-- Instantiate part:
		local dust = Instance.new("Part")
		dust.CanCollide = false
		dust.Massless = true
		dust.Material = floor.Material
		dust.Color = floor.Color
		dust.Size = sizeV3
		dust.CFrame = cf * cfOffset
		dust.Orientation = dust.Orientation + orientationOffset
		
		-- Reparent and set lifetimes:
		up.Parent = dust
		dust.Parent = workspace.Junk
		TS:Create(dust, TweenInfo.new(0.65), {Transparency = 1}):Play()
		Debris:AddItem(dust,.65)
		Debris:AddItem(up, 0.1)
	end
end

while wait(.2) do
	for _, player in pairs(Players:GetPlayers()) do
		-- Valid character instances:
		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
		if not player.Character:FindFirstChild("Humanoid") then continue end
			
		local character = player.Character
		local root = character.HumanoidRootPart
		
		-- Validate distance and velocity:
		local velocity = root.Velocity
		if overMagnitude(root.Position) then continue end
		if math.abs(velocity.X + velocity.Z) < 8 then continue end

		-- Validate player instances:

		local gameplay, values = player:FindFirstChild("Gameplay"), player:FindFirstChild("Values")
		if not gameplay or not values then continue end
		local health = values:FindFirstChild("Health")
		local sprinting = gameplay:FindFirstChild("Sprinting")
		if not health or not sprinting then continue end
		if health.Value <= 0 or not sprinting.Value then continue end
	
		-- Shoot ray and check for collision:

		local floorRay = Ray.new(root.Position, downVector)
		local hit, pos = workspace:FindPartOnRayWithWhitelist(floorRay, whiteList)
		if not hit or not pos then continue end

		-- Create dust:
		local x, y, z = root.CFrame:ToEulerAnglesYXZ()
		makeDust(CFrame.new(pos) * CFrame.Angles(x, y, z), hit, math.random(1,3))
	end
end