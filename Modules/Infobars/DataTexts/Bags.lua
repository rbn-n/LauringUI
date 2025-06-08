local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local format = string.format
local CalculateTotalNumberOfFreeBagSlots = CalculateTotalNumberOfFreeBagSlots

local function GetSlotString()
	local free = CalculateTotalNumberOfFreeBagSlots()
	local color = free < 10 and "|cffff0000" or "|cff00ff00"
	return format("%s: %s%d|r", L["Bags"], color, free)
end

local function OnEvent(self)
	self.Text:SetText(GetSlotString())
end

local function OnMouseUp(self, button)
	if button == "LeftButton" then
		ToggleAllBags()
	end
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["Bags"], 0.6, 0.8, 1)
	GameTooltip:AddLine("Click to open your bags", 1, 1, 1)
	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

module:RegisterDataText("Bags", {
	events = { "PLAYER_ENTERING_WORLD", "BAG_UPDATE" },
	onEvent = OnEvent,
	onMouseUp = OnMouseUp,
	onEnter = OnEnter,
	onLeave = OnLeave,
	panel = module.RightBottomPanel,
})