--Default configurations:
local X_SENSITIVITY = 0.4
local Y_SENSITIVITY = 0.4
local SNAP_ROTATE = true
local SNAP_ZOOM = true
local SCREENSHAKE_RATIO = 1
local RENDER_DISTANCE = 200

--Services:
local Players = game:GetService("Players")

--Instances:
local Player = Players.LocalPlayer
local PG = Player:WaitForChild("PlayerGui")

local xSensitivity = script:WaitForChild("xSensitivity")
local ySensitivity = script:WaitForChild("ySensitivity")
local snapZoom = script:WaitForChild("SnapZoom")
local snapRotate = script:WaitForChild("SnapRotate")
local screenshakeRatio = script:WaitForChild("ScreenshakeRatio")
local renderDistance = script:WaitForChild('RenderDistance')

--Init
xSensitivity.Value = X_SENSITIVITY
ySensitivity.Value = Y_SENSITIVITY
snapZoom.Value = SNAP_ZOOM
snapRotate.Value = SNAP_ROTATE
screenshakeRatio.Value = SCREENSHAKE_RATIO
renderDistance.Value = RENDER_DISTANCE