--This is mostly for weapon/armor (statbonuses, weapon basic attack sounds, weapon base damage/range)
local Equips = {	
	--Weapons
	Sword = {Damage = 5, Sound = "Slashed", DamageRange = 1};
	Daggers = {Damage = 2,  Sound = "Slashed", DamageRange = 1};
	Staff = {Damage = 3, Sound = "Smashed", DamageRange = 1};
	Hammer = {Damage = 11, Sound = "Smashed", DamageRange = 4};
	PaladinHammer = {Damage = 50, Sound = "Smashed", DamageRange = 50, StatBonuses = {Attack = -70}};
	WaterMagic = {Damage = 10, Statbonuses = {Intelligence = 20, Wisdom = 20}};
	
	--Armor
	SlooberCap = {StatBonuses = {Attack = 20}};
	
	}
return Equips
