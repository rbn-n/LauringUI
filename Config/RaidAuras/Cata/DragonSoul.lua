local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local module = Core:GetModule("AurasTable")

local TIER = 4
local INSTANCE = 187 -- Dragon Soul

local BOSS

BOSS = 311 -- Morchok
BOSS = 324 -- Warlord Zon'ozz
BOSS = 325 -- Yor'sahj the Unsleeping
BOSS = 317 -- Hagara the Stormbinder
BOSS = 331 -- Ultraxion
BOSS = 332 -- Warmaster Blackhorn
BOSS = 318 -- Spine of Deathwing
BOSS = 333 -- Madness of Deathwing

module:RegisterDebuff(TIER, INSTANCE, BOSS, 103541) -- Safe (Crystal stacks - Morchok)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 103536) -- Warning (Crystal stacks - Morchok)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 103534) -- Danger (Crystal stacks - Morchok)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 103687) -- Crush Armor (Zon'ozz)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 103434) -- Disrupting Shadows (Yor'sahj)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105171) -- Deep Corruption (Yor'sahj)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105465) -- Lightning Storm (Hagara)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 104451) -- Ice Tomb (Hagara)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 109325) -- Frostflake (Hagara)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105289) -- Shattered Ice (Hagara)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105285) -- Target (Ice Lance target marker - Hagara)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105259) -- Watery Entrenchment (Hagara)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 109075) -- Fading Light (Ultraxion)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 108043) -- Sunder Armor (Blackhorn)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 107558) -- Degeneration (Blackhorn)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 107567) -- Brutal Strike (Blackhorn)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 108046) -- Shockwave (Blackhorn)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 110214) -- Shockwave (Twilight Elite Dreadblade)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105479) -- Searing Plasma (Spine of Deathwing)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105490) -- Fiery Grip (Spine of Deathwing)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105563) -- Grasping Tendrils (Spine of Deathwing)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 106199) -- Blood Corruption: Death (Spine of Deathwing)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105841) -- Degenerative Bite (Deathwing's Mutated Corruption)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 106385) -- Crush (Madness of Deathwing - Elementium Fragment)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 106730) -- Tetanus (Madness of Deathwing)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 106444) -- Impale (Madness of Deathwing - Elementium Terror)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 106794) -- Shrapnel (Target) (Madness of Deathwing)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105445) -- Blistering Heat (Madness of Deathwing)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 108649) -- Corrupting Parasite (Madness of Deathwing)