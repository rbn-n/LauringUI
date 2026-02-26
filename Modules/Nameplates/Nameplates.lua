local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local oUF = ns.oUF
local Nameplates = Core:RegisterModule("Nameplates")
local UF = Core:GetModule("UnitFrames")

local _G = getfenv(0)
local strmatch, tonumber, pairs, unpack, rad = string.match, tonumber, pairs, unpack, math.rad
local UnitThreatSituation, UnitIsTapDenied, UnitPlayerControlled, UnitIsUnit = UnitThreatSituation, UnitIsTapDenied, UnitPlayerControlled, UnitIsUnit
local UnitReaction, UnitIsConnected, UnitIsPlayer, UnitSelectionColor = UnitReaction, UnitIsConnected, UnitIsPlayer, UnitSelectionColor
local UnitClassification, UnitExists, InCombatLockdown, UnitCanAttack = UnitClassification, UnitExists, InCombatLockdown, UnitCanAttack
local UnitGUID, GetPlayerInfoByGUID, Ambiguate, UnitName, UnitHealth, UnitHealthMax = UnitGUID, GetPlayerInfoByGUID, Ambiguate, UnitName, UnitHealth, UnitHealthMax
local SetCVar, UIFrameFadeIn, UIFrameFadeOut = SetCVar, UIFrameFadeIn, UIFrameFadeOut
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local INTERRUPTED = INTERRUPTED
local _QuestieTooltips, _QuestiePlayer

local DBM, QuestieLoader = DBM, QuestieLoader
local Codex, CodexDB, CodexMap = Codex, CodexDB, CodexMap
local GetNumQuestLogEntries, GetQuestLogTitle = GetNumQuestLogEntries, GetQuestLogTitle
local GetSpellInfo = GetSpellInfo

-- Init
function Nameplates:UpdateCVars()
	SetCVar("ClampTargetNameplateToScreen", Config.DB["Nameplates"]["ClampTarget"] and 1 or 0)
	SetCVar("nameplateMaxDistance", Config.DB["Nameplates"]["PlateRange"])
	SetCVar("namePlateMinScale", Config.DB["Nameplates"]["MinScale"])
	SetCVar("namePlateMaxScale", Config.DB["Nameplates"]["MinScale"])
	SetCVar("nameplateMinAlpha", Config.DB["Nameplates"]["MinAlpha"])
	SetCVar("nameplateMaxAlpha", Config.DB["Nameplates"]["MinAlpha"])
	SetCVar("nameplateNotSelectedAlpha", Config.DB["Nameplates"]["MinAlpha"])
	SetCVar("nameplateOverlapV", Config.DB["Nameplates"]["VerticalSpacing"])
end

local function SetupCVars()
	Nameplates:UpdateCVars()
	SetCVar("nameplateOverlapH", .8)
	SetCVar("nameplateSelectedAlpha", 1)

	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateLargerScale", 1)
	SetCVar("nameplateGlobalScale", 1)

	if C_AddOns.IsAddOnLoaded("Questie") and QuestieLoader then
		_QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
		_QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")

		local _QuestieEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
		if _QuestieEventHandler and _QuestieEventHandler.private then
			hooksecurefunc(_QuestieEventHandler.private, "UpdateAllQuests", function()
				for _, plate in pairs(C_NamePlate.GetNamePlates()) do
					if plate.unitFrame then
						Nameplates.UpdateQuestIndicator(plate.unitFrame)
					end
				end
			end)
		end
	end
end

local function BlockAddons()
	if not Config.DB["Nameplates"]["BlockDBM"] then return end
	if not DBM or not DBM.Nameplate then return end

	if DBM.Options then
		DBM.Options.DontShowNameplateIcons = true
		DBM.Options.DontShowNameplateIconsCD = true
		DBM.Options.DontShowNameplateIconsCast = true
	end

	local function showAurasForDBM(_, _, _, spellID)
		if not tonumber(spellID) then return end
		if not Config.Nameplates.WhiteList[spellID] then
			Config.Nameplates.WhiteList[spellID] = true
		end
	end

	hooksecurefunc(DBM.Nameplate, "Show", showAurasForDBM)
end

local function RefreshUnits(VALUE)
	wipe(Nameplates[VALUE])
	if not Config.DB["Nameplates"]["Show"..VALUE] then return end

	for npcID in pairs(Config.Nameplates[VALUE]) do
		if Config.DB["Nameplates"][VALUE][npcID] == nil then
			Nameplates[VALUE][npcID] = true
		end
	end
	for npcID, value in pairs(Config.DB["Nameplates"][VALUE]) do
		if value then
			Nameplates[VALUE][npcID] = true
		end
	end
end

Nameplates.CustomUnits = {}
function Nameplates:CreateUnitTable()
	RefreshUnits("CustomUnits")
end

-- Off-tank threat color
local groupRoles, isInGroup, myRole = {}, nil, nil
local function RefreshGroupRoles()
	local isInRaid = IsInRaid()
	isInGroup = isInRaid or IsInGroup()
	wipe(groupRoles)
	myRole = UnitGroupRolesAssigned("player")

	if isInGroup then
		local numPlayers = (isInRaid and GetNumGroupMembers()) or GetNumSubgroupMembers()
		local unit = (isInRaid and "raid") or "party"
		for i = 1, numPlayers do
			local index = unit..i
			if UnitExists(index) then
				groupRoles[UnitName(index)] = UnitGroupRolesAssigned(index)
			end
		end
	end
