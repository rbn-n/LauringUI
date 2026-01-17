local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

local GetSpellInfo = GetSpellInfo

local function UpdateAllHeaders()
	Core:GetModule("UnitFrames"):UpdateAllHeaders()
end

local function RefreshDebuffsIndicator()
	Core:GetModule("UnitFrames"):UpdateRaidDebuffsBlack()
end

local function UpdateCornerSpells()
	Core:GetModule("UnitFrames"):UpdateCornerSpells()
end

local function UpdateRaidDebuffs()
	Core:GetModule("UnitFrames"):UpdateRaidDebuffs()
end

local function SetupRaidFrame(parent)
	local guiName = "LauringUI_RaidFrameSetup"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName, L["RaidFrame"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)
	local UF = Core:GetModule("UnitFrames")

	local defaultValue = {80, 32, 2, 8, 1, 5}
	local options = {}
	for i = 1, 8 do
		options[i] = UF.RaidDirections[i].name
	end

	local function UpdateRaidDirection()
		if UF.CreateAndUpdateRaidHeader then
			UF:CreateAndUpdateRaidHeader(true)
			UF:UpdateRaidTeamIndex()
		end
	end

	local function ResizeRaidFrame()
		for _, frame in pairs(ns.oUF.objects) do
			if frame.mystyle == "Raid" or frame.mystyle == "Raid10" then
				G:SetUnitFrameSize(frame, UF)
				UF:SetPartyAndRaidName(frame.nameText, frame)
			end
		end
		if UF.CreateAndUpdateRaidHeader then
			UF:CreateAndUpdateRaidHeader()
		end
	end

	local function UpdateNumGroups()
		if UF.CreateAndUpdateRaidHeader then
			UF:CreateAndUpdateRaidHeader()
			UF:UpdateRaidTeamIndex()
			UF:UpdateAllHeaders()
		end
	end

	G:CreateOptionCheck(scroll.child, -10, L["RaidSortByRole"], "UFs", "RaidSortByRole", ResizeRaidFrame, L["RaidSortByRoleTip"])
	G:CreateOptionCheck(scroll.child, -40, L["RaidSortAscending"], "UFs", "RaidSortAscending", ResizeRaidFrame, L["RaidSortAscendingTip"])
	G:CreateOptionDropdown(scroll.child, L["GrowthDirection"], -90, options, L["RaidDirectionTip"], "UFs", "RaidDirection", 1, UpdateRaidDirection)
	G:CreateOptionSlider(scroll.child, L["Width"], 60, 200, defaultValue[1], -160, "RaidWidth", ResizeRaidFrame)
	G:CreateOptionSlider(scroll.child, L["Height"], 25, 60, defaultValue[2], -240, "RaidHeight", ResizeRaidFrame)
	G:CreateOptionSlider(scroll.child, L["Power Height"], 0, 30, defaultValue[3], -320, "RaidPowerHeight", ResizeRaidFrame)
	G:CreateOptionSlider(scroll.child, L["RaidGroups"], 2, 8, defaultValue[4], -400, "RaidGroups", UpdateNumGroups)
	G:CreateOptionSlider(scroll.child, L["RaidRows"], 1, 8, defaultValue[5], -480, "RaidRows", UpdateNumGroups)
	G:CreateOptionSlider(scroll.child, L["Spacing"], 0, 10, defaultValue[6], -560, "RaidSpacing", UpdateNumGroups)
end

