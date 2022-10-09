local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effects = ReplicatedStorage:WaitForChild("Effects")
local SharedEffects = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SharedEffects"))
local TS = game:GetService("TweenService")
local Junk = workspace:WaitForChild("Junk")
local Debris = game:GetService("Debris")
local RS = game:GetService("RunService")

----------------------------------------------------------------Vars

local EnergySpark = Effects:WaitForChild("EnergySpark")

local EHWeld = Instance.new("WeldConstraint")
EHWeld.Name = "EHWeld"

local ChargeBall = Instance.new("Part")
ChargeBall.Name = "ChargeBall"
ChargeBall.CanCollide = false
ChargeBall.Anchored = true
ChargeBall.Material = "Neon"
ChargeBall.Size = Vector3.new(0.05,0.05,0.05)
ChargeBall.Transparency = 1

local HammerSmashTrailWidth = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(.4, 1),
    NumberSequenceKeypoint.new(.7, .1),
	NumberSequenceKeypoint.new(1, 0)	
}

local HammerSmashTransparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(.6, .2),
	NumberSequenceKeypoint.new(.8, .05),
    NumberSequenceKeypoint.new(1, 1)
}

local AquaTrailTransparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(.5, .8),
	NumberSequenceKeypoint.new(.55, .9),
	NumberSequenceKeypoint.new(.6, .1),
    NumberSequenceKeypoint.new(1, 1)
}

local AquaTrailWidth = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(.6, 0),
	NumberSequenceKeypoint.new(1, 0)	
}


local PierceTrailTransparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 1),
 	NumberSequenceKeypoint.new(.5,0),
    NumberSequenceKeypoint.new(1, 0)
}

local PierceTrailWidth = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, .5),
	NumberSequenceKeypoint.new(1, 0)	
}

local WaterGlow = Effects:WaitForChild("WaterGlow")
local PureGlow = Effects:WaitForChild("PureGlow")
local FireSparks = Effects:WaitForChild("FireSparks")
local SmokeAshes = Effects:WaitForChild("SmokeAshes")

----------------------------------------------------------------Functions
local swait = function()
	RS.Heartbeat:Wait()
end

local AS = {}

function CheckDelay(WaitTime, Delay)
	if Delay < WaitTime then
		wait(WaitTime - Delay)
		return 0
	else
		return Delay - WaitTime
	end
end

DoCoroutine = function(func)
	coroutine.wrap(func)()
end

function GetEnergyHolders(Model, OptionalRatio, DeleteTime)
	local EHTable = {}
	local MaxSize = math.max(Model.Size.X,Model.Size.Y,Model.Size.Z)
	local SecondMaxSize
	local ShiftCF
	if MaxSize == Model.Size.X then
		ShiftCF = Model.CFrame.RightVector
		SecondMaxSize = math.max(Model.Size.Y, Model.Size.Z)
	elseif MaxSize == Model.Size.Z then
		ShiftCF = Model.CFrame.LookVector
		SecondMaxSize = math.max(Model.Size.Y, Model.Size.X)
	else
		ShiftCF = Model.CFrame.UpVector
		SecondMaxSize = math.max(Model.Size.X, Model.Size.Z)
	end	
	
	if OptionalRatio then
		SecondMaxSize = SecondMaxSize * OptionalRatio
	end
	
	local OneTwoRatio = math.floor(MaxSize/SecondMaxSize)
	local EHSize = Vector3.new(SecondMaxSize, SecondMaxSize, SecondMaxSize)
	local BaseCF = Model.CFrame + (ShiftCF *  (.75 - OneTwoRatio/2) * SecondMaxSize)
	
	for i = 0, OneTwoRatio - 1 do
		local EHClone = Instance.new("Part")
		EHClone.CanCollide = false
		EHClone.Anchored = false
		EHClone.Massless = true
		EHClone.Transparency = 1
		EHClone.Name = "EnergyHolder"
		local EHWeldClone = EHWeld:Clone()
		EHWeldClone.Part0 = Model
		EHWeldClone.Part1 = EHClone
		EHClone.CFrame = BaseCF + (ShiftCF * i * SecondMaxSize)
		EHWeldClone.Parent = EHClone
		EHClone.Size = EHSize
		EHClone.Parent = Junk
		table.insert(EHTable, EHClone)
		
		DoCoroutine(function()
			if DeleteTime and DeleteTime > 0.03 then
				wait(DeleteTime)
				EHClone:Destroy()
			end
		end)
	end
	
	return EHTable
