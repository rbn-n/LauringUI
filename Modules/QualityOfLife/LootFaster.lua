local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local QoL = Core:GetModule("QoL")
local GetLootMethod = C_PartyInfo.GetLootMethod

local lootDelay = 0
function QoL:LootFaster()
	if GetLootMethod() == "master" then return end

	if GetTime() - lootDelay >= .3 then
		lootDelay = GetTime()
		if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
			for i = GetNumLootItems(), 1, -1 do
				LootSlot(i)
			end
			lootDelay = GetTime()
		end
	end
end

function QoL:UpdateLootFaster()
	if Config.DB["QoL"]["LootFaster"] then
		Core:RegisterEvent("LOOT_READY", QoL.LootFaster)
	else
		Core:UnregisterEvent("LOOT_READY", QoL.LootFaster)
	end
end

QoL:RegisterQoL("LootFaster", QoL.UpdateLootFaster)