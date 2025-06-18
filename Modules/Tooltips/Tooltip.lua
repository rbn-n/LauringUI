local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local Tooltip = Core:RegisterModule("Tooltips")

local strfind, format, strupper, strlen, pairs = string.find, string.format, string.upper, string.len, pairs
local ICON_LIST = ICON_LIST
local PVP, LEVEL, FACTION_HORDE, FACTION_ALLIANCE = PVP, LEVEL, FACTION_HORDE, FACTION_ALLIANCE
local YOU, TARGET, AFK, DND, DEAD, PLAYER_OFFLINE = YOU, TARGET, AFK, DND, DEAD, PLAYER_OFFLINE
local FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL = FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL
local LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL = LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL
local UnitIsPVP, UnitFactionGroup, UnitRealmRelationship, UnitGUID = UnitIsPVP, UnitFactionGroup, UnitRealmRelationship, UnitGUID
local UnitIsConnected, UnitIsDeadOrGhost, UnitIsAFK, UnitIsDND, UnitReaction = UnitIsConnected, UnitIsDeadOrGhost, UnitIsAFK, UnitIsDND, UnitReaction
local InCombatLockdown, IsShiftKeyDown = InCombatLockdown, IsShiftKeyDown
local GetCreatureDifficultyColor, UnitCreatureType, UnitClassification = GetCreatureDifficultyColor, UnitCreatureType, UnitClassification
local UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel = UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel
local GetRaidTargetIndex, GetGuildInfo, IsInGuild = GetRaidTargetIndex, GetGuildInfo, IsInGuild
local GameTooltip_ClearMoney, GameTooltip_ClearStatusBars, GameTooltip_ClearProgressBars, GameTooltip_ClearWidgetSet = GameTooltip_ClearMoney, GameTooltip_ClearStatusBars, GameTooltip_ClearProgressBars, GameTooltip_ClearWidgetSet

local classification = {
	elite = " |cffcc8800"..ELITE.."|r",
	rare = " |cffff99cc"..L["Rare"].."|r",
	rareelite = " |cffff99cc"..L["Rare"].."|r ".."|cffcc8800"..ELITE.."|r",
	worldboss = " |cffff0000"..BOSS.."|r",
}
local npcIDstring = "%s "..DB.InfoColor.."%s"

function Tooltip:GetMouseFocus()
	if GetMouseFoci then
		local frames = GetMouseFoci()
		return frames and frames[1]
	else
		return GetMouseFocus()
	end
end

function Tooltip:GetUnit()
	local _, unit = self:GetUnit()
	if not unit then
		local mFocus = Tooltip:GetMouseFocus()
		unit = mFocus and (mFocus.unit or (mFocus.GetAttribute and mFocus:GetAttribute("unit")))
	end
	return unit
end

function Tooltip:HideLines()
    for i = 3, self:NumLines() do
        local tiptext = _G["GameTooltipTextLeft" .. i]
        local linetext = tiptext:GetText()
        if linetext then
            if linetext == PVP then
                tiptext:SetText("")
                tiptext:Hide()
            elseif linetext == FACTION_HORDE then
                tiptext:SetText("|cffff5040" .. linetext .. "|r")
            elseif linetext == FACTION_ALLIANCE then
                tiptext:SetText("|cff4080ff" .. linetext .. "|r")
            end
        end
    end
end

function Tooltip:GetLevelLine()
	for i = 2, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()
		if linetext and strfind(linetext, LEVEL) then
			return tiptext
		end
	end
end

function Tooltip:GetTarget(unit)
	if UnitIsUnit(unit, "player") then
		return format("|cffff0000%s|r", ">"..strupper(YOU).."<")
	else
		return Core.HexRGB(Core.UnitColor(unit))..UnitName(unit).."|r"
	end
end

function Tooltip:OnTooltipCleared()
	if self:IsForbidden() then return end

	if self.factionFrame and self.factionFrame:GetAlpha() ~= 0 then
		self.factionFrame:SetAlpha(0)
	end

	GameTooltip_ClearMoney(self)
	GameTooltip_ClearStatusBars(self)
	GameTooltip_ClearProgressBars(self)
	GameTooltip_ClearWidgetSet(self)
end

