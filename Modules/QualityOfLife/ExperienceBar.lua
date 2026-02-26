local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local QoL = Core:GetModule("QoL")

local pairs = pairs
local min, floor = math.min, math.floor
local IsPlayerAtEffectiveMaxLevel = IsPlayerAtEffectiveMaxLevel
local FACTION_BAR_COLORS = FACTION_BAR_COLORS

function QoL:ExperienceBar_Update()
	local rest = self.restBar
	if rest then rest:Hide() end

	local factionData = C_Reputation.GetWatchedFactionData()

	if not IsPlayerAtEffectiveMaxLevel() then
		local xp, mxp, rxp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		self:SetStatusBarColor(0, .7, 1)
		self:SetMinMaxValues(0, mxp)
		self:SetValue(xp)
		self:Show()
		if rxp then
			rest:SetMinMaxValues(0, mxp)
			rest:SetValue(min(xp + rxp, mxp))
			rest:Show()
		end
	elseif factionData then
		local standing = factionData.reaction
		local barMin = factionData.currentReactionThreshold
		local barMax = factionData.nextReactionThreshold
		local value = factionData.currentStanding

		local color = FACTION_BAR_COLORS[standing] or FACTION_BAR_COLORS[5]
		self:SetStatusBarColor(color.r, color.g, color.b, .85)
		self:SetMinMaxValues(barMin, barMax)
		self:SetValue(value)
		self:Show()
	else
		self:Hide()
	end
end

function QoL:ExperienceBar_UpdateTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(LEVEL.." "..UnitLevel("player"), 0,.6,1)

	if not IsPlayerAtEffectiveMaxLevel() then
		GameTooltip:AddLine(" ")
		local xp, mxp, rxp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		GameTooltip:AddDoubleLine(XP..":", xp.." / "..mxp.." ("..floor(xp/mxp*100).."%)", .6,.8,1, 1,1,1)
		if rxp then
			GameTooltip:AddDoubleLine(TUTORIAL_TITLE26..":", "+"..rxp.." ("..floor(rxp/mxp*100).."%)", .6,.8,1, 1,1,1)
		end
	end

	if DB.MyClass == "HUNTER" then
		local currXP, nextXP = GetPetExperience()
		if nextXP ~= 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(PET.." Lv"..UnitLevel("pet"), 0,.6,1)
			GameTooltip:AddDoubleLine(XP..":", currXP.." / "..nextXP.." ("..floor(currXP/nextXP*100).."%)", .6,.8,1, 1,1,1)
		end
	end

	local factionData = C_Reputation.GetWatchedFactionData()

	if factionData then
		local name = factionData.name
		local standing = factionData.reaction
		local barMin = factionData.currentReactionThreshold
		local barMax = factionData.nextReactionThreshold
		local value = factionData.currentStanding

		local standingtext = _G["FACTION_STANDING_LABEL"..standing] or UNKNOWN
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(name, 0,.6,1)
		GameTooltip:AddDoubleLine(standingtext, value - barMin.." / "..barMax - barMin.." ("..floor((value - barMin)/(barMax - barMin)*100).."%)", .6,.8,1, 1,1,1)
	end
	GameTooltip:Show()
end

function QoL:SetupScript(bar)
	bar.eventList = {
		"PLAYER_XP_UPDATE",
		"PLAYER_LEVEL_UP",
		"UPDATE_EXHAUSTION",
		"PLAYER_ENTERING_WORLD",
		"UPDATE_FACTION",
		"UNIT_INVENTORY_CHANGED",
		"ENABLE_XP_GAIN",
		"DISABLE_XP_GAIN",
	}
	for _, event in pairs(bar.eventList) do
		bar:RegisterEvent(event)
	end
	bar:SetScript("OnEvent", QoL.ExperienceBar_Update)
	bar:SetScript("OnEnter", QoL.ExperienceBar_UpdateTooltip)
	bar:SetScript("OnLeave", Core.HideTooltip)
end

function QoL:ExperienceBar()
	if not Config.DB["Minimap"]["Enable"] then return end

	local bar = CreateFrame("StatusBar", "LauringUIExpRepBar", MinimapCluster)
	bar:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 5, -5)
	bar:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", -5, -5)
	bar:SetHeight(5)
	bar:SetHitRectInsets(0, 0, 0, -10)
	Core.CreateSB(bar)

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints()
	rest:SetStatusBarTexture(DB.StatusBarTexture)
	rest:SetStatusBarColor(0, .4, 1, .6)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	bar.restBar = rest

	QoL:SetupScript(bar)
end

QoL:RegisterQoL("ExperienceBar", QoL.ExperienceBar)