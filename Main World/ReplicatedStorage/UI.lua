local UI = {}

function UI:FindRarityText(Rarity)
	if Rarity == 0 then
		return "Common"
	elseif Rarity == 1 then
		return "Uncommon"
	elseif Rarity == 2 then
		return "Rare"
	elseif Rarity == 3 then
		return "Epic"
	elseif Rarity == 4 then
		return "Mythical"
	else 
		return "Legendary"
	end
end

function UI:FindTextRarityColor(Rarity)
	local RarityColor
	if Rarity == 0 then
		RarityColor = Color3.new(1,1,1)
	elseif Rarity == 1 then
		RarityColor = Color3.new(0.1,1,0.1)
	elseif Rarity == 2 then
		RarityColor = Color3.new(.2,.1,1)
	elseif Rarity == 3 then
		RarityColor = Color3.new(.325,0,1)
	elseif Rarity == 4 then
		RarityColor = Color3.new(1,0,0.2)
	else
		RarityColor = Color3.new(1,1,0)
	end
	return RarityColor
end

function UI:FindRarityColor(Rarity)
	local RarityColor
	if Rarity == 0 then
		RarityColor = Color3.new(.5,.5,.5)
	elseif Rarity == 1 then
		RarityColor = Color3.new(0.1,.65,0.1)
	elseif Rarity == 2 then
		RarityColor = Color3.new(.2,.1,.8)
	elseif Rarity == 3 then
		RarityColor = Color3.new(.325,0,1)
	elseif Rarity == 4 then
		RarityColor = Color3.new(1,0,0.2)
	else
		RarityColor = Color3.new(1,1,0)
	end
	return RarityColor
end

function UI:FindParticleInfo(Rarity)
	local ParticleRate
	local ParticleEmission
	if Rarity == 0 then
		ParticleRate = 16
		ParticleEmission = .3
	elseif Rarity == 1 then
		ParticleRate = 21
		ParticleEmission = .4
	elseif Rarity == 2 then
		ParticleRate = 27
		ParticleEmission = .55
	elseif Rarity == 3 then
		ParticleRate = 34
		ParticleEmission = .6
	elseif Rarity == 4 then
		ParticleRate = 42
		ParticleEmission = .65
	else
		ParticleRate = 50
		ParticleEmission = .7
	end
	return ParticleRate, ParticleEmission
end


return UI
