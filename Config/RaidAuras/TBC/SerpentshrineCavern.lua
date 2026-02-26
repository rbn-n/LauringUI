local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 548 -- Serpentshrine Cavern

-- Trash mobs
module:RegisterDebuff(TIER, INSTANCE, 0, 39029) -- Vile Poison
module:RegisterDebuff(TIER, INSTANCE, 0, 39015) -- Shrink
module:RegisterDebuff(TIER, INSTANCE, 0, 38718) -- Poison Pool
module:RegisterDebuff(TIER, INSTANCE, 0, 39032) -- Initial Infection
module:RegisterDebuff(TIER, INSTANCE, 0, 39042) -- Rapid Infection
module:RegisterDebuff(TIER, INSTANCE, 0, 38626) -- Domination

-- Hydross the Unstable
module:RegisterDebuff(TIER, INSTANCE, 0, 38235) -- Watery Grave
module:RegisterDebuff(TIER, INSTANCE, 0, 38215) -- Mark of Hydross
module:RegisterDebuff(TIER, INSTANCE, 0, 38216) -- Mark of Hydross
module:RegisterDebuff(TIER, INSTANCE, 0, 38217) -- Mark of Hydross
module:RegisterDebuff(TIER, INSTANCE, 0, 38218) -- Mark of Hydross
module:RegisterDebuff(TIER, INSTANCE, 0, 38219) -- Mark of Corruption
module:RegisterDebuff(TIER, INSTANCE, 0, 38220) -- Mark of Corruption
module:RegisterDebuff(TIER, INSTANCE, 0, 38221) -- Mark of Corruption
module:RegisterDebuff(TIER, INSTANCE, 0, 38222) -- Mark of Corruption
module:RegisterDebuff(TIER, INSTANCE, 0, 38230) -- Mark of Corruption
module:RegisterDebuff(TIER, INSTANCE, 0, 38246) -- Vile Sludge

-- The Lurker Below
module:RegisterDebuff(TIER, INSTANCE, 0, 37284) -- Scalding Water

-- Morogrim Tidewalker
module:RegisterDebuff(TIER, INSTANCE, 0, 38023) -- Watery Grave
module:RegisterDebuff(TIER, INSTANCE, 0, 38024) -- Watery Grave
module:RegisterDebuff(TIER, INSTANCE, 0, 38025) -- Watery Grave
module:RegisterDebuff(TIER, INSTANCE, 0, 37850) -- Watery Grave
module:RegisterDebuff(TIER, INSTANCE, 0, 37730) -- Tidal Wave

-- Fathom-Lord Karathress
module:RegisterDebuff(TIER, INSTANCE, 0, 29436) -- Leeching Throw
module:RegisterDebuff(TIER, INSTANCE, 0, 39261) -- Dust Storm
module:RegisterDebuff(TIER, INSTANCE, 0, 38441) -- Catastrophic Bolt
module:RegisterDebuff(TIER, INSTANCE, 0, 38234) -- Frost Shock

-- Leotheras the Blind
module:RegisterDebuff(TIER, INSTANCE, 0, 37640) -- Whirlwind
module:RegisterDebuff(TIER, INSTANCE, 0, 37675) -- Chaos Blast
module:RegisterDebuff(TIER, INSTANCE, 0, 37676) -- Insidious Whisper

-- Lady Vashj
module:RegisterDebuff(TIER, INSTANCE, 0, 38253) -- Poison Bolt (Tainted Elemental)
module:RegisterDebuff(TIER, INSTANCE, 0, 38258) -- Panic (Coilfang Elite)
module:RegisterDebuff(TIER, INSTANCE, 0, 38262) -- Hamstring (Coilfang Elite)
module:RegisterDebuff(TIER, INSTANCE, 0, 38509) -- Shock Blast
module:RegisterDebuff(TIER, INSTANCE, 0, 38280) -- Static Charge