local function SetupPartyFrame(parent)
	local guiName = "LauringUI_PartyFrameSetup"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName, L["PartyFrame"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)
	local UF = Core:GetModule("UnitFrames")

	local function ResizePartyFrame()
		for _, frame in pairs(ns.oUF.objects) do
			if frame.mystyle == "Party" then
				G:SetUnitFrameSize(frame, UF)
				UF:SetPartyAndRaidName(frame.nameText, frame)
			end
		end
		if UF.CreateAndUpdatePartyHeader then
			UF:CreateAndUpdatePartyHeader()
		end
	end

	local defaultValue = {100, 32, 2, 5}
	local options = {}
	for i = 1, 4 do
		options[i] = UF.PartyDirections[i].name
	end
	G:CreateOptionCheck(scroll.child, -10, L["SortByRole"], "UFs", "SortByRole", ResizePartyFrame, L["SortByRoleTip"])
	G:CreateOptionCheck(scroll.child, -40, L["SortAscending"], "UFs", "SortAscending", ResizePartyFrame, L["SortAscendingTip"])
	G:CreateOptionDropdown(scroll.child, L["GrowthDirection"], -100, options, nil, "UFs", "PartyDirection", 1, ResizePartyFrame)
	G:CreateOptionSlider(scroll.child, L["Width"], 80, 400, defaultValue[1], -180, "PartyWidth", ResizePartyFrame)
	G:CreateOptionSlider(scroll.child, L["Height"], 25, 200, defaultValue[2], -260, "PartyHeight", ResizePartyFrame)
	G:CreateOptionSlider(scroll.child, L["Power Height"], 0, 30, defaultValue[3], -340, "PartyPowerHeight", ResizePartyFrame)
	G:CreateOptionSlider(scroll.child, L["Spacing"], 0, 10, defaultValue[4], -420, "PartySpacing", ResizePartyFrame)
end

local function SetupPartyPetFrame(parent)
	local guiName = "LauringUI_PartyPetFrameSetup"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName, L["PartyPetFrame"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local UF = Core:GetModule("UnitFrames")

	local function UpdatePartyPetHeader()
		if UF.UpdatePartyPetHeader then
			UF:UpdatePartyPetHeader()
		end
	end

	local function ResizePartyPetFrame()
		for _, frame in pairs(ns.oUF.objects) do
			if frame.mystyle == "PartyPet" then
				G:SetUnitFrameSize(frame, UF)
				UF:SetPartyAndRaidName(frame.nameText, frame)
			end
		end

		UpdatePartyPetHeader()
	end

	local options = {}
	for i = 1, 8 do
		options[i] = UF.RaidDirections[i].name
	end

	G:CreateOptionDropdown(scroll.child, L["GrowthDirection"], -30, options, nil, "UFs", "PartyPetDirection", 1, UpdatePartyPetHeader)
	G:CreateOptionDropdown(scroll.child, L["Visibility"], -90, {L["ShowInParty"], L["ShowInRaid"], L["ShowInGroup"]}, nil, "UFs", "PartyPetVisability", 1, UpdateAllHeaders)
	G:CreateOptionSlider(scroll.child, L["Width"], 60, 200, 100, -150, "PartyPetWidth", ResizePartyPetFrame)
	G:CreateOptionSlider(scroll.child, L["Height"], 20, 60, 22, -220, "PartyPetHeight", ResizePartyPetFrame)
	G:CreateOptionSlider(scroll.child, L["Power Height"], 0, 30, 2, -290, "PartyPetPowerHeight", ResizePartyPetFrame)
	G:CreateOptionSlider(scroll.child, L["UnitsPerColumn"], 5, 40, 5, -360, "PartyPetPerColumn", UpdatePartyPetHeader)
	G:CreateOptionSlider(scroll.child, L["MaxColumns"], 1, 5, 1, -430, "PartyPetMaxColumn", UpdatePartyPetHeader)
end

local function SetupDebuffsIndicator(parent)
	local guiName = "LauringUI_DebuffsIndicator"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName, L["BlackList"].."*")
	panel:SetScript("OnHide", RefreshDebuffsIndicator)

	local barList = {}

	local function createBar(barParent, spellID, isNew)
		local name, _, texture = GetSpellInfo(spellID)
		local bar = CreateFrame("Frame", nil, barParent, "BackdropTemplate")
		bar:SetSize(220, 30)
		Core.CreateBD(bar, .25)
		barList[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		Core.AddTooltip(icon, "ANCHOR_RIGHT", spellID)
		close:SetScript("OnClick", function()
			bar:Hide()
			if Config.RaidDebuffsBlack[spellID] then
				LauringUIAccountDB["RaidDebuffsBlack"][spellID] = false
			else
				LauringUIAccountDB["RaidDebuffsBlack"][spellID] = nil
			end
			barList[spellID] = nil
			G:SortBars(barList)
		end)

		local spellName = Core.CreateFS(bar, 14, name, false, "LEFT", 30, 0)
		spellName:SetWidth(180)
		spellName:SetJustifyH("LEFT")
		if isNew then spellName:SetTextColor(0, 1, 0) end

		G:SortBars(barList)
	end

	local function isAuraExisted(spellID)
		local modValue = LauringUIAccountDB["RaidDebuffsBlack"][spellID]
		local locValue = Config.RaidDebuffsBlack[spellID]
		return modValue or (modValue == nil and locValue)
	end

	local function addClick(clickParent)
		local spellID = tonumber(clickParent.box:GetText())
		if not spellID or not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		if isAuraExisted(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

		LauringUIAccountDB["RaidDebuffsBlack"][spellID] = true
		createBar(clickParent.child, spellID, true)
		clickParent.box:SetText("")
	end

	local frame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	frame:SetSize(280, 540)
	frame:SetPoint("TOPLEFT", 10, -50)
	Core.CreateBD(frame, .25)

	local scroll = G:CreateScroll(frame, 240, 485)
	scroll.box = Core.CreateEditBox(frame, 160, 25)
	scroll.box:SetPoint("TOPLEFT", 10, -10)
	Core.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["ID Intro"], "info", true)

	scroll.add = Core.CreateButton(frame, 45, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -8, -10)
	scroll.add:SetScript("OnClick", function()
		addClick(scroll)
	end)

	scroll.reset = Core.CreateButton(frame, 45, 25, RESET)
	scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_LAURINGUI_DEBUFFS_BLACK")
	end)

	local UF = Core:GetModule("UnitFrames")
	for spellID, value in pairs(UF.RaidDebuffsBlack) do
		if value then
			createBar(scroll.child, spellID)
		end
	end
