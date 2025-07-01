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
	FocusCastbar   = { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 950, 475 },

	PlayerPosition = { "BOTTOM", UIParent, "BOTTOM", -400, 450 },
	TargetPosition = { "BOTTOM", UIParent, "BOTTOM", 400, 450 },
	ToTPosition    = { "BOTTOM", UIParent, "BOTTOM", 473.5, 530 },
	PetPosition    = { "BOTTOM", UIParent, "BOTTOM", -473.5, 530 },
	FocusPosition  = { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 920, 450 },
	PartyPostion   = { "BOTTOM", UIParent, "BOTTOM", 0, 300 },
	RaidPosition   = { "BOTTOM", UIParent, "BOTTOM", 0, 106  },
	Raid10Position   = { "BOTTOM", UIParent, "BOTTOM", 0, 60  },
	Raid40Position   = { "BOTTOM", UIParent, "BOTTOM", 0, 60  },
}

Config.Tooltips = {
	Position = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 305 },
}
