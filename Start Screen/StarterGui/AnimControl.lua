local TS = game:GetService("TweenService")

while wait(0.05) do
	for i,v in pairs(script.Parent.Loading:GetChildren()) do
		if v.BackgroundTransparency == 1 then
			v.BackgroundTransparency = 0.125
		else
			v.BackgroundTransparency = v.BackgroundTransparency + 0.125
		end
	end
end