end

local function ResetGroupRoles()
	isInGroup = IsInRaid() or IsInGroup()
	wipe(groupRoles)
end

function Nameplates:UpdateGroupRoles()
	RefreshGroupRoles()
	Core:RegisterEvent("GROUP_ROSTER_UPDATE", RefreshGroupRoles)
	Core:RegisterEvent("GROUP_LEFT", ResetGroupRoles)
end

function Nameplates:CheckThreatStatus(unit)
	if not UnitExists(unit) then return end

	local unitTarget = unit.."target"
	local unitRole = isInGroup and UnitExists(unitTarget) and not UnitIsUnit(unitTarget, "player") and groupRoles[UnitName(unitTarget)] or "NONE"
	if myRole == "TANK" and unitRole == "TANK" then
		return true, UnitThreatSituation(unitTarget, unit)
	else
		return false, UnitThreatSituation("player", unit)
	end
end

function Nameplates:UpdateColor(_, unit)
	if not unit or self.unit ~= unit then return end

	local element = self.Health
	local name = self.unitName
	local npcID = self.npcID
	local isCustomUnit = Nameplates.CustomUnits[name] or Nameplates.CustomUnits[npcID]
	local isPlayer = self.isPlayer
	local isFriendly = self.isFriendly
	local isOffTank, status
	if Config.DB["Nameplates"]["OffTankThreat"] then
		isOffTank, status = Nameplates:CheckThreatStatus(unit)
	else
		status = UnitThreatSituation("player", unit)
	end
	local customColor = Config.DB["Nameplates"]["CustomColor"]
	local secureColor = Config.DB["Nameplates"]["SecureColor"]
	local transColor = Config.DB["Nameplates"]["TransColor"]
	local insecureColor = Config.DB["Nameplates"]["InsecureColor"]
    local revertThreat = Config.DB["Nameplates"]["DPSRevertThreat"]
	local offTankColor = Config.DB["Nameplates"]["OffTankColor"]
	local targetColor = Config.DB["Nameplates"]["TargetColor"]
	local focusColor = Config.DB["Nameplates"]["FocusColor"]
	local dotColor = Config.DB["Nameplates"]["DotColor"]
	local r, g, b

	local isSolo = ( (not IsInGroup()) or (GetNumGroupMembers() == 1) )

    if not UnitIsConnected(unit) then
        r, g, b = .7, .7, .7
    else
        if Config.DB["Nameplates"]["ColoredTarget"] and UnitIsUnit(unit, "target") then
            r, g, b = targetColor.r, targetColor.g, targetColor.b
        elseif Config.DB["Nameplates"]["ColoredFocus"] and UnitIsUnit(unit, "focus") then
            r, g, b = focusColor.r, focusColor.g, focusColor.b
        elseif isCustomUnit then
            r, g, b = customColor.r, customColor.g, customColor.b
        elseif self.Auras.hasTheDot then
            r, g, b = dotColor.r, dotColor.g, dotColor.b
        elseif isPlayer and isFriendly then
            if Config.DB["Nameplates"]["FriendlyCC"] then
                r, g, b = Core.UnitColor(unit)
            else
                r, g, b = .3, .3, 1
            end
        elseif isPlayer and (not isFriendly) and Config.DB["Nameplates"]["HostileCC"] then
            r, g, b = Core.UnitColor(unit)
        elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
            r, g, b = .6, .6, .6
        else
            r, g, b = UnitSelectionColor(unit, true)
             if status and (Config.DB["Nameplates"]["TankMode"] or DB.IsTank or isSolo) then
                if status == 3 then
                    if not DB.IsTank and revertThreat and not isSolo then
                        r, g, b = insecureColor.r, insecureColor.g, insecureColor.b
                    else
                        if isOffTank then
                            r, g, b = offTankColor.r, offTankColor.g, offTankColor.b
                        else
                            r, g, b = secureColor.r, secureColor.g, secureColor.b
                        end
                    end
                elseif status == 2 or status == 1 then
                    r, g, b = transColor.r, transColor.g, transColor.b
                elseif status == 0 then
                    if not DB.IsTank and revertThreat and not isSolo then
                        r, g, b = secureColor.r, secureColor.g, secureColor.b
                    else
                        r, g, b = insecureColor.r, insecureColor.g, insecureColor.b
                    end
                end
            end
        end
		-- else
        --     r, g, b = UnitSelectionColor(unit, true)
        --     if status and isSolo then
        --         if status == 3 then
        --             if revertThreat and not isSolo then
        --                 r, g, b = insecureColor.r, insecureColor.g, insecureColor.b
        --             else
        --                 if isOffTank then
        --                     r, g, b = offTankColor.r, offTankColor.g, offTankColor.b
        --                 else
        --                     r, g, b = secureColor.r, secureColor.g, secureColor.b
        --                 end
        --             end
        --         elseif status == 2 or status == 1 then
        --             r, g, b = transColor.r, transColor.g, transColor.b
        --         elseif status == 0 then
        --             if revertThreat and not isSolo then
        --                 r, g, b = secureColor.r, secureColor.g, secureColor.b
        --             else
        --                 r, g, b = insecureColor.r, insecureColor.g, insecureColor.b
        --             end
        --         end
        --     end
        -- end
    end

	if r or g or b then
		element:SetStatusBarColor(r, g, b)
	end

	self.ThreatIndicator:Hide()
	if status and (isCustomUnit or not Config.DB["Nameplates"]["TankMode"]) then
		if status == 3 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 0, 0)
			self.ThreatIndicator:Show()
		elseif status == 2 or status == 1 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 1, 0)
			self.ThreatIndicator:Show()
		end
	end

	self.nameText:SetTextColor(1, 1, 1)