end

----------------------------------------------------------------Abilities
AS.HammerSmash = function(Head, HRP, HitPos, HitPart)
	local TimeRate = 1.1
	local Maxsize = math.max(Head.Size.X, Head.Size.Y, Head.Size.Z)
	local FSClone = FireSparks:Clone()
	FSClone.Parent = Head
	FSClone.Enabled = true
	local SAClone = SmokeAshes:Clone()
	SAClone.Parent = Head
	SAClone.Enabled = true
	DoCoroutine(function()
		wait(.85)
		FSClone.Enabled = false
		SAClone.Enabled = false
		wait(.8)
		FSClone:Destroy()
		SAClone:Destroy()
	end)
	
	DoCoroutine(function()
		wait(.95)
		SharedEffects.MakeBlob("Smoke", Head, 3, 2.6, .075)
	end)
	
	SharedEffects.MakeBlob("Smoke", Head, 1, 2.3, .95, 500)
	SharedEffects.MakeBlob("Fire", Head, 1, 2.3, .95)
	SharedEffects.MakeScreenshake(9000, HitPos, 150)
	SharedEffects.MakeBlind(1, Head.Position, 150)
	--local BaseCF = CFrame.new(HitPos, HitPos + HitNormal) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))
	local HRPCF = HRP.CFrame - HRP.Position
	local x, y, z = HRPCF:ToEulerAnglesYXZ()
	local HOrientation = CFrame.Angles(0, y, 0)
	local EffectCF = CFrame.new(Head.Position) * HOrientation
	

	for i = 1,5 do
		SharedEffects.MakeShockwave(1.8 - .16 * i, EffectCF, Color3.new(1,1,1), (.4) * TimeRate, nil, nil, (i-1)*0.05)
	end
	for i = 1,3 do
		SharedEffects.MakeShockwave(1, EffectCF, Color3.new(1,1,1), (.4) * TimeRate, nil, CFrame.new(0,i*3.5,0), 0.06 + i*0.03)
		SharedEffects.MakeShockwave(1, EffectCF, Color3.new(1,1,1), (.4) * TimeRate, nil, CFrame.new(0,-i*3.5,0), 0.06 + i*0.03)
	end
	for i = 1,2 do
		SharedEffects.MakeShockwave(1 - .2 * i, EffectCF, Color3.new(1,1,1), (.4) * TimeRate, nil, CFrame.new(0,10.5 + i*1.3,0), 0.155 + i * 0.025)
		SharedEffects.MakeShockwave(1 - .2 * i, EffectCF, Color3.new(1,1,1), (.4) * TimeRate, nil, CFrame.new(0,-10.5 - i*1.3,0), 0.155 + i * 0.025)
	end
	
	SharedEffects.MakeExplosion(Vector3.new(0.52,0.52,0.52), EffectCF, Color3.new(1,1,1), 0, Vector3.new(20,20,20), 0.6 * TimeRate, 0.25 * TimeRate)
	SharedEffects.MakeExplosion(Vector3.new(0.6,0.6,0.6), EffectCF, Color3.new(1,.8,0), 0.25, Vector3.new(23,23,23), 0.6 * TimeRate, 0.25 * TimeRate)
	SharedEffects.MakeExplosion(Vector3.new(0.68,0.68,0.68), EffectCF, Color3.new(1,0.25,0), .5, Vector3.new(26,26,26), 0.6 * TimeRate, 0.25 * TimeRate)
		
	SharedEffects.MakeSparks(HitPos, math.random(32,40), Vector3.new(.85,.85,2), Color3.new(1,1,1), .68, 0.675 * 25, 0.55 * TimeRate, .4 * TimeRate, Vector3.new(0,0,1.2))
	SharedEffects.MakeSparks(HitPos, math.random(12,16), Vector3.new(.25,.25,.25), Color3.new(1,1,1), .68, 0.675 * 40, 1 * TimeRate, 0 * TimeRate, Vector3.new(0,0,0), true)
	
	local SpiralReference =  Instance.new("Part")
	SpiralReference.CanCollide = false
	SpiralReference.Massless = true
	SpiralReference.Transparency = 1
	SpiralReference.Anchored = true
	SpiralReference.CFrame = EffectCF
	SpiralReference.Parent = Junk
	DoCoroutine(function()
		for i=1,6 do
			for i,SpiralPart in pairs(SharedEffects.SpiralPart(SpiralReference, 1.1 * TimeRate, 1, Vector3.new(0.4,3,0.,4), Vector3.new(math.random(5,8),math.random(5,8),math.random(5,8)))) do
				local T1, O1, T1 = SharedEffects.TrailPart(SpiralPart, .75*TimeRate, .3*TimeRate, Vector3.new(0, 3 + 2, 0), Vector3.new(0, 3 - 2, 0), Color3.new(1,1,1), HammerSmashTransparency, HammerSmashTrailWidth, "AirTrail")
				local T2, O2, T2 = SharedEffects.TrailPart(SpiralPart, .75*TimeRate, .3*TimeRate, Vector3.new(0, -3 + 2, 0), Vector3.new(0, -3 - 2, 0), Color3.new(1,1,1), HammerSmashTransparency, HammerSmashTrailWidth, "AirTrail")
				local T3, O3, T3 = SharedEffects.TrailPart(SpiralPart, .75*TimeRate, .3*TimeRate, Vector3.new(0, 3 + 3, 0), Vector3.new(0, 3 - 3, 0), Color3.new(1,1,1), HammerSmashTransparency, HammerSmashTrailWidth, "AirTrail")
				local T4, O4, T4 = SharedEffects.TrailPart(SpiralPart, .75*TimeRate, .3*TimeRate, Vector3.new(0, -3 + 3, 0), Vector3.new(0, -3 - 3, 0), Color3.new(1,1,1), HammerSmashTransparency, HammerSmashTrailWidth, "AirTrail")
	
				local TrailTweenTime = TimeRate * math.random(300,500)/1000
				local FinalSize = math.random(195,240)/10
				SharedEffects.TweenPosition(O1, Vector3.new(0, FinalSize), TrailTweenTime, "Quad")
				SharedEffects.TweenPosition(O2, Vector3.new(0, -FinalSize), TrailTweenTime, "Quad")
				SharedEffects.TweenPosition(O3, Vector3.new(0, FinalSize), TrailTweenTime, "Quad")
				SharedEffects.TweenPosition(O4, Vector3.new(0, -FinalSize), TrailTweenTime, "Quad")
				SharedEffects.TweenPosition(T1, Vector3.new(0, FinalSize), TrailTweenTime, "Quad")
				SharedEffects.TweenPosition(T2, Vector3.new(0, -FinalSize), TrailTweenTime, "Quad")
				SharedEffects.TweenPosition(T3, Vector3.new(0, FinalSize), TrailTweenTime, "Quad")
				SharedEffects.TweenPosition(T4, Vector3.new(0, -FinalSize), TrailTweenTime, "Quad")
			end
			SpiralReference.Orientation = Vector3.new(math.random(0,360),math.random(0,360),math.random(0,360))
		end
		wait()
		SpiralReference:Destroy()
	end)
	
	SharedEffects.MakeRing(.85, HitPos, Color3.new(1,1,1), .65 * TimeRate, .675 * TimeRate, 40)
	SharedEffects.MakeRing(.825, HitPos, Color3.new(1,1,1), .65 * TimeRate, .675 * TimeRate, 40)
	SharedEffects.MakeRing(.8, HitPos, Color3.new(1,1,1), .65 * TimeRate, .675 * TimeRate, 40)	
	
	SharedEffects.MakeDebris(math.random(4,5), HitPart, HitPos, "Fire", math.random(100,125)/10)
