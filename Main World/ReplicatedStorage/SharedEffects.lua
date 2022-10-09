local Effects = {}

-- Services:
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local PS = game:GetService("PhysicsService")

-- Modules: 
local replicatedModules = ReplicatedStorage:WaitForChild("Modules")
local DisplayInfo = require(replicatedModules:WaitForChild("DisplayInfo"))

-- Config:
local debugMode = false
Effects["MAX_EFFECT_TIME"] = 300

-- Misc:
local EffectsFolder = ReplicatedStorage:WaitForChild("Effects")
local Junk = workspace:WaitForChild("Junk")

-- Functions: 
Effects.MakeCharge = function(Target, Minimum, Maximum, TypeValue, SR)
	local Charge = Instance.new("ObjectValue")
	Charge.Name = "Charge"
	Charge.Value = Target
	
	local Min = Instance.new("IntValue")
	Min.Name = "Minimum"
	Min.Value = Minimum
	Min.Parent = Charge
	
	local Max = Instance.new("IntValue")
	Max.Name = "Maximum"
	Max.Value = Maximum
	Max.Parent = Charge
	
	local Type = Instance.new("StringValue")
	Type.Name = "Type"
	Type.Value = TypeValue
	Type.Parent = Charge
	
	local SizeRatio = Instance.new("NumberValue")
	SizeRatio.Name = "SizeRatio"
	SizeRatio.Value = SR
	SizeRatio.Parent = Charge
	
	Charge.Parent = Junk
	Debris:AddItem(Charge, Effects["MAX_EFFECT_TIME"])
	return Charge
end