end

function Nameplates:UpdateThreatColor(_, unit)
	if unit ~= self.unit then return end

	Nameplates.UpdateColor(self, _, unit)
end

local function CreateThreatColor(frame)
	local threatIndicator = Core.CreateSD(frame.backdrop, nil, true)
	threatIndicator:Hide()
	frame.backdrop.__shadow = nil

	frame.ThreatIndicator = threatIndicator
	frame.ThreatIndicator.Override = Nameplates.UpdateThreatColor
end

function Nameplates:UpdateFocusColor()
	if Config.DB["Nameplates"]["ColoredFocus"] then
		Nameplates.UpdateThreatColor(self, _, self.unit)
	end
end

-- Target indicator
function Nameplates:UpdateTargetChange()
	local element = self.TargetIndicator
	local unit = self.unit

	if UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player") then
		element:Show()
	else
		element:Hide()
	end

	if Config.DB["Nameplates"]["ColoredTarget"] then
		Nameplates.UpdateThreatColor(self, _, unit)
	end
end

local function UpdateTargetGlow(frame)
	local element = frame.TargetIndicator
	local isNameOnly = frame.plateType == "NameOnly"

	if isNameOnly then
		element.Glow:Hide()
		element.nameGlow:Show()
	else
		element.Glow:Show()
		element.nameGlow:Hide()
	end

	element:Show()
end

local function AddTargetIndicator(frame)
	local targetIndicator = CreateFrame("Frame", nil, frame)
	targetIndicator:SetAllPoints()
	targetIndicator:SetFrameLevel(0)
	targetIndicator:Hide()

	targetIndicator.Glow = Core.CreateSD(targetIndicator, 8, true)
	Core:SetOutside(targetIndicator.Glow, frame.backdrop, 8, 8)
	targetIndicator.Glow:SetBackdropBorderColor(1, 1, 1)
	targetIndicator.Glow:SetFrameLevel(0)

	targetIndicator.nameGlow = targetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	targetIndicator.nameGlow:SetSize(150, 80)
	targetIndicator.nameGlow:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
	targetIndicator.nameGlow:SetVertexColor(0, .6, 1)
	targetIndicator.nameGlow:SetBlendMode("ADD")
	targetIndicator.nameGlow:SetPoint("CENTER", frame, "BOTTOM")

	frame.TargetIndicator = targetIndicator
	frame:RegisterEvent("PLAYER_TARGET_CHANGED", function() UpdateTargetGlow(frame) end, true)

	UpdateTargetGlow(frame)
end

-- Quest progress
local isInInstance
local function CheckInstanceStatus()
	isInInstance = IsInInstance()
end

function Nameplates:QuestIconCheck()
	CheckInstanceStatus()
	Core:RegisterEvent("PLAYER_ENTERING_WORLD", CheckInstanceStatus)
end

function Nameplates:UpdateQuestUnit(_, unit)
	if not Config.DB["Nameplates"]["QuestIndicator"] then return end
	if isInInstance then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end

	unit = unit or self.unit

	local isLootQuest, questProgress
	Core.ScanTip:SetOwner(UIParent, "ANCHOR_NONE")
	Core.ScanTip:SetUnit(unit)

	for i = 2, Core.ScanTip:NumLines() do
		local textLine = _G["LauringUI_ScanTooltipTextLeft"..i]
		local text = textLine:GetText()
		if textLine and text then
			local r, g, b = textLine:GetTextColor()
			local unitName, progressText = strmatch(text, "^ ([^ ]-) ?%- (.+)$")
			if r > .99 and g > .82 and b == 0 then
				isLootQuest = true
			elseif unitName and progressText then
				isLootQuest = false
				if unitName == "" or unitName == DB.MyName then
					local current, goal = strmatch(progressText, "(%d+)/(%d+)")
					local progress = strmatch(progressText, "([%d%.]+)%%")
					if current and goal then
						if tonumber(current) < tonumber(goal) then
							questProgress = goal - current
							break
						end
					elseif progress then
						progress = tonumber(progress)
						if progress and progress < 100 then
							questProgress = progress.."%"
							break
						end
					else
						isLootQuest = true
						break
					end
				end
			end
		end
	end

	if questProgress then
		self.questCount:SetText(questProgress)
		self.questIcon:SetAtlas(DB.ObjectTexture)
		self.questIcon:Show()
	else
		self.questCount:SetText("")
		if isLootQuest then
			self.questIcon:SetAtlas(DB.QuestTexture)
			self.questIcon:Show()
		else
			self.questIcon:Hide()
		end
	end
end