end

local AgileTrailTransparency =  NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(.3, .7),
    NumberSequenceKeypoint.new(1, 1)
}

AS.AgileSwipe = function(Player, Delay)
	local Character = Player.Character
	if not Character or not Character:FindFirstChild("HumanoidRootPart") 
	or not Character:FindFirstChild("Humanoid") or not Character:FindFirstChild("WeaponTag", true) then return end
	
	local weapon = Character:FindFirstChild("WeaponTag", true).Parent
	local HRP = Character.HumanoidRootPart
	local Humanoid = Character.Humanoid
	local EnergyColor = Character.Head.RightEye.Color or Color3.new(1,1,1)
	local Transparency = .7
	local EnergyTable = {}
	local Landed = false
	
	for i,v in pairs(weapon:GetDescendants()) do
		if v:IsA("BasePart") and string.find(string.lower(v.Name),"head") then
			local EHHolders = GetEnergyHolders(v, 1.25, 10)
			if #EHHolders == 0 then
				local EHClone = Instance.new("Part")
				EHClone.CanCollide = false
				EHClone.Anchored = false
				EHClone.Massless = true
				EHClone.Transparency = 1
				EHClone.Name = "EnergyHolder"
				local EHWeldClone = EHWeld:Clone()
				EHWeldClone.Part0 = v
				EHWeldClone.Part1 = EHClone
				EHClone.CFrame = v.CFrame
				EHWeldClone.Parent = EHClone
				local MSize = math.max(v.Size.X, v.Size.Y, v.Size.Z)
				EHClone.Size = Vector3.new(MSize, MSize, MSize)
				EHClone.Parent = Junk
				table.insert(EHHolders, EHClone)
			end
			
			for i,x in pairs(EHHolders) do
				table.insert(EnergyTable, SharedEffects.MakeBlob("Energy", x, 1, x.Size.X * 3, 5, 700, EnergyColor))		
				local PG = PureGlow:Clone()
				local EG = PureGlow:Clone()
				EG.Color = ColorSequence.new(EnergyColor)
				EG.Size = NumberSequence.new{
    			NumberSequenceKeypoint.new(0, x.Size.X * 3),
    			NumberSequenceKeypoint.new(1, x.Size.X * 3)}
				PG.Size = NumberSequence.new{
   	 			NumberSequenceKeypoint.new(0, x.Size.X * 2),
    			NumberSequenceKeypoint.new(1, x.Size.X * 2)}
				EG.Rate = 250/#EHHolders
				PG.Rate = 250/#EHHolders
				EG.ZOffset = 1
				PG.ZOffset = 1
				EG.Parent = x
				PG.Parent = x
				EG.Enabled = true
				PG.Enabled = true
				DoCoroutine(function()
					while not Landed do swait() end
					EG.Enabled = false
					PG.Enabled = false
					Debris:AddItem(x, 0.25)
					Debris:AddItem(EG, 0.25)
					Debris:AddItem(PG, 0.25)
				end)
			end
		end
	end
	
	Delay = CheckDelay(0.295, Delay)
	local ImpactTrails = {}
	for i = 0,1 do
		for j = 0,1 do
			local T = SharedEffects.TrailPart(Character.Torso, 100, math.random(35,42)/100, Vector3.new(-.045 -.25 + .5*j, -.25 + .5*i, 0), Vector3.new(.035 -.25 + .5*j, -.25 + .5*i, 0), nil, AgileTrailTransparency, nil, nil)
			table.insert(ImpactTrails, T)
		end
	end
	
	local TorsoTrail, T1, T2 = SharedEffects.TrailPart(Character.Torso, 10, math.random(25,35)/100, Vector3.new(-.035, 0, 0), Vector3.new(.035, 0, 0), nil, AgileTrailTransparency, nil, nil)
	local LATrail, LA1, LA2 = SharedEffects.TrailPart(Character.LeftArm, 10, math.random(25,35)/100, Vector3.new(-.035, 0, 0), Vector3.new(.035, 0, 0), nil, AgileTrailTransparency, nil, nil)
	local RATrail, RA1, RA2 = SharedEffects.TrailPart(Character.RightArm, 10, math.random(25,35)/100, Vector3.new(-.035, 0, 0), Vector3.new(.035, 0, 0), nil, AgileTrailTransparency, nil, nil)
	local LLTrail, LL1, LL2 = SharedEffects.TrailPart(Character.LeftLeg, 10, math.random(25,35)/100, Vector3.new(-.035, 0, 0), Vector3.new(.035, 0, 0), nil, AgileTrailTransparency, nil, nil)
	local RLTrail, RL1, RL2 = SharedEffects.TrailPart(Character.RightLeg, 10, math.random(25,35)/100, Vector3.new(-.035, 0, 0), Vector3.new(.035, 0, 0), nil, AgileTrailTransparency, nil, nil)
	local GlassEffect = SharedEffects.MakeGlassEffect(Character, .03, Transparency)
	
	Delay = CheckDelay(0.235, Delay)
	
	for i,Trail in pairs(ImpactTrails) do
		Trail.Enabled = false
		Debris:AddItem(Trail.Attachment0, Trail.Lifetime)
		Debris:AddItem(Trail.Attachment1, Trail.Lifetime)
		Debris:AddItem(Trail, Trail.Lifetime)
	end

	while Character and Humanoid:GetState() == Enum.HumanoidStateType.Freefall do
		swait()
	end
	Landed = true
	
	if #EnergyTable > 0 then
		for i,v in pairs(EnergyTable) do
			v:Destroy()
		end	
	end
	
	if GlassEffect then
		GlassEffect:Destroy()
	end
	
	TorsoTrail.Enabled = false
	LATrail.Enabled = false
	RATrail.Enabled = false
	LLTrail.Enabled = false
	RLTrail.Enabled = false
	
	Debris:AddItem(T1, LATrail.Lifetime)
	Debris:AddItem(T2, LATrail.Lifetime)
	Debris:AddItem(TorsoTrail, LATrail.Lifetime)
	
	Debris:AddItem(LA1, LATrail.Lifetime)
	Debris:AddItem(LA2, LATrail.Lifetime)
	Debris:AddItem(LATrail, LATrail.Lifetime)
	
	Debris:AddItem(RA1, LATrail.Lifetime)
	Debris:AddItem(RA2, LATrail.Lifetime)
	Debris:AddItem(RATrail, LATrail.Lifetime)
	
	Debris:AddItem(LL1, LATrail.Lifetime)
	Debris:AddItem(LL2, LATrail.Lifetime)
	Debris:AddItem(LLTrail, LATrail.Lifetime)
	
	Debris:AddItem(RL1, LATrail.Lifetime)
	Debris:AddItem(RL2, LATrail.Lifetime)
	Debris:AddItem(RLTrail, LATrail.Lifetime)
