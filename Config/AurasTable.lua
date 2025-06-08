local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:RegisterModule("AurasTable")

local GetSpellInfo = GetSpellInfo

function module:CheckCornerSpells()
	if not LauringUIAccountDB["CornerSpells"][DB.MyClass] then
        LauringUIAccountDB["CornerSpells"][DB.MyClass] = {}
    end

	local classCornerBuffs = Config.CornerBuffs[DB.MyClass]
	if not classCornerBuffs then return end

	for spellID in pairs(classCornerBuffs) do
		local name = GetSpellInfo(spellID)
		if not name then
			print("Invalid cornerspell ID: "..spellID)
		end
	end

	for spellID, value in pairs(LauringUIAccountDB["CornerSpells"][DB.MyClass]) do
		if not next(value) and Config.CornerBuffs[DB.MyClass][spellID] == nil then
			LauringUIAccountDB["CornerSpells"][DB.MyClass][spellID] = nil
		end
	end
end

function module:OnLogin()
	module:CheckCornerSpells()
end