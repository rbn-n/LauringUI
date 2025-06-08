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

Config.CornerBuffs = {
	["PRIEST"] = {
		[17]     = {"TOPLEFT", {.7, .7, .7}},			-- Power Word: Shield
		[139]    = {"TOPRIGHT", {.4, .7, .2}},			-- Renew
		[6346]   = {"BOTTOMRIGHT", {1, .8, 0}},			-- Fear Ward
		[6788]   = {"TOP", {.8, .1, .1}, true},			-- Weakened Soul
		[33206]  = {"LEFT", {.47, .35, .74}, true},		-- Pain Suppression
		[41635]  = {"RIGHT", {1, .7, .4}},				-- Prayer of Mending
	},
	["DRUID"] = {
		[467]    = {"LEFT", {.8, 1, .3}},				-- Thorns
		[774]    = {"TOPRIGHT", {.8, .4, .8}},			-- Rejuvenation
		[8936]   = {"RIGHT", {.2, .8, .2}},				-- Regrowth
		[33763]  = {"TOPLEFT", {.2, .8, .6}},			-- Lifebloom
		[29166]  = {"TOP", {0, .4, 1}, true},			-- Innervate
	},
	["PALADIN"] = {
		[1022]   = {"TOPRIGHT", {.2, .2, 1}, true},		-- Blessing of Protection
		[1044]   = {"TOPRIGHT", {.89, .45, 0}, true},	-- Blessing of Freedom
		[6940]   = {"TOPRIGHT", {.89, .1, .1}, true},	-- Blessing of Sacrifice
	},
	["WARLOCK"] = {
		[20707]  = {"BOTTOMRIGHT", {.8, .4, .8}, true},	-- Soulstone Resurrection
	},
	["MAGE"] = {},
	["WARRIOR"] = {},
	["SHAMAN"] = {
		[974]    = {"RIGHT", {1, .8, 0}},				-- Earth Shield
	},
	["HUNTER"] = {},
	["ROGUE"] = {},
	["DEATHKNIGHT"] = {},
	["MONK"] = {},
}

-- Corner icon blacklist
Config.CornerBlackList = {
	[57669] = true, -- Renew triggered by Vampiric Touch and Winter's Chill
}
