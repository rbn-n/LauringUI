local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:RegisterModule("AurasTable")

local pairs, next = pairs, next
local GetSpellInfo = GetSpellInfo

local RaidDebuffs = {}
function module:RegisterDebuff(_, instID, _, spellID, level)
	local instName = GetRealZoneText(instID)

	if not RaidDebuffs[instName] then RaidDebuffs[instName] = {} end
	if not level then level = 2 end
	if level > 6 then level = 6 end

	RaidDebuffs[instName][spellID] = level
end

local function CheckCornerSpells()
	if not LauringUIAccountDB["CornerSpells"][DB.MyClass] then LauringUIAccountDB["CornerSpells"][DB.MyClass] = {} end
	local data = Config.CornerBuffs[DB.MyClass]
	if not data then return end

	for spellID, value in pairs(LauringUIAccountDB["CornerSpells"][DB.MyClass]) do
		if not next(value) and Config.CornerBuffs[DB.MyClass][spellID] == nil then
			LauringUIAccountDB["CornerSpells"][DB.MyClass][spellID] = nil
		end
	end
end

local function CheckMajorSpells()
	for spellID in pairs(Config.Nameplates.MajorSpells) do
		local name = GetSpellInfo(spellID)
		if name then
			if LauringUIAccountDB["MajorSpells"][spellID] then
				LauringUIAccountDB["MajorSpells"][spellID] = nil
			end
		end
	end

	for spellID, value in pairs(LauringUIAccountDB["MajorSpells"]) do
		if value == false and Config.Nameplates.MajorSpells[spellID] == nil then
			LauringUIAccountDB["MajorSpells"][spellID] = nil
		end
	end
end

local function CheckNameplateFilter(list, key)
	for spellID in pairs(list) do
		local name = GetSpellInfo(spellID)
		if name then
			if LauringUIAccountDB[key][spellID] then
				LauringUIAccountDB[key][spellID] = nil
			end
		end
	end

	for spellID, value in pairs(LauringUIAccountDB[key]) do
		if value == false and list[spellID] == nil then
			LauringUIAccountDB[key][spellID] = nil
		end
	end
end

local function CleanupNameplateUnits(VALUE)
	for npcID in pairs(Config.Nameplates[VALUE]) do
		if Config.DB["Nameplates"][VALUE][npcID] then
			Config.DB["Nameplates"][VALUE][npcID] = nil
		end
	end
	for npcID, value in pairs(Config.DB["Nameplates"][VALUE]) do
		if value == false and Config.Nameplates[VALUE][npcID] == nil then
			Config.DB["Nameplates"][VALUE][npcID] = nil
		end
	end
end

function module:CheckNameplateFilters()
	CheckNameplateFilter(Config.Nameplates.WhiteList, "NameplateWhite")
	CheckNameplateFilter(Config.Nameplates.BlackList, "NameplateBlack")
	CleanupNameplateUnits("CustomUnits")
end

function module:OnLogin()
	for instName, value in pairs(RaidDebuffs) do
		for spell, priority in pairs(value) do
			if LauringUIAccountDB["RaidDebuffs"][instName] and LauringUIAccountDB["RaidDebuffs"][instName][spell] and LauringUIAccountDB["RaidDebuffs"][instName][spell] == priority then
				LauringUIAccountDB["RaidDebuffs"][instName][spell] = nil
			end
		end
	end
	for instName, value in pairs(LauringUIAccountDB["RaidDebuffs"]) do
		if not next(value) then
			LauringUIAccountDB["RaidDebuffs"][instName] = nil
		end
	end

	RaidDebuffs[0] = {} -- OTHER spells
	Config.RaidDebuffs = RaidDebuffs

	CheckCornerSpells()
	CheckMajorSpells()
	module:CheckNameplateFilters()
end