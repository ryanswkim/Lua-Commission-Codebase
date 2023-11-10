-- Services:
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Config:
local MAX_CALLS_PER_SECOND = 3
local DEBOUNCE_THRESHOLD = 5

-- Modules:
local Modules = ReplicatedStorage:WaitForChild("Modules")
local UI = require(Modules:WaitForChild("UI"))
local DisplayInfo = require(Modules:WaitForChild("DisplayInfo"))

-- Remotes:
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Display = Remotes:WaitForChild("Display")
local TransferItem = Remotes:WaitForChild("TransferItem")
local ItemDrop = Remotes:WaitForChild("ItemDrop")
local RightClickItemOptions = Remotes:WaitForChild("RightClickItemOptions")

-- Player instances:
local Player = Players.LocalPlayer
local Health = Player:WaitForChild("Values"):WaitForChild("Health")
local Mouse = Player:GetMouse()

-- GUI Instances:
local ZXCV = script.Parent
local Main = script.Parent.Parent:WaitForChild("Main")
local InteractText = Main:WaitForChild("Interact")

local MainFrame = ZXCV:WaitForChild("MainFrame")
local Left = MainFrame:WaitForChild("Left")
local Right = MainFrame:WaitForChild("Right")

local RightClickFrame = ZXCV:WaitForChild("RightClickFrame")
local Top = RightClickFrame:WaitForChild("Top")
local Bottom = RightClickFrame:WaitForChild("Bottom")

local DescriptionFrame = Left:WaitForChild("Description")
local EquipsFrame = Left:WaitForChild("Equips")
local VanityFrame = Left:WaitForChild("Vanity")

local Z = Right:WaitForChild("Z")
local X = Right:WaitForChild("X")
local C = Right:WaitForChild("C")
local V = Right:WaitForChild("V")

local EquipmentInventoryFrame = Z:WaitForChild("EquipmentInventory")
local CollectibleInventoryFrame = Z:WaitForChild("CollectibleInventory")

-- Updating description:
local function UpdateInfoBox(Name, Description, Category, Rarity)
	if Rarity == -1 then 
		DescriptionFrame:WaitForChild("Name").Text = ""
		DescriptionFrame:WaitForChild("Information").Text = "" 
		DescriptionFrame:WaitForChild("Name"):WaitForChild("Underline").Visible = false
	else
		local RarityText = UI:FindRarityText(Rarity)
		DescriptionFrame:WaitForChild("Name").Text = Name
		DescriptionFrame:WaitForChild("Information").Text = Description .. ". " .. RarityText .. " " .. Category .. " Item" 
		DescriptionFrame:WaitForChild("Name"):WaitForChild("Underline").Visible = true
		local RarityColor = UI:FindTextRarityColor(Rarity)
		DescriptionFrame:WaitForChild("Name").TextColor3 = RarityColor
		DescriptionFrame:WaitForChild("Information").TextColor3 = RarityColor		
	end
end

local CurrentItem
local CurrentFrame
local Mouse1Connections = {}
local Mouse2Connections = {}

-- Main update function for each inventory icon:
local function Update(NewInfo, Frame, TopLabel, BottomLabel)
	for i,v in pairs(NewInfo) do
		local ItemName = v["Item"]
		if not DisplayInfo["Items"][ItemName] then
			ItemName = "Placeholder"
		end
		Frame:WaitForChild("Items"):WaitForChild(i):WaitForChild("Display").Image = DisplayInfo["Items"][ItemName]["Image"]
		Frame:WaitForChild("Items"):WaitForChild(i):WaitForChild("CountLabel").Text = "x" .. tostring(v["Count"])
		if v["Count"] <= 1 then
			Frame:WaitForChild("Items"):WaitForChild(i):WaitForChild("CountLabel").TextTransparency = 1
			Frame:WaitForChild("Items"):WaitForChild(i):WaitForChild("CountLabel").TextStrokeTransparency = 1
		else
			Frame:WaitForChild("Items"):WaitForChild(i):WaitForChild("CountLabel").TextTransparency = 0
			Frame:WaitForChild("Items"):WaitForChild(i):WaitForChild("CountLabel").TextStrokeTransparency = 0
		end
		
		if Mouse1Connections[Frame] and Mouse1Connections[Frame][i] then 
			Mouse1Connections[Frame][i]:Disconnect() 
		elseif not Mouse1Connections[Frame] then
			Mouse1Connections[Frame] = {}
		end
		Mouse1Connections[Frame][i] = Frame:WaitForChild("Items"):WaitForChild(i):WaitForChild("Display").MouseButton1Down:Connect(function()
			UpdateInfoBox(DisplayInfo["Items"][ItemName]["Name"], DisplayInfo["Items"][ItemName]["Description"], DisplayInfo["Items"][ItemName]["Category"], DisplayInfo["Items"][ItemName]["Rarity"])
		end)
		
		if Mouse2Connections[Frame] and Mouse2Connections[Frame][i] then 
			Mouse2Connections[Frame][i]:Disconnect() 
		elseif not Mouse2Connections[Frame] then
			Mouse2Connections[Frame] = {}
		end
		Mouse2Connections[Frame][i] = Frame:WaitForChild("Items"):WaitForChild(i):WaitForChild("Display").MouseButton2Down:Connect(function()
			if ItemName ~= "None" then
				CurrentItem = i
				CurrentFrame = Frame
				RightClickFrame.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
				Top:WaitForChild("Label").Text = TopLabel
			end
		end)	
	end
