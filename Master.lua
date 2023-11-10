local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CAS = game:GetService("ContextActionService")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

----------------------------------------------------
local Main = script.Parent.Parent:WaitForChild("Main")
local ZXCV = script.Parent
local MainFrame = ZXCV:WaitForChild("MainFrame")
local TopBar = MainFrame:WaitForChild("TopBar")
local MainLabel = TopBar:WaitForChild("Label")
local ExitButton = TopBar:WaitForChild("Exit")

local Left = MainFrame:WaitForChild("Left")
local DescriptionFrame = Left:WaitForChild("Description")
local EquipsFrame = Left:WaitForChild("Equips")
local VanityFrame = Left:WaitForChild("Vanity")
local EquipsButton = Left:WaitForChild("EquipsButton")
local VanityButton = Left:WaitForChild("VanityButton")

local Right = MainFrame:WaitForChild("Right")
local Z = Right:WaitForChild("Z")
local X = Right:WaitForChild("X")
local C = Right:WaitForChild("C")
local V = Right:WaitForChild("V")

local EquipmentInventoryFrame = Z:WaitForChild("EquipmentInventory")
local CollectibleInventoryFrame = Z:WaitForChild("CollectibleInventory")
local SkillsInventoryFrame = Z:WaitForChild("SkillsInventory")
local EquipmentInventoryButton = Z:WaitForChild("EquipmentButton")
local CollectibleInventoryButton = Z:WaitForChild("CollectibleButton")
local SkillsButton = Z:WaitForChild("SkillsButton")

local Sidebar = Main:WaitForChild("Sidebar")
local InventoryButton = Sidebar:WaitForChild("Inventory")
local QuestsButton = Sidebar:WaitForChild("Quests")
local StatsButton = Sidebar:WaitForChild("Stats")
local SettingsButton = Sidebar:WaitForChild("Settings")

local RightClickFrame = ZXCV:WaitForChild("RightClickFrame")
local Top = RightClickFrame:WaitForChild("Top")
local Bottom = RightClickFrame:WaitForChild("Bottom")

local Active = {Z = false, X = false, C = false, V = false}
local MainLabelText = {Z = "Inventory", X = "Quests", C = "Stats", V = "Settings"}

local Health = Player:WaitForChild("Values"):WaitForChild("Health")
----------------------------------------------------Opening MainGui
local function Close()
	Active["Z"] = false
	Active["X"] = false
	Active["C"] = false
	Active["V"] = false
	Z.Visible = false
	X.Visible = false
	C.Visible = false
	V.Visible = false
	ZXCV.Enabled = false
end

local function Open(Key)
	Close()
	Active[Key] = true
	Right:WaitForChild(Key).Visible = true
	MainLabel.Text = MainLabelText[Key]
	ZXCV.Enabled = true
end

local Health = Player:WaitForChild("Values"):WaitForChild("Health")
local function Handle(actionName, inputState, inputObj, Key)
	if Health.Value <= 0 then return end
	if inputState == Enum.UserInputState.Begin then
		if Active[Key] then
			Close()
		else
			Open(Key)
		end
	end
end

ZXCV.Changed:Connect(function()
	if not ZXCV.Enabled then
		CAS:UnbindAction("ZXCVFreeze")
		Close()
	elseif ZXCV.Enabled then
		CAS:BindAction("ZXCVFreeze", function() return Enum.ContextActionResult.Sink end, false, unpack(Enum.PlayerActions:GetEnumItems()))
	end
end)

InventoryButton.Activated:Connect(function()
	Handle(nil, Enum.UserInputState.Begin, nil, "Z")	
end)
QuestsButton.Activated:Connect(function()
	Handle(nil, Enum.UserInputState.Begin, nil, "X")	
end)
StatsButton.Activated:Connect(function()
	Handle(nil, Enum.UserInputState.Begin, nil, "C")	
end)
SettingsButton.Activated:Connect(function()
	Handle(nil, Enum.UserInputState.Begin, nil, "V")	
end)
ExitButton.Activated:Connect(Close)

