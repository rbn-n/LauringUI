local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

local GetSpellInfo, GetSpellTexture = GetSpellInfo, GetSpellTexture

local function SortBars(barTable)
	local num = 1
	for _, bar in pairs(barTable) do
		bar:SetPoint("TOPLEFT", 10, -10 - 35*(num-1))
		num = num + 1
	end
end

local function RefreshNameplateFilters()
	Core:GetModule("Nameplates"):RefreshFilters()
end

local function IsAuraExisted(index, spellID)
    local key = index == 1 and "NameplateWhite" or "NameplateBlack"
    local modValue = LauringUIAccountDB[key][spellID]
    local locValue = (index == 1 and Config.Nameplates.WhiteList[spellID]) or (index == 2 and Config.Nameplates.BlackList[spellID])
    return modValue or (modValue == nil and locValue)
end

local function SetupNameplateFilter(parent)
	local guiName = "LauringUI_NameplateFilter"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName)
	panel:SetScript("OnHide", RefreshNameplateFilters)

	local frameData = {
		[1] = {text = L["WhiteList"].."*", offset = -25, barList = {}},
		[2] = {text = L["BlackList"].."*", offset = -315, barList = {}},
	}

    local function createBar(parent, index, spellID)
        local name, _, texture = GetSpellInfo(spellID)
        local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        bar:SetSize(220, 30)
        Core.CreateBD(bar, .3)
        frameData[index].barList[spellID] = bar

        local icon, close = G:CreateBarWidgets(bar, texture)
        Core.AddTooltip(icon, "ANCHOR_RIGHT", spellID)
        close:SetScript("OnClick", function()
            bar:Hide()
            if index == 1 then
                if Config.Nameplates.WhiteList[spellID] then
                    LauringUIAccountDB["NameplateWhite"][spellID] = false
                else
                    LauringUIAccountDB["NameplateWhite"][spellID] = nil
                end
            elseif index == 2 then
                if Config.Nameplates.BlackList[spellID] then
                    LauringUIAccountDB["NameplateBlack"][spellID] = false
                else
                    LauringUIAccountDB["NameplateBlack"][spellID] = nil
                end
            end
            frameData[index].barList[spellID] = nil
            SortBars(frameData[index].barList)
        end)

        local spellName = Core.CreateFS(bar, 14, name, false, "LEFT", 30, 0)
        spellName:SetWidth(180)
        spellName:SetJustifyH("LEFT")
        if index == 2 then spellName:SetTextColor(1, 0, 0) end

        SortBars(frameData[index].barList)
    end

    local function addClick(parent, index)
        local spellID = tonumber(parent.box:GetText())
        if not spellID or not GetSpellInfo(spellID) then
            UIErrorsFrame:AddMessage(DB.InfoColor .. L["Incorrect SpellID"])
            return
        end
        if IsAuraExisted(index, spellID) then
            UIErrorsFrame:AddMessage(DB.InfoColor .. L["Existing ID"])
            return
        end

        local key = index == 1 and "NameplateWhite" or "NameplateBlack"
        LauringUIAccountDB[key][spellID] = true
        createBar(parent.child, index, spellID)
        parent.box:SetText("")
    end

	local Nameplates = Core:GetModule("Nameplates")

	local filterIndex
	StaticPopupDialogs["RESET_LAURINGUI_NAMEPLATEFILTER"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			local key = filterIndex == 1 and "NameplateWhite" or "NameplateBlack"
			wipe(LauringUIAccountDB[key])
			ReloadUI()
		end,
		whileDead = 1,
	}

	for index, value in ipairs(frameData) do
		Core.CreateFS(panel, 14, value.text, "system", "TOPLEFT", 20, value.offset)
		local frame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
		frame:SetSize(280, 250)
		frame:SetPoint("TOPLEFT", 10, value.offset - 25)
		Core.CreateBD(frame, .3)

		local scroll = G:CreateScroll(frame, 240, 200)
		scroll.box = Core.CreateEditBox(frame, 160, 25)
		scroll.box:SetPoint("TOPLEFT", 10, -10)
		Core.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["ID Intro"], "info", true)

		scroll.add = Core.CreateButton(frame, 45, 25, ADD)
		scroll.add:SetPoint("TOPRIGHT", -8, -10)
		scroll.add:SetScript("OnClick", function()
			addClick(scroll, index)
		end)

		scroll.reset = Core.CreateButton(frame, 45, 25, RESET)
		scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
		scroll.reset:SetScript("OnClick", function()
			filterIndex = index
			StaticPopup_Show("RESET_LauringUI_NAMEPLATEFILTER")
		end)

		local key = index == 1 and "NameplateWhite" or "NameplateBlack"
		for spellID, nameplateValue in pairs(Nameplates[key]) do
			if nameplateValue then
				createBar(scroll.child, index, spellID)
			end
		end
	end
