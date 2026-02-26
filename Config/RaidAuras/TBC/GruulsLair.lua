local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 565 -- Gruul's Lair

-- High King Maulgar
module:RegisterDebuff(TIER, INSTANCE, 0, 36032) -- Arcane Blast
module:RegisterDebuff(TIER, INSTANCE, 0, 11726) -- Enslave Demon
module:RegisterDebuff(TIER, INSTANCE, 0, 33129) -- Dark Decay
module:RegisterDebuff(TIER, INSTANCE, 0, 33175) -- Arcane Shock
module:RegisterDebuff(TIER, INSTANCE, 0, 33061) -- Blast Wave
module:RegisterDebuff(TIER, INSTANCE, 0, 33130) -- Death Coil
module:RegisterDebuff(TIER, INSTANCE, 0, 16508) -- Intimidating Roar

-- Gruul the Dragonkiller
module:RegisterDebuff(TIER, INSTANCE, 0, 38927) -- Fel Pain
module:RegisterDebuff(TIER, INSTANCE, 0, 36240) -- Cave In
module:RegisterDebuff(TIER, INSTANCE, 0, 33652) -- Petrify
module:RegisterDebuff(TIER, INSTANCE, 0, 33525) -- Ground Slam
