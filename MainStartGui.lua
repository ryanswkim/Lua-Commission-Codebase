--Globals
local RS = game:GetService("ReplicatedStorage")
local Character = workspace:WaitForChild("Customize"):WaitForChild("Model")
local Head = Character:WaitForChild("Head")

local function SetColors(Group, Color, ButtonsFolder)
	for i,v in pairs(ButtonsFolder:GetChildren()) do
		if v:IsA("GuiObject") then
			if v.Name == tostring(Color) then
				v.BorderSizePixel = 2
				v.BorderColor3 = Color3.new(1,1,1)
			else
				v.BorderSizePixel = 0
			end
		end
	end
	for i,v in pairs(Group) do
		v.BrickColor = BrickColor.new(tostring(Color))
	end
end

--Datatables
local BodyParts = {Character:WaitForChild("Head"), Character:WaitForChild("LeftArm"), Character:WaitForChild("RightArm"), Character:WaitForChild("Torso"), Character:WaitForChild("LeftLeg"), Character:WaitForChild("RightLeg")}
local EyeParts = {Character:WaitForChild("Head"):WaitForChild("LeftEye"), Character:WaitForChild("Head"):WaitForChild("RightEye")}
local ReturnSettings = {BodyColor = "Dark stone grey", EyeColor = "Really black", HairColor = "Really black", HairType = 0, PrimaryFacialHairType = 0, SecondaryFacialHairType = 0}

--Data
local Data = RS:WaitForChild("GetData"):InvokeServer()
local ExistingLoad
if Data then
	ExistingLoad = true
	ReturnSettings = Data["Character"]
end

ReturnSettings["ShoeColor"] = "Black"
ReturnSettings["ShoeType"] = 0
ReturnSettings["ClothingColor"] = "Black"
ReturnSettings["ClothingType"] = 0

--Body/Eye Colors
local Selections = script.Parent:WaitForChild("Selections")
local LeftFrame = Selections:WaitForChild("LeftFrame")
local RightFrame = Selections:WaitForChild("RightFrame")
local BodyColorButtons = LeftFrame:WaitForChild("BodyColors"):WaitForChild("Colors"):WaitForChild("Buttons")
local EyeColorButtons = LeftFrame:WaitForChild("EyeColors"):WaitForChild("Colors"):WaitForChild("Buttons")

for i,Button in pairs(BodyColorButtons:GetChildren()) do
	if Button:IsA("TextButton") then
		Button.Activated:Connect(function()
			local BodyColor = BrickColor.new(Button.Name)
			ReturnSettings["BodyColor"] = BodyColor
			SetColors(BodyParts, BodyColor, BodyColorButtons)
		end)
	end
end

for i,Button in pairs(EyeColorButtons:GetChildren()) do
	if Button:IsA("TextButton") then
		Button.Activated:Connect(function()
			local EyeColor = BrickColor.new(Button.Name)
			ReturnSettings["EyeColor"] = EyeColor
			SetColors(EyeParts, EyeColor, EyeColorButtons)
		end)
	end
end

--Hairs
local HairColors = RightFrame:WaitForChild("HairColors"):WaitForChild("Colors"):WaitForChild("Buttons")
local HairTypes = RightFrame:WaitForChild("HairTypes")
local HairTypeLeft = HairTypes:WaitForChild("Left")
local HairTypeRight = HairTypes:WaitForChild("Right")
local HairTypeNumber = HairTypes:WaitForChild("Number")
local RSHairs = RS:WaitForChild("Hairs")