end

local function NameplateColorDots(parent)
	local guiName = "LauringUI_NameplateColorDots"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName, L["ColorDotsList"].."*", true)

	local barTable = {}

	local function createBar(barParent, spellID, isNew)
		local spellName = GetSpellInfo(spellID)
		local texture = GetSpellTexture(spellID)

		local bar = CreateFrame("Frame", nil, barParent, "BackdropTemplate")
		bar:SetSize(220, 30)
		Core.CreateBD(bar, .25)
		barTable[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
	    Core.AddTooltip(icon, "ANCHOR_RIGHT", spellID, "system")
		close:SetScript("OnClick", function()
			bar:Hide()
			barTable[spellID] = nil
			Config.DB["Nameplates"]["DotSpells"][spellID] = nil
			SortBars(barTable)
		end)

		local name = Core.CreateFS(bar, 14, spellName, false, "LEFT", 30, 0)
		name:SetWidth(120)
		name:SetJustifyH("LEFT")
		if isNew then name:SetTextColor(0, 1, 0) end

		SortBars(barTable)
	end

	local frame = panel.bg

	local scroll = G:CreateScroll(frame, 240, 485)
	scroll.box = Core.CreateEditBox(frame, 135, 25)
	scroll.box:SetPoint("TOPLEFT", 35, -10)
	Core.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["ID Intro"], "info", true)

	local swatch = Core.CreateColorSwatch(frame, nil, Config.DB["Nameplates"]["DotColor"])
	swatch:SetPoint("RIGHT", scroll.box, "LEFT", -5, 0)
	swatch.__default = G.DefaultSettings["Nameplates"]["DotColor"]

	local function addClick(button)
		local owner = button.__owner
		local spellID = tonumber(owner.box:GetText())
		if not spellID or not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		if Config.DB["Nameplates"]["DotSpells"][spellID] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end
		Config.DB["Nameplates"]["DotSpells"][spellID] = true
		createBar(owner.child, spellID, true)
		owner.box:SetText("")
	end
	scroll.add = Core.CreateButton(frame, 45, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -8, -10)
	scroll.add.__owner = scroll
	scroll.add:SetScript("OnClick", addClick)

	scroll.reset = Core.CreateButton(frame, 45, 25, RESET)
	scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	StaticPopupDialogs["RESET_LAURINGUI_DOTSPELLS"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			Config.DB["Nameplates"]["DotSpells"] = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_LAURINGUI_DOTSPELLS")
	end)

	for npcID in pairs(Config.DB["Nameplates"]["DotSpells"]) do
		createBar(scroll.child, npcID)
	end
end

local function RefreshUnitTable()
	Core:GetModule("Nameplates"):CreateUnitTable()
end