local function ShouldHideInCombat()
	local index = Config.DB["Tooltips"]["HideInCombat"]
	if index == 1 then
		return true
	elseif index == 2 then
		return IsAltKeyDown()
	elseif index == 3 then
		return IsShiftKeyDown()
	elseif index == 4 then
		return IsControlKeyDown()
	elseif index == 5 then
		return false
	end
end

function Tooltip:OnTooltipSetUnit()
	if self:IsForbidden() then return end

	if (not ShouldHideInCombat()) and InCombatLockdown() then
		self:Hide()
		return
	end

	Tooltip.HideLines(self)

	local unit = Tooltip.GetUnit(self)
	if not unit or not UnitExists(unit) then return end

	local isShiftKeyDown = IsShiftKeyDown()
	local isPlayer = UnitIsPlayer(unit)
	if isPlayer then
		local name, realm = UnitName(unit)
		local relationship = UnitRealmRelationship(unit)

		if realm and realm ~= "" then
			if isShiftKeyDown or not Config.DB["Tooltip"]["HideRealm"] then
				name = name.."-"..realm
			elseif relationship == LE_REALM_RELATION_COALESCED then
				name = name..FOREIGN_SERVER_LABEL
			elseif relationship == LE_REALM_RELATION_VIRTUAL then
				name = name..INTERACTIVE_SERVER_LABEL
			end
		end

		local status = (UnitIsAFK(unit) and AFK) or (UnitIsDND(unit) and DND) or (not UnitIsConnected(unit) and PLAYER_OFFLINE)
		if status then
			status = format(" |cffffcc00[%s]|r", status)
		end
		GameTooltipTextLeft1:SetFormattedText("%s", name..(status or ""))

		local guildName, rank, rankIndex, guildRealm = GetGuildInfo(unit)
		local hasText = GameTooltipTextLeft2:GetText()
		if guildName and hasText then
			local myGuild, _, _, myGuildRealm = GetGuildInfo("player")
			if IsInGuild() and guildName == myGuild and guildRealm == myGuildRealm then
				GameTooltipTextLeft2:SetTextColor(.25, 1, .25)
			else
				GameTooltipTextLeft2:SetTextColor(.6, .8, 1)
			end

			rankIndex = rankIndex + 1

			if guildRealm and isShiftKeyDown then
				guildName = guildName.."-"..guildRealm
			end

			if Config.DB["Tooltip"]["HideJunkGuild"] and not isShiftKeyDown then
				if strlen(guildName) > 31 then guildName = "..." end
			end
			GameTooltipTextLeft2:SetText("<"..guildName.."> "..rank.."("..rankIndex..")")
		end
	end

	local r, g, b = Core.UnitColor(unit)
	local hexColor = Core.HexRGB(r, g, b)
	local text = GameTooltipTextLeft1:GetText()
	if text then
		local ricon = GetRaidTargetIndex(unit)
		if ricon and ricon > 8 then ricon = nil end
		ricon = ricon and ICON_LIST[ricon].."18|t " or ""
		GameTooltipTextLeft1:SetFormattedText(("%s%s%s"), ricon, hexColor, text)
	end

	local alive = not UnitIsDeadOrGhost(unit)
	local level = UnitLevel(unit)

	if level then
		local boss
		if level == -1 then boss = "|cffff0000??|r" end

		local diff = GetCreatureDifficultyColor(level)
		local classify = UnitClassification(unit)
		local textLevel = format("%s%s%s|r", Core.HexRGB(diff), boss or format("%d", level), classification[classify] or "")
		local tiptextLevel = Tooltip.GetLevelLine(self)
		if tiptextLevel then
			local reaction = UnitReaction(unit, "player")
			local standingText = not isPlayer and reaction and hexColor.._G["FACTION_STANDING_LABEL"..reaction].."|r " or ""

			local pvpFlag = isPlayer and UnitIsPVP(unit) and format(" |cffff0000%s|r", PVP) or ""
			local unitClass = isPlayer and format("%s %s", UnitRace(unit) or "", hexColor..(UnitClass(unit) or "").."|r") or UnitCreatureType(unit) or ""

			tiptextLevel:SetFormattedText(("%s%s %s %s"), textLevel, pvpFlag, standingText..unitClass, (not alive and "|cffCCCCCC"..DEAD.."|r" or ""))
		end
	end

	if UnitExists(unit.."target") then
		local tarRicon = GetRaidTargetIndex(unit.."target")
		if tarRicon and tarRicon > 8 then tarRicon = nil end
		local tar = format("%s%s", (tarRicon and ICON_LIST[tarRicon].."10|t") or "", Tooltip:GetTarget(unit.."target"))
		self:AddLine(TARGET..": "..tar)
	end

	if not isPlayer and isShiftKeyDown then
		local guid = UnitGUID(unit)
		local npcID = guid and Core.GetNPCID(guid)
		if npcID then
			self:AddLine(format(npcIDstring, "NpcID:", npcID))
		end
	end

	if isPlayer then
		Tooltip.InspectUnitItemLevel(self, unit)
	end

	self.StatusBar:SetStatusBarColor(r, g, b)
