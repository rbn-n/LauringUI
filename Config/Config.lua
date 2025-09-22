local _, ns = ...
local Core, Config, L, DB = unpack(ns)

Config.DataText = {
    Font = "Fonts\\FRIZQT__.TTF",
    Size = 17,
    Outline = "OUTLINE"
}

Config.UIScale = 1

Config.UFs = {
	PlayerCastbar       = { "BOTTOM", UIParent, "BOTTOM", 0, 384 },
	TargetCastbar       = { "BOTTOM", UIParent, "BOTTOM", 0, 606 },
	FocusCastbar        = { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 967, 599 },

	PlayerPosition      = { "BOTTOM", UIParent, "BOTTOM", -400, 450 },
	TargetPosition      = { "BOTTOM", UIParent, "BOTTOM", 400, 450 },
	ToTPosition         = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -1064, 450 },
	PetPosition         = { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 1064, 450 },
	FocusPosition       = { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 990, 625 },
	FocusTargetPosition = { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 990, 573 },
	PartyPosition       = { "BOTTOM", UIParent, "BOTTOM", 0, 296 },
	RaidPosition        = { "BOTTOM", UIParent, "BOTTOM", 0, 100 },
	Raid10Position      = { "BOTTOM", UIParent, "BOTTOM", 0, 60 },
	Raid40Position      = { "BOTTOM", UIParent, "BOTTOM", 0, 60 },
}

Config.Tooltips = {
	Position = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 305 },
}

Config.Nameplates = {
	WhiteList = {},
	BlackList = {},
	MajorSpells = {},
	CustomUnits = {},
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
