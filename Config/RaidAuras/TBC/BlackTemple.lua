local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 564 -- Black Temple

-- Trash mobs
module:RegisterDebuff(TIER, INSTANCE, 0, 40090) -- Cyclone
module:RegisterDebuff(TIER, INSTANCE, 0, 40079) -- Debilitating Spray
module:RegisterDebuff(TIER, INSTANCE, 0, 40078) -- Poison
module:RegisterDebuff(TIER, INSTANCE, 0, 40084) -- Glaive Thrower's Mark
module:RegisterDebuff(TIER, INSTANCE, 0, 40082) -- Net
module:RegisterDebuff(TIER, INSTANCE, 0, 40103) -- Sludge Nova
module:RegisterDebuff(TIER, INSTANCE, 0, 40946) -- Rain of Chaos
module:RegisterDebuff(TIER, INSTANCE, 0, 40877) -- Fireball
module:RegisterDebuff(TIER, INSTANCE, 0, 40892) -- Fixate
module:RegisterDebuff(TIER, INSTANCE, 0, 41115) -- Flame Shock
module:RegisterDebuff(TIER, INSTANCE, 0, 41150) -- Fear
module:RegisterDebuff(TIER, INSTANCE, 0, 41238) -- Blood Drain
module:RegisterDebuff(TIER, INSTANCE, 0, 41193) -- Disease Cloud
module:RegisterDebuff(TIER, INSTANCE, 0, 41274) -- Fel Stomp
module:RegisterDebuff(TIER, INSTANCE, 0, 41272) -- Behemoth Charge
module:RegisterDebuff(TIER, INSTANCE, 0, 41170) -- Coldhearted Curse
module:RegisterDebuff(TIER, INSTANCE, 0, 41168) -- Sonic Strike
module:RegisterDebuff(TIER, INSTANCE, 0, 41171) -- Skull Shot
module:RegisterDebuff(TIER, INSTANCE, 0, 41406) -- Frenzy
module:RegisterDebuff(TIER, INSTANCE, 0, 41409) -- Frenzy
module:RegisterDebuff(TIER, INSTANCE, 0, 41397) -- Confusion
module:RegisterDebuff(TIER, INSTANCE, 0, 41346) -- Poison Throw
module:RegisterDebuff(TIER, INSTANCE, 0, 41384) -- Frostbolt
module:RegisterDebuff(TIER, INSTANCE, 0, 41382) -- Blizzard
module:RegisterDebuff(TIER, INSTANCE, 0, 41379) -- Flame Storm

-- High Warlord Naj'entus
module:RegisterDebuff(TIER, INSTANCE, 0, 39837) -- Impaling Spine

-- Supremus
module:RegisterDebuff(TIER, INSTANCE, 0, 40253) -- Molten Flame

-- Shade of Akama
module:RegisterDebuff(TIER, INSTANCE, 0, 42023) -- Rain of Fire
module:RegisterDebuff(TIER, INSTANCE, 0, 41978) -- Debilitating Poison

-- Teron Gorefiend
module:RegisterDebuff(TIER, INSTANCE, 0, 40251) -- Shadow of Death
module:RegisterDebuff(TIER, INSTANCE, 0, 40243) -- Shadow of Doom
module:RegisterDebuff(TIER, INSTANCE, 0, 40239) -- Burn
module:RegisterDebuff(TIER, INSTANCE, 0, 40327) -- Cripple

-- Gurtogg Bloodboil
module:RegisterDebuff(TIER, INSTANCE, 0, 40481) -- Acidic Wound
module:RegisterDebuff(TIER, INSTANCE, 0, 42005) -- Bloodboil
module:RegisterDebuff(TIER, INSTANCE, 0, 40595) -- Fel Acid Breath
module:RegisterDebuff(TIER, INSTANCE, 0, 40508) -- Fel Acid Breath

-- Reliquary of Souls
module:RegisterDebuff(TIER, INSTANCE, 0, 41294) -- Fixate
module:RegisterDebuff(TIER, INSTANCE, 0, 41376) -- Enmity
module:RegisterDebuff(TIER, INSTANCE, 0, 41377) -- Enmity

-- Mother Shahraz
module:RegisterDebuff(TIER, INSTANCE, 0, 40823) -- Shriek of Silence
module:RegisterDebuff(TIER, INSTANCE, 0, 41001) -- Fatal Attraction
module:RegisterDebuff(TIER, INSTANCE, 0, 40860) -- Depravity

-- Illidari Council
module:RegisterDebuff(TIER, INSTANCE, 0, 41541) -- Consecration
module:RegisterDebuff(TIER, INSTANCE, 0, 41482) -- Blizzard
module:RegisterDebuff(TIER, INSTANCE, 0, 41481) -- Flame Storm
module:RegisterDebuff(TIER, INSTANCE, 0, 41472) -- Divine Wrath
module:RegisterDebuff(TIER, INSTANCE, 0, 41485) -- Deadly Poison
module:RegisterDebuff(TIER, INSTANCE, 0, 41461) -- Bloodboil Judgment

-- Illidan Stormrage
module:RegisterDebuff(TIER, INSTANCE, 0, 41914) -- Parasitic Shadowfiend
module:RegisterDebuff(TIER, INSTANCE, 0, 41917) -- Parasitic Shadowfiend
module:RegisterDebuff(TIER, INSTANCE, 0, 40932) -- Flame of Azzinoth
