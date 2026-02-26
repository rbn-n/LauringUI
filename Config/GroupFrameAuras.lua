local _, ns = ...
local Core, Config, L, DB = unpack(ns)

Config.CornerBuffs = {
	["ALL"] = {},

	["PRIEST"] = {
		[17]    = {"BOTTOMRIGHT"},              -- Power Word: Shield
		[139]   = {"BOTTOMRIGHT"},              -- Renew
		[6346]  = {"TOPRIGHT", true},       -- Fear Ward
		[6788]  = {"TOPRIGHT", true},    -- Weakened Soul
		[33076] = {"BOTTOMRIGHT"},              -- Prayer of Mending (TBC)
	},

	["DRUID"] = {
		[774]   = {"BOTTOMRIGHT"},              -- Rejuvenation
		[8936]  = {"BOTTOMRIGHT"},              -- Regrowth
		[33763] = {"BOTTOMRIGHT"},              -- Lifebloom (TBC added)
		[29166] = {"TOPRIGHT", true},    	-- Innervate
	},

	["PALADIN"] = {
		[53563] = {"BOTTOMRIGHT"},              -- Beacon of Light (TBC)
		[1022]  = {"TOPRIGHT", true},     	-- Blessing of Protection
		[1044]  = {"TOPRIGHT", true},    	-- Blessing of Freedom
		[6940]  = {"TOPRIGHT", true},     	-- Blessing of Sacrifice
	},

	["WARLOCK"] = {
		[20707] = {"TOPRIGHT", true},    -- Soulstone Resurrection
	},

	["MAGE"] = {
		[45438] = {"TOPRIGHT", true},     -- Ice Block
	},

	["WARRIOR"] = {
		[871]   = {"TOPRIGHT", true},     -- Shield Wall
	},

	["SHAMAN"] = {
		[974]   = {"BOTTOMRIGHT", true},        -- Earth Shield (TBC)
		[61295] = {"BOTTOMRIGHT"},              -- Riptide (⚠ NOT TBC → remove)
	},

	["HUNTER"] = {},

	["ROGUE"] = {
		[31224] = {"TOPRIGHT", true},     -- Cloak of Shadows (TBC)
		[26669] = {"TOPRIGHT", true},     -- Evasion
	},
}


-- Corner icon blacklist (used to ignore certain auras from being shown in corner indicators)
Config.CornerBlackList = {
	[57669] = true, -- Renew triggered by Vampiric Touch or Winter’s Chill
}

-- Debuff indicator blacklist for raid frames
Config.RaidDebuffsBlack = {
	[23445] = true, -- Evil Twin
	[28274] = true, -- Bloodthistle Withdrawal
	[36893] = true, -- Teleporter Malfunction
	[36895] = true, -- Teleporter Malfunction
	[36897] = true, -- Teleporter Malfunction
	[36899] = true, -- Teleporter Malfunction
	[36900] = true, -- Soul Split: Evil
	[36901] = true, -- Soul Split: Good
	[36940] = true, -- Teleporter Malfunction
}