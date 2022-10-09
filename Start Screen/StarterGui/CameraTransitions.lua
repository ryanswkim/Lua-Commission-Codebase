local TS = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
repeat wait() until Player.Character
local Character = workspace:WaitForChild("Customize"):WaitForChild("Model")
local HRP = Character:WaitForChild("HumanoidRootPart")
HRP.Anchored = true

local LE = Character:WaitForChild("Head"):WaitForChild("LeftEye"):WaitForChild("Mesh")
local RE = Character:WaitForChild("Head"):WaitForChild("RightEye"):WaitForChild("Mesh")
spawn(function()
	while true do
		wait(math.random(4,7))
		for i = 1,math.random(1,2) do
			TS:Create(RE, TweenInfo.new(.075), {Scale = Vector3.new(1, 0, 1)}):Play()
			TS:Create(LE, TweenInfo.new(.075), {Scale = Vector3.new(1, 0, 1)}):Play()
			wait(.075)
			TS:Create(RE, TweenInfo.new(.075), {Scale = Vector3.new(1, 1, 1)}):Play()
			TS:Create(LE, TweenInfo.new(.075), {Scale = Vector3.new(1, 1, 1)}):Play()
			wait(.075)
		end
	end
end)


--Camera intros
local Camera = workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable
local HomeScreen = true
function InterpolateCam()
	Camera.CameraType = Enum.CameraType.Scriptable
	repeat
		Camera.CFrame = CFrame.new(math.random(0,100),math.random(0,100),math.random(0,100)) 
		Camera:Interpolate(CFrame.new(math.random(0,100),math.random(0,100),math.random(0,100)),  CFrame.new(math.random(0,100),math.random(0,100),math.random(0,100)), 5)
		wait(5)
	until not HomeScreen
end

-- -- -- -- -- -- -- --
spawn(InterpolateCam)
-- -- -- -- -- -- -- --

--New/Load Game
local New = script.Parent:WaitForChild("New"):WaitForChild("Button")
local Play = script.Parent:WaitForChild("Play"):WaitForChild("Button")
local Transition = script.Parent:WaitForChild("Extras"):WaitForChild("Transition")

local Focus = script.Parent:WaitForChild("Extras"):WaitForChild("Focus")
local Customizing = script.Parent:WaitForChild("Customizing")
local Left = Customizing:WaitForChild("Left")
local Right = Customizing:WaitForChild("Right")
local Selections = Customizing:WaitForChild("Selections")
local LeftFrame = Selections:WaitForChild("LeftFrame")
local RightFrame = Selections:WaitForChild("RightFrame")
local CustomizationsLabel = Customizing:WaitForChild("CustomizationsLabel")
local Back = LeftFrame:WaitForChild("Back"):WaitForChild("Button")
local Create = RightFrame:WaitForChild("Create"):WaitForChild("Button")

local VPSize = Camera.ViewportSize
local XFrames = math.ceil(VPSize.X/100) - 1
local YFrames = math.ceil(VPSize.Y/100)

local function DoCouroutine(f)
	coroutine.resume(coroutine.create(f))
end

local function Transitioning()
	for x = 0,XFrames do
		for y = 0, YFrames do
			local CubeFrame = Instance.new("Frame")
			CubeFrame.Parent = Transition
			CubeFrame.ZIndex = 999999998
			CubeFrame.Size = UDim2.new(0,0,0,0)
			CubeFrame.AnchorPoint = Vector2.new(0.5,0.5)
			CubeFrame.BackgroundColor3 = Color3.new(0,0,0)
			CubeFrame.Position = UDim2.new(0, x*100 + 50 - math.fmod(VPSize.X,100), 0, y*100 - 50)
			CubeFrame.BorderSizePixel = 0
			DoCouroutine(function()
				if x > 0 or y > 0 then
					wait(0.03 * (x+y))
				end
				TS:Create(CubeFrame, TweenInfo.new(.65), {Size = UDim2.new(0,100,0,100)}):Play()
				
				wait(.65 + (XFrames + YFrames) * .03)
				TS:Create(CubeFrame, TweenInfo.new(.65), {Size = UDim2.new(0,0,0,0)}):Play()
				wait(.65)
				CubeFrame:Destroy()
			end)
		end
	end
end

local function ResetModel()
	Character:SetPrimaryPartCFrame(CFrame.new(HRP.Position) * CFrame.Angles(0,math.rad(90),0))
end

