local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local module = Core:GetModule("AurasTable")

local TIER = 5
local INSTANCE
 
INSTANCE = 324 -- Siege of Niuzao Temple
module:RegisterDebuff(5, INSTANCE, 0, 396152) -- Insecurity

INSTANCE = 312 -- Shado-Pan Monastery
module:RegisterDebuff(5, INSTANCE, 0, 396152) -- Insecurity

INSTANCE = 303 -- Gate of the Setting Sun
module:RegisterDebuff(5, INSTANCE, 0, 396152) -- Insecurity

INSTANCE = 316 -- Scarlet Monastery
module:RegisterDebuff(5, INSTANCE, 0, 396152) -- Insecurity

INSTANCE = 311 -- Scarlet Halls
module:RegisterDebuff(5, INSTANCE, 0, 396152) -- Insecurity

INSTANCE = 246 -- Scholomance
module:RegisterDebuff(5, INSTANCE, 0, 396152) -- Insecurity

INSTANCE = 313 -- Temple of the Jade Serpent
module:RegisterDebuff(5, INSTANCE, 0, 396150) -- Superiority
module:RegisterDebuff(5, INSTANCE, 0, 397878) -- Corrupted Ripple
module:RegisterDebuff(5, INSTANCE, 0, 106113) -- Touch of Nothingness
module:RegisterDebuff(5, INSTANCE, 0, 397914) -- Tainted Ripple
module:RegisterDebuff(5, INSTANCE, 0, 397904) -- Sunset Kick
module:RegisterDebuff(5, INSTANCE, 0, 397911) -- Touch of Ruin
module:RegisterDebuff(5, INSTANCE, 0, 395859) -- Wandering Scream
module:RegisterDebuff(5, INSTANCE, 0, 374037) -- Unstoppable Rage
module:RegisterDebuff(5, INSTANCE, 0, 396093) -- Savage Leap
module:RegisterDebuff(5, INSTANCE, 0, 106823) -- Serpent Kick
module:RegisterDebuff(5, INSTANCE, 0, 396152) -- Insecurity
module:RegisterDebuff(5, INSTANCE, 0, 110125) -- Shattered Resolve
module:RegisterDebuff(5, INSTANCE, 0, 397797) -- Corruption Vortex

INSTANCE = 302 -- Stormstout Brewery
module:RegisterDebuff(5, INSTANCE, 0, 396152) -- Insecurity

INSTANCE = 321 -- Mogu'shan Palace
module:RegisterDebuff(5, INSTANCE, 0, 396152) -- Insecurity