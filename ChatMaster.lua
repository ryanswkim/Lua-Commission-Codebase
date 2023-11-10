local Players = game:GetService("Players")
local ChatSound = game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("ChatSound")
local Player = Players.LocalPlayer

for i,Player in pairs(Players:GetPlayers()) do
	Player.Chatted:Connect(function(message)
		MainMessageHandler(message, Player)
	end)
end

local function SansEffect(SpecialGuy)
	if SpecialGuy.Character and SpecialGuy.Character:FindFirstChild("Head") then
		local RightEye = SpecialGuy.Character.Head.RightEye
		local LeftEye = SpecialGuy.Character.Head.LeftEye
	
		local Megalovania = game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Megalovania"):Clone()
		Megalovania.Parent = LeftEye
		Megalovania:Play()
		
		local OriginalRight = RightEye.BrickColor
		local OriginalLeft = LeftEye.BrickColor
	
		RightEye.BrickColor = BrickColor.new("Really black")
		LeftEye.BrickColor = BrickColor.new("Really black")
		
		wait(8.18)
		
		local SansFire = game:GetService("ReplicatedStorage"):WaitForChild("Effects"):WaitForChild("SansFireHolder"):WaitForChild("SansFire"):Clone()
		SansFire.Parent = LeftEye
		SansFire:WaitForChild("P").Enabled = true
		
		for i = 0,50 do
			if not SpecialGuy.Character or not SpecialGuy.Character:FindFirstChild("Head") then return end
			if i%2 == 0 then
				LeftEye.BrickColor = BrickColor.new("Toothpaste")
			else
				LeftEye.BrickColor = BrickColor.new("New Yeller")
			end
			wait(.1)
		end
		if not SpecialGuy.Character or not SpecialGuy.Character:FindFirstChild("Head") then return end
		Megalovania:Stop()
		RightEye.BrickColor = BrickColor.new("Really black")
		LeftEye.BrickColor = BrickColor.new("Really black")
		SansFire.P.Enabled = false
		wait(1)
		if not SpecialGuy.Character or not SpecialGuy.Character:FindFirstChild("Head") then return end
		RightEye.BrickColor = OriginalRight
		LeftEye.BrickColor = OriginalLeft
		Megalovania:Destroy()
		SansFire:Destroy()
	end
end

function MainMessageHandler(message, Typer)
	if string.find(string.lower(message),"sans") and Typer.Character and Typer.Character:FindFirstChild("Head") and not Typer:FindFirstChild("SansCooldown") then
		local SansCooldown = Instance.new("BoolValue")
		SansCooldown.Name = "SansCooldown"
		SansCooldown.Parent = Typer
		spawn(function() wait(60) SansCooldown:Destroy() end)
		spawn(function() SansEffect(Typer) end)
		
	end
	if Typer.Character and Typer:FindFirstChild("VoiceTone") and Typer.Character:FindFirstChild("Head") and Typer.Character:FindFirstChild("HumanoidRootPart") then
		local VoiceTone = Typer.VoiceTone
		local ChatGUI = Typer.Character.HumanoidRootPart:WaitForChild("ChatGUI")
		ChatGUI:WaitForChild("Chat").Text = ""
		if not Typer.Character.Head:FindFirstChild("ChatSound") then
			local ChatSound = ChatSound:Clone()
			ChatSound.Parent = Typer.Character.Head
		end
		local ChatSound = Typer.Character.Head:WaitForChild("ChatSound")
		ChatSound.PlaybackSpeed = VoiceTone.Value
		local NewMessage = false
		for i = 1,string.len(message) do
			Typer.Chatted:Connect(function(new)
				NewMessage = true
			end)
			if NewMessage then break end
			ChatGUI:WaitForChild("Chat").Text = string.sub(message, 1, i)
			ChatSound:Play()
			wait(.055)
		end
		if not NewMessage then
			wait(1.8)
			ChatGUI.Chat.Text = ""
		end
	end
end		
		

Players.PlayerAdded:Connect(function(Player)
	Player.Chatted:Connect(function(message)
		MainMessageHandler(message, Player)
	end)
end)