end

local function SetupSpellsIndicator(parent)
	local guiName = "LauringUI_SpellsIndicator"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName, L["BuffIndicator"].."*")
	panel:SetScript("OnHide", UpdateCornerSpells)

	local barList = {}

	local decodeAnchor = {
		["TL"] = "TOPLEFT",
		["TR"] = "TOPRIGHT",
		["BL"] = "BOTTOMLEFT",
		["BR"] = "BOTTOMRIGHT",
	}
	local anchors = {"TL", "TR", "BL", "BR"}

	local function createBar(parent, spellID, anchor, showAll)
		local name, _, texture = GetSpellInfo(spellID)
		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		Core.CreateBD(bar, .25)
		barList[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		Core.AddTooltip(icon, "ANCHOR_RIGHT", spellID)
		close:SetScript("OnClick", function()
			bar:Hide()
			local value = Config.CornerBuffs[DB.MyClass][spellID]
			if value then
				LauringUIAccountDB["CornerSpells"][DB.MyClass][spellID] = {}
			else
				LauringUIAccountDB["CornerSpells"][DB.MyClass][spellID] = nil
			end
			barList[spellID] = nil
			G:SortBars(barList)
		end)

		name = L[anchor] or name
		local text = Core.CreateFS(bar, 14, name, false, "LEFT", 30, 0)
		text:SetWidth(180)
		text:SetJustifyH("LEFT")
		if showAll then Core.CreateFS(bar, 14, "ALL", false, "RIGHT", -30, 0) end

		G:SortBars(barList)
	end

	local function addClick(clickParent)
		local spellID = tonumber(clickParent.box:GetText())
		if not spellID or not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		local anchor = clickParent.dd.Text:GetText()
		local showAll = clickParent.showAll:GetChecked() or nil
		local modValue = LauringUIAccountDB["CornerSpells"][DB.MyClass][spellID]
		if (modValue and next(modValue)) or (Config.CornerBuffs[DB.MyClass][spellID] and not modValue) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end
		anchor = decodeAnchor[anchor]
		LauringUIAccountDB["CornerSpells"][DB.MyClass][spellID] = {anchor, showAll}
		createBar(clickParent.child, spellID, anchor, showAll)
		clickParent.box:SetText("")
	end

	local function optionOnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L[decodeAnchor[self.text]], 1, 1, 1)
		GameTooltip:Show()
	end

	local frame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	frame:SetSize(280, 540)
	frame:SetPoint("TOPLEFT", 10, -50)
	Core.CreateBD(frame, .25)

	local scroll = G:CreateScroll(frame, 240, 485)
	scroll.box = Core.CreateEditBox(frame, 50, 25)
	scroll.box:SetPoint("TOPLEFT", 10, -10)
	scroll.box:SetMaxLetters(8) -- might have 8 digits for spellID
	Core.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["ID Intro"], "info", true)

	scroll.add = Core.CreateButton(frame, 45, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -8, -10)
	scroll.add:SetScript("OnClick", function()
		addClick(scroll)
	end)

	scroll.reset = Core.CreateButton(frame, 45, 25, RESET)
	scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_LAURINGUI_RaidBuffsWhite")
	end)

	scroll.dd = Core.CreateDropDown(frame, 60, 25, anchors)
	scroll.dd:SetPoint("TOPLEFT", 10, -10)
	scroll.dd.options[1]:Click()

	for i = 1, 4 do
		scroll.dd.options[i]:HookScript("OnEnter", optionOnEnter)
		scroll.dd.options[i]:HookScript("OnLeave", Core.HideTooltip)
	end
	scroll.box:SetPoint("TOPLEFT", scroll.dd, "TOPRIGHT", 5, 0)

	local showAll = Core.CreateCheckBox(frame)
	showAll:SetPoint("LEFT", scroll.box, "RIGHT", 5, 0)
	showAll:SetHitRectInsets(0, 0, 0, 0)
	showAll.bg:SetBackdropBorderColor(1, .8, 0, .5)
	Core.AddTooltip(showAll, "ANCHOR_TOPRIGHT", L["ShowAllTip"], "info", true)
	scroll.showAll = showAll

	local UF = Core:GetModule("UnitFrames")
	for spellID, value in pairs(UF.CornerSpells) do
		createBar(scroll.child, spellID, value[1], value[2])
	end
