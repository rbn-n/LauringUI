local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

-- MoP-compatible wrappers
local GetSpecialization = GetSpecialization or C_SpecializationInfo.GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo or C_SpecializationInfo.GetSpecializationInfo
local GetLootSpecialization = GetLootSpecialization or C_SpecializationInfo.GetLootSpecialization
local GetSpecializationInfoByID = GetSpecializationInfoByID or C_SpecializationInfo.GetSpecializationInfoByID

local ToggleTalentFrame = ToggleTalentFrame
local UnitLevel = UnitLevel
local InCombatLockdown = InCombatLockdown
local GameTooltip = GameTooltip
local UIErrorsFrame = UIErrorsFrame

local format = format
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local SHOW_SPEC_LEVEL = SHOW_SPEC_LEVEL or 10
local NONE = NONE or "NONE"

local currentSpecIndex, currentLootSpecIndex

local function AddIcon(texture)
	if not texture then return "" end
	return "|T" .. texture .. ":12:12:0:0:50:50:4:46:4:46|t"
end

local function OnEvent(self)
	currentSpecIndex = GetSpecialization()
	if currentSpecIndex and currentSpecIndex > 0 then
		local _, name, _, _ = GetSpecializationInfo(currentSpecIndex)
		if not name then return end

		self.Text:SetText(L["Spec"] .. ": " .. DB.MyColor .. name)
	else
		self.Text:SetText(L["Spec"] .. ": " .. DB.MyColor .. NONE)
	end
end

local function OnEnter(self)
	if not currentSpecIndex or currentSpecIndex == 0 then return end

	local _, anchor, offset = module:GetTooltipAnchor(self)
	GameTooltip:SetOwner(self, "ANCHOR_" .. anchor, 0, offset)
	GameTooltip:ClearLines()

	local _, name, _, icon = GetSpecializationInfo(currentSpecIndex)
	GameTooltip:AddLine(L["Talents"], 0.6, 0.8, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(AddIcon(icon) .. " " .. name, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["LeftClick"], L["OpenTalents"], 1, 1, 1, 0.6, 0.8, 1)

	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

local function OnMouseUp(self, btn)
	if btn ~= "LeftButton" then return end

	local level = UnitLevel("player")
	if level < SHOW_SPEC_LEVEL then
		UIErrorsFrame:AddMessage(DB.InfoColor .. format(L["FeatureAvailableAtLevel"], SHOW_SPEC_LEVEL))
		return
	end

	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(DB.InfoColor .. ERR_NOT_IN_COMBAT)
		return
	end

	ToggleTalentFrame()
end

module:RegisterDataText("Spec", {
	panel = module.CentralBottomPanel,
	anchor = "LEFT",
	events = {
		"PLAYER_ENTERING_WORLD",
		"ACTIVE_PLAYER_SPECIALIZATION_CHANGED",
		"PLAYER_LOOT_SPEC_UPDATED",
		"CHARACTER_POINTS_CHANGED",
		"SPELLS_CHANGED",
	},
	onEvent = OnEvent,
	onEnter = OnEnter,
	onLeave = OnLeave,
	onMouseUp = OnMouseUp,
})