local function UpdateHair(Color, Type)
	HairTypeNumber.Text = Type
	if Character:FindFirstChild("HairTag", true) then
		Character:FindFirstChild("HairTag", true).Parent:Destroy()
	end
	
	if type(Type) == "number" and Type ~= 0 then
		local NewClone = RSHairs:WaitForChild(Type):Clone()
		for i,v in pairs(NewClone:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
				v.Anchored = false
			end
		end
		local NewTag = Instance.new("StringValue")
		NewTag.Name = "HairTag"
		NewTag.Parent = NewClone
		NewClone:SetPrimaryPartCFrame(Head.CFrame)
		NewClone:WaitForChild("Anchor"):WaitForChild("Weld").Part0 = Head
		NewClone:WaitForChild("Model").BrickColor = BrickColor.new(tostring(Color))
		NewClone.Parent = Character
	end
end

HairTypeLeft.Activated:Connect(function()
	if ReturnSettings["HairType"] == 0 then
		ReturnSettings["HairType"] = #RSHairs:GetChildren()
	else
		ReturnSettings["HairType"] = ReturnSettings["HairType"] - 1
	end
	UpdateHair(ReturnSettings["HairColor"], ReturnSettings["HairType"])
end)

HairTypeRight.Activated:Connect(function()
	if ReturnSettings["HairType"] == #RSHairs:GetChildren() then
		ReturnSettings["HairType"] = 0
	else
		ReturnSettings["HairType"] = ReturnSettings["HairType"] + 1
	end
	HairTypeNumber.Text = ReturnSettings["HairType"]
	UpdateHair(ReturnSettings["HairColor"], ReturnSettings["HairType"])
end)

--Primary Facial Hairs
local RSFacialHairs = RS:WaitForChild("FacialHairs")
local PrimaryHairFacialTypes = RightFrame:WaitForChild("PrimaryFacialHairTypes")
local PrimaryHairFacialTypesLeft = PrimaryHairFacialTypes:WaitForChild("Left")
local PrimaryHairFacialTypesRight = PrimaryHairFacialTypes:WaitForChild("Right")
local PrimaryHairFacialTypesNumber = PrimaryHairFacialTypes:WaitForChild("Number")

local function UpdateFacialHair(Color, Type, Label, Tag, Storage)
	Label.Text = Type
	if Character:FindFirstChild(Tag, true) then
		Character:FindFirstChild(Tag, true).Parent:Destroy()
	end
	
	if type(Type) == "number" and Type ~= 0 then
		local NewClone = Storage:WaitForChild(Type):Clone()
		for i,v in pairs(NewClone:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
				v.Anchored = false
			end
		end
		local NewTag = Instance.new("StringValue")
		NewTag.Name = Tag
		NewTag.Parent = NewClone
		NewClone:SetPrimaryPartCFrame(Head.CFrame)
		NewClone:WaitForChild("Anchor"):WaitForChild("Weld").Part0 = Head
		NewClone:WaitForChild("Model").BrickColor = BrickColor.new(tostring(Color))
		NewClone.Parent = Character
	end
end 

PrimaryHairFacialTypesLeft.Activated:Connect(function()
	if ReturnSettings["PrimaryFacialHairType"] == 0 then
		ReturnSettings["PrimaryFacialHairType"] = #RSFacialHairs:GetChildren()
	else
		ReturnSettings["PrimaryFacialHairType"] = ReturnSettings["PrimaryFacialHairType"] - 1
	end
	UpdateFacialHair(ReturnSettings["HairColor"], ReturnSettings["PrimaryFacialHairType"], PrimaryHairFacialTypesNumber, "PrimaryFacialHairTag", RSFacialHairs)
end)

PrimaryHairFacialTypesRight.Activated:Connect(function()
	if ReturnSettings["PrimaryFacialHairType"] == #RSFacialHairs:GetChildren() then
		ReturnSettings["PrimaryFacialHairType"] = 0
	else
		ReturnSettings["PrimaryFacialHairType"] = ReturnSettings["PrimaryFacialHairType"] + 1
	end
	UpdateFacialHair(ReturnSettings["HairColor"], ReturnSettings["PrimaryFacialHairType"], PrimaryHairFacialTypesNumber, "PrimaryFacialHairTag", RSFacialHairs)
end)


--Secondary Facial Hairs
local SecondaryHairFacialTypes = RightFrame:WaitForChild("SecondaryFacialHairTypes")
local SecondaryHairFacialTypesLeft = SecondaryHairFacialTypes:WaitForChild("Left")
local SecondaryHairFacialTypesRight = SecondaryHairFacialTypes:WaitForChild("Right")
local SecondaryHairFacialTypesNumber = SecondaryHairFacialTypes:WaitForChild("Number")

SecondaryHairFacialTypesLeft.Activated:Connect(function()
	if ReturnSettings["SecondaryFacialHairType"] == 0 then
		ReturnSettings["SecondaryFacialHairType"] = #RSFacialHairs:GetChildren()
	else
		ReturnSettings["SecondaryFacialHairType"] = ReturnSettings["SecondaryFacialHairType"] - 1
	end
	UpdateFacialHair(ReturnSettings["HairColor"], ReturnSettings["SecondaryFacialHairType"], SecondaryHairFacialTypesNumber, "SecondaryFacialHairTag", RSFacialHairs)
end)

SecondaryHairFacialTypesRight.Activated:Connect(function()
	if ReturnSettings["SecondaryFacialHairType"] == #RSFacialHairs:GetChildren() then
		ReturnSettings["SecondaryFacialHairType"] = 0
	else
		ReturnSettings["SecondaryFacialHairType"] = ReturnSettings["SecondaryFacialHairType"] + 1
	end
	UpdateFacialHair(ReturnSettings["HairColor"], ReturnSettings["SecondaryFacialHairType"], SecondaryHairFacialTypesNumber, "SecondaryFacialHairTag", RSFacialHairs)
end)

--Hair Colors
for i,Button in pairs(HairColors:GetChildren()) do
	if Button:IsA("TextButton") then
		Button.Activated:Connect(function()
			for i,v in pairs(HairColors:GetChildren()) do
				if v == Button then
					v.BorderSizePixel = 2
					v.BorderColor3 = Color3.new(1,1,1)
				else
					if v:IsA("GuiObject") then
						v.BorderSizePixel = 0
					end
				end
			end
			ReturnSettings["HairColor"] = BrickColor.new(Button.Name)
			UpdateFacialHair(ReturnSettings["HairColor"], ReturnSettings["PrimaryFacialHairType"], PrimaryHairFacialTypesNumber, "PrimaryFacialHairTag", RSFacialHairs)
			UpdateFacialHair(ReturnSettings["HairColor"], ReturnSettings["SecondaryFacialHairType"], SecondaryHairFacialTypesNumber, "SecondaryFacialHairTag", RSFacialHairs)
			UpdateHair(ReturnSettings["HairColor"], ReturnSettings["HairType"])
		end)
	end
end

--Clothing
local ClothingColors = RightFrame:WaitForChild("ClothingColors")
local ClothingTypes = RightFrame:WaitForChild("ClothingTypes")
local RSClothes = RS:WaitForChild("Clothes")

local function UpdateClothes(Color, Type)
	ClothingTypes:WaitForChild("Number").Text = Type
	for i,v in pairs(ClothingColors:WaitForChild("Colors"):WaitForChild("Buttons"):GetChildren()) do
		if v.Name == tostring(Color) then
			v.BorderSizePixel = 2
			v.BorderColor3 = Color3.new(1,1,1)
		else
			if v:IsA("GuiObject") then
				v.BorderSizePixel = 0
			end
		end
	end
	if Character:FindFirstChild("ClothesTag", true) then
		Character:FindFirstChild("ClothesTag", true).Parent:Destroy()
	end
	
	if type(Type) == "number" and Type ~= 0 then
		local ClothingModel = RSClothes:WaitForChild(Type):WaitForChild(Color):Clone()
		for i,v in pairs(ClothingModel:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
				v.Anchored = false
			end
		end
		local ClothesTag = Instance.new("StringValue")
		ClothesTag.Name = "ClothesTag"
		ClothesTag.Parent = ClothingModel
		ClothingModel.Parent = Character
		for i,v in pairs(ClothingModel:GetChildren()) do
			if v.ClassName == "Model" then
				local Part0 = v:WaitForChild("Part0").Value
				local Weld = v:WaitForChild("Anchor"):WaitForChild("Weld")
				Weld.Part1 = v:WaitForChild("Anchor")
				v:SetPrimaryPartCFrame(Character[Part0].CFrame)
				Weld.Part0 = Character[Part0]
			end
		end
	end
end

ClothingTypes:WaitForChild("Left").Activated:Connect(function()
	if ReturnSettings["ClothingType"] == 0 then
		ReturnSettings["ClothingType"] = #RSClothes:GetChildren()
	else
		ReturnSettings["ClothingType"] = ReturnSettings["ClothingType"] - 1
	end
	UpdateClothes(ReturnSettings["ClothingColor"], ReturnSettings["ClothingType"])
end)

ClothingTypes:WaitForChild("Right").Activated:Connect(function()
	if ReturnSettings["ClothingType"] == #RSClothes:GetChildren() then
		ReturnSettings["ClothingType"] = 0
	else
		ReturnSettings["ClothingType"] = ReturnSettings["ClothingType"] + 1
	end
	UpdateClothes(ReturnSettings["ClothingColor"], ReturnSettings["ClothingType"])
end)

for i,Button in pairs(ClothingColors:WaitForChild("Colors"):WaitForChild("Buttons"):GetChildren()) do
	if Button:IsA("TextButton") then
		Button.Activated:Connect(function()
			ReturnSettings["ClothingColor"] = Button.Name
			UpdateClothes(ReturnSettings["ClothingColor"], ReturnSettings["ClothingType"])
		end)
	end
end

--Shoes
local ShoeTypes = LeftFrame:WaitForChild("ShoeTypes")
local ShoeTypeLeft = ShoeTypes:WaitForChild("Left")
local ShoeTypeRight = ShoeTypes:WaitForChild("Right")
local ShoeTypeNumber = ShoeTypes:WaitForChild("Number")
local ShoeColors = LeftFrame:WaitForChild("ShoeColors")
local RSShoes = RS:WaitForChild("Shoes")

local function UpdateShoes(Color, Type)
	ShoeTypes:WaitForChild("Number").Text = Type
	for i,v in pairs(ShoeColors:WaitForChild("Colors"):WaitForChild("Buttons"):GetChildren()) do
		if v.Name == tostring(Color) then
			v.BorderSizePixel = 2
			v.BorderColor3 = Color3.new(1,1,1)
		else
			if v:IsA("GuiObject") then
				v.BorderSizePixel = 0
			end
		end
	end
	
	if Character:FindFirstChild("ShoeTag", true) then
		Character:FindFirstChild("ShoeTag", true).Parent:Destroy()
	end
	
	if type(Type) == "number" and Type ~= 0 then
		local ShoeModel = RSShoes:WaitForChild(Type):WaitForChild(Color):Clone()
		for i,v in pairs(ShoeModel:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
				v.Anchored = false
			end
		end
		local ShoeTag = Instance.new("StringValue")
		ShoeTag.Name = "ShoeTag"
		ShoeTag.Parent = ShoeModel
		ShoeModel.Parent = Character
		for i,v in pairs(ShoeModel:GetChildren()) do
			if v:IsA("Model") then
				local Part0 = v:WaitForChild("Part0").Value
				local Weld = v:WaitForChild("Anchor"):WaitForChild("Weld")
				Weld.Part1 = v:WaitForChild("Anchor")
				v:SetPrimaryPartCFrame(Character[Part0].CFrame)
				Weld.Part0 = Character[Part0]
			end
		end
	end
end

ShoeTypeLeft.Activated:Connect(function()
	if ReturnSettings["ShoeType"] == 0 then
		ReturnSettings["ShoeType"] = #RSShoes:GetChildren()
	else
		ReturnSettings["ShoeType"] = ReturnSettings["ShoeType"] - 1
	end
	ShoeTypeNumber.Text = ReturnSettings["ShoeType"]
	UpdateShoes(ReturnSettings["ShoeColor"], ReturnSettings["ShoeType"])
end)

ShoeTypeRight.Activated:Connect(function()
	if ReturnSettings["ShoeType"] == #RSShoes:GetChildren() then
		ReturnSettings["ShoeType"] = 0
	else
		ReturnSettings["ShoeType"] = ReturnSettings["ShoeType"] + 1
	end
	ShoeTypeNumber.Text = ReturnSettings["ShoeType"]
	UpdateShoes(ReturnSettings["ShoeColor"], ReturnSettings["ShoeType"])
end)

for i,Button in pairs(ShoeColors:WaitForChild("Colors"):WaitForChild("Buttons"):GetChildren()) do
	if Button:IsA("TextButton") then
		Button.Activated:Connect(function()
			ReturnSettings["ShoeColor"] = Button.Name
			UpdateShoes(ReturnSettings["ShoeColor"], ReturnSettings["ShoeType"])
		end)
	end
end

--Initialize
SetColors(BodyParts, ReturnSettings["BodyColor"], BodyColorButtons)
SetColors(EyeParts, ReturnSettings["EyeColor"], EyeColorButtons)
UpdateClothes(ReturnSettings["ClothingColor"], ReturnSettings["ClothingType"])
UpdateHair(ReturnSettings["HairColor"], ReturnSettings["HairType"])
UpdateFacialHair(ReturnSettings["HairColor"], ReturnSettings["PrimaryFacialHairType"], PrimaryHairFacialTypesNumber, "PrimaryFacialHairTag", RSFacialHairs)
UpdateFacialHair(ReturnSettings["HairColor"], ReturnSettings["SecondaryFacialHairType"], SecondaryHairFacialTypesNumber, "SecondaryFacialHairTag", RSFacialHairs)
UpdateShoes(ReturnSettings["ShoeColor"], ReturnSettings["ShoeType"])
for i,v in pairs(HairColors:GetChildren()) do
	if v.Name == tostring(ReturnSettings["HairColor"]) then
		v.BorderSizePixel = 2
		v.BorderColor3 = Color3.new(1,1,1)
	else
		if v:IsA("GuiObject") then
			v.BorderSizePixel = 0
		end
	end  
end

--Finalizing
local TS = game:GetService("TweenService")
local Create = RightFrame:WaitForChild("Create"):WaitForChild("Button")
local TP = RS:WaitForChild("TP")

Create.Activated:Connect(function()
	if ExistingLoad then
		--Tween warning
		TP:FireServer(ReturnSettings)
	else
		TP:FireServer(ReturnSettings)
	end
end)

local Play = script.Parent.Parent:WaitForChild("Play"):WaitForChild("Button")
local New = script.Parent.Parent:WaitForChild("New"):WaitForChild("Button")
Play.Activated:Connect(function()
	if ExistingLoad then
		Play.Active = false
		New.Active = false
		TP:FireServer()
	end
end)