end

local function AddNewDungeon(dungeons, dungeonID)
	local name = EJ_GetInstanceInfo(dungeonID)
	if name then
		tinsert(dungeons, name)
	end
end

local function ClearEdit(options)
	for i = 1, #options do
		G:ClearEdit(options[i])
	end
end

local function SetupRaidDebuffs(parent)
	local guiName = "LauringUI_RaidDebuffs"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName, L["RaidFrame Debuffs"].."*", true)
	panel:SetScript("OnHide", UpdateRaidDebuffs)

	local setupBars
	local frame = panel.bg
	local bars, options = {}, {}

	local iType = G:CreateDropdown(frame, L["Type*"], 10, -30, {DUNGEONS, RAID, OTHER}, L["Instance Type"])
	for i = 1, 3 do
		iType.options[i]:HookScript("OnClick", function()
			for j = 1, 2 do
				G:ClearEdit(options[j])
				if i == j then
					options[j]:Show()
				else
					options[j]:Hide()
				end
			end

			for k = 1, #bars do
				bars[k]:Hide()
			end

			if i == 3 then
				setupBars(0) -- add OTHER spells
			end
		end)
	end

	local dungeons = {}

	for id = 63, 71 do
		AddNewDungeon(dungeons, id)
	end
	AddNewDungeon(dungeons, 76)   -- Zul'Gurub
	AddNewDungeon(dungeons, 77)   -- Zul'Aman
	AddNewDungeon(dungeons, 184)  -- End Time
	AddNewDungeon(dungeons, 185)  -- Well of Eternity
	AddNewDungeon(dungeons, 186)  -- Hour of Twilight

	local raids = {
		[1] = EJ_GetInstanceInfo(75),
		[2] = EJ_GetInstanceInfo(72),
		[3] = EJ_GetInstanceInfo(74),
		[4] = EJ_GetInstanceInfo(73),
		[5] = EJ_GetInstanceInfo(78),
		[6] = EJ_GetInstanceInfo(187),
	}

	options[1] = G:CreateDropdown(frame, DUNGEONS.."*", 120, -30, dungeons, L["Dungeons Intro"], 130, 30)
	options[1]:Hide()
	options[2] = G:CreateDropdown(frame, RAID.."*", 120, -30, raids, L["Raid Intro"], 130, 30)
	options[2]:Hide()

	options[3] = G:CreateEditbox(frame, "ID*", 10, -90, L["ID Intro"])
	options[4] = G:CreateEditbox(frame, L["Priority"], 120, -90, L["Priority Intro"])

	local function analyzePrio(priority)
		priority = priority or 2
		priority = min(priority, 6)
		priority = max(priority, 1)
		return priority
	end

	local function isAuraExisted(instName, spellID)
		local localPrio = Config.RaidDebuffs[instName][spellID]
		local savedPrio = LauringUIAccountDB["RaidDebuffs"][instName] and LauringUIAccountDB["RaidDebuffs"][instName][spellID]
		if (localPrio and savedPrio and savedPrio == 0) or (not localPrio and not savedPrio) then
			return false
		end
		return true
	end

	local function addClick(clickOptions)
		local dungeonName, raidName, spellID, priority = clickOptions[1].Text:GetText(), clickOptions[2].Text:GetText(), tonumber(clickOptions[3]:GetText()), tonumber(clickOptions[4]:GetText())
		local instName = dungeonName or raidName or (iType.Text:GetText() == OTHER and 0)
		if not instName or not spellID then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incomplete Input"]) return end
		if spellID and not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		if isAuraExisted(instName, spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

		priority = analyzePrio(priority)
		if not LauringUIAccountDB["RaidDebuffs"][instName] then LauringUIAccountDB["RaidDebuffs"][instName] = {} end
		LauringUIAccountDB["RaidDebuffs"][instName][spellID] = priority
		setupBars(instName)
		G:ClearEdit(clickOptions[3])
		G:ClearEdit(clickOptions[4])
	end

	local scroll = G:CreateScroll(frame, 240, 350)
	scroll.reset = Core.CreateButton(frame, 70, 25, RESET)
	scroll.reset:SetPoint("TOPLEFT", 10, -140)
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_LAURINGUI_RAIDDEBUFFS")
	end)
	scroll.add = Core.CreateButton(frame, 70, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -10, -140)
	scroll.add:SetScript("OnClick", function()
		addClick(options)
	end)
	scroll.clear = Core.CreateButton(frame, 70, 25, KEY_NUMLOCK_MAC)
	scroll.clear:SetPoint("RIGHT", scroll.add, "LEFT", -10, 0)
	scroll.clear:SetScript("OnClick", function()
		ClearEdit(options)
	end)

	local function iconOnEnter(self)
		local spellID = self:GetParent().spellID
		if not spellID then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:ClearLines()
		GameTooltip:SetSpellByID(spellID)
		GameTooltip:Show()
	end

	local function createBar(index, texture)
		local bar = CreateFrame("Frame", nil, scroll.child, "BackdropTemplate")
		bar:SetSize(220, 30)
		Core.CreateBD(bar, .25)
		bar.index = index

		local icon, close = G:CreateBarWidgets(bar, texture)
		icon:SetScript("OnEnter", iconOnEnter)
		icon:SetScript("OnLeave", Core.HideTooltip)
		bar.icon = icon

		close:SetScript("OnClick", function()
			bar:Hide()
			if Config.RaidDebuffs[bar.instName][bar.spellID] then
				if not LauringUIAccountDB["RaidDebuffs"][bar.instName] then LauringUIAccountDB["RaidDebuffs"][bar.instName] = {} end
				LauringUIAccountDB["RaidDebuffs"][bar.instName][bar.spellID] = 0
			else
				LauringUIAccountDB["RaidDebuffs"][bar.instName][bar.spellID] = nil
			end
			setupBars(bar.instName)
		end)

		local spellName = Core.CreateFS(bar, 14, "", false, "LEFT", 30, 0)
		spellName:SetWidth(120)
		spellName:SetJustifyH("LEFT")
		bar.spellName = spellName

		local prioBox = Core.CreateEditBox(bar, 30, 24)
		prioBox:SetPoint("RIGHT", close, "LEFT", -15, 0)
		prioBox:SetTextInsets(10, 0, 0, 0)
		prioBox:SetMaxLetters(1)
		prioBox:SetTextColor(0, 1, 0)
		prioBox.bg:SetBackdropColor(1, 1, 1, .2)
		prioBox:HookScript("OnEscapePressed", function(self)
			self:SetText(bar.priority)
		end)
		prioBox:HookScript("OnEnterPressed", function(self)
			local prio = analyzePrio(tonumber(self:GetText()))
			if not LauringUIAccountDB["RaidDebuffs"][bar.instName] then LauringUIAccountDB["RaidDebuffs"][bar.instName] = {} end
			LauringUIAccountDB["RaidDebuffs"][bar.instName][bar.spellID] = prio
			self:SetText(prio)
		end)
		Core.AddTooltip(prioBox, "ANCHOR_TOPRIGHT", L["Prio Editbox"], "info", true)
		bar.prioBox = prioBox

		return bar
	end

	local function applyData(index, instName, spellID, priority)
		local name, _, texture = GetSpellInfo(spellID)
		if not bars[index] then
			bars[index] = createBar(index, texture)
		end
		bars[index].instName = instName
		bars[index].spellID = spellID
		bars[index].priority = priority
		bars[index].spellName:SetText(name)
		bars[index].prioBox:SetText(priority)
		bars[index].icon.Icon:SetTexture(texture)
		bars[index]:Show()
	end

	function setupBars(self)
		local instName = tonumber(self) or self.text or self
		local index = 0

		if Config.RaidDebuffs[instName] then
			for spellID, priority in pairs(Config.RaidDebuffs[instName]) do
				if not (LauringUIAccountDB["RaidDebuffs"][instName] and LauringUIAccountDB["RaidDebuffs"][instName][spellID]) then
					index = index + 1
					applyData(index, instName, spellID, priority)
				end
			end
		end

		if LauringUIAccountDB["RaidDebuffs"][instName] then
			for spellID, priority in pairs(LauringUIAccountDB["RaidDebuffs"][instName]) do
				if priority > 0 then
					index = index + 1
					applyData(index, instName, spellID, priority)
				end
			end
		end

		for i = 1, #bars do
			if i > index then
				bars[i]:Hide()
			end
		end

		for i = 1, index do
			bars[i]:SetPoint("TOPLEFT", 10, -10 - 35*(i-1))
		end
	end

	for i = 1, 2 do
		for j = 1, #options[i].options do
			options[i].options[j]:HookScript("OnClick", setupBars)
		end
	end

	local function autoSelectInstance()
		local instName, instType = GetInstanceInfo()
		if instType == "none" then return end
		for i = 1, 2 do
			local option = options[i]
			for j = 1, #option.options do
				local name = option.options[j].text
				if instName == name then
					iType.options[i]:Click()
					options[i].options[j]:Click()
				end
			end
		end
	end
	autoSelectInstance()
	panel:HookScript("OnShow", autoSelectInstance)