function Nameplates:UpdateForQuestie(npcID)
	local data = _QuestieTooltips.lookupByKey and _QuestieTooltips.lookupByKey["m_"..npcID]
	if data then
		local foundObjective, progressText
		for _, tooltip in pairs(data) do
			if not tooltip.npc then
				local questID = tooltip.questId
				if questID then
					if _QuestiePlayer.currentQuestlog[questID] then
						foundObjective = true

						if tooltip.objective and tooltip.objective.Needed then
							progressText = tooltip.objective.Needed - tooltip.objective.Collected
							if progressText == 0 then
								foundObjective = nil
							end
							break
						end
					end
				end
			end
		end

		if foundObjective then
			self.questIcon:Show()
			self.questCount:SetText(progressText)
		end
	end
end

function Nameplates:UpdateCodexQuestUnit(name)
	if name and CodexMap.tooltips[name] then
		for _, meta in pairs(CodexMap.tooltips[name]) do
			local questData = meta["quest"]
			local quests = CodexDB.quests.loc

			if questData then
				for questIndex = 1, GetNumQuestLogEntries() do
					local _, _, _, header, _, _, _, questId = GetQuestLogTitle(questIndex)
					if not header and quests[questId] and questData == quests[questId].T then
						local objectives = GetNumQuestLeaderBoards(questIndex)
						local foundObjective, progressText = nil, nil
						if objectives then
							for i = 1, objectives do
								local text, type = GetQuestLogLeaderBoard(i, questIndex)
								if type == "monster" then
									local _, _, monsterName, objNum, objNeeded = strfind(text, Codex:SanitizePattern(QUEST_MONSTERS_KILLED))
									if meta["spawn"] == monsterName then
										progressText = objNeeded - objNum
										foundObjective = true
										break
									end
								elseif #meta["item"] > 0 and type == "item" and meta["dropRate"] then
									local _, _, itemName, objNum, objNeeded = strfind(text, Codex:SanitizePattern(QUEST_OBJECTS_FOUND))
									for _, item in pairs(meta["item"]) do
										if item == itemName then
											progressText = objNeeded - objNum
											foundObjective = true
											break
										end
									end
								end
							end
						end

						if foundObjective and progressText > 0 then
							self.questIcon:Show()
							self.questCount:SetText(progressText)
						elseif not foundObjective then
							self.questIcon:Show()
						end
					end
				end
			end
		end
	end
end

function Nameplates:UpdateQuestIndicator()
	if not Config.DB["Nameplates"]["QuestIndicator"] then return end

	self.questIcon:Hide()
	self.questCount:SetText("")
	if isInInstance then return end

	if CodexMap then
		Nameplates.UpdateCodexQuestUnit(self, self.unitName)
	elseif _QuestieTooltips and _QuestiePlayer then
		Nameplates.UpdateForQuestie(self, self.npcID)
	end
end

local function AddQuestIcon(frame)
	if not Config.DB["Nameplates"]["QuestIndicator"] then return end

	local qicon = frame:CreateTexture(nil, "OVERLAY", nil, 2)
	qicon:SetPoint("LEFT", frame, "RIGHT", 4, 0)
	qicon:SetSize(30, 30)
	qicon:SetAtlas(DB.QuestTexture)
	qicon:Hide()
	local count = Core.CreateFS(frame, 20, "", nil, "LEFT", 0, 0)
	count:SetPoint("LEFT", qicon, "RIGHT", -4, 0)
	count:SetTextColor(.6, .8, 1)

	frame.questIcon = qicon
	frame.questCount = count
	--self:RegisterEvent("QUEST_LOG_UPDATE", UF.UpdateQuestUnit, true)
	frame:RegisterEvent("QUEST_LOG_UPDATE", Nameplates.UpdateQuestIndicator, true)
end

-- Unit classification
local NPClassifies = {
	rare = {1, 1, 1, true},
	elite = {1, 1, 1},
	rareelite = {1, .1, .1},
	worldboss = {0, 1, 0},
}

local function AddCreatureIcon(frame)
	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetTexture(DB.StarTexture)
	icon:SetPoint("RIGHT", frame.nameText, "LEFT", 10, 0)
	icon:SetSize(18, 18)
	icon:Hide()

	frame.ClassifyIndicator = icon
end

function Nameplates:UpdateUnitClassify(unit)
	if not self.ClassifyIndicator then return end
	if not unit then unit = self.unit end

	self.ClassifyIndicator:Hide()

	if self.__tagIndex > 3 then
		local class = UnitClassification(unit)
		local classify = class and NPClassifies[class]
		if classify then
			local r, g, b, desature = unpack(classify)
			self.ClassifyIndicator:SetVertexColor(r, g, b)
			self.ClassifyIndicator:SetDesaturated(desature)
			self.ClassifyIndicator:Show()
		end
	end
end

-- Mouseover indicator
function Nameplates:IsMouseoverUnit()
	if not self or not self.unit then return end

	if self:IsVisible() and UnitExists("mouseover") then
		return UnitIsUnit("mouseover", self.unit)
	end
	return false
end

function Nameplates:UpdateMouseoverShown()
	if not self or not self.unit then return end

	if self:IsShown() and UnitIsUnit("mouseover", self.unit) then
		self.HighlightIndicator:Show()
		self.HighlightUpdater:Show()
	else
		self.HighlightUpdater:Hide()
	end
end

