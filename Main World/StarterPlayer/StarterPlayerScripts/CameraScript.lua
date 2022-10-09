-- Services:
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

--Player
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Torso = Character:WaitForChild("Torso")

--Configuration:
local playerSettings = Player:WaitForChild("PlayerScripts"):WaitForChild("Settings")

local xSensitivity = playerSettings:WaitForChild("xSensitivity")
local ySensitivity = playerSettings:WaitForChild("ySensitivity")
local SnapZoom = playerSettings:WaitForChild("SnapZoom")
local SnapRotate = playerSettings:WaitForChild("SnapRotate")
local ScreenshakeRatio = playerSettings:WaitForChild("ScreenshakeRatio")

--Statics:
local TRANSPARENCY_DIST =  1.75
local MAX_ZOOM = 8
local SCROLL_SENSITIVITY = 1
local WORLD_OFFSET = Vector3.new(0, 1.25, 0)
local LOCAL_OFFSET = Vector3.new(1.85, -1.05, 9.5)

--Variables:
local zoom = MAX_ZOOM
local camera = workspace.CurrentCamera
local xAngle = script:WaitForChild("xAngle")
xAngle.Value = 0
local yAngle = 0
local cameraLocked = script:WaitForChild("CameraLocked")

------------------------------------Functions------------------------------------