local function NameplateUnitFilter(parent)
	local guiName = "LauringUI_NameplateUnitFilter"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName, L["UnitColor List"].."*", true)
	panel:SetScript("OnHide", RefreshUnitTable)

	local barTable = {}

	local function createBar(barParent, text, isNew)
		local npcID = tonumber(text)

		local bar = CreateFrame("Frame", nil, barParent, "BackdropTemplate")
		bar:SetSize(220, 30)
		Core.CreateBD(bar, .25)
		barTable[text] = bar

		local icon, close = G:CreateBarWidgets(bar, npcID and 136243 or 132288)
		if npcID then
			Core.AddTooltip(icon, "ANCHOR_RIGHT", "ID: "..npcID, "system")
		end
		close:SetScript("OnClick", function()
			bar:Hide()
			barTable[text] = nil
			if Config.Nameplates.CustomUnits[text] then
				Config.DB["Nameplates"]["CustomUnits"][text] = false
			else
				Config.DB["Nameplates"]["CustomUnits"][text] = nil
			end
			SortBars(barTable)
		end)

		local name = Core.CreateFS(bar, 14, text, false, "LEFT", 30, 0)
		name:SetWidth(190)
		name:SetJustifyH("LEFT")
		if isNew then name:SetTextColor(0, 1, 0) end
		if npcID then
			Core.GetNPCName(npcID, function(npcName)
				name:SetText(npcName)
				if npcName == UNKNOWN then
					name:SetTextColor(1, 0, 0)
				end
			end)
		end

		SortBars(barTable)
	end

	local frame = panel.bg

	local scroll = G:CreateScroll(frame, 240, 485)
	scroll.box = Core.CreateEditBox(frame, 135, 25)
	scroll.box:SetPoint("TOPLEFT", 35, -10)
	Core.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["NPCID or Name"], "info", true)

	local swatch = Core.CreateColorSwatch(frame, nil, Config.DB["Nameplates"]["CustomColor"])
	swatch:SetPoint("RIGHT", scroll.box, "LEFT", -5, 0)
	swatch.__default = G.DefaultSettings["Nameplates"]["CustomColor"]

	local function addClick(button)
		local owner = button.__owner
		local text = tonumber(owner.box:GetText()) or owner.box:GetText()
		if text and text ~= "" then
			local modValue = Config.DB["Nameplates"]["CustomUnits"][text]
			if modValue or modValue == nil and Config.Nameplates.CustomUnits[text] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end
			Config.DB["Nameplates"]["CustomUnits"][text] = true
			createBar(owner.child, text, true)
			owner.box:SetText("")
		end
	end
	scroll.add = Core.CreateButton(frame, 45, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -8, -10)
	scroll.add.__owner = scroll
	scroll.add:SetScript("OnClick", addClick)

	scroll.reset = Core.CreateButton(frame, 45, 25, RESET)
	scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	StaticPopupDialogs["RESET_LAURINGUI_UNITFILTER"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			Config.DB["Nameplates"]["CustomUnits"] = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_LAURINGUI_UNITFILTER")
	end)

	local Nameplates = Core:GetModule("Nameplates")
	for npcID in pairs(Nameplates.CustomUnits) do
		createBar(scroll.child, npcID)
	end
end

local function UpdatePowerUnitList()
	Core:GetModule("Nameplates"):CreatePowerUnitTable()
end

