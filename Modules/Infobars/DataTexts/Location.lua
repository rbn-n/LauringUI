local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local format = string.format
local GetSubZoneText, GetZoneText, IsInInstance = GetSubZoneText, GetZoneText, IsInInstance
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos
local GetZonePVPInfo = C_PvP and C_PvP.GetZonePVPInfo or GetZonePVPInfo
local ToggleWorldMap = ToggleWorldMap
local ChatFrame_OpenChat = ChatFrame_OpenChat
local UnitExists, UnitIsPlayer, UnitName = UnitExists, UnitIsPlayer, UnitName
local SELECTED_DOCK_FRAME = SELECTED_DOCK_FRAME

local zoneInfo = {
	sanctuary = { SANCTUARY_TERRITORY, { 0.41, 0.8, 0.94 } },
	arena = { FREE_FOR_ALL_TERRITORY, { 1, 0.1, 0.1 } },
	friendly = { FACTION_CONTROLLED_TERRITORY, { 0.1, 1, 0.1 } },
	hostile = { FACTION_CONTROLLED_TERRITORY, { 1, 0.1, 0.1 } },
	contested = { CONTESTED_TERRITORY, { 1, 0.7, 0 } },
	combat = { COMBAT_ZONE, { 1, 0.1, 0.1 } },
	neutral = { format(FACTION_CONTROLLED_TERRITORY, FACTION_STANDING_LABEL4), { 1, 0.93, 0.76 } },
}

local subzone, zone, pvpType, faction
local coordX, coordY = 0, 0

local function GetFormattedCoords()
	return format("%.1f, %.1f", coordX * 100, coordY * 100)
end

-- Map position caching (same as before)
local cachedMapRects = {}
local playerWorldPos = CreateVector2D(0, 0)
local VEC_ZERO = CreateVector2D(0, 0)
local VEC_ONE = CreateVector2D(1, 1)

local function GetPlayerMapPos(mapID)
	if not mapID then return end
	playerWorldPos.x, playerWorldPos.y = UnitPosition("player")
	if not playerWorldPos.x then return end

	local mapRect = cachedMapRects[mapID]
	if not mapRect then
		mapRect = {}
		mapRect[1] = select(2, C_Map_GetWorldPosFromMapPos(mapID, VEC_ZERO))
		mapRect[2] = select(2, C_Map_GetWorldPosFromMapPos(mapID, VEC_ONE))
		mapRect[2]:Subtract(mapRect[1])
		cachedMapRects[mapID] = mapRect
	end

	playerWorldPos:Subtract(mapRect[1])
	return playerWorldPos.y / mapRect[2].y, playerWorldPos.x / mapRect[2].x
end

local function RefreshTooltip(self)
	local _, anchor, offset = module:GetTooltipAnchor(self)
	GameTooltip:SetOwner(self, "ANCHOR_" .. anchor, 0, offset)
	GameTooltip:ClearLines()

	GameTooltip:AddLine(format("%s |cffffffff(%s)", zone or "", GetFormattedCoords()), 0, 0.6, 1)

	if pvpType and not IsInInstance() then
		local r, g, b = unpack(zoneInfo[pvpType][2])
		if subzone and subzone ~= zone then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(subzone, r, g, b)
		end
		GameTooltip:AddLine(format(zoneInfo[pvpType][1], faction or ""), r, g, b)
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton .. L["WorldMap"] .. " ", 1, 1, 1, 0.6, 0.8, 1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton .. L["Send My Pos"] .. " ", 1, 1, 1, 0.6, 0.8, 1)
	GameTooltip:Show()
end

local function RefreshCoords(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		local x, y = GetPlayerMapPos(C_Map_GetBestMapForUnit("player"))
		if x then
			coordX, coordY = x, y
		else
			coordX, coordY = 0, 0
			self:SetScript("OnUpdate", nil)
		end
		RefreshTooltip(self)
		self.elapsed = 0
	end
end

local function OnEnter(self)
	self:SetScript("OnUpdate", RefreshCoords)
	RefreshTooltip(self)
end

local function OnLeave(self)
	self:SetScript("OnUpdate", nil)
	GameTooltip:Hide()
end

local function OnMouseUp(self, btn)
	if btn == "LeftButton" then
		ToggleWorldMap()
	elseif btn == "RightButton" then
		local hasUnit = UnitExists("target") and not UnitIsPlayer("target")
		local unitName = hasUnit and UnitName("target") or nil
		local message = format("%s: %s (%s) %s", L["My Position"], zone or "", GetFormattedCoords(), unitName or "")
		ChatFrame_OpenChat(message, SELECTED_DOCK_FRAME)
	end
end


function module:CreateLocation()
	local panelHeight = 20
	local panel = CreateFrame("Frame", "LauringUICentralTopPanel", UIParent)
	panel:SetFrameStrata("LOW")
	panel:SetHeight(panelHeight)
	panel:SetPoint("TOP", UIParent, "TOP", 0, 0)
	module:StylePanel(panel)

	local frame = CreateFrame("Button", "LauringUILocationDataText", panel)
	frame:SetAllPoints(panel)
	frame:SetFrameStrata("HIGH")
	frame:SetFrameLevel(panel:GetFrameLevel() + 5)

	local text = frame:CreateFontString(nil, "OVERLAY")
	text:SetFont(Config.DataText.Font, 20, Config.DataText.Outline)
	text:SetPoint("CENTER")
	frame.Text = text

	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("ZONE_CHANGED")
	frame:RegisterEvent("ZONE_CHANGED_INDOORS")
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

	frame:SetScript("OnEvent", function(self)
		subzone = GetSubZoneText()
		zone = GetZoneText()
		pvpType, _, faction = GetZonePVPInfo()
		pvpType = pvpType or "neutral"

		local r, g, b = unpack(zoneInfo[pvpType][2])
		local displayText = (subzone and subzone ~= "") and subzone or zone

		self.Text:SetText(displayText)
		self.Text:SetTextColor(r, g, b)

		-- Resize panel based on text width + padding
		local padding = 30
		local width = self.Text:GetStringWidth() + padding
		panel:SetWidth(width)
		panel:Show()
	end)

	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", OnLeave)
	frame:SetScript("OnMouseUp", OnMouseUp)

	return frame, panel
end
