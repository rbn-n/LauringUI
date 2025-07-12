local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local GetSpellInfo = GetSpellInfo

local module = Core:RegisterModule("AurasTable")

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
		else
			if DB.isDeveloper then print("Invalid nameplate filter ID: "..spellID) end
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
	CleanupNameplateUnits("PowerUnits")
end

function module:OnLogin()
	CheckMajorSpells()
	module:CheckNameplateFilters()
end