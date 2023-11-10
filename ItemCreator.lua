local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local Drops = workspace:WaitForChild("Items"):WaitForChild("Drops")
local Player = Players.LocalPlayer

-----------------------------------------------------------------------Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local UI = require(Modules:WaitForChild("UI"))
local DisplayInfo = require(Modules:WaitForChild("DisplayInfo"))

-----------------------------------------------------------------------Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ItemDrop = Remotes:WaitForChild("ItemDrop")

-----------------------------------------------------------------------Vars
local Mouse = Player:GetMouse()
Mouse.TargetFilter = workspace:WaitForChild("Junk")
local Main = script.Parent.Parent.Parent:WaitForChild("Main")
local ZXCV = script.Parent.Parent
local InteractText = Main:WaitForChild("Interact")

-----------------------------------------------------------------------Instances
local ItemCount = Instance.new("IntValue")
ItemCount.Name = "Count"

local ItemID = Instance.new("IntValue")
ItemID.Name = "ID"

local ItemCategory = Instance.new("StringValue")
ItemCategory.Name = "Category"

local ItemName = Instance.new("StringValue")
ItemName.Name = "Name"

-----------------------------------------------------------------------Funcs
local IDIndex = 0
ItemDrop.OnClientEvent:Connect(function(pos, Category, Name, Count)
	local Rarity = DisplayInfo["Items"][Name]["Rarity"]
	local Item = ReplicatedStorage:WaitForChild("Effects"):WaitForChild("Item"):Clone()
	Item:SetPrimaryPartCFrame(CFrame.new(Vector3.new(pos:match("(.+), (.+), (.+)"))))
	
	local RarityColor = UI:FindRarityColor(Rarity)
	local Outer = Item:WaitForChild("Outer")
	local Inner = Item:WaitForChild("Inner")
	local Particle = Inner:WaitForChild("A"):WaitForChild("P")
	
	Outer.Color = RarityColor
	Inner.Color = RarityColor
	Particle.Color = ColorSequence.new(RarityColor)
	Particle.Rate, Particle.LightEmission = UI:FindParticleInfo(Rarity)
	
	local CountClone = ItemCount:Clone()
	CountClone.Value = Count
	local IDClone = ItemID:Clone()
	IDClone.Value = IDIndex
	local CategoryClone = ItemCategory:Clone()
	CategoryClone.Value = Category
	local NameClone = ItemName:Clone()
	NameClone.Value = Name
	
	CategoryClone.Parent = Item
	NameClone.Parent = Item
	IDClone.Parent = Item
	CountClone.Parent = Item
	
	Item:WaitForChild("Root").Anchored = true
	Item.Parent = Drops
	
	IDIndex = IDIndex + 1
end)


local function UpdateInteractText()
	if ZXCV.Enabled or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") or not Mouse.Target 
	or (Mouse.Target.Position - Player.Character.HumanoidRootPart.Position).magnitude > 6.5 then
		if InteractText.TextTransparency ~= 1 then
			TS:Create(InteractText, TweenInfo.new(.225, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1, TextStrokeTransparency = 1}):Play() 
		end 
		return
	end
	
	local Target = Mouse.Target
	if Target:FindFirstAncestor("Drops") then
		local Item = Mouse.Target:FindFirstAncestorWhichIsA("Model")
		local Name = Item:FindFirstChild("Name")
		local Category = Item:FindFirstChild("Category")
		local ID = Item:FindFirstChild("ID")
		local Count = Item:FindFirstChild("Count")
		if not Item or not Name or not Category or not ID or not Count then return end
		
		local ItemName = DisplayInfo["Items"][Name.Value or "None"]["Name"] or ""
		InteractText.Text = "[E] Pickup " .. ItemName .. " (" .. Count.Value .. ")"
		TS:Create(InteractText, TweenInfo.new(.225, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0, TextStrokeTransparency = 0}):Play() 
	elseif Mouse.Target:FindFirstAncestor("NPCs") then
		InteractText.Text = "[E] Interact"
		TS:Create(InteractText, TweenInfo.new(.225, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0, TextStrokeTransparency = 0}):Play() 
	else
		TS:Create(InteractText, TweenInfo.new(.225, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1, TextStrokeTransparency = 1}):Play() 
	end
end

RS.RenderStepped:Connect(UpdateInteractText)