Effects.MakeDeathParticle = function(ToFade, Time, Rate)
	local DeathParticle = Instance.new("Folder")
	DeathParticle.Name = "DeathParticle"
		
	local Z = math.random(5,10)
	local X = math.random(5,10)
	local DZ
	local DX
	if math.random(0,100) > 50 then
		DZ = -1
	else
		DZ = 1
	end
	if math.random(0,100) > 50 then
		DX = -1
	else
		DX = 1
	end
	local ParticleAcceleration = Instance.new("Vector3Value")
	ParticleAcceleration.Name = "ParticleAcceleration"
	ParticleAcceleration.Value = Vector3.new(X * DX, 7.5, Z * DZ)
	ParticleAcceleration.Parent = DeathParticle
	
	local MobTag = Instance.new("ObjectValue")
	MobTag.Value = ToFade
	MobTag.Name = "MobTag"
	MobTag.Parent = DeathParticle
	
	local WaitTime = Instance.new("NumberValue")
	WaitTime.Value = Time
	WaitTime.Name = "WaitTime"
	WaitTime.Parent = DeathParticle
	
	local ParticleRate = Instance.new("IntValue")
	ParticleRate.Value = Rate
	ParticleRate.Name = "ParticleRate"
	ParticleRate.Parent = DeathParticle
	
	DeathParticle.Parent = workspace:WaitForChild("Junk")
	for i,v in pairs(ToFade:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("UnionOperation") then
			PS:SetPartCollisionGroup(v, "Rigparts")
		end
	end
	Debris:AddItem(DeathParticle, Time * 2)
end

Effects.MakeBlind = function(Intensity, Position, Range)
	local Blind = Instance.new("Vector3Value")
	Blind.Name = "Blind"
	Blind.Value = Position
	
	local IntensityTag = Instance.new("NumberValue")
	IntensityTag.Name = "Intensity"
	IntensityTag.Value = Intensity
	IntensityTag.Parent = Blind
	
	local RangeTag = Instance.new("NumberValue")
	RangeTag.Name = "Range"
	RangeTag.Value = Range
	RangeTag.Parent = Blind
	
	Blind.Parent = Junk
	Debris:AddItem(Blind, 0.5)
end

Effects.MakeBlood = function(Position)
	local DamageParticle = EffectsFolder:WaitForChild("DamageParticle"):Clone() 
	DamageParticle.Name = "DamageParticle" 
	DamageParticle.Position = Position 
	DamageParticle.Parent = workspace.Junk 
	for i, Particle in pairs(DamageParticle:WaitForChild("A"):GetChildren()) do
		Particle.Enabled = true
		spawn(function()
			wait(0.15)
			Particle.Enabled = false
		end)
	end
	Debris:AddItem(DamageParticle, .4)
end

Effects.SpiralPart = function(Part, LifeTime, Number, Size, Rotation, TweenSize, TweenTime)
	local SpiralParts = {}
	for i = 1, Number do
		local SpiralPart = Instance.new("Part")
		SpiralPart.Size = Vector3.new(.05,05,.05)
		SpiralPart.Transparency = 1
		SpiralPart.Anchored = true
		SpiralPart.CanCollide = false
		SpiralPart.Massless = true
		SpiralPart.CFrame = Part.CFrame
		SpiralPart.Orientation = SpiralPart.Orientation + Vector3.new(0,0,360/Number * i)
		SpiralPart.Name = "SpiralPart"
		SpiralPart.Size = Size
		
		local Parent = Instance.new("ObjectValue")
		Parent.Value = Part
		Parent.Name = "Parent"
		Parent.Parent = SpiralPart
		
		local RotSpeed = Instance.new("Vector3Value")
		RotSpeed.Value = Rotation
		RotSpeed.Name = "Rotation"
		RotSpeed.Parent = SpiralPart
		
		if TweenSize and TweenTime then
			local TSize = Instance.new("Vector3Value")
			TSize.Value = TweenSize
			TSize.Name = "TweenSize"
			TSize.Parent = SpiralPart
			
			local TTime = Instance.new("NumberValue")
			TTime.Value = TweenTime
			TTime.Name = "TweenTime"
			TTime.Parent = SpiralPart
		end
		
		SpiralPart.Parent = Junk
		table.insert(SpiralParts, SpiralPart)
		if LifeTime then
			Debris:AddItem(SpiralPart, LifeTime)
		end
	end
	return SpiralParts
end

Effects.TweenPosition = function(ToTween, FinalPosition, TimeValue, StyleValue)
	local Index = Instance.new("ObjectValue")
	Index.Value = ToTween
	Index.Name = "TweenPosition"
	
	local Value = Instance.new("Vector3Value")
	Value.Name = "Value"
	Value.Value = FinalPosition
	Value.Parent = Index
	
	local Time = Instance.new("NumberValue")
	Time.Value = TimeValue
	Time.Name = "Time"
	Time.Parent = Index
	
	if StyleValue then
		local Style = Instance.new("StringValue")
		Style.Name = StyleValue
		Style.Parent = Index
	end
	
	Index.Parent = Junk
	Debris:AddItem(Index, TimeValue * 1.25)
end

Effects.TrailPart = function(Part, TrailTime, Lifetime, OnePos, TwoPos, Color, Transparency, Width, CustomTexture)
	local Trail = EffectsFolder:WaitForChild("BasicTrail"):Clone()
	Trail.Lifetime = Lifetime
	if Color then Trail.Color = ColorSequence.new(Color) end
	local One = Instance.new("Attachment")
	One.Parent = Part
	One.Name = "One"
	One.Position = OnePos
	
	local Two = Instance.new("Attachment")
	Two.Parent = Part
	Two.Name = "Two"
	Two.Position = TwoPos
	
	Trail.Attachment0 = One
	Trail.Attachment1 = Two
	Trail.Transparency = Transparency
	if CustomTexture and EffectsFolder:FindFirstChild(CustomTexture) then
		Trail.Texture = ReplicatedStorage.Effects[CustomTexture].Texture
		Trail.TextureLength = ReplicatedStorage.Effects[CustomTexture].TextureLength
	end
	
	Trail.Parent = Part
	Trail.Enabled = true
	
	if Width then
		Trail.WidthScale = Width
	end
	
	if TrailTime then
		Debris:AddItem(Trail, Lifetime + TrailTime)
		Debris:AddItem(One, Lifetime + TrailTime)
		Debris:AddItem(Two, Lifetime + TrailTime)
		spawn(function() 
			wait(TrailTime)
			if Trail then
				Trail.Enabled = false 
			end
		end)
	end
	
	
	
	return Trail, One, Two
end

Effects.MakeBlob = function(Name, Object, BlobRate, BlobSize, DeleteTime, ProbabilityValue, ColorOption, Expand)
	local Blob = Instance.new("ObjectValue")
	Blob.Value = Object
	Blob.Name = "BlobEffect"
	local EffectType = Instance.new("StringValue")
	EffectType.Name = "EffectType"
	EffectType.Value = Name
	EffectType.Parent = Blob
	
	local Rate = Instance.new("IntValue")
	Rate.Value = BlobRate
	Rate.Name = "Rate"
	Rate.Parent = Blob
	
	local Size = Instance.new("NumberValue")
	Size.Value = BlobSize
	Size.Name = "SizeFactor"
	Size.Parent = Blob

	if ColorOption then
		local Color = Instance.new("Color3Value")
		Color.Value = ColorOption
		Color.Name = "Color"
		Color.Parent = Blob
	end
	
	if ProbabilityValue then
		local Probability = Instance.new("IntValue")
		Probability.Value = ProbabilityValue
		Probability.Name = "Probability"
		Probability.Parent = Blob
	end
	
	if Expand then
		local ExpandRate = Instance.new("NumberValue")
		ExpandRate.Value = Expand
		ExpandRate.Name = "ExpandRate"
		ExpandRate.Parent = Blob
	end

	Blob.Parent = Junk
	if DeleteTime then
		Debris:AddItem(Blob, DeleteTime)
	end
	Debris:AddItem(Blob, Effects["MAX_EFFECT_TIME"])
	return Blob
end

Effects.MakeGlassEffect = function(ToClone, IntervalValue, TransparencyValue, Time)
	local GlassEffect = Instance.new("ObjectValue")
	GlassEffect.Name = "GlassEffect"
	GlassEffect.Value = ToClone
	
	local Interval = Instance.new("NumberValue")
	Interval.Value = IntervalValue
	Interval.Name = "Interval"
	Interval.Parent = GlassEffect
	GlassEffect.Parent = Junk
	
	local Transparency = Instance.new("NumberValue")
	Transparency.Value = TransparencyValue
	Transparency.Name = "Transparency"
	Transparency.Parent = GlassEffect
	
	if Time then
		Debris:AddItem(GlassEffect, Time)
	else
		Debris:AddItem(GlassEffect, Effects["MAX_EFFECT_TIME"])
		return GlassEffect
	end
end

Effects.MakeSparks = function(PositionValue, RateValue, SizeValue, ColorValue, StartDistanceValue, EndDistanceValue, TravelTimeValue, TransparencyDelayValue, EndSizeValue, Square, Linear)
	local SparkEffect = Instance.new("Vector3Value")
	SparkEffect.Name = "SparkEffect"
	SparkEffect.Value = PositionValue
	
	local Rate = Instance.new("IntValue")
	Rate.Value = RateValue
	Rate.Name = "Rate"
	Rate.Parent = SparkEffect
	
	local Size = Instance.new("Vector3Value")
	Size.Value = SizeValue
	Size.Name = "Size"
	Size.Parent = SparkEffect
	
	local Color = Instance.new("Color3Value")
	Color.Value = ColorValue
	Color.Name = "Color"
	Color.Parent = SparkEffect

	local StartDistance = Instance.new("NumberValue")
	StartDistance.Value = StartDistanceValue
	StartDistance.Name = "StartDistance"
	StartDistance.Parent = SparkEffect
	
	local EndDistance = Instance.new("NumberValue")
	EndDistance.Value = EndDistanceValue
	EndDistance.Name = "EndDistance"
	EndDistance.Parent = SparkEffect
	
	local TravelTime = Instance.new("NumberValue")
	TravelTime.Value = TravelTimeValue
	TravelTime.Name = "TravelTime"
	TravelTime.Parent = SparkEffect
	
	local TransparencyDelay = Instance.new("NumberValue")
	TransparencyDelay.Value = TransparencyDelayValue
	TransparencyDelay.Name = "TransparencyDelay"
	TransparencyDelay.Parent = SparkEffect
	
	local EndSize = Instance.new("Vector3Value")
	EndSize.Value = EndSizeValue
	EndSize.Name = "EndSize"
	EndSize.Parent = SparkEffect
	
	if Square then
		local Square = Instance.new("StringValue")
		Square.Name = "Square"
		Square.Parent = SparkEffect
	end
	
	if Linear then
		local Linear = Instance.new("StringValue")
		Linear.Name = "Linear"
		Linear.Parent = SparkEffect
	end
	
	SparkEffect.Parent = Junk
	Debris:AddItem(SparkEffect, TravelTimeValue * 1.1)
end

Effects.MakeDust = function(RateValue, Position, Object, DirectionValue, Duration)
	local DustEffect = Instance.new("Vector3Value")
	DustEffect.Name = "DustEffect"
	DustEffect.Value = Position
	
	local Rate = Instance.new("NumberValue")
	Rate.Value = RateValue
	Rate.Name = "Rate"
	Rate.Parent = DustEffect
	
	local Pos = Instance.new("Vector3Value")
	Pos.Value = Position
	Pos.Name = "Position"
	Pos.Parent = DustEffect
	
	local Material = Instance.new("ObjectValue")
	Material.Name = "Material"
	Material.Value = Object
	Material.Parent = DustEffect
	
	local Direction = Instance.new("Vector3Value")
	Direction.Value = DirectionValue
	Direction.Name = "Direction"
	Direction.Parent = DustEffect
	
	DustEffect.Parent = Junk
	Debris:AddItem(DustEffect, Duration)
	
end

Effects.MakeExplosion = function(Size, CFrameValue, Color, Transparency, FinalSizeValue, TimeValue, TransparencyTimeValue, ExtraOrientation)
	local Explosion = Instance.new("Part")
	Explosion.Anchored = true
	Explosion.CanCollide = false
	Explosion.CastShadow = false
	Explosion.Color = Color
	Explosion.Size = Size
	Explosion.CFrame = CFrameValue
	Explosion.Name = "Explosion"
	Explosion.Transparency = Transparency
	Explosion.Material = "Neon"
	if ExtraOrientation then
		Explosion.CFrame = Explosion.CFrame * ExtraOrientation
	end
	
	local FinalSize = Instance.new("Vector3Value")
	FinalSize.Value = FinalSizeValue
	FinalSize.Name = "FinalSize"
	FinalSize.Parent = Explosion
	
	local Time = Instance.new("NumberValue")
	Time.Value = TimeValue
	Time.Name = "Time"
	Time.Parent = Explosion
	
	local TransparencyTime = Instance.new("NumberValue")
	TransparencyTime.Value = TransparencyTimeValue
	TransparencyTime.Name = "TransparencyTime"
	TransparencyTime.Parent = Explosion
	Explosion.Parent = Junk
	
	Debris:AddItem(Explosion, math.max(TransparencyTime.Value, Time.Value) * 1.25)
	return Explosion
end

Effects.MakeScreenshake = function(MagnitudeValue, PositionValue, RangeValue)
	local Screenshake = Instance.new("Vector3Value")
	Screenshake.Name = "Screenshake"
	Screenshake.Value = PositionValue
	local Magnitude = Instance.new("IntValue")
	Magnitude.Name = "Magnitude"
	Magnitude.Value = MagnitudeValue
	Magnitude.Parent = Screenshake
	local Range = Instance.new("NumberValue")
	Range.Value = RangeValue
	Range.Name = "Range"
	Range.Parent = Screenshake
	
	Screenshake.Parent = Junk
	Debris:AddItem(Screenshake, 0.5)
end

Effects.MakeRing = function(SizeValue, PositionValue, ColorValue, TimeValue, TransparencyTimeValue, FinalSizeValue)
	local Ring = EffectsFolder:WaitForChild("Ring"):Clone()
	Ring.Position = PositionValue
	Ring.Color = ColorValue
	Ring.Orientation = Vector3.new(math.random(0,360),math.random(0,360),math.random(0,360))
	Ring.Size = Vector3.new(SizeValue,SizeValue,SizeValue)
	
	local Time = Instance.new("NumberValue")
	Time.Value = TimeValue
	Time.Name = "Time"
	Time.Parent = Ring
	
	local TransparencyTime = Instance.new("NumberValue")
	TransparencyTime.Value = TransparencyTimeValue
	TransparencyTime.Name = "TransparencyTime"
	TransparencyTime.Parent = Ring
	
	local FinalSize = Instance.new("NumberValue")
	FinalSize.Value = FinalSizeValue
	FinalSize.Name = "FinalSize"
	FinalSize.Parent = Ring
	
	Ring.Parent = Junk
	
	Debris:AddItem(Ring, math.max(TransparencyTime.Value, Time.Value) * 1.25)
end

Effects.MakeShockwave = function(SizeValue, CFrameValue, ColorValue, TimeValue, ExtraOrientation, Shift, DelayValue)
	local Shockwave = EffectsFolder:WaitForChild("Shockwave"):Clone()
	Shockwave.CFrame = CFrameValue
	Shockwave.Size = Vector3.new(SizeValue,SizeValue,SizeValue)
	Shockwave.Color = ColorValue	
	local Time = Instance.new("NumberValue")
	Time.Value = TimeValue
	Time.Name = "Time"
	Time.Parent = Shockwave
	if ExtraOrientation then
		Shockwave.CFrame = Shockwave.CFrame * ExtraOrientation
	end
	if Shift then
		Shockwave.CFrame = Shockwave.CFrame * Shift
	end
	if DelayValue then
		local Delay = Instance.new("NumberValue")
		Delay.Name = "Delay"
		Delay.Value = DelayValue
		Delay.Parent = Shockwave
	end
	Shockwave.Parent = Junk
	Debris:AddItem(Shockwave, TimeValue * 1.5)
end

Effects.MakeDebris = function(CountValue, HitPartValue, HitPos, TypeValue, SizeValue, DirectionOption, VelocityRatio)
	local Position = Instance.new("Vector3Value")
	Position.Value = HitPos
	Position.Name = "Debris"
	local Count = Instance.new("IntValue")
	Count.Value = CountValue
	Count.Name = "Count"
	Count.Parent = Position
	local HitPart = Instance.new("ObjectValue")
	HitPart.Value = HitPartValue
	HitPart.Name = "HitPart"
	HitPart.Parent = Position
	local Type = Instance.new("StringValue")
	Type.Name = "Type"
	Type.Value = TypeValue
	Type.Parent = Position
	local Size = Instance.new("NumberValue")
	Size.Value = SizeValue
	Size.Name = "Size"
	Size.Parent = Position
	if DirectionOption then
		local Direction = Instance.new("Vector3Value")
		Direction.Name = "Direction"
		Direction.Value = DirectionOption
		Direction.Parent = Position
	end
	if VelocityRatio then
		local Ratio = Instance.new("NumberValue")
		Ratio.Name = "Ratio"
		Ratio.Value = VelocityRatio
		Ratio.Parent = Position
	end
	
	Position.Parent = Junk
	Debris:AddItem(Position,1)
end

function Effects:Projectile(origin, dir, speed, weapon, lifeTime, isFirer)
	local projectile = Instance.new("Part")
	projectile.Name = "Projectile"
	projectile.Massless = true
	projectile.Anchored = false
	projectile.CanCollide = false
	projectile.Size = Vector3.new(1,1,1)
	projectile.Transparency = 1
	projectile.CFrame = CFrame.new(origin, origin + dir)
	
	local velocity = Instance.new("BodyVelocity")
	velocity.Name = "Velocity"
	velocity.Velocity = dir * speed
	velocity.Parent = projectile
	
	if isFirer then 
		local id = Instance.new("StringValue")
		id.Name = "IsFirer"
		id.Parent = projectile
	end
	
	local weaponTag = Instance.new("StringValue")
	weaponTag.Value = weapon
	weaponTag.Name = "Weapon"
	weaponTag.Parent = projectile
	
	projectile.Parent = Junk
	Effects:DecorateProjectile(projectile, lifeTime, weapon)
	coroutine.wrap(function()
		wait(lifeTime)
		projectile.Anchored = true
	end)
	
	return projectile
end

function Effects:DecorateProjectile(projectile, lifeTime, weapon)
	if weapon == "WaterMagic" then
		-- Blob effect:
		local waterBlob = Effects.MakeBlob("Water", projectile, 1, projectile.Size.X, lifeTime, 500)
		
		-- Spinning trails:
		local trails = {}
		local trailWidthRatio = 1.4
		local trailLifetimeRatio = 0.175
		
		local trailTransparency = NumberSequence.new{
		    NumberSequenceKeypoint.new(0, 0),
		    NumberSequenceKeypoint.new(.5, .8),
			NumberSequenceKeypoint.new(.55, .9),
			NumberSequenceKeypoint.new(.6, .1),
		    NumberSequenceKeypoint.new(1, 1)
		}
		local trailWidth = NumberSequence.new{
		    NumberSequenceKeypoint.new(0, 1),
		    NumberSequenceKeypoint.new(.6, 0),
			NumberSequenceKeypoint.new(1, 0)	
		}
		
		local spiralParts = Effects.SpiralPart(projectile, lifeTime + 1.5 * trailLifetimeRatio, 1, Vector3.new(0.05, projectile.Size.X * 1.5, 0.05), Vector3.new(0, 0, 20))
		for _, spiralPart in pairs(spiralParts) do
			local trail1 = Effects.TrailPart(spiralPart, lifeTime, 1.5 * trailLifetimeRatio, Vector3.new(0, spiralPart.Size.Y/2 + .015 * trailWidthRatio, 0), Vector3.new(0, spiralPart.Size.Y/2 - .015 * trailWidthRatio, 0), Color3.new(1,1,1), trailTransparency, trailWidth)
			local trail2 = Effects.TrailPart(spiralPart, lifeTime, 1.5 * trailLifetimeRatio, Vector3.new(0, -spiralPart.Size.Y/2 + .015 * trailWidthRatio, 0), Vector3.new(0, -spiralPart.Size.Y/2 - .015 * trailWidthRatio, 0), Color3.new(1,1,1), trailTransparency, trailWidth)
			local trail3 = Effects.TrailPart(spiralPart, lifeTime, 1.5 * trailLifetimeRatio, Vector3.new(0, spiralPart.Size.Y/2 + .08 * trailWidthRatio, 0), Vector3.new(0, spiralPart.Size.Y/2 - .08 * trailWidthRatio, 0), Color3.new(0,.5,1), trailTransparency, trailWidth)
			local trail4 = Effects.TrailPart(spiralPart, lifeTime, 1.5 * trailLifetimeRatio, Vector3.new(0, -spiralPart.Size.Y/2 + .08 * trailWidthRatio, 0), Vector3.new(0, -spiralPart.Size.Y/2 - .08 * trailWidthRatio, 0), Color3.new(0,.5,1), trailTransparency, trailWidth)
			
			table.insert(trails, #trails + 1, trail1)
			table.insert(trails, #trails + 1, trail2)
			table.insert(trails, #trails + 1, trail3)
			table.insert(trails, #trails + 1, trail4)
		end
		
		-- Projectile tail:
		local baseTrailTransparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0), 
			NumberSequenceKeypoint.new(0.4, 0.8),
			NumberSequenceKeypoint.new(1, 1)
		}
		
		local projectileTrail = Effects.TrailPart(projectile, lifeTime, 1.3 * trailLifetimeRatio, Vector3.new(0, 0.02, 0), Vector3.new(0, -0.02, 0), Color3.new(1,1,1), baseTrailTransparency)
		
		-- Particles:
		local particles = {}
		local waterParticle = EffectsFolder:WaitForChild("WaterBurst"):WaitForChild("A"):Clone()
		local sizeSequence = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 0.01)}
		
		waterParticle.Parent = projectile
		for _, particle in pairs(waterParticle:GetChildren()) do
			table.insert(particles, #particles + 1, particle)
			particle.Rate = 25
			particle.Size = sizeSequence
			particle.Speed = NumberRange.new(0, 7)
			particle.Enabled = true
			
			coroutine.wrap(function()
				wait(lifeTime - 0.45)
				particle.Enabled = false
			end)()
		end
		Debris:AddItem(waterParticle, lifeTime)
		
		-- Deactivation:
		projectile:GetPropertyChangedSignal("Anchored"):Connect(function()
			if projectile.Anchored then 
				waterBlob:Destroy()
				for _, particle in pairs(particles) do
					particle.Enabled = false
				end
				for _, trail in pairs(trails) do
					trail.Enabled = false
				end
				projectileTrail.Enabled = false
				
				Debris:AddItem(projectile, 1)
				for _, spiralPart in pairs(spiralParts) do
					Debris:AddItem(spiralPart, 0.6)
				end
			end
		end)
	end
end

function Effects:CollideProjectile(projectile, weapon, hit, pos, normal)
	projectile.Anchored = true
	if weapon == "WaterMagic" then
		local waterParticle = EffectsFolder:WaitForChild("WaterBurst"):WaitForChild("A"):Clone()
		local sizeSequence = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.275), NumberSequenceKeypoint.new(1, 0)}
		
		waterParticle.Parent = projectile
		for _, particle in pairs(waterParticle:GetChildren()) do
			particle.Acceleration = Vector3.new(0, -70, 0)
			particle.Rotation = NumberRange.new(0, 360)
			particle.RotSpeed = NumberRange.new(0, 360)
			particle.Lifetime = NumberRange.new(0.4, 0.45)
			particle.Size = sizeSequence
			particle.Speed = NumberRange.new(14, 20)
			particle:Emit(35)
		end
		Debris:AddItem(waterParticle, 0.6)
	end
end

return Effects
