local _, ns = ...
local Core, Config, L, DB = unpack(ns)

Config.DataText = {
    Font = "Fonts\\FRIZQT__.TTF",
    Size = 17,
    Outline = "OUTLINE"
}

Config.UIScale = 1

Config.UFs = {
	PlayerCastbar		= {"BOTTOM", UIParent, "BOTTOM", 0, 375},
	TargetCastbar		= {"CENTER", UIParent, "CENTER", 0, -109},
	FocusCastbar		= {"CENTER", UIParent, "CENTER", 0, 200},
	BossCastbar			= {"CENTER", UIParent, "CENTER", 0, 200},

	PlayerPosition		= {"BOTTOM", UIParent, "BOTTOM", -400, 450},
	TargetPosition		= {"BOTTOM", UIParent, "BOTTOM", 400, 450},
	ToTPosition 		= {"BOTTOM", UIParent, "BOTTOM", 473.5, 530},
	PetPosition 		= {"BOTTOM", UIParent, "BOTTOM", -473.5, 530},
	FocusPosition		= {"LEFT", UIParent, "LEFT", 5, -150},
}


Config.Tooltips = {
	Position = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -55, 230 },
}
