local _, ns = ...
local Core, Config, L, DB = unpack(ns)

Config.CornerBuffs = {
	["PRIEST"] = {
		[17]     = {"TOPLEFT"},            		-- Power Word: Shield
		[139]    = {"TOPLEFT"},           		-- Renew
		[6346]   = {"BOTTOMLEFT", true},        -- Fear Ward
		[6788]   = {"BOTTOMRIGHT", true},   	-- Weakened Soul
		[33206]  = {"BOTTOMLEFT", true},    	-- Pain Suppression
		[41635]  = {"TOPLEFT"},             	-- Prayer of Mending
	},
	["DRUID"] = {
		[774]    = {"TOPLEFT"},           		-- Rejuvenation
		[8936]   = {"TOPLEFT"},             	-- Regrowth
		[33763]  = {"TOPLEFT"},            		-- Lifebloom
		[48438]  = {"TOPRIGHT"},          		-- Wild Growth
		[29166]  = {"BOTTOMLEFT", true},    	-- Innervate
	},
	["PALADIN"] = {
		[1022]   = {"BOTTOMLEFT", true},     	-- Blessing of Protection
		[1044]   = {"BOTTOMLEFT", true},     	-- Blessing of Freedom
		[6940]   = {"BOTTOMLEFT", true},     	-- Blessing of Sacrifice
	},
	["WARLOCK"] = {
		[20707]  = {"BOTTOMRIGHT", true},  		-- Soulstone Resurrection
		[110913]  = {"BOTTOMLEFT", true},  		-- Dark Bargain
		[104773]  = {"BOTTOMLEFT", true},  		-- Unending Resolve
	},
	["MAGE"] = {
		[45438]  = {"BOTTOMLEFT", true},        -- Ice Block
	},
	["WARRIOR"] = {
		[871]     = {"BOTTOMLEFT", true},			-- Shield Wall
		[84159]  = {"BOTTOMLEFT", true},			-- Die by the Sword
	},
	["SHAMAN"] = {
		[974]    = {"TOPLEFT"},              	-- Earth Shield
		[61295]  = {"TOPLEFT"},              	-- Rip Tide
		[30823]  = {"BOTTOMLEFT", true},        -- Shamanistic Rage
	},
	["HUNTER"] = {
		[19263]  = {"BOTTOMLEFT", true},         -- Deterrence
	},
	["ROGUE"] = {
		[31224]  = {"BOTTOMLEFT", true},     	-- Cloak of Shadows
		[26669]  = {"BOTTOMLEFT", true},         -- Evasion
	},
	["DEATHKNIGHT"] = {
		[47484]     = {"BOTTOMLEFT", true},		-- Huddle
		[48792]     = {"BOTTOMLEFT", true},		-- Icebound Fortitude
		[48707]     = {"BOTTOMLEFT", true},		-- Anti-Magic Shell
	},
	["MONK"] = {
        [119611]     = {"TOPLEFT"},				-- Renewing Mist
        [132120]     = {"TOPLEFT"},				-- Enveloping Mist
        [115175]     = {"TOPLEFT"},				-- Soothing Mist
        [116849]     = {"BOTTOMLEFT", true},	-- Life Cocoon
        [120954]     = {"BOTTOMLEFT", true},	-- Fortyfying Brew
        [131523]     = {"BOTTOMLEFT", true},	-- Zen Meditation
        [122783]     = {"BOTTOMLEFT", true},	-- Difuse Magic
        [124274]     = {"BOTTOMRIGHT", true},	-- Moderate Stagger
        [124273]     = {"BOTTOMRIGHT", true},	-- Heavy Stagger
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

-- Buff indicator whitelist for raid frames (important cooldowns / survivals)
Config.RaidBuffsWhite = {
	[642] = true,     -- Divine Shield
	[871] = true,     -- Shield Wall
	[1022] = true,    -- Blessing of Protection
	[27827] = true,   -- Spirit of Redemption
}
