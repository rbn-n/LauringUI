local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local QoL = Core:GetModule("QoL")

local errorsToHideInCombat = {
	[ERR_ABILITY_COOLDOWN] = true,
	[ERR_ATTACK_MOUNTED] = true,
	[ERR_OUT_OF_ENERGY] = true,
	[ERR_OUT_OF_FOCUS] = true,
	[ERR_OUT_OF_HEALTH] = true,
	[ERR_OUT_OF_MANA] = true,
	[ERR_OUT_OF_RAGE] = true,
	[ERR_OUT_OF_RANGE] = true,
	[ERR_OUT_OF_RUNES] = true,
	[ERR_OUT_OF_HOLY_POWER] = true,
	[ERR_OUT_OF_RUNIC_POWER] = true,
	[ERR_OUT_OF_SOUL_SHARDS] = true,
	[ERR_OUT_OF_ARCANE_CHARGES] = true,
	[ERR_OUT_OF_COMBO_POINTS] = true,
	[ERR_OUT_OF_CHI] = true,
	[ERR_OUT_OF_POWER_DISPLAY] = true,
	[ERR_SPELL_COOLDOWN] = true,
	[ERR_ITEM_COOLDOWN] = true,
	[SPELL_FAILED_BAD_IMPLICIT_TARGETS] = true,
	[SPELL_FAILED_BAD_TARGETS] = true,
	[SPELL_FAILED_CASTER_AURASTATE] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
	[SPELL_FAILED_TARGET_AURASTATE] = true,
	[ERR_NO_ATTACK_TARGET] = true,
}

local isRegistered = true
function QoL:ErrorBlockerOnEvent(_, text)
	if InCombatLockdown() and errorsToHideInCombat[text] and isRegistered then
        UIErrorsFrame:UnregisterEvent(self)
        isRegistered = false
	elseif not isRegistered then
        UIErrorsFrame:RegisterEvent(self)
        isRegistered = true
	end
end

function QoL:UpdateErrorFilter()
	if Config.DB["QoL"]["ErrorFilter"] then
		Core:RegisterEvent("UI_ERROR_MESSAGE", QoL.ErrorBlockerOnEvent)
	else
		isRegistered = true
		UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
		Core:UnregisterEvent("UI_ERROR_MESSAGE", QoL.ErrorBlockerOnEvent)
	end
end

QoL:RegisterQoL("ErrorFilter", QoL.UpdateErrorFilter)