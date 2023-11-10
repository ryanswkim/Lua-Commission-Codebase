--This is for shop stuff (sell and buy)
local Items = {
	--None
	None = {Stack = 0, Purchase = -1, Sell = -1, Category = "All", Type = nil};
	
	--Weapons
	Sword = {Stack = 1, Purchase = -1, Sell = -1, Category = "EquipmentInventory", Type = "Weapon"};
	Staff = {Stack = 1, Purchase = -1, Sell = -1, Category = "EquipmentInventory", Type = "Weapon"};
	Hammer = {Stack = 1, Purchase = -1, Sell = -1, Category = "EquipmentInventory", Type = "Weapon"};
	PaladinHammer = {Stack = 1, Purchase = 500, Sell = 250, Category = "EquipmentInventory", Type = "Weapon"};
	Daggers = {Stack = 1, Purchase = -1, Sell = -1, Category = "EquipmentInventory", Type = "Weapon"};
	WaterMagic = {Stack = 1, Purchase = 800000, Sell = 250000, Category = "EquipmentInventory", Type = "Weapon"};

	--Armors
	SlooberCap = {Stack = 1, Purchase = 2, Sell = 1, Category = "EquipmentInventory", Type = "Head"};
	
	BlackClothing1 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BlackClothing2 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BlackClothing3 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BlackClothing4 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BlackClothing5 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BlackClothing6 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	
	WhiteClothing1 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	WhiteClothing2 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	WhiteClothing3 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	WhiteClothing4 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	WhiteClothing5 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	WhiteClothing6 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};

	BrownClothing1 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BrownClothing2 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BrownClothing3 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BrownClothing4 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BrownClothing5 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BrownClothing6 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	
	RedClothing1 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	RedClothing2 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	RedClothing3 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	RedClothing4 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	RedClothing5 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	RedClothing6 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};

	YellowClothing1 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	YellowClothing2 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	YellowClothing3 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	YellowClothing4 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	YellowClothing5 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	YellowClothing6 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};

	GreenClothing1 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	GreenClothing2 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	GreenClothing3 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	GreenClothing4 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	GreenClothing5 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	GreenClothing6 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};

	BlueClothing1 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BlueClothing2 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BlueClothing3 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BlueClothing4 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BlueClothing5 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	BlueClothing6 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};

	PurpleClothing1 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	PurpleClothing2 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	PurpleClothing3 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	PurpleClothing4 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	PurpleClothing5 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};
	PurpleClothing6 = {Stack = 1, Purchase = 10, Sell = 0, Category = "EquipmentInventory", Type = "Body"};

	CopperChestplate = {Stack = 1, Purchase = 10, Sell = 5, Category = "EquipmentInventory", Type = "Body"};
	CopperBoots = {Stack = 1, Purchase = 10, Sell = 5, Category = "EquipmentInventory", Type = "Feet"};
	
	--Collectibles
	Slimeball = {Stack = 3, Purchase = 2, Sell = 1, Category = "CollectibleInventory", Type = "Collectible"};
}

return Items