end

function Tooltip:StatusBar_OnValueChanged(value)
	if self:IsForbidden() or not value then return end
	local min, max = self:GetMinMaxValues()
	if (value < min) or (value > max) then return end

	if not self.text then
		self.text = Core.CreateFS(self, 12, "")
	end

	if value > 0 and max == 1 then
		self.text:SetFormattedText("%d%%", value*100)
		self:SetStatusBarColor(.6, .6, .6) -- Wintergrasp building
	else
		self.text:SetText(Core.Numb(value).." | "..Core.Numb(max))
	end
end

function Tooltip:ReskinStatusBar()
	self.StatusBar:ClearAllPoints()
	self.StatusBar:SetPoint("BOTTOMLEFT", self.__border, "TOPLEFT", Config.PixelMultiplexer, 3)
	self.StatusBar:SetPoint("BOTTOMRIGHT", self.__border, "TOPRIGHT", -Config.PixelMultiplexer, 3)
	self.StatusBar:SetStatusBarTexture(DB.StatusBarTexture2)
	self.StatusBar:SetHeight(5)
	Core.SetBD(self.StatusBar)
    --Core:StyleFrame(self.StatusBar)
end

function Tooltip:GameTooltip_ShowStatusBar()
	if not self or self:IsForbidden() then return end
	if not self.statusBarPool then return end

	local bar = self.statusBarPool:GetNextActive()
	if bar and not bar.styled then
		Core.RemoveBlizzTextures(bar)
		Core.CreateBDFrame(bar, .25)
		bar:SetStatusBarTexture(DB.StatusBarTexture2)

		bar.styled = true
	end
end

function Tooltip:GameTooltip_ShowProgressBar()
	if not self or self:IsForbidden() then return end
	if not self.progressBarPool then return end

	local bar = self.progressBarPool:GetNextActive()
	if bar and not bar.styled then
		Core.StripTextures(bar.Bar)
		Core.CreateBDFrame(bar.Bar, .25)
		bar.Bar:SetStatusBarTexture(DB.StatusBarTexture2)

		bar.styled = true
	end
end

local anchorIndex = {
	[1] = "TOPLEFT",
	[2] = "TOPRIGHT",
	[3] = "BOTTOMLEFT",
	[4] = "BOTTOMRIGHT",
}
local mover
function Tooltip:GameTooltip_SetDefaultAnchor(parent)
	if self:IsForbidden() then return end
	if not parent then return end

	self:SetOwner(parent, "ANCHOR_NONE")

    if not mover then
        mover = Core.Mover(self, L["Tooltip"], "GameTooltip", Config.Tooltips.Position, 100, 100)
    end

    self:ClearAllPoints()
    self:SetPoint(anchorIndex[Config.DB["Tooltips"]["Anchor"]], mover)
end

-- Fix comparison error on cursor
function Tooltip:GameTooltip_ComparisonFix(anchorFrame, shoppingTooltip1, shoppingTooltip2, _, secondaryItemShown)
	local point = shoppingTooltip1:GetPoint(2)
	if secondaryItemShown then
		if point == "TOP" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 3, 0)
			shoppingTooltip2:ClearAllPoints()
			shoppingTooltip2:SetPoint("TOPLEFT", shoppingTooltip1, "TOPRIGHT", 3, 0)
		elseif point == "RIGHT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -3, 0)
			shoppingTooltip2:ClearAllPoints()
			shoppingTooltip2:SetPoint("TOPRIGHT", shoppingTooltip1, "TOPLEFT", -3, 0)
		end
	else
		if point == "LEFT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 3, 0)
		elseif point == "RIGHT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -3, 0)
		end
	end