--Transparency when zooming in
local CharacterParts = {}
local TransparencyValues = {}
local function AppendCharacterParts(Object)
	table.insert(CharacterParts, #CharacterParts + 1, Object)
	table.insert(TransparencyValues, #TransparencyValues + 1, Object.Transparency)
	
	Object:GetPropertyChangedSignal("Name"):Connect(function()
		if tonumber(Object.Name) then
			for i,v in pairs(CharacterParts) do
				if v == Object then
					TransparencyValues[i] = tonumber(Object.Name)
				end
			end
		end
	end)
	
	Object.AncestryChanged:Connect(function(_, Parent)
		if not Parent then
			for i,v in pairs(CharacterParts) do
				if v == Object then
					table.remove(CharacterParts, i)
					table.remove(TransparencyValues, i)
					break
				end
			end
		end
	end)
end

for i,Object in pairs(Character:GetDescendants()) do
	if Object:IsA("BasePart") then
		AppendCharacterParts(Object)
	end
end
Character.DescendantAdded:Connect(function(Object)
	if Object:IsA("BasePart") then
		AppendCharacterParts(Object)
	end
end)

--Mouse moving and scrolling
local zoomValue = script:WaitForChild("Zoom")
zoomValue.Value = zoom
UIS.InputChanged:Connect(function(Input, processed)
	if processed then return end
	if Input.UserInputType == Enum.UserInputType.MouseMovement then
		local Delta = Input.Delta
		local DX = Delta.X
		local DY = Delta.Y
		
		xAngle.Value = math.fmod((xAngle.Value - DX * xSensitivity.Value + 360), 360)
		yAngle = math.clamp(yAngle - DY * ySensitivity.Value, -80, 80)
	elseif Input.UserInputType == Enum.UserInputType.MouseWheel then
		if Input.Position.Z == 1 then
			zoom = math.max(0, zoom - SCROLL_SENSITIVITY)
		else
			zoom = math.min(MAX_ZOOM, zoom + SCROLL_SENSITIVITY)
		end
		
		if SnapZoom.Value then
			zoomValue.Value = zoom
		else
			TS:Create(zoomValue, TweenInfo.new(0.2), {Value = zoom}):Play()
		end
	end
end)

--Character rotate toggling	
local _, tempX, _ = HRP.CFrame:ToEulerAnglesYXZ()
local tempXAngle = xAngle.Value

UIS.InputBegan:Connect(function(Input, processed)
	if processed then return end 
	if Input.KeyCode == Enum.KeyCode.LeftShift then
		if cameraLocked.Value then
			_, tempX, _ = HRP.CFrame:ToEulerAnglesYXZ()
			tempXAngle = xAngle.Value
		else
			local _, curX, _ = HRP.CFrame:ToEulerAnglesYXZ()
			local newX = tempXAngle + math.deg(curX - tempX)
			
			if SnapRotate.Value then
				xAngle.Value = math.fmod(newX, 360)
			else
				if math.abs(newX - xAngle.Value) > 180 then
					if newX > xAngle.Value then
						while newX > xAngle.Value do
							newX = newX - 360
						end
					else
						while xAngle.Value > newX do
							xAngle.Value = xAngle.Value - 360
						end
					end
				end
				TS:Create(xAngle, TweenInfo.new(.3), {Value = newX}):Play()
				wait(.31)
			end		
		end
		cameraLocked.Value = not cameraLocked.Value
	end
end)

--ZXCV Camera Mode
local function UpdateZXCV()
	if Torso.Transparency ~= 0 then
		for i,v in pairs(CharacterParts) do
			v.Transparency = TransparencyValues[i]
		end
	end
	UIS.MouseBehavior = Enum.MouseBehavior.Default
	camera.CameraSubject = HRP
	camera.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(180), 0) + HRP.CFrame.LookVector * 11 + Vector3.new(0,1,0)
end

--Default Camera Mode
local function UpdateDefault()
	UIS.MouseBehavior = Enum.MouseBehavior.LockCenter --Necessary for mouse to stay stationary
	camera.CameraSubject = HRP --Subject is always humanoidrootpart
	
	local rootPos = HRP.Position
	--Horizontal angle
	local xAngleCFrame = CFrame.Angles(0, math.rad(xAngle.Value), 0) 
	
	--Applied vertical angle
	local anglesCFrame = xAngleCFrame:ToWorldSpace(CFrame.Angles(math.rad(yAngle), 0, 0)) 
	
	--Camera's position before checking for parts between subject and camera
	local endCF = CFrame.new(HRP.Position + WORLD_OFFSET) * anglesCFrame * CFrame.new(LOCAL_OFFSET) 
	
	--Ray from head to initial camera position to find final position
	local dir = CFrame.new(rootPos, endCF.Position).LookVector 
	local PopperRay = Ray.new(rootPos + WORLD_OFFSET, dir * zoomValue.Value)
	local hit, finalPos = workspace:FindPartOnRayWithIgnoreList(PopperRay, {Character, workspace.Junk, workspace.Items})
	if hit then
		finalPos = (rootPos + WORLD_OFFSET):Lerp(finalPos, 0.98)
		--finalPos = rootPos + (finalPos - rootPos).Unit * (finalPos - rootPos).Magnitude * 0.98
	end
	
	--Reapply camera angle
	local cameraCFrame = CFrame.new(finalPos):ToWorldSpace(anglesCFrame)
	
	--Update camera focus (rendering details)
	--local cameraFocus = cameraCFrame:ToWorldSpace(CFrame.new(0, 0, -LOCAL_OFFSET.Z))
	
    --Assign focus and CFrame
    --camera.Focus = cameraFocus
	camera.CFrame = cameraCFrame

	if (cameraCFrame.Position - (rootPos + WORLD_OFFSET)).Magnitude < TRANSPARENCY_DIST then
		local magnitude = (cameraCFrame.Position - (rootPos + WORLD_OFFSET)).Magnitude
		local transparency
		if math.max(magnitude, 1) == magnitude then
			transparency = (TRANSPARENCY_DIST - magnitude)/(TRANSPARENCY_DIST - 1)
		else
			transparency = 1
		end
		for i,v in pairs(CharacterParts) do
			v.Transparency = math.clamp(TransparencyValues[i] + transparency, 0, 1)
		end
	else
		if Torso.Transparency ~= 0 then
			for i,v in pairs(CharacterParts) do
				if tonumber(v.Name) and tonumber(v.Name) == math.clamp(tonumber(v.Name), 0, 1) then
					TransparencyValues[i] = tonumber(v.Name)
				end
				v.Transparency = TransparencyValues[i]
			end
		end
	end
	
	--Rotate character
	if cameraLocked.Value then
		local primaryPartCFrame = Character:GetPrimaryPartCFrame()
    	local newCFrame = CFrame.new(primaryPartCFrame.Position):ToWorldSpace(xAngleCFrame)
    	Character:SetPrimaryPartCFrame(newCFrame)
	end
end 

--Screenshake
local Screenshake = Player:WaitForChild("Gameplay"):WaitForChild("Screenshake")
local function SS()
	camera.CoordinateFrame = camera.CoordinateFrame * CFrame.new((math.random(-Screenshake.Value,Screenshake.Value)/1000), (math.random(-Screenshake.Value,Screenshake.Value)/1000), 0) 
	Screenshake.Value = Screenshake.Value * .95
	if Screenshake.Value < 75 then
		Screenshake.Value = 0
	end
end	

--Binding
local PG = Player.PlayerGui
local ZXCV = PG:WaitForChild("ZXCV")
RS.RenderStepped:Connect(function()
	if ZXCV.Enabled then
		UpdateZXCV()
	else
		UpdateDefault()
	end
	
	if Screenshake.Value > 0 then
		SS()
	end
end)