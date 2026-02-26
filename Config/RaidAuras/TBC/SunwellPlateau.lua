local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 580 -- Sunwell Plateau

-- Kalecgos
module:RegisterDebuff(TIER, INSTANCE, 0, 45034) -- Curse of Boundless Agony
module:RegisterDebuff(TIER, INSTANCE, 0, 45032) -- Curse of Boundless Agony
module:RegisterDebuff(TIER, INSTANCE, 0, 46021) -- Spectral Realm
module:RegisterDebuff(TIER, INSTANCE, 0, 44867) -- Spectral Exhaustion
module:RegisterDebuff(TIER, INSTANCE, 0, 45029) -- Corrupting Strike

-- Brutallus
module:RegisterDebuff(TIER, INSTANCE, 0, 45150) -- Meteor Slash
module:RegisterDebuff(TIER, INSTANCE, 0, 46394) -- Burn
module:RegisterDebuff(TIER, INSTANCE, 0, 45185) -- Stomp

-- Felmyst
module:RegisterDebuff(TIER, INSTANCE, 0, 45402) -- Demonic Vapor
module:RegisterDebuff(TIER, INSTANCE, 0, 47002) -- Gas Nova (Poison Gas)
module:RegisterDebuff(TIER, INSTANCE, 0, 45855) -- Gas Nova
module:RegisterDebuff(TIER, INSTANCE, 0, 45866) -- Corrosion

-- Eredar Twins
module:RegisterDebuff(TIER, INSTANCE, 0, 46771) -- Flame Sear
module:RegisterDebuff(TIER, INSTANCE, 0, 45348) -- Flame Touch
module:RegisterDebuff(TIER, INSTANCE, 0, 45342) -- Conflagration
module:RegisterDebuff(TIER, INSTANCE, 0, 45271) -- Shadow Strike
module:RegisterDebuff(TIER, INSTANCE, 0, 45345) -- Dark Flame
module:RegisterDebuff(TIER, INSTANCE, 0, 45347) -- Shadow Touch

-- M'uru
module:RegisterDebuff(TIER, INSTANCE, 0, 46161) -- Void Blast
module:RegisterDebuff(TIER, INSTANCE, 0, 45996) -- Darkness

-- Kil'jaeden
module:RegisterDebuff(TIER, INSTANCE, 0, 45641) -- Fire Bloom
module:RegisterDebuff(TIER, INSTANCE, 0, 45740) -- Flame Dart
module:RegisterDebuff(TIER, INSTANCE, 0, 45741) -- Flame Dart
module:RegisterDebuff(TIER, INSTANCE, 0, 45737) -- Flame Dart
module:RegisterDebuff(TIER, INSTANCE, 0, 45885) -- Shadow Spike
module:RegisterDebuff(TIER, INSTANCE, 0, 45770) -- Shadow Bolt Volley
module:RegisterDebuff(TIER, INSTANCE, 0, 45442) -- Soul Flay