end

AS.AquaPulse = function(Player, Delay)
	if not Player.Character or not Player.Character:FindFirstChild("LeftArm") or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
	local Character = Player.Character
	local LeftArm = Character.LeftArm
	local HRP = Character:WaitForChild("HumanoidRootPart")
	
	local ArmBlob = SharedEffects.MakeBlob("Water", LeftArm, 1, LeftArm.Size.X/3 + 25.5/6 * Delay, 5, 300, nil, .1275)
	
	local Charging = true
	local BVWait = true

	for i,SpiralPart in pairs(SharedEffects.SpiralPart(LeftArm, 2, 3, Vector3.new(0.4,.9,0.4), Vector3.new(0,0,25))) do
		local T1 = SharedEffects.TrailPart(SpiralPart, 5, .35, Vector3.new(0, SpiralPart.Size.Y/2 + .015, 0), Vector3.new(0, SpiralPart.Size.Y/2 - .015, 0), Color3.new(1,1,1), AquaTrailTransparency, AquaTrailWidth)
		local T2 = SharedEffects.TrailPart(SpiralPart, 5, .35, Vector3.new(0, -SpiralPart.Size.Y/2 + .015, 0), Vector3.new(0, -SpiralPart.Size.Y/2 - .015, 0), Color3.new(1,1,1), AquaTrailTransparency, AquaTrailWidth)
		local T3 = SharedEffects.TrailPart(SpiralPart, 5, .35, Vector3.new(0, SpiralPart.Size.Y/2 + .08, 0), Vector3.new(0, SpiralPart.Size.Y/2 - .08, 0), Color3.new(0,.5,1), AquaTrailTransparency, AquaTrailWidth)
		local T4 = SharedEffects.TrailPart(SpiralPart, 5, .35, Vector3.new(0, -SpiralPart.Size.Y/2 + .08, 0), Vector3.new(0, -SpiralPart.Size.Y/2 - .08, 0), Color3.new(0,.5,1), AquaTrailTransparency, AquaTrailWidth)
		DoCoroutine(function()
			repeat swait() until not BVWait
			wait(.55)
			T1.Enabled = false
			T2.Enabled = false
			T3.Enabled = false
			T4.Enabled = false
			T1.Attachment0:Destroy()
			T1.Attachment1:Destroy()
			T2.Attachment0:Destroy()
			T2.Attachment1:Destroy()
			T3.Attachment0:Destroy()
			T3.Attachment1:Destroy()
			T4.Attachment0:Destroy()
			T4.Attachment1:Destroy()
			wait(T1.Lifetime)
			T1:Destroy()
			T2:Destroy()
			T3:Destroy()
			T4:Destroy()
		end)
	end
	
	local SizeFactor = ArmBlob:WaitForChild("SizeFactor")
	local OriginalSize = SizeFactor.Value - 25.5/6*Delay
	DoCoroutine(function()
		repeat
			for i = 1, math.random(10,14) do
				local ChargeBallClone = ChargeBall:Clone()
				ChargeBallClone.Color = Color3.fromRGB(math.random(80,160),math.random(160,225),math.random(225,255))
				local Delta = math.floor(SizeFactor.Value * 2.75) + math.floor(LeftArm.Size.X) * 3.5
				ChargeBallClone.Position = LeftArm.Position + Vector3.new(math.random(-Delta, Delta) * math.random(10,20)/10, 
					math.random(-Delta, Delta) * math.random(10,20)/10,
					math.random(-Delta, Delta) * math.random(10,20)/10)
				ChargeBallClone.Size = ChargeBallClone.Size * math.random(3,7)/10 * SizeFactor.Value/OriginalSize
				ChargeBallClone.Orientation = Vector3.new(math.random(0,360), math.random(0,360), math.random(0,360))
				ChargeBallClone.Parent = workspace:WaitForChild("Junk")
				game:GetService("Debris"):AddItem(ChargeBallClone, 0.25)
				TS:Create(ChargeBallClone, TweenInfo.new(0.35), {Transparency = 0}):Play()
				TS:Create(ChargeBallClone, TweenInfo.new(0.275), {Position = LeftArm.Position}):Play()
			end
			wait()
		until not Charging
	end)
	
	DoCoroutine(function() 
		Delay = CheckDelay(0.3, Delay) 
		Charging = false 
	end)
	
	repeat swait() until HRP:FindFirstChild("StopAquaPulseCharge") or not Charging
	Charging = false
	ArmBlob:WaitForChild("ExpandRate"):Destroy()
	
	DoCoroutine(function() 
		Delay = CheckDelay(.3, Delay)
		BVWait = false 
	end)
	repeat swait() until HRP:FindFirstChild("AquaPulse") and HRP.AquaPulse.MaxForce == Vector3.new(500000,500000,500000) or not BVWait

	local TorsoTrail = SharedEffects.TrailPart(Character.Torso, .275, .1, Vector3.new(-.075, 0, 0), Vector3.new(.075, 0, 0), nil, AgileTrailTransparency)
	local LATrail = SharedEffects.TrailPart(Character.LeftArm, .275, .1, Vector3.new(-.075, 0, 0), Vector3.new(.075, 0, 0), nil, AgileTrailTransparency)
	local RATrail = SharedEffects.TrailPart(Character.RightArm, .275, .1, Vector3.new(-.075, 0, 0), Vector3.new(.075, 0, 0), nil, AgileTrailTransparency)
	local LLTrail = SharedEffects.TrailPart(Character.LeftLeg, .275, .1, Vector3.new(-.075, 0, 0), Vector3.new(.075, 0, 0), nil, AgileTrailTransparency)
	local RLTrail = SharedEffects.TrailPart(Character.RightLeg, .275, .1, Vector3.new(-.075, 0, 0), Vector3.new(.075, 0, 0), nil, AgileTrailTransparency)
	
	local ExplodePosition = LeftArm.Position
	SharedEffects.MakeScreenshake(1500, ExplodePosition, 40)			
	SharedEffects.MakeDebris(math.random(8,10), LeftArm, ExplodePosition, "Water", 1.8)--, HRP.CFrame.LookVector)
	
	local WaterBurst = ReplicatedStorage:WaitForChild("Effects"):WaitForChild("WaterBurst"):Clone()
	WaterBurst.Position = ExplodePosition
	WaterBurst.Parent = workspace:WaitForChild("Junk")
	WaterBurst:WaitForChild("A"):WaitForChild("P1").Enabled = true
	WaterBurst:WaitForChild("A"):WaitForChild("P2").Enabled = true
	WaterBurst:WaitForChild("A"):WaitForChild("P3").Enabled = true
	DoCoroutine(function() 
		wait(.35) 
		WaterBurst.A.P1.Enabled = false 
		WaterBurst.A.P2.Enabled = false 
		WaterBurst.A.P3.Enabled = false 
		Debris:AddItem(WaterBurst, 0.5)
	end)
	
	
	for i = 0,2 do
		SharedEffects.MakeShockwave(.35 - i * .09, HRP.CFrame * CFrame.Angles(math.rad(45),0,0) - HRP.Position + LeftArm.Position, Color3.new(1,1,1), .3 + i * .065)
	end
	
	SharedEffects.MakeSparks(ExplodePosition, math.random(22,28), Vector3.new(.38,.38, 1.75), Color3.new(1,1,1), -1.6, 6, 0.5, 0.4, Vector3.new(0,0,.1))
	SharedEffects.MakeSparks(ExplodePosition, math.random(9,16), Vector3.new(.25,.25,.25), Color3.new(1,1,1), 0, 10, 0.7, .75, Vector3.new(0,0,0), true)
	
	if 0.6 > Delay then
		Debris:AddItem(ArmBlob, 0.6 - Delay)
	else
		ArmBlob:Destroy()
	end
