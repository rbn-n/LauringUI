local _, ns = ...
local Core, Config, L, DB = unpack(ns)

Config.DataText = {
    Font = "Fonts\\FRIZQT__.TTF",
    Size = 17,
    Outline = "OUTLINE"
}

Config.UIScale = 1

Config.UFs = {
	PlayerCastbar  = { "BOTTOM", UIParent, "BOTTOM", 0, 382 },
	TargetCastbar  = { "BOTTOM", UIParent, "BOTTOM", 0, 606 },
	FocusCastbar   = { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 900, 475 },

	PlayerPosition = { "BOTTOM", UIParent, "BOTTOM", -400, 450 },
	TargetPosition = { "BOTTOM", UIParent, "BOTTOM", 400, 450 },
	ToTPosition    = { "BOTTOM", UIParent, "BOTTOM", 473.5, 530 },
	PetPosition    = { "BOTTOM", UIParent, "BOTTOM", -473.5, 530 },
	FocusPosition  = { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 900, 450 },
	PartyPosition  = { "BOTTOM", UIParent, "BOTTOM", 0, 303 },
	RaidPosition   = { "BOTTOM", UIParent, "BOTTOM", 0, 78 },
	Raid10Position = { "BOTTOM", UIParent, "BOTTOM", 0, 60 },
	Raid40Position = { "BOTTOM", UIParent, "BOTTOM", 0, 60 },
}

Config.Tooltips = {
	Position = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 305 },
}

Config.Nameplates = {
	WhiteList = {},
	BlackList = {},
	MajorSpells = {},
	CustomUnits = {},
	PowerUnits = {},
}

Config.Infobar = {
	GuildPosition      = { "BOTTOMLEFT", UIParent, 15, 6 },
	FriendsPosition    = { "BOTTOMLEFT", UIParent, 105, 6 },
	LatencyPosition    = { "BOTTOMLEFT", UIParent, 195, 6 },
	SystemPosition     = { "BOTTOMLEFT", UIParent, 285, 6 },
	LocationPosition   = { "BOTTOMLEFT", UIParent, 380, 6 },
	SpecPosition       = { "BOTTOMRIGHT", UIParent, -310, 6 },
	DurabilityPosition = { "BOTTOM", UIParent, "BOTTOMRIGHT", -230, 6 },
	GoldPosition       = { "BOTTOM", UIParent, "BOTTOMRIGHT", -125, 6 },
	TimePosition       = { "BOTTOMRIGHT", UIParent, -15, 6 },
}
