local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 544 -- Magtheridon's Lair

-- Magtheridon
module:RegisterDebuff(TIER, INSTANCE, 0, 44032) -- Mind Exhaustion
module:RegisterDebuff(TIER, INSTANCE, 0, 30530) -- Fear
module:RegisterDebuff(TIER, INSTANCE, 0, 38927) -- Fel Pain
