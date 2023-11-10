local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Info = {
	Projectiles = {
		Water = {Lifetime = 10, Speed = 35}
	},
	
	Skills = {
	--Weapons
	None = {ManaCost = 0, Cooldown = 0, RequiresEquip = false, Image = "http://www.roblox.com/asset/?id=4535451740"},
	Sword = {ManaCost = 1, Cooldown = 1, RequiresEquip = true, Image = "http://www.roblox.com/asset/?id=4524907680"},
	Daggers = {ManaCost = 1, Cooldown = 1, RequiresEquip = true, Image = "http://www.roblox.com/asset/?id=4524907680"},
	Hammer = {ManaCost = 25, Cooldown = 10, RequiresEquip = true, Image = "http://www.roblox.com/asset/?id=4524907680"},
	PaladinHammer = {ManaCost = 20, Cooldown = 30, RequiresEquip = true, Image = "http://www.roblox.com/asset/?id=4524907680"},
	WaterMagic = {ManaCost = 10, Cooldown = 3, RequiresEquip = true, Image = "http://www.roblox.com/asset/?id=4524907680"},
	},
	
	Items = {
		--None
		None = {Name = "", Description = "", Category = "", Rarity = -1, Image = "http://www.roblox.com/asset/?id=4535451740"};
		Placeholder = {Name = "Sorry!", Description = "We couldn't load this item for you yet. :(", Rarity = 1, Image = "http://www.roblox.com/asset/?id=4535451740"};
		
		--Weapons
		Sword = {Name = "Sword", Description = "A basic sword.", Category = "Weapon", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907680"};
		Staff = {Name = "Staff", Description = "A basic staff.", Category = "Weapon", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907680"};
		Daggers = {Name = "Daggers", Description = "Basic daggers.", Category = "Weapon", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907680"};
		Hammer = {Name = "Hammer", Description = "A basic hammer.", Category = "Weapon", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907680"};
		PaladinHammer = {Name = "Paladin's Hammer", Description = "Bruh hammer.", Category = "Weapon", Rarity = 1, Image = "http://www.roblox.com/asset/?id=4524907680"};
		WaterMagic = {Name = "Water Magic Spellbook", Description = "Water", Category = "Weapon", Rarity = 3, Image = "http://www.roblox.com/asset/?id=4524907680"};
		
		--Armors
		BlackClothing1 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BlackClothing2 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BlackClothing3 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BlackClothing4 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BlackClothing5 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BlackClothing6 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		
		RedClothing1 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		RedClothing2 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		RedClothing3 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		RedClothing4 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		RedClothing5 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		RedClothing6 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		
		BlueClothing1 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BlueClothing2 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BlueClothing3 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BlueClothing4 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BlueClothing5 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BlueClothing6 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		
		YellowClothing1 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		YellowClothing2 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		YellowClothing3 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		YellowClothing4 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		YellowClothing5 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		YellowClothing6 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		
		GreenClothing1 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		GreenClothing2 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		GreenClothing3 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		GreenClothing4 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		GreenClothing5 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		GreenClothing6 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		
		WhiteClothing1 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		WhiteClothing2 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		WhiteClothing3 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		WhiteClothing4 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		WhiteClothing5 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		WhiteClothing6 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		
		BrownClothing1 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BrownClothing2 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BrownClothing3 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BrownClothing4 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BrownClothing5 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		BrownClothing6 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		
		PurpleClothing1 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		PurpleClothing2 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		PurpleClothing3 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		PurpleClothing4 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		PurpleClothing5 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		PurpleClothing6 = {Name = "Black 1", Description = "Black 1", Category = "Body", Rarity = 0, Image = "http://www.roblox.com/asset/?id=4524907134"};
		
		CopperChestplate = {Name = "Copper Chestplate", Description = "A sexy copper chestplate", Category = "Body", Rarity = 3, Image = "http://www.roblox.com/asset/?id=4524907134"};
		CopperBoots = {Name = "Copper Boots", Description = "A sexy pair of copper boots", Category = "Feet", Rarity = 3, Image = "http://www.roblox.com/asset/?id=4524907134"};
	
		SlooberCap = {Name = "Sloober Cap", Description = "Very fancc", Category = "Head", Rarity = 3, Image = "http://www.roblox.com/asset/?id=4524907680"};
		
		--Collectibles
		Slimeball = {Name = "Slimeball", Description = "Yummy!", Category = "Collectible", Rarity = 5, Image = "http://www.roblox.com/asset/?id=4524907680"};
	};
	
	Titles = {Adventurer = {Name = "Adventurer", Description = "Earned when you begin your quest", Rarity = 0}};
	
	Cubelins = {
		Bronze = "http://www.roblox.com/asset/?id=4524906911";
		Silver = "http://www.roblox.com/asset/?id=4524818409";
		Gold = "http://www.roblox.com/asset/?id=4524907134"};
	
	Mobs = {
		Sloober = {Name = "Sloober", Description = "Slime", Difficulty = 1, BloodColor = Color3.new(1,0,0)};
		NommTerra = {Name = "Nomm", Description = "Slime", Difficulty = 1, BloodColor = Color3.new(0,0,1)};
	};
	
	Sounds = {
		Sword = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Slashed");
		Daggers = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Slashed");
		Staff = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Smashed");
		Hammer = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Smashed");
		PaladinHammer = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Smashed");
	};
	
	}
return Info
