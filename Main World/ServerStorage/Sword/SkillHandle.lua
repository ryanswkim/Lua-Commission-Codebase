local Players = game:GetService("Players")
local Player = Players:GetPlayerFromCharacter(script.Parent.Parent.Parent)
local RS = game:GetService("ReplicatedStorage")
local Skills = require(game:GetService("ServerStorage"):WaitForChild("ModuleFunctions"):WaitForChild("Skills"))

local WeaponSkillPlaying = Player:WaitForChild("PlayingSkills"):WaitForChild("Weapon")
----------------------------------------------------------------------
local Connector = script.Parent:WaitForChild("Connector")
local MAR = RS:WaitForChild("Remotes"):WaitForChild("MAR")
local Clock = require(RS:WaitForChild("Clock"))

Connector.OnServerEvent:Connect(function(Player, Time)
	if Time then
		if not Skills.ServerCheck(Player, script.Parent.Parent.Name) then return end
		local ServerTime = Clock:GetTime()
		local DelayTime = ServerTime - Time
		if DelayTime < 0 or DelayTime > 40 then return end	
		WeaponSkillPlaying.Value = true
		MAR:FireAllClients(Player, "AgileSwipe", DelayTime, ServerTime)
	else
		WeaponSkillPlaying.Value = false
	end
end)