end

-- Drop/equip/unequip/use item:
local function RightClickFunction(NewInfoTable)
	for i,v in pairs(NewInfoTable) do
		local TopLabel
		local BottomLabel = "Drop"
		local FrameToUpdate
		if i == "Equips" then
			FrameToUpdate = EquipsFrame
			TopLabel = "Unequip"
		elseif i == "Vanity" then
			FrameToUpdate = VanityFrame
			TopLabel = "Unequip"
		elseif i == "EquipmentInventory" then
			FrameToUpdate = EquipmentInventoryFrame
			TopLabel = "Equip"
		else
			FrameToUpdate = CollectibleInventoryFrame
			TopLabel = "Use"
		end
		Update(v, FrameToUpdate, TopLabel, BottomLabel)
	end
end

local function InvokeRightClick(Button)
	local ActiveLeft
	if EquipsFrame.Visible then
		ActiveLeft = "Equips"
	elseif VanityFrame.Visible then
		ActiveLeft = "Vanity"
	end
	if not ActiveLeft or not Button:FindFirstChild("Label") then return end
	local Command = Button.Label.Text
	if Command ~= "Equip" and Command ~= "Unequip" and Command ~= "Drop" and Command ~= "Use" then return end
	
	local NewInfoTable = RightClickItemOptions:InvokeServer(Command, CurrentItem, tostring(CurrentFrame), ActiveLeft)
	if NewInfoTable then
		RightClickFunction(NewInfoTable)
	end
end
Bottom.Activated:Connect(function()
	InvokeRightClick(Bottom)
end)
Top.Activated:Connect(function()
	InvokeRightClick(Top)
end)

-- Items:
local debounce = 0

UIS.InputBegan:Connect(function(Input, GPE)
	if GPE or Input.KeyCode ~= Enum.KeyCode.E then return end
	if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") or Health.Value <= 0 then return end --Invalid
	if debounce > DEBOUNCE_THRESHOLD then return end --"Please wait"
	if ZXCV.Enabled then return end --"Can not pick up items while looking through inventory"
	if Mouse.Target and Mouse.Target:FindFirstAncestor("Items") then
		local CurrentItem = Mouse.Target:FindFirstAncestorWhichIsA("Model")
		local CurrentName = CurrentItem:FindFirstChild("Name")
		local CurrentCategory = CurrentItem:FindFirstChild("Category")
		local CurrentCount = CurrentItem:FindFirstChild("Count")
		if not CurrentItem or not CurrentName or not CurrentCategory or not CurrentCount then return end
		
		local NewInfo, Remaining, ItemCategory = TransferItem:InvokeServer(CurrentName.Value, CurrentCategory.Value, CurrentCount.Value)
		if not NewInfo then return end
		debounce = debounce + 1
		if Remaining == 0 then
			local AnimationController = CurrentItem:WaitForChild("AnimationController")
			for i,v in pairs(AnimationController:GetPlayingAnimationTracks()) do
				v:Stop()
			end
			TranslateItem(CurrentItem, true)
		elseif Remaining ~= 0 and Remaining ~= CurrentCount.Value then
			TranslateItem(CurrentItem, false)
			CurrentCount.Value = Remaining
			InteractText.Text = "[E] Pickup " .. CurrentName.Value .. " (" .. CurrentCount.Value .. ")"
		end
		if ItemCategory == "CollectibleInventory" then
			Update(NewInfo, CollectibleInventoryFrame, "Use", "Drop")
		elseif ItemCategory == "EquipmentInventory" then
			Update(NewInfo, EquipmentInventoryFrame, "Equip", "Drop")
		end
	end
end)

function TranslateItem(Item, Destroy)
	if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
	for i,Part in pairs(Item:GetChildren()) do
		if Part:IsA("BasePart") then
			local Effect = Part:Clone()
			Effect.Anchored = true
			for i,v in pairs(Effect:GetChildren()) do
				if v:IsA("BasePart") or v:IsA("Attachment") or v:IsA("ParticleEmitter") then continue end
				v:Destroy()
			end
			Effect.Parent = workspace:WaitForChild("Junk")
			TS:Create(Effect, TweenInfo.new(0.15), {Transparency = 1, Position = Player.Character.HumanoidRootPart.Position}):Play()
			Debris:AddItem(Effect, 0.15)
		end
	end
	if Destroy then
		Item:Destroy()
	end
end

-- Init:
local Equips, Vanity, EquipmentInventory, CollectibleInventory = Display:InvokeServer({"Equips", "Vanity", "EquipmentInventory", "CollectibleInventory",}) 
Update(Equips, EquipsFrame, "Unequip", "Drop")
Update(Vanity, VanityFrame, "Unequip", "Drop")
Update(EquipmentInventory, EquipmentInventoryFrame, "Equip", "Drop")
Update(CollectibleInventory,CollectibleInventoryFrame, "Use", "Drop")

-- Updating debounce:
while wait(1) do
	debounce = math.max(0, debounce - MAX_CALLS_PER_SECOND)
end