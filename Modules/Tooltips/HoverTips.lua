local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local Tooltip = Core:GetModule("Tooltips")

local strmatch = string.match

local orig1, orig2 = {}, {}
local linkTypes = {
	achievement = true,
	item = true,
	enchant = true,
	spell = true,
	quest = true,
	unit = true,
	talent = true,
	instancelock = true,
	glyph = true,
	currency = true,
}

function Tooltip:HyperLink_SetTypes(link)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", -3, 5)
	GameTooltip:SetHyperlink(link)
	GameTooltip:Show()
end

function Tooltip:HyperLink_OnEnter(link, ...)
	local linkType = strmatch(link, "^([^:]+)")
	if linkType and linkTypes[linkType] then
		Tooltip.HyperLink_SetTypes(self, link)
	end

	if orig1[self] then return orig1[self](self, link, ...) end
end

function Tooltip:HyperLink_OnLeave(_, ...)
	GameTooltip:Hide()

	if orig2[self] then return orig2[self](self, ...) end
end

for i = 1, NUM_CHAT_WINDOWS do
	local frame = _G["ChatFrame"..i]
	orig1[frame] = frame:GetScript("OnHyperlinkEnter")
	frame:SetScript("OnHyperlinkEnter", Tooltip.HyperLink_OnEnter)
	orig2[frame] = frame:GetScript("OnHyperlinkLeave")
	frame:SetScript("OnHyperlinkLeave", Tooltip.HyperLink_OnLeave)
end