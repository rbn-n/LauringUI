local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local min, floor = math.min, math.floor
local UnitXP, UnitXPMax, GetXPExhaustion = UnitXP, UnitXPMax, GetXPExhaustion
local UnitLevel, GetMaxPlayerLevel = UnitLevel, GetMaxPlayerLevel
local GetWatchedFactionInfo, GetPetExperience = GetWatchedFactionInfo, GetPetExperience
local GameTooltip, UNKNOWN = GameTooltip, UNKNOWN
local FACTION_BAR_COLORS = FACTION_BAR_COLORS

local bar, text, restedBar

local function UpdateBar()
	if UnitLevel("player") < GetMaxPlayerLevel() then
		local xp, mxp, rxp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		bar:SetStatusBarColor(.5, 0, .75)
		bar:SetMinMaxValues(0, mxp)
		bar:SetValue(xp)

		if rxp then
			restedBar:SetMinMaxValues(0, mxp)
			restedBar:SetValue(min(xp + rxp, mxp))
			restedBar:Show()
		else
			restedBar:Hide()
		end

		local percent = floor(xp / mxp * 100)
		text:SetText(percent.."%")
		bar:Show()
	elseif GetWatchedFactionInfo() then
		local _, standing, barMin, barMax, value = GetWatchedFactionInfo()
		local color = FACTION_BAR_COLORS[standing] or {r=1, g=1, b=1}
		bar:SetStatusBarColor(color.r, color.g, color.b, 0.85)
		bar:SetMinMaxValues(barMin, barMax)
		bar:SetValue(value)

		local percent = floor((value - barMin) / (barMax - barMin) * 100)
		text:SetText(percent.."%")
		restedBar:Hide()
		bar:Show()
	else
		bar:Hide()
	end
end

local function UpdateTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:ClearLines()

	GameTooltip:AddLine(LEVEL.." "..UnitLevel("player"), 0,.6,1)

	if UnitLevel("player") < GetMaxPlayerLevel() then
		local xp, mxp, rxp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		GameTooltip:AddLine(" ")
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

	if GetWatchedFactionInfo() then
		local name, standing, barMin, barMax, value = GetWatchedFactionInfo()
		local standingtext = _G["FACTION_STANDING_LABEL"..standing] or UNKNOWN
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(name, 0,.6,1)
		GameTooltip:AddDoubleLine(standingtext, (value - barMin).." / "..(barMax - barMin).." ("..floor((value - barMin)/(barMax - barMin)*100).."%)", .6,.8,1, 1,1,1)
	end

	GameTooltip:Show()
end

function module:CreateExperienceBar()
	local panel = self.LeftBottomPanel
	if not panel then return end

	bar = CreateFrame("StatusBar", "LauringUI_ExperienceBar", panel)
	bar:SetAllPoints(panel)
	bar:SetStatusBarTexture(DB.StatusBarTexture2 or "Interface\\TargetingFrame\\UI-StatusBar")
	bar:SetFrameLevel(panel:GetFrameLevel() + 1)

	restedBar = CreateFrame("StatusBar", nil, bar)
	restedBar:SetAllPoints()
	restedBar:SetStatusBarTexture(DB.StatusBarTexture2 or "Interface\\TargetingFrame\\UI-StatusBar")
	restedBar:SetStatusBarColor(0, .4, 1, .3)
	restedBar:SetFrameLevel(bar:GetFrameLevel() - 1)
	bar.restedBar = restedBar

	text = bar:CreateFontString(nil, "OVERLAY")
	text:SetFont(DB.Font[1], DB.Font[2], DB.Font[3])
	text:SetPoint("CENTER")
	text:SetTextColor(1, 1, 1)

	local events = {
		"PLAYER_XP_UPDATE",
		"PLAYER_LEVEL_UP",
		"UPDATE_EXHAUSTION",
		"PLAYER_ENTERING_WORLD",
		"UPDATE_FACTION",
		"UNIT_INVENTORY_CHANGED",
		"ENABLE_XP_GAIN",
		"DISABLE_XP_GAIN",
	}

	for _, event in ipairs(events) do
		bar:RegisterEvent(event)
	end

	bar:SetScript("OnEvent", UpdateBar)
	bar:SetScript("OnEnter", UpdateTooltip)
	bar:SetScript("OnLeave", GameTooltip_Hide)

	UpdateBar()
end
