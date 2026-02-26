local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 532 -- Karazhan

-- Attumen the Huntsman
module:RegisterDebuff(TIER, INSTANCE, 0, 29833) -- Intangible Presence
module:RegisterDebuff(TIER, INSTANCE, 0, 29711) -- Knockdown

-- Moroes
module:RegisterDebuff(TIER, INSTANCE, 0, 29425) -- Gouge
module:RegisterDebuff(TIER, INSTANCE, 0, 34694) -- Blind
module:RegisterDebuff(TIER, INSTANCE, 0, 37066) -- Garrote

-- Opera Event
module:RegisterDebuff(TIER, INSTANCE, 0, 30822) -- Poisoned Thrust
module:RegisterDebuff(TIER, INSTANCE, 0, 30889) -- Powerful Attraction
module:RegisterDebuff(TIER, INSTANCE, 0, 30890) -- Blind Passion

-- Maiden of Virtue
module:RegisterDebuff(TIER, INSTANCE, 0, 29511) -- Repentance
module:RegisterDebuff(TIER, INSTANCE, 0, 29522) -- Holy Fire
module:RegisterDebuff(TIER, INSTANCE, 0, 29512) -- Holy Ground

-- The Curator
-- Terestian Illhoof
module:RegisterDebuff(TIER, INSTANCE, 0, 30053) -- Fire Vulnerability
module:RegisterDebuff(TIER, INSTANCE, 0, 30115) -- Sacrifice

-- Shade of Aran
module:RegisterDebuff(TIER, INSTANCE, 0, 29946) -- Flame Wreath
module:RegisterDebuff(TIER, INSTANCE, 0, 29947) -- Flame Wreath
module:RegisterDebuff(TIER, INSTANCE, 0, 29990) -- Slow
module:RegisterDebuff(TIER, INSTANCE, 0, 29991) -- Chains of Ice
module:RegisterDebuff(TIER, INSTANCE, 0, 29954) -- Frostbolt
module:RegisterDebuff(TIER, INSTANCE, 0, 29951) -- Blizzard

-- Netherspite
module:RegisterDebuff(TIER, INSTANCE, 0, 38637) -- Nether Exhaustion
module:RegisterDebuff(TIER, INSTANCE, 0, 38638) -- Nether Exhaustion
module:RegisterDebuff(TIER, INSTANCE, 0, 38639) -- Nether Exhaustion
module:RegisterDebuff(TIER, INSTANCE, 0, 30400) -- Nether Beam - Perseverance
module:RegisterDebuff(TIER, INSTANCE, 0, 30401) -- Nether Beam - Serenity
module:RegisterDebuff(TIER, INSTANCE, 0, 30402) -- Nether Beam - Dominance
module:RegisterDebuff(TIER, INSTANCE, 0, 30421) -- Nether Portal - Perseverance
module:RegisterDebuff(TIER, INSTANCE, 0, 30422) -- Nether Portal - Serenity
module:RegisterDebuff(TIER, INSTANCE, 0, 30423) -- Nether Portal - Dominance

-- Chess Event
module:RegisterDebuff(TIER, INSTANCE, 0, 30529) -- Recently Controlled Piece

-- Prince Malchezaar
module:RegisterDebuff(TIER, INSTANCE, 0, 39095) -- Damage Amplification
module:RegisterDebuff(TIER, INSTANCE, 0, 30898) -- Shadow Word: Pain
module:RegisterDebuff(TIER, INSTANCE, 0, 30854) -- Shadow Word: Pain

-- Nightbane
module:RegisterDebuff(TIER, INSTANCE, 0, 37091) -- Rain of Bones
module:RegisterDebuff(TIER, INSTANCE, 0, 30210) -- Smoldering Breath
module:RegisterDebuff(TIER, INSTANCE, 0, 30129) -- Charred Earth
module:RegisterDebuff(TIER, INSTANCE, 0, 30127) -- Burning Ash
module:RegisterDebuff(TIER, INSTANCE, 0, 36922) -- Deep Roar