end

-- Tooltip skin
local fakeBg = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
fakeBg:SetBackdrop({ bgFile = DB.BackgroundTexture, edgeFile = DB.BackgroundTexture, edgeSize = 1 })
local function __GetBackdrop() return fakeBg:GetBackdrop() end
local function __GetBackdropColor() return 0, 0, 0, .7 end
local function __GetBackdropBorderColor() return 0, 0, 0 end

function Tooltip:ReskinTooltip()
	if not self then
		return
	end
	if self:IsForbidden() then return end
	self:SetScale(Config.DB["Tooltips"]["Scale"])

	if not self.tipStyled then
		if self.NineSlice then self.NineSlice:SetAlpha(0) end
		if self.SetBackdrop then self:SetBackdrop(nil) end
		self:DisableDrawLayer("BACKGROUND")
		Core:StyleFrame(self)

		if self.StatusBar then
			Tooltip.ReskinStatusBar(self)
		end

		if self.GetBackdrop then
			self.GetBackdrop = __GetBackdrop
			self.GetBackdropColor = __GetBackdropColor
			self.GetBackdropBorderColor = __GetBackdropBorderColor
		end

		self.tipStyled = true
	end

	Core.SetBorderColor(self.__border)
	if Config.DB["Tooltips"]["ItemQuality"] and self.GetItem then
		local _, item = self:GetItem()
		if item then
			local quality = select(3, C_Item.GetItemInfo(item))
			local color = DB.QualityColors[quality or 1]
			if color then
				self.__border:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
	end
end

local function TooltipSetFont(font, size)
	Core.SetFontSize(font, size)
	font:SetShadowColor(0, 0, 0, 0)
end

function Tooltip:SetupTooltipFonts()
	local textSize = DB.Font[2] + 2
	local headerSize = DB.Font[2] + 4

	TooltipSetFont(GameTooltipHeaderText, headerSize)
	TooltipSetFont(GameTooltipText, textSize)
	TooltipSetFont(GameTooltipTextSmall, textSize)

	if not GameTooltip.hasMoney then
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		GameTooltip_ClearMoney(GameTooltip)
	end
	if GameTooltip.hasMoney then
		for i = 1, GameTooltip.numMoneyFrames do
			TooltipSetFont(_G["GameTooltipMoneyFrame"..i.."PrefixText"], textSize)
			TooltipSetFont(_G["GameTooltipMoneyFrame"..i.."SuffixText"], textSize)
		end
	end

	for _, tooltip in ipairs(GameTooltip.shoppingTooltips) do
		for i = 1, tooltip:GetNumRegions() do
			local region = select(i, tooltip:GetRegions())
			if region:IsObjectType("FontString") then
				TooltipSetFont(region, textSize)
			end
		end
	end
end

function Tooltip:FixRecipeItemNameWidth()
	local name = self:GetName()
	for i = 1, self:NumLines() do
		local line = _G[name.."TextLeft"..i]
		if line:GetHeight() > 40 then
			line:SetWidth(line:GetWidth() + 1)
		end
	end
end

function Tooltip:ResetUnit(btn)
	if btn == "LSHIFT" and UnitExists("mouseover") then
		GameTooltip:SetUnit("mouseover")
	end
end