local function NameplatePowerUnits(parent)
	local guiName = "LauringUI_NameplatePowerUnits"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName, L["ShowPowerList"].."*", true)
	panel:SetScript("OnHide", UpdatePowerUnitList)

	local barTable = {}

	local function createBar(barParent, text, isNew)
		local npcID = tonumber(text)

		local bar = CreateFrame("Frame", nil, barParent, "BackdropTemplate")
		bar:SetSize(220, 30)
		Core.CreateBD(bar, .25)
		barTable[text] = bar

		local icon, close = G:CreateBarWidgets(bar, npcID and 136243 or 132288)
		if npcID then
			Core.AddTooltip(icon, "ANCHOR_RIGHT", "ID: "..npcID, "system")
		end
		close:SetScript("OnClick", function()
			bar:Hide()
			barTable[text] = nil
			if Config.Nameplates.PowerUnits[text] then
				Config.DB["Nameplates"]["PowerUnits"][text] = false
			else
				Config.DB["Nameplates"]["PowerUnits"][text] = nil
			end
			SortBars(barTable)
		end)

		local name = Core.CreateFS(bar, 14, text, false, "LEFT", 30, 0)
		name:SetWidth(190)
		name:SetJustifyH("LEFT")
		if isNew then name:SetTextColor(0, 1, 0) end
		if npcID then
			Core.GetNPCName(npcID, function(npcName)
				name:SetText(npcName)
				if npcName == UNKNOWN then
					name:SetTextColor(1, 0, 0)
				end
			end)
		end

		SortBars(barTable)
	end

	local frame = panel.bg

	local scroll = G:CreateScroll(frame, 240, 485)
	scroll.box = Core.CreateEditBox(frame, 160, 25)
	scroll.box:SetPoint("TOPLEFT", 10, -10)
	Core.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["NPCID or Name"], "info", true)

	local function addClick(button)
		local owner = button.__owner
		local text = tonumber(owner.box:GetText()) or owner.box:GetText()
		if text and text ~= "" then
			local modValue = Config.DB["Nameplates"]["PowerUnits"][text]
			if modValue or modValue == nil and Config.Nameplates.PowerUnits[text] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end
			Config.DB["Nameplates"]["PowerUnits"][text] = true
			createBar(owner.child, text, true)
			owner.box:SetText("")
		end
	end
	scroll.add = Core.CreateButton(frame, 45, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -8, -10)
	scroll.add.__owner = scroll
	scroll.add:SetScript("OnClick", addClick)

	scroll.reset = Core.CreateButton(frame, 45, 25, RESET)
	scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	StaticPopupDialogs["RESET_LAURINGUI_POWERUNITS"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			Config.DB["Nameplates"]["PowerUnits"] = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_LAURINGUI_POWERUNITS")
	end)

	local UF = Core:GetModule("UnitFrames")
	for npcID in pairs(UF.PowerUnits) do
		createBar(scroll.child, npcID)
	end
end