function Nameplates:HighlightOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		if not Nameplates.IsMouseoverUnit(self.__owner) then
			self:Hide()
		end
		self.elapsed = 0
	end
end

function Nameplates:HighlightOnHide()
	self.__owner.HighlightIndicator:Hide()
end

local function MouseoverIndicator(frame)
	local highlight = CreateFrame("Frame", nil, frame.Health)
	highlight:SetAllPoints(frame)
	highlight:Hide()
	local texture = highlight:CreateTexture(nil, "ARTWORK")
	texture:SetAllPoints()
	texture:SetColorTexture(1, 1, 1, .25)

	frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT", Nameplates.UpdateMouseoverShown, true)

	local updater = CreateFrame("Frame", nil, frame)
	updater.__owner = frame
	updater:SetScript("OnUpdate", Nameplates.HighlightOnUpdate)
	updater:HookScript("OnHide", Nameplates.HighlightOnHide)

	frame.HighlightIndicator = highlight
	frame.HighlightUpdater = updater
end

-- Interrupt info on castbars
function Nameplates:UpdateSpellInterruptor(...)
	if not Config.DB["Nameplates"]["Interruptor"] then return end

	local _, _, sourceGUID, sourceName, _, _, destGUID = ...
	if destGUID == self.unitGUID and sourceGUID and sourceName and sourceName ~= "" then
		local _, class = GetPlayerInfoByGUID(sourceGUID)
		local r, g, b = Core.ClassColor(class)
		local color = Core.HexRGB(r, g, b)
		local ambiguateSourceName = Ambiguate(sourceName, "short")
		self.Castbar.Text:SetText(INTERRUPTED.." > "..color..ambiguateSourceName)
		self.Castbar.Time:SetText("")
	end
end

local function SpellInterruptor(frame)
	if not frame.Castbar then return end
	frame:RegisterCombatEvent("SPELL_INTERRUPT", Nameplates.UpdateSpellInterruptor)
end

local function ShowUnitTargeted(frame)
	local tex = frame:CreateTexture()
	tex:SetSize(20, 20)
	tex:SetPoint("LEFT", frame, "RIGHT", 5, 0)
	tex:SetAtlas("target")
	tex:Hide()
	local count = Core.CreateFS(frame, 22)
	count:SetPoint("LEFT", tex, "RIGHT", 1, 0)
	count:SetTextColor(1, .8, 0)

	frame.tarByTex = tex
	frame.tarBy = count
end

local function CreateFrameText(frame)
	local textFrame = CreateFrame("Frame", nil, frame)
	textFrame:SetAllPoints(frame.Health)

    local nameFontSize = Config.DB["Nameplates"].NameTextSize
	local name = Core.CreateFS(textFrame, nameFontSize, "", false, "LEFT", 3, 0)
    frame.nameText = name
	name:SetJustifyH("LEFT")
    name:ClearAllPoints()
    name:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 5)
    name:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 5)
    frame:Tag(name, "[nplevel][abbrevname]")

    local healthFontSize = Config.DB["Nameplates"].HealthTextSize
    local healthText = Core.CreateFS(textFrame, healthFontSize, "", false, "RIGHT", -3, 0)
    healthText:SetPoint("RIGHT", frame, 0, 5)
    frame:Tag(healthText, "[VariousHP(currentpercent)]")
	frame.healthValue = healthText
end

local platesList = {}
function Nameplates:Create()
	self.mystyle = "Nameplate"
	self:SetSize(Config.DB["Nameplates"]["PlateWidth"], Config.DB["Nameplates"]["PlateHeight"])
	self:SetPoint("CENTER")
	self:SetScale(LauringUIAccountDB["UIScale"])

	local health = CreateFrame("StatusBar", nil, self)
	health:SetAllPoints()
	health:SetStatusBarTexture(DB.StatusBarTexture2)
	self.backdrop = Core.SetBD(health)
	self.backdrop.__shadow = nil
	Core:SmoothBar(health)

	self.Health = health
	self.Health.frequentUpdates = true
	self.Health.UpdateColor = Nameplates.UpdateColor

	local tarName = Core.CreateFS(self, Config.DB["Nameplates"]["NameTextSize"]+4)
	tarName:ClearAllPoints()
	tarName:SetPoint("TOP", self, "BOTTOM", 0, -10)
	tarName:Hide()
	self:Tag(tarName, "[tarname]")
	self.tarName = tarName

	CreateFrameText(self)
	UF:CreateCastbar(self)
	UF:CreateRaidMark(self)
	UF:CreateHealPrediction(self)
	UF:CreateAuras(self)
	CreateThreatColor(self)

	self.Auras.showStealableBuffs = Config.DB["Nameplates"]["DispellMode"] == 1
	self.Auras.alwaysShowStealable = Config.DB["Nameplates"]["DispellMode"] == 2

	local title = Core.CreateFS(self, Config.DB["Nameplates"]["NameTextSize"]-1)
	title:ClearAllPoints()
	title:SetPoint("TOP", self.nameText, "BOTTOM", 0, -3)
	title:Hide()
	self:Tag(title, "[npctitle]")
	self.npcTitle = title

	MouseoverIndicator(self)
	AddTargetIndicator(self)
	AddCreatureIcon(self)
	AddQuestIcon(self)
	SpellInterruptor(self)
	ShowUnitTargeted(self)

	self:RegisterEvent("PLAYER_FOCUS_CHANGED", Nameplates.UpdateFocusColor, true)

	platesList[self] = self:GetName()
