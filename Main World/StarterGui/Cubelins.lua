local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local DisplayInfo = require(Modules:WaitForChild("DisplayInfo"))

local Display = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Display")
local Main = script.Parent.Parent:WaitForChild("Main")
local Cubelins = Main:WaitForChild("Cubelins")

local PlayerCubelins = Display:InvokeServer({"Cubelins"})

local function UpdateCubelins(Value)
	if Value > 1000000 then
		Cubelins:WaitForChild("Image").Image = DisplayInfo["Cubelins"]["Gold"]
		Cubelins:WaitForChild("Label").Text = tostring(math.floor(Value/1000000 * 10)/10)
	elseif Value < 1000000 and Value > 1000 then
		Cubelins:WaitForChild("Image").Image = DisplayInfo["Cubelins"]["Silver"]
		Cubelins:WaitForChild("Label").Text = tostring(math.floor(Value/1000 * 10)/10)
	else
		Cubelins:WaitForChild("Image").Image = DisplayInfo["Cubelins"]["Bronze"]
		Cubelins:WaitForChild("Label").Text = tostring(Value)
	end
end

UpdateCubelins(PlayerCubelins)

