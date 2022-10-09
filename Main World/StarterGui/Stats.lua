-- Services:
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Remotes:
local remotes = replicatedStorage:WaitForChild("Remotes")
local display = remotes:WaitForChild("Display")
local statUpdate = remotes:WaitForChild("StatUpdate")

-- GUI Instances:
local ZXCV = script.Parent
local mainFrame = ZXCV:WaitForChild("MainFrame"):WaitForChild("Right"):WaitForChild("C"):WaitForChild("Backdrop"):WaitForChild("MainFrame")
local statsFrames = mainFrame:WaitForChild("Stats")
local spFrame = mainFrame:WaitForChild("SP")

-- Functions:
local function update(newStats)
	for stat, number in pairs(newStats) do
		if statsFrames:FindFirstChild(stat) then
			local statFrame = statsFrames[stat]
			local value = statFrame:WaitForChild("Value")
			local shadowValue = statFrame:WaitForChild("Shadows"):WaitForChild("Value")
			
			value.Text = number
			shadowValue.Text = number
		end
	end
end




-- Init:
local stats = display:InvokeServer({"Stats"})
update(stats)