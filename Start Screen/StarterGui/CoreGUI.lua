local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local success, ErrorStatement = pcall(function()
	game:GetService('StarterGui'):SetCore('ResetButtonCallback', false)
end)

while not success do
 	wait()
 	success, ErrorStatement = pcall(function()
		game:GetService('StarterGui'):SetCore('ResetButtonCallback', false)
	end)
end