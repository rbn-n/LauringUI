local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 550 -- Tempest Keep

-- Trash mobs
module:RegisterDebuff(TIER, INSTANCE, 0, 37132) -- Arcane Shock (Astromancer Apprentice)
module:RegisterDebuff(TIER, INSTANCE, 0, 37133) -- Arcane Strike (Astromancer Apprentice)
module:RegisterDebuff(TIER, INSTANCE, 0, 37279) -- Rain of Fire (Apprentice Star-Scryer)
module:RegisterDebuff(TIER, INSTANCE, 0, 38712) -- Shockwave (Star-Scryer Lord)
module:RegisterDebuff(TIER, INSTANCE, 0, 37289) -- Dragon’s Breath (Star-Scryer Lord)
module:RegisterDebuff(TIER, INSTANCE, 0, 37123) -- Jagged Blade (Core Mechanic)
module:RegisterDebuff(TIER, INSTANCE, 0, 37135) -- Dominate (Void Seer)
module:RegisterDebuff(TIER, INSTANCE, 0, 17928) -- Fear Howl (Void Seer)
module:RegisterDebuff(TIER, INSTANCE, 0, 37118) -- Shell Shock (Tempest Keep Blacksmith)
module:RegisterDebuff(TIER, INSTANCE, 0, 37120) -- Shard Bomb (Tempest Keep Blacksmith)
module:RegisterDebuff(TIER, INSTANCE, 0, 37160) -- Silence (Phoenix Hatchling)
module:RegisterDebuff(TIER, INSTANCE, 0, 37155) -- Sacrifice (Stormhawk Trainer)
module:RegisterDebuff(TIER, INSTANCE, 0, 39077) -- Hammer of Justice (Blood Guard Acolyte / Fiery Hand Blood Knight)
module:RegisterDebuff(TIER, INSTANCE, 0, 13005) -- Hammer of Justice (Blood Guard Officer)
module:RegisterDebuff(TIER, INSTANCE, 0, 37276) -- Mind Flay (Fiery Hand Inquisitor)
module:RegisterDebuff(TIER, INSTANCE, 0, 37263) -- Blizzard (Fiery Hand Battle Mage)
module:RegisterDebuff(TIER, INSTANCE, 0, 37265) -- Cone of Cold (Fiery Hand Battle Mage)
module:RegisterDebuff(TIER, INSTANCE, 0, 39087) -- Frost Attack (Fiery Hand Battle Mage)
module:RegisterDebuff(TIER, INSTANCE, 0, 37262) -- Ice Barrage (Fiery Hand Battle Mage)
module:RegisterDebuff(TIER, INSTANCE, 0, 33390) -- Arcane Torrent (Scryer Priest)

-- Kael’thas & associates
module:RegisterDebuff(TIER, INSTANCE, 0, 35383) -- Land of Flames
module:RegisterDebuff(TIER, INSTANCE, 0, 35410) -- Armor Melt
module:RegisterDebuff(TIER, INSTANCE, 0, 34190) -- Arcane Orb (Mana Bomb)
module:RegisterDebuff(TIER, INSTANCE, 0, 33023) -- Mark of Solarian
module:RegisterDebuff(TIER, INSTANCE, 0, 33044) -- Wrath of the Astromancer
module:RegisterDebuff(TIER, INSTANCE, 0, 33045) -- Wrath of the Astromancer
module:RegisterDebuff(TIER, INSTANCE, 0, 36970) -- Arcane Blast (Astromancer Capernia)
module:RegisterDebuff(TIER, INSTANCE, 0, 37018) -- Flamestrike (Astromancer Capernia)
module:RegisterDebuff(TIER, INSTANCE, 0, 44863) -- Roar (Baron Sagunar)
module:RegisterDebuff(TIER, INSTANCE, 0, 37027) -- Remote Toy (Chief Engineer Talonikus)
module:RegisterDebuff(TIER, INSTANCE, 0, 36965) -- Rend (Desecrator Saladris)
module:RegisterDebuff(TIER, INSTANCE, 0, 30225) -- Silence (Desecrator Saladris)
module:RegisterDebuff(TIER, INSTANCE, 0, 36834) -- Arcane Disruption (Kael’thas Sunstrider)
module:RegisterDebuff(TIER, INSTANCE, 0, 36797) -- Mind Control (Kael’thas Sunstrider)