end

local function SetupRaidFrameFunc()
	SetupRaidFrame(G.GuiPage["GroupFrames"])
end

local function SetupPartyFrameFunc()
	SetupPartyFrame(G.GuiPage["GroupFrames"])
end

local function SetupPartyPetFrameFunc()
	SetupPartyPetFrame(G.GuiPage["GroupFrames"])
end

local function SetupDebuffsIndicatorFunc()
	SetupDebuffsIndicator(G.GuiPage["GroupFrames"])
end

local function UpdateRaidAurasOptions()
	Core:GetModule("UnitFrames"):RaidAuras_UpdateOptions()
end

local function SetupSpellsIndicatorFunc()
	SetupSpellsIndicator(G.GuiPage["GroupFrames"])
end

local function SetupRaidDebuffsFunc()
	SetupRaidDebuffs(G.GuiPage["GroupFrames"])
end

local function UpdateRaidHealthMethod()
	Core:GetModule("UnitFrames"):UpdateRaidHealthMethod()
end

local function UpdateRaidTextScale()
	Core:GetModule("UnitFrames"):UpdateRaidTextScale()
end

local function UpdateTeamIndex()
	local UF = Core:GetModule("UnitFrames")
	if UF.CreateAndUpdateRaidHeader then
		UF:CreateAndUpdateRaidHeader()
		UF:UpdateRaidTeamIndex()
	end
	UpdateRaidTextScale()
