local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("AurasTable")

local TIER = 2
local INSTANCE -- 5-player dungeons

INSTANCE = 540 -- Hellfire Citadel: The Shattered Halls
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 558 -- Auchindoun: Auchenai Crypts
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 556 -- Auchindoun: Sethekk Halls
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 555 -- Auchindoun: Shadow Labyrinth
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 542 -- Hellfire Citadel: The Blood Furnace
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 546 -- Coilfang Reservoir: The Underbog
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 545 -- Coilfang Reservoir: The Steamvault
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 547 -- Coilfang Reservoir: The Slave Pens
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 553 -- Tempest Keep: The Botanica
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 554 -- Tempest Keep: The Mechanar
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 552 -- Tempest Keep: The Arcatraz
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 557 -- Auchindoun: Mana-Tombs
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 269 -- Opening the Dark Portal
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 560 -- Escape from Durnholde
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 543 -- Hellfire Citadel: Hellfire Ramparts
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse

INSTANCE = 585 -- Magisters' Terrace
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- Barren Curse
