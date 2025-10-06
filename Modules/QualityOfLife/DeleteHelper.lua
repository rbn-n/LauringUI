local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local QoL = Core:GetModule("QoL")

function QoL:DeleteHelper()
    local deleteDialog = StaticPopupDialogs["DELETE_GOOD_ITEM"]
	if deleteDialog.OnShow then
		hooksecurefunc(deleteDialog, "OnShow", function(self)
			if Config.DB["QoL"]["DeleteHelper"] then
				self.EditBox:SetText(DELETE_ITEM_CONFIRM_STRING)
			end
		end)
	end
end

QoL:RegisterQoL("DeleteHelper", QoL.DeleteHelper)