local function SetupNameplateSize(parent)
	local guiName = "LauringUI_PlateSizeSetup"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName, L["NameplateSize"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local optionValues = {
		["enemy"] = {"PlateWidth", "PlateHeight", "NameTextSize", "HealthTextSize", "HealthTextOffset", "PlateCBHeight", "CBTextSize", "PlateCBOffset"},
		["friend"] = {"FriendPlateWidth", "FriendPlateHeight", "FriendNameSize", "FriendHealthSize", "FriendHealthOffset", "FriendPlateCBHeight", "FriendCBTextSize", "FriendPlateCBOffset"},
	}
	local function CreateOptionGroup(optionParent, title, offset, value, func)
		G:CreateOptionTitle(optionParent, title, offset)
		G:CreateOptionSlider(optionParent, L["Width"], 50, 500, 190, offset-60, optionValues[value][1], func, "Nameplates")
		G:CreateOptionSlider(optionParent, L["Height"], 5, 50, 8, offset-130, optionValues[value][2], func, "Nameplates")
		G:CreateOptionSlider(optionParent, L["NameTextSize"], 10, 50, 14, offset-200, optionValues[value][3], func, "Nameplates")
		G:CreateOptionSlider(optionParent, L["HealthTextSize"], 10, 50, 16, offset-270, optionValues[value][4], func, "Nameplates")
		G:CreateOptionSlider(optionParent, L["Health Offset"], -50, 50, 5, offset-340, optionValues[value][5], func, "Nameplates")
		G:CreateOptionSlider(optionParent, L["Castbar Height"], 5, 50, 8, offset-410, optionValues[value][6], func, "Nameplates")
		G:CreateOptionSlider(optionParent, L["CastbarTextSize"], 10, 50, 14, offset-480, optionValues[value][7], func, "Nameplates")
		G:CreateOptionSlider(optionParent, L["CastbarTextOffset"], -50, 50, -1, offset-550, optionValues[value][8], func, "Nameplates")
	end

	local Nameplates = Core:GetModule("Nameplates")
	CreateOptionGroup(scroll.child, L["HostileNameplate"], -10, "enemy", Nameplates.RefreshAll)
	CreateOptionGroup(scroll.child, L["FriendlyNameplate"], -650, "friend", Nameplates.RefreshAll)
end

local function SetupNameOnlySize(parent)
	local guiName = "LauringUI_NameOnlySetup"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName, L["NameOnlyMode"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)
	local optionParent, offset = scroll.child, -10

	local Nameplates = Core:GetModule("Nameplates")
	G:CreateOptionCheck(optionParent, offset, L["ShowNPCTitle"], "Nameplates", "NameOnlyTitle", Nameplates.RefreshAll)
	G:CreateOptionCheck(optionParent, offset-35, L["ShowUnitGuild"], "Nameplates", "NameOnlyGuild", Nameplates.RefreshAll)
	G:CreateOptionSlider(optionParent, L["NameTextSize"], 10, 50, 14, offset-105, "NameOnlyTextSize", Nameplates.RefreshAll, "Nameplates")
	G:CreateOptionSlider(optionParent, L["TitleTextSize"], 10, 50, 12, offset-175, "NameOnlyTitleSize", Nameplates.RefreshAll, "Nameplates")
end

local function RefreshMajorSpells()
	Core:GetModule("Nameplates"):RefreshMajorSpells()
end

local function PlateCastbarGlow(parent)
	local guiName = "LauringUI_PlateCastbarGlow"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName, L["PlateCastbarGlow"].."*", true)
	panel:SetScript("OnHide", RefreshMajorSpells)

	local barTable = {}

	local function createBar(barParent, spellID)
		local spellName = GetSpellInfo(spellID)
		local texture = GetSpellTexture(spellID)

		local bar = CreateFrame("Frame", nil, barParent, "BackdropTemplate")
		bar:SetSize(220, 30)
		Core.CreateBD(bar, .25)
		barTable[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		Core.AddTooltip(icon, "ANCHOR_RIGHT", spellID, "system")
		close:SetScript("OnClick", function()
			bar:Hide()
			barTable[spellID] = nil
			if Config.Nameplates.MajorSpells[spellID] then
				LauringUIAccountDB["MajorSpells"][spellID] = false
			else
				LauringUIAccountDB["MajorSpells"][spellID] = nil
			end
			SortBars(barTable)
		end)

		local name = Core.CreateFS(bar, 14, spellName, false, "LEFT", 30, 0)
		name:SetWidth(120)
		name:SetJustifyH("LEFT")

		SortBars(barTable)
	end

	local frame = panel.bg
	local scroll = G:CreateScroll(frame, 240, 485)
	scroll.box = Core.CreateEditBox(frame, 160, 25)
	scroll.box:SetPoint("TOPLEFT", 10, -10)
	Core.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["ID Intro"], "info", true)

	local function addClick(button)
		local owner = button.__owner
		local spellID = tonumber(owner.box:GetText())
		if not spellID or not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		local modValue = LauringUIAccountDB["MajorSpells"][spellID]
		if modValue or modValue == nil and Config.Nameplates.MajorSpells[spellID] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end
		LauringUIAccountDB["MajorSpells"][spellID] = true
		createBar(owner.child, spellID)
		owner.box:SetText("")
	end
	scroll.add = Core.CreateButton(frame, 45, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -8, -10)
	scroll.add.__owner = scroll
	scroll.add:SetScript("OnClick", addClick)

	scroll.reset = Core.CreateButton(frame, 45, 25, RESET)
	scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	StaticPopupDialogs["RESET_LAURINGUI_MAJORSPELLS"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			LauringUIAccountDB["MajorSpells"] = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_LAURINGUI_MAJORSPELLS")
	end)

	local Nameplates = Core:GetModule("Nameplates")
	for spellID, value in pairs(Nameplates.MajorSpells) do
		if value then
			createBar(scroll.child, spellID)
		end
	end
end

local function UpdatePlateCVars()
	Core:GetModule("Nameplates"):UpdateCVars()
end

local function RefreshPlateByEvents()
	Core:GetModule("Nameplates"):RefreshPlateByEvents()
end

local function UpdateClickThrough()
	Core:GetModule("Nameplates"):UpdatePlateClickThrough()
end

local function RefreshNameplates()
	Core:GetModule("Nameplates"):RefreshAll()
end

local function SetupNameplateFilterFunc()
	SetupNameplateFilter(G.GuiPage["Nameplates"])
end

local function SetupNameplateColorDotsFunc()
	NameplateColorDots(G.GuiPage["Nameplates"])