end

local options = {
    {1, "UFs", "EnableRaidFrame", G.HeaderTag..L["UFs Raid"], nil, SetupRaidFrameFunc, nil, L["RaidFrameTip"]},
    {1, "UFs", "EnablePartyFrame", L["UFs Party"], true, SetupPartyFrameFunc, nil, L["PartyFrameTip"]},
    {1, "UFs", "EnablePartyPetFrame", L["UFs PartyPet"], nil, SetupPartyPetFrameFunc, nil, L["PartyPetTip"]},
	{1, "UFs", "FrequentHealth", G.HeaderTag..L["FrequentHealth"].."*", nil, nil, UpdateRaidHealthMethod, L["FrequentHealthTip"]},
    {3, "UFs", "HealthFrequency", L["HealthFrequency"].."*", true, {.1, .5, .05}, UpdateRaidHealthMethod, L["HealthFrequencyTip"], nil, true},
    {},--blank
	{1, "UFs", "ShowBlizzardDebuff", L["ShowBlizzardDebuff"].."*", nil, SetupDebuffsIndicatorFunc, UpdateRaidAurasOptions, L["ShowBlizzardDebuffTip"]},
	{3, "UFs", "BlizzardDebuffSize", L["BlizzardDebuffSize"].."*", true, {5, 30, 1}, UpdateRaidAurasOptions, nil, nil, true},
	{1, "UFs", "DebuffClickThrough", L["DebuffClickThrough"].."*", nil, nil, UpdateRaidAurasOptions, L["ClickThroughTip"]},

	{4, "UFs", "InstanceAuraDispellType", L["Dispellable"].."*", nil, {L["Always"], L["Filter"], DISABLE}, UpdateRaidAurasOptions, L["DispellTypeTip"]},

	{1, "UFs", "ShowInstanceAuras", G.HeaderTag..L["Instance Auras"].."*", nil, SetupRaidDebuffsFunc, UpdateRaidAurasOptions, L["InstanceAurasTip"]},
	{3, "UFs", "InstanceAuraScale", L["InstanceAuraScale"].."*", true, {.8, 2, .1}, UpdateRaidAurasOptions, nil, nil, true},
	{1, "UFs", "InstanceAuraClickThrough", L["InstanceAuras ClickThrough"].."*", nil, nil, UpdateRaidAurasOptions, L["ClickThroughTip"]},
	{},--blank
	{1, "UFs", "RaidBuffIndicator", G.HeaderTag..L["RaidBuffIndicator"].."*", nil, SetupSpellsIndicatorFunc, UpdateRaidAurasOptions, L["RaidBuffIndicatorTip"]},
	{3, "UFs", "BuffIndicatorScale", L["BuffIndicatorScale"].."*", true, {.8, 2, .1}, UpdateRaidAurasOptions, nil, nil, true},
    {},--blank
    {4, "UFs", "ShowRoleMode", L["ShowRoleMode"], nil, {ALL, DISABLE, L["HideDPSRole"]}},
    {3, "UFs", "RaidTextScale", L["UFTextScale"].."*", true, {.8, 1.5, .05}, UpdateRaidTextScale},
    {1, "UFs", "ShowSolo", L["ShowSolo"].."*", nil, nil, UpdateAllHeaders, L["ShowSoloTip"]},
    {1, "UFs", "SmartRaid", G.HeaderTag..L["SmartRaid"].."*", true, nil, UpdateAllHeaders, L["SmartRaidTip"]},
    {1, "UFs", "TeamIndex", L["RaidFrame TeamIndex"].."*", nil, nil, UpdateTeamIndex},
    {1, "UFs", "HideTip", L["HideTooltip"].."*", true, nil, UpdateRaidTextScale, L["HideTooltipTip"]},
}

G.TabList["GroupFrames"] = options