function Tooltip:OnLogin()
	GameTooltip.StatusBar = GameTooltipStatusBar
	GameTooltip:HookScript("OnTooltipCleared", Tooltip.OnTooltipCleared)
	GameTooltip:HookScript("OnTooltipSetUnit", Tooltip.OnTooltipSetUnit)
	GameTooltip.StatusBar:SetScript("OnValueChanged", Tooltip.StatusBar_OnValueChanged)
	hooksecurefunc("GameTooltip_ShowStatusBar", Tooltip.GameTooltip_ShowStatusBar)
	hooksecurefunc("GameTooltip_ShowProgressBar", Tooltip.GameTooltip_ShowProgressBar)
	hooksecurefunc("GameTooltip_SetDefaultAnchor", Tooltip.GameTooltip_SetDefaultAnchor)
	hooksecurefunc("GameTooltip_AnchorComparisonTooltips", Tooltip.GameTooltip_ComparisonFix)
	Tooltip:SetupTooltipFonts()
	GameTooltip:HookScript("OnTooltipSetItem", Tooltip.FixRecipeItemNameWidth)
	ItemRefTooltip:HookScript("OnTooltipSetItem", Tooltip.FixRecipeItemNameWidth)
	EmbeddedItemTooltip:HookScript("OnTooltipSetItem", Tooltip.FixRecipeItemNameWidth)

	-- Elements
	Tooltip:ReskinTooltipIcons()
	Tooltip:SetupTooltipID()
	Tooltip:TargetedInfo()
	Core:RegisterEvent("MODIFIER_STATE_CHANGED", Tooltip.ResetUnit)
end

-- Tooltip Skin Registration
local tipTable = {}
function Tooltip:RegisterTooltips(addon, func)
	tipTable[addon] = func
end
local function addonStyled(_, addon)
	if tipTable[addon] then
		tipTable[addon]()
		tipTable[addon] = nil
	end
end
Core:RegisterEvent("ADDON_LOADED", addonStyled)

Tooltip:RegisterTooltips("LauringUI", function()
	local tooltips = {
		ChatMenu,
		EmoteMenu,
		LanguageMenu,
		VoiceMacroMenu,
		GameTooltip,
		EmbeddedItemTooltip,
		ItemRefTooltip,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ShoppingTooltip1,
		ShoppingTooltip2,
		AutoCompleteBox,
		FriendsTooltip,
		GeneralDockManagerOverflowBuTooltiponList,
		NamePlateTooltip,
		WorldMapTooltip,
		IMECandidatesFrame,
		QueueStatusFrame,
	}
	for _, f in pairs(tooltips) do
		f:HookScript("OnShow", Tooltip.ReskinTooltip)
	end

	Core.ReskinClose(ItemRefCloseButton)

	if SettingsTooltip then
		Tooltip.ReskinTooltip(SettingsTooltip)
		SettingsTooltip:SetScale(UIParent:GetScale())
	end

	-- DropdownMenu
	local function reskinDropdown()
		for _, name in pairs({"DropDownList", "L_DropDownList", "Lib_DropDownList"}) do
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				local menu = _G[name..i.."MenuBackdrop"]
				if menu and not menu.styled then
					menu:HookScript("OnShow", Tooltip.ReskinTooltip)
					menu.styled = true
				end
			end
		end
	end
	hooksecurefunc("UIDropDownMenu_CreateFrames", reskinDropdown)

	-- IME
	local r, g, b = DB.r, DB.g, DB.b
	IMECandidatesFrame.selection:SetVertexColor(r, g, b)

	-- Others
	C_Timer.After(5, function()
		-- Lib minimap icon
		if LibDBIconTooltip then
			Tooltip.ReskinTooltip(LibDBIconTooltip)
		end
		-- TomTom
		if TomTomTooltip then
			Tooltip.ReskinTooltip(TomTomTooltip)
		end
		-- RareScanner
		if RSMapItemToolTip then
			Tooltip.ReskinTooltip(RSMapItemToolTip)
		end
		if LootBarToolTip then
			Tooltip.ReskinTooltip(LootBarToolTip)
		end
		-- Altoholic
		if AltoTooltip then
			Tooltip.ReskinTooltip(AltoTooltip)
		end
	end)
end)

Tooltip:RegisterTooltips("Blizzard_DebugTools", function()
	Tooltip.ReskinTooltip(FrameStackTooltip)
	FrameStackTooltip:SetScale(UIParent:GetScale())
end)

Tooltip:RegisterTooltips("Blizzard_EvenTooltiprace", function()
	Tooltip.ReskinTooltip(EvenTooltipraceTooltip)
end)

Tooltip:RegisterTooltips("Blizzard_LookingForGroupUI", function()
	Tooltip.ReskinTooltip(LFGBrowseSearchEntryTooltip)
end)