end

local function SetupNameplateUnitFilterFunc()
	NameplateUnitFilter(G.GuiPage["Nameplates"])
end

local function SetupNameplatePowerUnitsFunc()
	NameplatePowerUnits(G.GuiPage["Nameplates"])
end

local function SetupNameplateSizeFunc()
	SetupNameplateSize(G.GuiPage["Nameplates"])
end

local function SetupNameOnlySizeFunc()
	SetupNameOnlySize(G.GuiPage["Nameplates"])
end

local function SetupPlateCastbarGlowFunc()
	PlateCastbarGlow(G.GuiPage["Nameplates"])
end

local options = {
		{1, "Nameplates", "Enable", G.HeaderTag..L["Enable Nameplate"], nil, SetupNameplateSizeFunc, RefreshNameplates},
		{1, "Nameplates", "FriendPlate", L["FriendPlate"].."*", nil, nil, RefreshNameplates, L["FriendPlateTip"]},
		{1, "Nameplates", "NameOnlyMode", L["NameOnlyMode"].."*", true, SetupNameOnlySizeFunc, nil, L["NameOnlyModeTip"]},
		{4, "Nameplates", "NameType", L["NameTextType"].."*", nil, {DISABLE, L["Tag:name"], L["Tag:levelname"], L["Tag:rarename"], L["Tag:rarelevelname"]}, RefreshNameplates, L["PlateLevelTagTip"]},
		{4, "Nameplates", "HealthType", L["HealthValueType"].."*", true, G.HealthValues, RefreshNameplates, L["100PercentTip"]},
		{},--blank
		{1, "Nameplates", "PlateAuras", G.HeaderTag..L["PlateAuras"].."*", nil, SetupNameplateFilterFunc, RefreshNameplates},
		{4, "Nameplates", "DispellMode", L["Dispellable"].."*", nil, {L["Filter"], L["Always"], DISABLE}, RefreshNameplates, L["DispellableTip"]},
		{4, "Nameplates", "AuraFilter", L["NameplateAuraFilter"].."*", true, {L["BlackNWhite"], L["PlayerOnly"], L["IncludeCrowdControl"]}, RefreshNameplates},
		{1, "Nameplates", "Desaturate", L["DesaturateIcon"].."*", nil, nil, RefreshNameplates, L["DesaturateIconTip"]},
		{1, "Nameplates", "DebuffColor", L["DebuffColor"].."*", true, nil, RefreshNameplates, L["DebuffColorTip"]},
		{3, "Nameplates", "FontSize", L["AuraFontSize"].."*", nil, {10, 30, 1}, RefreshNameplates},
		{3, "Nameplates", "SizeRatio", L["SizeRatio"].."*", true, {.5, 1, .1}, RefreshNameplates},
		{3, "Nameplates", "MaxAuras", L["Max Auras"].."*", false, {1, 20, 1}, RefreshNameplates},
		{3, "Nameplates", "AuraSize", L["Auras Size"].."*", true, {18, 60, 1}, RefreshNameplates},
		{},--blank
		{4, "Nameplates", "TargetIndicator", L["TargetIndicator"].."*", nil, {DISABLE, L["TopArrow"], L["RightArrow"], L["TargetGlow"], L["TopNGlow"], L["RightNGlow"]}, RefreshNameplates},
		{3, "Nameplates", "ExecuteRatio", L["ExecuteRatio"].."*", true, {0, 90, 1}, nil, L["ExecuteRatioTip"]},
		{1, "Nameplates", "FriendlyCC", L["Friendly CC"].."*"},
		{1, "Nameplates", "HostileCC", L["Hostile CC"].."*", true},
		{1, "Nameplates", "FriendlyThru", "|cffff0000"..L["Friendly ClickThru"].."*", nil, nil, UpdateClickThrough, L["PlateClickThruTip"]},
		{1, "Nameplates", "EnemyThru", "|cffff0000"..L["Enemy ClickThru"].."*", true, nil, UpdateClickThrough, L["PlateClickThruTip"]},
		{1, "Nameplates", "UnitTargeted", L["Show TargetedBy"].."*", nil, nil, RefreshPlateByEvents, L["TargetedByTip"]},
		{1, "Nameplates", "CastTarget", L["PlateCastTarget"].."*", true, nil, nil, L["PlateCastTargetTip"]},
		{1, "Nameplates", "ClampTarget", L["ClampTargetPlate"].."*", nil, nil, UpdatePlateCVars, L["ClampTargetPlateTip"]},
		{1, "Nameplates", "QuestIndicator", L["QuestIndicator"], true, nil, nil, L["QuestIndicatorAddOns"]},
		{1, "Nameplates", "BlockDBM", L["BlockDBM"], nil, nil, nil, L["BlockDBMTip"]},
		{1, "Nameplates", "Interruptor", L["ShowInterruptor"].."*", true},
		{1, "Nameplates", "TarName", L["TarName"].."*"},
		{},--blank
		{1, "Nameplates", "ColoredTarget", G.HeaderTag..L["ColoredTarget"].."*", nil, nil, nil, L["ColoredTargetTip"]},
		{1, "Nameplates", "ColoredFocus", G.HeaderTag..L["ColoredFocus"].."*", true, nil, nil, L["ColoredFocusTip"]},
		{5, "Nameplates", "TargetColor", L["TargetNP Color"].."*"},
		{5, "Nameplates", "FocusColor", L["FocusNP Color"].."*", 2},
		{1, "Nameplates", "ColorByDot", G.HeaderTag..L["ColorByDot"].."*", nil, SetupNameplateColorDotsFunc, nil, L["ColorByDotTip"]},
		{1, "Nameplates", "CastbarGlow", G.HeaderTag..L["PlateCastbarGlow"].."*", true, SetupPlateCastbarGlowFunc, nil, L["PlateCastbarGlowTip"]},
		{1, "Nameplates", "ShowCustomUnits", G.HeaderTag..L["ShowCustomUnits"].."*", nil, SetupNameplateUnitFilterFunc, RefreshUnitTable, L["CustomUnitsTip"]},
		{1, "Nameplates", "ShowPowerUnits", G.HeaderTag..L["ShowPowerUnits"].."*", true, SetupNameplatePowerUnitsFunc, UpdatePowerUnitList, L["PowerUnitsTip"]},
		{},--blank
		{1, "Nameplates", "TankMode", G.HeaderTag..L["Tank Mode"].."*", nil, nil, nil, L["TankModeTip"]},
		{1, "Nameplates", "DPSRevertThreat", L["DPS Revert Threat"].."*", true, nil, nil, L["RevertThreatTip"]},
		{1, "Nameplates", "OffTankThreat", L["OffTankThreat"].."*", nil, nil, nil, L["OffTankThreatTip"]},
		{5, "Nameplates", "SecureColor", L["Secure Color"].."*"},
		{5, "Nameplates", "TransColor", L["Trans Color"].."*", 1},
		{5, "Nameplates", "InsecureColor", L["Insecure Color"].."*", 2},
		{5, "Nameplates", "OffTankColor", L["OffTank Color"].."*", 3},
		{},--blank
		{1, "Nameplates", "CVarOnlyNames", L["CVarOnlyNames"], nil, nil, UpdatePlateCVars, L["CVarOnlyNamesTip"]},
		{1, "Nameplates", "CVarShowNPCs", L["CVarShowNPCs"].."*", true, nil, UpdatePlateCVars, L["CVarShowNPCsTip"]},
		{3, "Nameplates", "PlateRange", L["PlateRange"].."*", nil, {0, 41, 1}, UpdatePlateCVars},
		{3, "Nameplates", "VerticalSpacing", L["NP VerticalSpacing"].."*", true, {.5, 1.5, .1}, UpdatePlateCVars},
		{3, "Nameplates", "MinScale", L["Nameplate MinScale"].."*", false, {.5, 1, .1}, UpdatePlateCVars},
		{3, "Nameplates", "MinAlpha", L["Nameplate MinAlpha"].."*", true, {.3, 1, .1}, UpdatePlateCVars},
	}

    G.TabList["Nameplates"] = options