end

AS.Pierce = function(Player, Delay)
	if not Player.Character or not Player:WaitForChild("Gameplay"):WaitForChild("Equipped").Value or not Player.Character:FindFirstChild("WeaponTag", true) then return end
	local Character = Player.Character
	local HRP = Character:WaitForChild("HumanoidRootPart")
	if not Character:FindFirstChild("Head") or not Character.Head:FindFirstChild("RightEye") then return end
	
	local EnergyTable = {}
	local EnergyColor = Character.Head.RightEye.Color or Color3.new(1,1,1) 
	
	for j = 0,1 do
		local SpiralParent = Instance.new("Part")
		SpiralParent.CanCollide = false
		SpiralParent.Anchored = false
		SpiralParent.Massless = true
		SpiralParent.Transparency = 1
		SpiralParent.Position = HRP.Position + Vector3.new(0,-1.125 + j * 6.125,0)
		SpiralParent.Orientation = Vector3.new(90,90 + j * 90,135) + Vector3.new(0, HRP.Orientation.Y, HRP.Orientation.Z)
		SpiralParent.Parent = Junk
		for i,SpiralPart in pairs(SharedEffects.SpiralPart(SpiralParent, 1.2, 2, Vector3.new(0.4,15,0.4), Vector3.new(0,0, 10 ))) do
			local Rotation = SpiralPart:WaitForChild("Rotation")
			local T1 = SharedEffects.TrailPart(SpiralPart, 5, .5, Vector3.new(0, SpiralPart.Size.Y/2 + .075, 0), Vector3.new(0, SpiralPart.Size.Y/2 - .075, 0), Color3.new(1,1,1), PierceTrailTransparency, PierceTrailWidth)
			local T2 = SharedEffects.TrailPart(SpiralPart, 5, .5, Vector3.new(0, -SpiralPart.Size.Y/2 + .075, 0), Vector3.new(0, -SpiralPart.Size.Y/2 - .075, 0), Color3.new(1,1,1), PierceTrailTransparency, PierceTrailWidth)
			local T3 = SharedEffects.TrailPart(SpiralPart, 5, .5, Vector3.new(0, SpiralPart.Size.Y/2 + .3, 0), Vector3.new(0, SpiralPart.Size.Y/2 - .3, 0), EnergyColor, PierceTrailTransparency, PierceTrailWidth)
			local T4 = SharedEffects.TrailPart(SpiralPart, 5, .5, Vector3.new(0, -SpiralPart.Size.Y/2 + .3, 0), Vector3.new(0, -SpiralPart.Size.Y/2 - .3, 0), EnergyColor, PierceTrailTransparency, PierceTrailWidth)
			DoCoroutine(function()
				DoCoroutine(function()
					while SpiralParent do
						TS:Create(SpiralParent, TweenInfo.new(.3), {Position = HRP.Position + Vector3.new(0,5 - 6.125*j,0)}):Play()
						wait(.1)
					end
				end)
				wait(.4)
				T2.Lifetime = .15
				T2.Lifetime = .15
				T2.Lifetime = .15
				T2.Lifetime = .15
				wait(.15)
				TS:Create(Rotation, TweenInfo.new(.2), {Value = Vector3.new(0,0,0)}):Play()
				wait(.2)
				SpiralParent:Destroy()
			end)
		end 
	end
	
	for i,v in pairs(Character:FindFirstChild("WeaponTag", true).Parent:GetDescendants()) do
		if v:IsA("BasePart") and string.find(string.lower(v.Name),"head") then
			local EHHolders = GetEnergyHolders(v, 1.25, 30)
			if #EHHolders == 0 then
				local EHClone = Instance.new("Part")
				EHClone.CanCollide = false
				EHClone.Anchored = false
				EHClone.Massless = true
				EHClone.Transparency = 1
				EHClone.Name = "EnergyHolder"
				local EHWeldClone = EHWeld:Clone()
				EHWeldClone.Part0 = v
				EHWeldClone.Part1 = EHClone
				EHClone.CFrame = v.CFrame
				EHWeldClone.Parent = EHClone
				local MSize = math.max(v.Size.X, v.Size.Y, v.Size.Z)
				EHClone.Size = Vector3.new(MSize, MSize, MSize)
				EHClone.Parent = Junk
				table.insert(EHHolders, EHClone)
			end
			for i,x in pairs(EHHolders) do
				table.insert(EnergyTable, SharedEffects.MakeBlob("Energy", x, 1, x.Size.X * 1.55, 10, 600, EnergyColor))
				local ESpark = EnergySpark:Clone()
				local PSpark = EnergySpark:Clone()
				local PG = PureGlow:Clone()
				local EG = PureGlow:Clone()
				ESpark.Color = ColorSequence.new(EnergyColor)
				EG.Color = ColorSequence.new(EnergyColor)
				EG.Size = NumberSequence.new{
    			NumberSequenceKeypoint.new(0, .75),
    			NumberSequenceKeypoint.new(1, .75)}
				PG.Size = NumberSequence.new{
   	 			NumberSequenceKeypoint.new(0, .525),
    			NumberSequenceKeypoint.new(1, .525)}
				PG.ZOffset = 1
				EG.ZOffset = 1
				EG.Rate = math.floor(300/#EHHolders)
				PG.Rate = math.floor(300/#EHHolders)
				PSpark.Rate = math.floor(175/#EHHolders)
				ESpark.Rate = math.floor(175/#EHHolders)
				PSpark.EmissionDirection = "Right"
				ESpark.EmissionDirection = "Right"
				EG.Parent = x
				PG.Parent = x
				ESpark.Parent = x
				PSpark.Parent = x
				EG.Enabled = true
				PG.Enabled = true
				ESpark.Enabled = true
				PSpark.Enabled = true
				DoCoroutine(function()
					CheckDelay(10, Delay)
					x:Destroy()
					for i,E in pairs(EnergyTable) do
						E:Destroy()
					end
					EG.Enabled = false
					PG.Enabled = false
					ESpark.Enabled = false
					PSpark.Enabled = false
					wait(EG.Lifetime)
					EG:Destroy()
					PG:Destroy()
					ESpark:Destroy()
					PSpark:Destroy()
				end)
			end
		end
	end
end

return AS