end

local function ToggleAuras(frame)
	if Config.DB["Nameplates"]["PlateAuras"] then
		if not frame:IsElementEnabled("Auras") then
			frame:EnableElement("Auras")
		end
	else
		if frame:IsElementEnabled("Auras") then
			frame:DisableElement("Auras")
		end
	end
end

function Nameplates:UpdateAuras()
	ToggleAuras(self)

	if not Config.DB["Nameplates"]["PlateAuras"] then return end

	local element = self.Auras
	element:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 5)
	element.numTotal = Config.DB["Nameplates"]["maxAuras"]
	element.size = Config.DB["Nameplates"]["AuraSize"]
	element.fontSize = Config.DB["Nameplates"]["FontSize"]
	element.showDebuffType = Config.DB["Nameplates"]["DebuffColor"]
	element.showStealableBuffs = Config.DB["Nameplates"]["DispellMode"] == 1
	element.alwaysShowStealable = Config.DB["Nameplates"]["DispellMode"] == 2
	element.desaturateDebuff = Config.DB["Nameplates"]["Desaturate"]
	UF:UpdateAuraContainer(self, element, element.numTotal)
	element:ForceUpdate()
end

local nameTags = {
	[1] = "",
	[2] = "[name]",
	[3] = "[nplevel][abbrevname]",
	[4] = "[nprare][abbrevname]",
	[5] = "[nprare][nplevel][abbrevname]",
}

local function UpdateSize(frame)
	local plateWidth, plateHeight = Config.DB["Nameplates"]["PlateWidth"], Config.DB["Nameplates"]["PlateHeight"]
	local plateCBHeight, plateCBOffset = Config.DB["Nameplates"]["PlateCBHeight"], Config.DB["Nameplates"]["PlateCBOffset"]
	local nameTextSize, CBTextSize = Config.DB["Nameplates"]["NameTextSize"], Config.DB["Nameplates"]["CBTextSize"]
	local healthTextSize = Config.DB["Nameplates"]["HealthTextSize"]
	local healthTextOffset = Config.DB["Nameplates"]["HealthTextOffset"]
	if Config.DB["Nameplates"]["FriendPlate"] and frame.isFriendly and not Config.DB["Nameplates"]["NameOnlyMode"] then -- cannot use plateType here
		plateWidth, plateHeight = Config.DB["Nameplates"]["FriendPlateWidth"], Config.DB["Nameplates"]["FriendPlateHeight"]
		plateCBHeight, plateCBOffset = Config.DB["Nameplates"]["FriendPlateCBHeight"], Config.DB["Nameplates"]["FriendPlateCBOffset"]
		nameTextSize, CBTextSize = Config.DB["Nameplates"]["FriendNameSize"], Config.DB["Nameplates"]["FriendCBTextSize"]
		healthTextSize = Config.DB["Nameplates"]["FriendHealthSize"]
		healthTextOffset = Config.DB["Nameplates"]["FriendHealthOffset"]
	end
	local iconSize = plateHeight + plateCBHeight + 5
	local nameType = Config.DB["Nameplates"]["NameType"]
	local nameOnlyTextSize, nameOnlyTitleSize = Config.DB["Nameplates"]["NameOnlyTextSize"], Config.DB["Nameplates"]["NameOnlyTitleSize"]

	if frame.plateType == "NameOnly" then
		Core.SetFontSize(frame.nameText, nameOnlyTextSize)
		frame:Tag(frame.nameText, "[nprare][nplevel][color][name]")
		frame.__tagIndex = 6
		Core.SetFontSize(frame.npcTitle, nameOnlyTitleSize)
		frame.npcTitle:UpdateTag()
	else
		Core.SetFontSize(frame.nameText, nameTextSize)
		frame:Tag(frame.nameText, nameTags[nameType])
		frame.__tagIndex = nameType

		frame:SetSize(plateWidth, plateHeight)
		Core.SetFontSize(frame.tarName, nameTextSize+4)
		frame.Castbar.Icon:SetSize(iconSize, iconSize)
		frame.Castbar.glowFrame:SetSize(iconSize+8, iconSize+8)
		frame.Castbar:SetHeight(plateCBHeight)
		Core.SetFontSize(frame.Castbar.Time, CBTextSize)
		frame.Castbar.Time:SetPoint("TOPRIGHT", frame.Castbar, "RIGHT", 0, plateCBOffset)
		Core.SetFontSize(frame.Castbar.Text, CBTextSize)
		frame.Castbar.Text:SetPoint("TOPLEFT", frame.Castbar, "LEFT", 0, plateCBOffset)
		frame.Castbar.Shield:SetPoint("TOP", frame.Castbar, "CENTER", 0, plateCBOffset)
		frame.Castbar.Shield:SetSize(CBTextSize + 4, CBTextSize + 4)
		Core.SetFontSize(frame.Castbar.spellTarget, CBTextSize+3)
		Core.SetFontSize(frame.healthValue, healthTextSize)
		frame.healthValue:SetPoint("RIGHT", frame, 0, healthTextOffset)
		frame:Tag(frame.healthValue, "[VariousHP("..UF.VariousTagIndex[Config.DB["Nameplates"]["HealthType"]]..")]")
		frame.healthValue:UpdateTag()
	end
	frame.nameText:UpdateTag()
