local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Display = Remotes:WaitForChild("Display")

local ZXCV = script.Parent
local MainFrame = ZXCV:WaitForChild("MainFrame")
local Right = MainFrame:WaitForChild("Right")
local Z = Right:WaitForChild("Z")
local SkillsInventoryFrame = Z:WaitForChild("SkillsInventory")
local SkillsInfo = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DisplayInfo"))["Skills"]

------------------------------------------------------------------
local http = game:GetService("HttpService")
function qwe(toprint)
	print(http:JSONEncode(toprint))
end

local SkillsInventory, Slots = Display:InvokeServer({"SkillsInventory", "Slots"})
------------------------------------------------------------------
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Mouse1Connections = {}
local swait = function()
	game:GetService("RunService").Heartbeat:Wait()
end

local function UpdateSkillsInventory()
	for i,v in pairs(SkillsInventory) do
		local DisplayButton = SkillsInventoryFrame:WaitForChild("Items"):WaitForChild(i):WaitForChild("Display")
		if not SkillsInfo[v] then
			v = "None"
		end
		DisplayButton.Image = (SkillsInfo[v] or SkillsInfo["None"])["Image"]
		if Mouse1Connections[i] then
			Mouse1Connections[i]:Disconnect()
		end
		
	end
end

UpdateSkillsInventory()