CAS:BindAction("Z", function(actionName, inputState, inputObj) Handle(nil, inputState, nil, "Z") end, false, Enum.KeyCode.Z)
CAS:BindAction("X", function(actionName, inputState, inputObj) Handle(nil, inputState, nil, "X") end, false, Enum.KeyCode.X)
CAS:BindAction("C", function(actionName, inputState, inputObj) Handle(nil, inputState, nil, "C") end, false, Enum.KeyCode.C)
CAS:BindAction("V", function(actionName, inputState, inputObj) Handle(nil, inputState, nil, "V") end, false, Enum.KeyCode.V)

----------------------------------------------------Transitions/FX
VanityButton.Activated:Connect(function()
	VanityButton.Size = UDim2.new(.08, 0, .05, 0)
	EquipsButton.Size = UDim2.new(.07, 0, .04, 0)
	VanityFrame.Visible = true
	EquipsFrame.Visible = false
end)

EquipsButton.Activated:Connect(function()
	EquipsButton.Size = UDim2.new(.08, 0, .05, 0)
	VanityButton.Size = UDim2.new(.07, 0, .04, 0)
	VanityFrame.Visible = false
	EquipsFrame.Visible = true
end)

EquipmentInventoryButton.Activated:Connect(function()
	EquipmentInventoryFrame.Visible = true
	CollectibleInventoryFrame.Visible = false
	SkillsInventoryFrame.Visible = false
	EquipmentInventoryButton.Size = UDim2.new(.235,0,.05,0)
	CollectibleInventoryButton.Size = UDim2.new(.175,0,.04,0)
	SkillsButton.Size = UDim2.new(.175,0,.04,0)
end)

CollectibleInventoryButton.Activated:Connect(function()
	EquipmentInventoryFrame.Visible = false
	CollectibleInventoryFrame.Visible = true
	SkillsInventoryFrame.Visible = false
	EquipmentInventoryButton.Size = UDim2.new(.175,0,.04,0)
	CollectibleInventoryButton.Size = UDim2.new(.235,0,.05,0)
	SkillsButton.Size = UDim2.new(.175,0,.04,0)
end)

SkillsButton.Activated:Connect(function()
	EquipmentInventoryFrame.Visible = false
	CollectibleInventoryFrame.Visible = false
	SkillsInventoryFrame.Visible = true
	EquipmentInventoryButton.Size = UDim2.new(.175,0,.04,0)
	CollectibleInventoryButton.Size = UDim2.new(.175,0,.04,0)
	SkillsButton.Size = UDim2.new(.235,0,.05,0)
end)

----------------------------------------------------Right clicking gridstuff
local OnRightClickFrame = false
UIS.InputBegan:Connect(function(input)
	if ZXCV.Enabled == true and not OnRightClickFrame and input.UserInputType == Enum.UserInputType.MouseButton1 then
		RightClickFrame.Position = UDim2.new(2,0,2,0)
	end
	if input.KeyCode == Enum.KeyCode.Z or input.KeyCode == Enum.KeyCode.X or input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.V then
		RightClickFrame.Position = UDim2.new(2,0,2,0)
	end
end)
RightClickFrame.MouseEnter:Connect(function()
	OnRightClickFrame = true
end)
Top.MouseEnter:Connect(function()
	OnRightClickFrame = true
end)
Bottom.MouseEnter:Connect(function()
	OnRightClickFrame = true
end)
RightClickFrame.MouseLeave:Connect(function()
	OnRightClickFrame = false
end)
Top.MouseLeave:Connect(function()
	OnRightClickFrame = false
end)
Bottom.MouseLeave:Connect(function()
	OnRightClickFrame = false
end)

Health.Changed:Connect(function(NH)
	if NH == 0 then
		ZXCV.Enabled = false
	end
end)