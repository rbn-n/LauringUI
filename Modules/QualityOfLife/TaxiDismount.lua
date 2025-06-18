local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local QoL = Core:GetModule("QoL")

local C_Timer_After = C_Timer_After

function QoL:UpdateTaxiDismount()
	local lastTaxiIndex

	local function RetryTaxi()
		if InCombatLockdown() then return end
		if lastTaxiIndex then
			TakeTaxiNode(lastTaxiIndex)
			lastTaxiIndex = nil
		end
	end

	hooksecurefunc("TakeTaxiNode", function(index)
		if not Config.DB["QoL"]["AutoDismount"] then return end
		if not IsMounted() then return end

		Dismount()
		lastTaxiIndex = index
		C_Timer_After(.5, RetryTaxi)
	end)
end

QoL:RegisterQoL("TaxiDismount", QoL.UpdateTaxiDismount)