local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local module = Core:GetModule("AurasTable")

local TIER = 4
local INSTANCE -- 5-man dungeons

INSTANCE = 67 -- The Stonecore
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain

INSTANCE = 64 -- Shadowfang Keep
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain

INSTANCE = 69 -- Lost City of the Tol'vir
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain

INSTANCE = 68 -- The Vortex Pinnacle
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain

INSTANCE = 71 -- Grim Batol
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain

INSTANCE = 63 -- The Deadmines
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain

INSTANCE = 65 -- Throne of the Tides
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain

INSTANCE = 70 -- Halls of Origination
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain

INSTANCE = 66 -- Blackrock Caverns
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain

INSTANCE = 76 -- Zul'Gurub
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain

INSTANCE = 77 -- Zul'Aman
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain

INSTANCE = 184 -- End Time
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain

INSTANCE = 185 -- Well of Eternity
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain

INSTANCE = 186 -- Hour of Twilight
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Venom Rain