New.Activated:Connect(function()
	Back.Active = true
	Create.Active = true
	ResetModel()
	New.Active = false
	Play.Active = false
	spawn(function()
		TS:Create(New, TweenInfo.new(.05), {Position = UDim2.new(0.18, 0, .85, 0)}):Play()
		wait(.05)
		TS:Create(New, TweenInfo.new(.1), {Position = UDim2.new(0.18, 0, .84, 0)}):Play()
		wait(.05)
		for i,v in pairs(Play.Parent:GetChildren()) do
			TS:Create(v, TweenInfo.new(1), {Position = UDim2.new(0.57, 0, 1.1, 0)}):Play()
		end
		for i,v in pairs(New.Parent:GetChildren()) do
			TS:Create(v, TweenInfo.new(1), {Position = UDim2.new(0.18, 0, 1.1, 0)}):Play()
		end
	end)
	wait(.25)

	Transitioning()
	wait(0.65 + (XFrames + YFrames) * 0.03)
	Camera:Interpolate(HRP.CFrame + HRP.CFrame.LookVector * 8 + Vector3.new(0,2,0), HRP.CFrame *  CFrame.Angles(0, math.rad(180), 0), .03)
	Focus.Visible = true
	HomeScreen = false
	wait(.75)
	TS:Create(LeftFrame, TweenInfo.new(1, Enum.EasingStyle.Back), {Position = UDim2.new(0.05, 0, 0.05,0)}):Play()
	TS:Create(RightFrame, TweenInfo.new(1, Enum.EasingStyle.Back), {Position = UDim2.new(0.95, 0, 0.05,0)}):Play()
	TS:Create(CustomizationsLabel, TweenInfo.new(1, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, 0, 0.095,0)}):Play()
	wait(.75)
	TS:Create(Left, TweenInfo.new(.25), {ImageTransparency = 0.75}):Play()
	TS:Create(Right, TweenInfo.new(.25), {ImageTransparency = 0.75}):Play()
	wait(.25)
	Left.Active = true
	Right.Active = true
end)

Play.Activated:Connect(function()
	--New.Active = false
	--Play.Active = false
	TS:Create(Play, TweenInfo.new(.05), {Position = UDim2.new(0.57, 0, .85, 0)}):Play()
	wait(.05)
	TS:Create(Play, TweenInfo.new(.1), {Position = UDim2.new(0.57, 0, .84, 0)}):Play()
end)

--Customizing Screen
local swait = function()
	game:GetService("RunService").Heartbeat:Wait()
end

Left.MouseButton1Down:Connect(function()
	if not Left.Active then return end
	local Rotating = true
	local RotateConnect = Left.MouseButton1Up:Connect(function()
		Rotating = false
	end)
	repeat 
		TS:Create(HRP, TweenInfo.new(.1), {CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(-15), 0)}):Play()
		swait()
	until not Rotating or not Left.Active
	RotateConnect:Disconnect()
	TS:Create(HRP, TweenInfo.new(.14), {CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(8), 0)}):Play()
	wait(.14)
	TS:Create(HRP, TweenInfo.new(.145), {CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(-4), 0)}):Play()
end)


Right.MouseButton1Down:Connect(function()
	if not Right.Active then return end
	local Rotating = true
	local RotateConnect = Right.MouseButton1Up:Connect(function()	
		Rotating = false
	end)
	repeat 
		TS:Create(HRP, TweenInfo.new(.1), {CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(15), 0)}):Play()
		swait()
	until not Rotating or not Right.Active
	RotateConnect:Disconnect()
	TS:Create(HRP, TweenInfo.new(.14), {CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(-8), 0)}):Play()
	wait(.14)
	TS:Create(HRP, TweenInfo.new(.145), {CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(4), 0)}):Play()
end)


Back.Activated:Connect(function()
	Back.Active = false
	Create.Active = false
	Left.Active = false
	Right.Active = false
	
	TS:Create(Back, TweenInfo.new(.05), {Position = UDim2.new(0.5, 0, .825, 0)}):Play()
	wait(.05)
	TS:Create(Back, TweenInfo.new(.1), {Position = UDim2.new(0.5, 0, .818, 0)}):Play()
	wait(.1)
	
	TS:Create(Left, TweenInfo.new(.25), {ImageTransparency = 1}):Play()
	TS:Create(Right, TweenInfo.new(.25), {ImageTransparency = 1}):Play()
	wait(.125)
	TS:Create(LeftFrame, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(-0.3, 0, 0.05,0)}):Play()
	TS:Create(RightFrame, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1.3, 0, 0.05,0)}):Play()
	TS:Create(CustomizationsLabel, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, -0.25,0)}):Play()
	wait(.35)
	Transitioning()
	wait(0.65 + (XFrames + YFrames) * 0.03)
	Focus.Visible = false
	HomeScreen = true
	spawn(InterpolateCam)
	wait(.25)
	TS:Create(Play.Parent:WaitForChild("Frame"), TweenInfo.new(1), {Position = UDim2.new(0.57, 0, .85, 0)}):Play()
	TS:Create(Play, TweenInfo.new(1), {Position = UDim2.new(0.57, 0, .84, 0)}):Play()
	TS:Create(New.Parent:WaitForChild("Frame"), TweenInfo.new(1), {Position = UDim2.new(0.18, 0, .85, 0)}):Play()
	TS:Create(New, TweenInfo.new(1), {Position = UDim2.new(0.18, 0, .84, 0)}):Play()
	wait(1)
	New.Active = true
	Play.Active = true
end)

Create.Activated:Connect(function()
	Create.Active = false
	Back.Active = false
	TS:Create(Create, TweenInfo.new(.05), {Position = UDim2.new(0.5, 0, .825, 0)}):Play()
	wait(.05)
	TS:Create(Create, TweenInfo.new(.1), {Position = UDim2.new(0.5, 0, .818, 0)}):Play()
end)