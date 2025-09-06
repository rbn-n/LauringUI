local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobar")

local INFO = module:RegisterInfobar("Zone", Config.Infobar.LocationPosition)

local format, unpack = string.format, unpack
local SELECTED_DOCK_FRAME, ChatFrame_OpenChat = SELECTED_DOCK_FRAME, ChatFrame_OpenChat
local GetSubZoneText, GetZoneText, IsInInstance = GetSubZoneText, GetZoneText, IsInInstance
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetZonePVPInfo = C_PvP and C_PvP.GetZonePVPInfo or GetZonePVPInfo
local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos

local zoneInfo = {
	sanctuary = {SANCTUARY_TERRITORY, {.41, .8, .94}},
	arena = {FREE_FOR_ALL_TERRITORY, {1, .1, .1}},
	friendly = {FACTION_CONTROLLED_TERRITORY, {.1, 1, .1}},
	hostile = {FACTION_CONTROLLED_TERRITORY, {1, .1, .1}},
	contested = {CONTESTED_TERRITORY, {1, .7, 0}},
	combat = {COMBAT_ZONE, {1, .1, .1}},
	neutral = {format(FACTION_CONTROLLED_TERRITORY, FACTION_STANDING_LABEL4), {1, .93, .76}}
}

local subzone, zone, pvpType, faction
local coordX, coordY = 0, 0

local function formatCoords()
	return format("%.1f, %.1f", coordX*100, coordY*100)
end

INFO.eventList = {
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD",
}

INFO.onEvent = function(self)
	subzone = GetSubZoneText()
	zone = GetZoneText()
	pvpType, _, faction = GetZonePVPInfo()
	pvpType = pvpType or "neutral"

	local r, g, b = unpack(zoneInfo[pvpType][2])
	self.text:SetText((subzone ~= "") and subzone or zone)
	self.text:SetTextColor(r, g, b)
end

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

local function UpdateCoords(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		local x, y = GetPlayerMapPos(C_Map_GetBestMapForUnit("player"))
		if x then
			coordX, coordY = x, y
		else
			coordX, coordY = 0, 0
			self:SetScript("OnUpdate", nil)
		end
		self:onEnter()

		self.elapsed = 0
	end
end

INFO.onEnter = function(self)
	self:SetScript("OnUpdate", UpdateCoords)

	local _, anchor, offset = module:GetTooltipAnchor(INFO)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(format("%s |cffffffff(%s)", zone, formatCoords()), 0,.6,1)

	if pvpType and not IsInInstance() then
		local r, g, b = unpack(zoneInfo[pvpType][2])
		if subzone and subzone ~= zone then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(subzone, r, g, b)
		end
		GameTooltip:AddLine(format(zoneInfo[pvpType][1], faction or ""), r, g, b)
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["WorldMap"].." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Send My Pos"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

INFO.onLeave = function(self)
	self:SetScript("OnUpdate", nil)
	GameTooltip:Hide()
end

INFO.onMouseUp = function(_, btn)
	if btn == "LeftButton" then
		ToggleWorldMap()
	elseif btn == "RightButton" then
		local hasUnit = UnitExists("target") and not UnitIsPlayer("target")
		local unitName = nil
		if hasUnit then unitName = UnitName("target") end
		ChatFrame_OpenChat(format("%s: %s (%s) %s", L["My Position"], zone, formatCoords(), unitName or ""), SELECTED_DOCK_FRAME)
	end
end