end

function Nameplates:RefreshAll()
	for nameplate in pairs(platesList) do
		UpdateSize(nameplate)
		Nameplates.UpdateUnitClassify(nameplate)
		Nameplates.UpdateAuras(nameplate)
		UpdateTargetGlow(nameplate)
		Nameplates.UpdateTargetChange(nameplate)
	end
end

local DisabledElements = {
	"Health", "Castbar", "HealthPrediction", "ThreatIndicator"
}
local function UpdateByType(frame)
	local name = frame.nameText
	local hpval = frame.healthValue
	local title = frame.npcTitle
	local raidtarget = frame.RaidTargetIndicator
	local questIcon = frame.questIcon

	name:ClearAllPoints()
	raidtarget:ClearAllPoints()

	if frame.plateType == "NameOnly" then
		for _, element in pairs(DisabledElements) do
			if frame:IsElementEnabled(element) then
				frame:DisableElement(element)
			end
		end

		name:SetJustifyH("CENTER")
		name:SetPoint("CENTER", frame, "BOTTOM")
		hpval:Hide()
		title:Show()

		raidtarget:SetPoint("TOP", title, "BOTTOM", 0, -5)
		if questIcon then questIcon:SetPoint("LEFT", name, "RIGHT", -1, 0) end
	else
		for _, element in pairs(DisabledElements) do
			if not frame:IsElementEnabled(element) then
				frame:EnableElement(element)
			end
		end

		name:SetJustifyH("LEFT")
		name:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 5)
		name:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 5)
		hpval:Show()
		title:Hide()

		raidtarget:SetPoint("BOTTOMRIGHT", frame, "TOPLEFT", 0, 3)
		if questIcon then questIcon:SetPoint("LEFT", frame, "RIGHT", -1, 0) end
	end

	UpdateSize(frame)
	UpdateTargetGlow(frame)
	ToggleAuras(frame)
end

function Nameplates:RefreshPlateType(unit)
	self.reaction = UnitReaction(unit, "player")
	self.isFriendly = self.reaction and self.reaction >= 4 and not UnitCanAttack("player", unit)
	if Config.DB["Nameplates"]["NameOnlyMode"] and self.isFriendly or self.widgetsOnly then
		self.plateType = "NameOnly"
	elseif Config.DB["Nameplates"]["FriendPlate"] and self.isFriendly then
		self.plateType = "FriendPlate"
	else
		self.plateType = "None"
	end

	if self.previousType == nil or self.previousType ~= self.plateType then
		UpdateByType(self)
		self.previousType = self.plateType
	end
end

function Nameplates:OnUnitFactionChanged(unit)
	local nameplate = C_NamePlate_GetNamePlateForUnit(unit)
	local unitFrame = nameplate and nameplate.unitFrame
	if unitFrame and unitFrame.unitName then
		Nameplates.RefreshPlateType(unitFrame, unit)
	end
end

local targetedList = {}

local function GetGroupUnit(index, maxGroups, isInRaid)
	if isInRaid then
		return "raid"..index
	elseif index == maxGroups then
		return "player"
	else
		return "party"..index
	end
end

local function OnUnitTargetChanged()
	if not isInInstance then return end

	wipe(targetedList)

	local maxGroups = GetNumGroupMembers()
	if maxGroups > 1 then
		local isInRaid = IsInRaid()
		for i = 1, maxGroups do
			local member = GetGroupUnit(i, maxGroups, isInRaid)
			local memberTarget = member.."target"
			if not UnitIsDeadOrGhost(member) and UnitExists(memberTarget) then
				local unitGUID = UnitGUID(memberTarget)
                if unitGUID then
                    targetedList[unitGUID] = (targetedList[unitGUID] or 0) + 1
                end
			end
		end
	end

	for nameplate in pairs(platesList) do
		nameplate.tarBy:SetText(targetedList[nameplate.unitGUID] or "")
		nameplate.tarByTex:SetShown(targetedList[nameplate.unitGUID])
	end
end

function Nameplates:RefreshByEvents()
	Core:RegisterEvent("UNIT_FACTION", Nameplates.OnUnitFactionChanged)

	if Config.DB["Nameplates"]["UnitTargeted"] then
		OnUnitTargetChanged()
		Core:RegisterEvent("UNIT_TARGET", OnUnitTargetChanged)
		Core:RegisterEvent("PLAYER_TARGET_CHANGED", OnUnitTargetChanged)
	else
		for nameplate in pairs(platesList) do
			nameplate.tarBy:SetText("")
			nameplate.tarByTex:Hide()
		end
		Core:UnregisterEvent("UNIT_TARGET", OnUnitTargetChanged)
		Core:UnregisterEvent("PLAYER_TARGET_CHANGED", OnUnitTargetChanged)
	end
end

local function UpdateTargetClassPower()
	local plate = _G.oUF_TargetPlate
	if not plate then return end

	local bar = plate.ClassPowerBar
	local nameplate = C_NamePlate_GetNamePlateForUnit("target")
	if nameplate then
		bar:SetParent(nameplate.unitFrame)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOM", nameplate.unitFrame.nameText, "TOP", 0, 5)
		bar:Show()
	else
		bar:Hide()
	end
