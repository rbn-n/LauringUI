local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobar")

local INFO = module:RegisterInfobar("Spec", Config.Infobar.SpecPosition)

local function AddIcon(texture)
	if not texture then return "" end
	return "|T"..texture..":12:12:0:0:64:64:4:60:4:60|t "
end

local function GetTalentDistribution()
	local points = {}
	local highestPoints = 0
	local mainTreeName
	local mainTreeIcon

	for treeIndex = 1, GetNumTalentTabs() do
		local _, tabName, _, tabIcon, pointsSpent = GetTalentTabInfo(treeIndex)
		points[treeIndex] = pointsSpent

		if pointsSpent > highestPoints then
			highestPoints = pointsSpent
			mainTreeName = tabName
			mainTreeIcon = tabIcon
		end
	end

	return points, mainTreeName, mainTreeIcon
end

local function GetTalentString(points)
	-- White talent string: 0/21/40
	return string.format("|cffffffff%d/%d/%d|r", points[1] or 0, points[2] or 0, points[3] or 0)
end

INFO.eventList = {
	"PLAYER_ENTERING_WORLD",
	"PLAYER_TALENT_UPDATE",
	"CHARACTER_POINTS_CHANGED",
}

INFO.onEvent = function(self)
	if GetNumTalentTabs() == 0 then
		self.text:SetText(DB.MyColor..NONE)
		return
	end

	local points, mainTreeName, mainTreeIcon = GetTalentDistribution()
	if not mainTreeName then
		self.text:SetText(DB.MyColor..NONE)
		return
	end

	local talentString = GetTalentString(points)
	local icon = AddIcon(mainTreeIcon)

	self.text:SetText(
		talentString.." "..icon..DB.MyColor..mainTreeName
	)
end

INFO.onEnter = function(self)
	if GetNumTalentTabs() == 0 then return end

	local points, mainTreeName, mainTreeIcon = GetTalentDistribution()
	if not mainTreeName then return end

	local talentString = GetTalentString(points)
	local icon = AddIcon(mainTreeIcon)
	local _, anchor, offset = module:GetTooltipAnchor(INFO)

	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(TALENTS_BUTTON, 0, .6, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(talentString.." "..icon..mainTreeName, .6, .8, 1)
	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["SpecPanel"].." ", 1, 1, 1, .6, .8, 1)
	GameTooltip:Show()
end

INFO.onLeave = Core.HideTooltip

INFO.onMouseUp = function(self, btn)
	if btn == "LeftButton" then
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT)
			return
		end
		ToggleTalentFrame()
	end
end