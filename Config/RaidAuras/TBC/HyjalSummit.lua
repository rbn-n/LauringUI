local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 534 -- Battle for Mount Hyjal

-- Trash mobs
module:RegisterDebuff(TIER, INSTANCE, 0, 31688) -- Frost Breath
module:RegisterDebuff(TIER, INSTANCE, 0, 31651) -- Banshee Curse
module:RegisterDebuff(TIER, INSTANCE, 0, 31724) -- Flame Strike
module:RegisterDebuff(TIER, INSTANCE, 0, 31610) -- Knockdown

-- Rage Winterchill
module:RegisterDebuff(TIER, INSTANCE, 0, 31257) -- Icebolt
module:RegisterDebuff(TIER, INSTANCE, 0, 31250) -- Frost Nova
module:RegisterDebuff(TIER, INSTANCE, 0, 31249) -- Frostbolt
module:RegisterDebuff(TIER, INSTANCE, 0, 31258) -- Death and Decay

-- Anetheron
module:RegisterDebuff(TIER, INSTANCE, 0, 31298) -- Sleep
module:RegisterDebuff(TIER, INSTANCE, 0, 31306) -- Carrion Swarm

-- Kaz'rogal
module:RegisterDebuff(TIER, INSTANCE, 0, 31447) -- Mark of Kaz'rogal
module:RegisterDebuff(TIER, INSTANCE, 0, 31480) -- War Stomp
module:RegisterDebuff(TIER, INSTANCE, 0, 31477) -- Cripple

-- Azgalor
module:RegisterDebuff(TIER, INSTANCE, 0, 31341) -- Unquenchable Flames
module:RegisterDebuff(TIER, INSTANCE, 0, 31347) -- Doom
module:RegisterDebuff(TIER, INSTANCE, 0, 31340) -- Rain of Fire
module:RegisterDebuff(TIER, INSTANCE, 0, 31344) -- Howl of Azgalor

-- Archimonde
module:RegisterDebuff(TIER, INSTANCE, 0, 31972) -- Grip of the Legion
module:RegisterDebuff(TIER, INSTANCE, 0, 31944) -- Doomfire
module:RegisterDebuff(TIER, INSTANCE, 0, 31970) -- Fear
module:RegisterDebuff(TIER, INSTANCE, 0, 42201) -- Eternal Silence