end

function Nameplates:PostUpdate(event, unit)
	if not self then return end

	if event == "NAME_PLATE_UNIT_ADDED" then
		self.unitName = UnitName(unit)
		self.unitGUID = UnitGUID(unit)
		self.npcID = Core.GetNPCID(self.unitGUID)
		self.isPlayer = UnitIsPlayer(unit)

		Nameplates.RefreshPlateType(self, unit)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		self.npcID = nil
		self.tarBy:SetText("")
		self.tarByTex:Hide()
	end

	if event ~= "NAME_PLATE_UNIT_REMOVED" then
		Nameplates.UpdateTargetChange(self)
		--UF.UpdateQuestUnit(self, event, unit)
		Nameplates.UpdateQuestIndicator(self)
		Nameplates.UpdateUnitClassify(self, unit)
		UpdateTargetClassPower()

		self.tarName:SetShown(self.plateType ~= "NameOnly" and Config.DB["Nameplates"]["TarName"])
	end
end

-- Player Nameplate
function Nameplates:Visibility(event)
	local alpha = Config.DB["Nameplates"]["FadeoutAlpha"]
	if (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) and UnitIsUnit("player", self.unit) then
		UIFrameFadeIn(self.Health, .3, self.Health:GetAlpha(), 1)
		UIFrameFadeIn(self.Health.bg, .3, self.Health.bg:GetAlpha(), 1)
		UIFrameFadeIn(self.predicFrame, .3, self:GetAlpha(), 1)
	else
		UIFrameFadeOut(self.Health, 2, self.Health:GetAlpha(), alpha)
		UIFrameFadeOut(self.Health.bg, 2, self.Health.bg:GetAlpha(), alpha)
		UIFrameFadeOut(self.predicFrame, 2, self:GetAlpha(), alpha)
	end
end

function Nameplates:ToggleVisibility()
	local plate = _G.oUF_PlayerPlate
	if not plate then return end

	if Config.DB["Nameplates"]["Fadeout"] then
		plate:RegisterEvent("UNIT_EXITED_VEHICLE", Nameplates.Visibility)
		plate:RegisterEvent("UNIT_ENTERED_VEHICLE", Nameplates.Visibility)
		plate:RegisterEvent("PLAYER_REGEN_ENABLED", Nameplates.Visibility, true)
		plate:RegisterEvent("PLAYER_REGEN_DISABLED", Nameplates.Visibility, true)
		plate:RegisterEvent("PLAYER_ENTERING_WORLD", Nameplates.Visibility, true)
		Nameplates.Visibility(plate)
	else
		plate:UnregisterEvent("UNIT_EXITED_VEHICLE", Nameplates.Visibility)
		plate:UnregisterEvent("UNIT_ENTERED_VEHICLE", Nameplates.Visibility)
		plate:UnregisterEvent("PLAYER_REGEN_ENABLED", Nameplates.Visibility)
		plate:UnregisterEvent("PLAYER_REGEN_DISABLED", Nameplates.Visibility)
		plate:UnregisterEvent("PLAYER_ENTERING_WORLD", Nameplates.Visibility)
		Nameplates.Visibility(plate, "PLAYER_REGEN_DISABLED")
	end
end

Nameplates.MajorSpells = {}
function Nameplates:RefreshMajorSpells()
	wipe(Nameplates.MajorSpells)

	for spellID in pairs(Config.Nameplates.MajorSpells) do
		local name = GetSpellInfo(spellID)
		if name then
			local modValue = LauringUIAccountDB["MajorSpells"][spellID]
			if modValue == nil then
				Nameplates.MajorSpells[spellID] = true
			end
		end
	end

	for spellID, value in pairs(LauringUIAccountDB["MajorSpells"]) do
		if value then
			Nameplates.MajorSpells[spellID] = true
		end
	end
end

Nameplates.NameplateWhite = {}
Nameplates.NameplateBlack = {}

local function RefreshNameplateFilter(list, key)
	wipe(Nameplates[key])

	for spellID in pairs(list) do
		local name = GetSpellInfo(spellID)
		if name then
			if LauringUIAccountDB[key][spellID] == nil then
				Nameplates[key][spellID] = true
			end
		end
	end

	for spellID, value in pairs(LauringUIAccountDB[key]) do
		if value then
			Nameplates[key][spellID] = true
		end
	end
end

function Nameplates:RefreshFilters()
	RefreshNameplateFilter(Config.Nameplates.WhiteList, "NameplateWhite")
	RefreshNameplateFilter(Config.Nameplates.BlackList, "NameplateBlack")
end

function Nameplates:OnLogin()
    if not Config.DB["Nameplates"]["Enable"] then return end

    SetupCVars()
    BlockAddons()
    Nameplates:CreateUnitTable()
    Nameplates:UpdateGroupRoles()
    Nameplates:QuestIconCheck()
    Nameplates:RefreshByEvents()
    Nameplates:RefreshMajorSpells()
    Nameplates:RefreshFilters()

    oUF:RegisterStyle("Nameplates", Nameplates.Create)
    oUF:SetActiveStyle("Nameplates")
    oUF:SpawnNamePlates("oUF_NPs", Nameplates.PostUpdate)
end