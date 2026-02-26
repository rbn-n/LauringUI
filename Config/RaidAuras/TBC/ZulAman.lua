local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 568 -- Zul'Aman

-- Akil'zon
module:RegisterDebuff(TIER, INSTANCE, 0, 43621) -- Gust of Wind
module:RegisterDebuff(TIER, INSTANCE, 0, 43648) -- Electrical Storm

-- Nalorakk
module:RegisterDebuff(TIER, INSTANCE, 0, 42395) -- Rip
module:RegisterDebuff(TIER, INSTANCE, 0, 42397) -- Tear
module:RegisterDebuff(TIER, INSTANCE, 0, 42398) -- Deafening Roar

-- Jan'alai
module:RegisterDebuff(TIER, INSTANCE, 0, 43114) -- Fire Wall
module:RegisterDebuff(TIER, INSTANCE, 0, 43140) -- Fire Breath
module:RegisterDebuff(TIER, INSTANCE, 0, 43299) -- Flame Strike

-- Halazzi
module:RegisterDebuff(TIER, INSTANCE, 0, 43303) -- Flame Shock

-- Hex Lord Malacrass
module:RegisterDebuff(TIER, INSTANCE, 0, 44131) -- Energy Drain
module:RegisterDebuff(TIER, INSTANCE, 0, 43501) -- Soul Siphon
module:RegisterDebuff(TIER, INSTANCE, 0, 43586) -- Rapid Infection
module:RegisterDebuff(TIER, INSTANCE, 0, 43550) -- Mind Control
module:RegisterDebuff(TIER, INSTANCE, 0, 43441) -- Deadly Strike

-- Zul'jin
module:RegisterDebuff(TIER, INSTANCE, 0, 43150) -- Claw Rage
module:RegisterDebuff(TIER, INSTANCE, 0, 43983) -- Energy Storm
module:RegisterDebuff(TIER, INSTANCE, 0, 43093) -- Heavy Wound Throw
module:RegisterDebuff(TIER, INSTANCE, 0, 43437) -- Paralyze
module:RegisterDebuff(TIER, INSTANCE, 0, 43095) -- Paralysis Spread
