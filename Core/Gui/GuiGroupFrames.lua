local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

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
				G:SetUnitFrameSize(frame)
				UF.UpdateRaidNameAnchor(frame, frame.nameText)
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

	G:CreateOptionDropdown(scroll.child, L["GrowthDirection"], -30, options, L["RaidDirectionTip"], "UFs", "RaidDirec", 1, UpdateRaidDirection)
	G:CreateOptionSlider(scroll.child, L["Width"], 60, 200, defaultValue[1], -100, "RaidWidth", ResizeRaidFrame)
	G:CreateOptionSlider(scroll.child, L["Height"], 25, 60, defaultValue[2], -180, "RaidHeight", ResizeRaidFrame)
	G:CreateOptionSlider(scroll.child, L["Power Height"], 0, 30, defaultValue[3], -260, "RaidPowerHeight", ResizeRaidFrame)
	G:CreateOptionSlider(scroll.child, L["Num Groups"], 2, 8, defaultValue[4], -340, "NumGroups", UpdateNumGroups)
	G:CreateOptionSlider(scroll.child, L["RaidRows"], 1, 8, defaultValue[5], -420, "RaidRows", UpdateNumGroups)
	G:CreateOptionSlider(scroll.child, L["Spacing"], 0, 10, defaultValue[6], -500, "RaidSpacing", UpdateNumGroups)
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
				G:SetUnitFrameSize(frame)
				UF.UpdateRaidNameAnchor(frame, frame.nameText)
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
	G:CreateOptionDropdown(scroll.child, L["GrowthDirection"], -100, options, nil, "UFs", "PartyDirec", 1, ResizePartyFrame)
	G:CreateOptionSlider(scroll.child, L["Width"], 80, 200, defaultValue[1], -180, "PartyWidth", ResizePartyFrame)
	G:CreateOptionSlider(scroll.child, L["Height"], 25, 60, defaultValue[2], -260, "PartyHeight", ResizePartyFrame)
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
				G:SetUnitFrameSize(frame)
				UF.UpdateRaidNameAnchor(frame, frame.nameText)
			end
		end

		UpdatePartyPetHeader()
	end

	local options = {}
	for i = 1, 8 do
		options[i] = UF.RaidDirections[i].name
	end

	G:CreateOptionDropdown(scroll.child, L["GrowthDirection"], -30, options, nil, "UFs", "PetDirec", 1, UpdatePartyPetHeader)
	G:CreateOptionDropdown(scroll.child, L["Visibility"], -90, {L["ShowInParty"], L["ShowInRaid"], L["ShowInGroup"]}, nil, "UFs", "PartyPetVsby", 1, UF.UpdateAllHeaders)
	G:CreateOptionSlider(scroll.child, L["Width"], 60, 200, 100, -150, "PartyPetWidth", ResizePartyPetFrame)
	G:CreateOptionSlider(scroll.child, L["Height"], 20, 60, 22, -220, "PartyPetHeight", ResizePartyPetFrame)
	G:CreateOptionSlider(scroll.child, L["Power Height"], 0, 30, 2, -290, "PartyPetPowerHeight", ResizePartyPetFrame)
	G:CreateOptionSlider(scroll.child, L["UnitsPerColumn"], 5, 40, 5, -360, "PartyPetPerCol", UpdatePartyPetHeader)
	G:CreateOptionSlider(scroll.child, L["MaxColumns"], 1, 5, 1, -430, "PartyPetMaxCol", UpdatePartyPetHeader)
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

local function UpdateRaidHealthMethod()
	Core:GetModule("UnitFrames"):UpdateRaidHealthMethod()
end

local function UpdateRaidTextScale()
	Core:GetModule("UnitFrames"):UpdateRaidTextScale()
end

local function UpdateAllHeaders()
	Core:GetModule("UnitFrames"):UpdateAllHeaders()
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
    {1, "UFs", "RaidFrame", G.HeaderTag..L["UFs RaidFrame"], nil, SetupRaidFrameFunc, nil, L["RaidFrameTip"]},
    {1, "UFs", "PartyFrame", L["PartyFrame"], nil, SetupPartyFrameFunc, nil, L["PartyFrameTip"]},
    {1, "UFs", "PartyPetFrame", L["PartyPetFrame"], true, SetupPartyPetFrameFunc, nil, L["PartyPetTip"]},
    {},--blank
    {1, "UFs", "FrequentHealth", G.HeaderTag..L["FrequentHealth"].."*", nil, nil, UpdateRaidHealthMethod, L["FrequentHealthTip"]},
    {3, "UFs", "HealthFrequency", L["HealthFrequency"].."*", true, {.1, .5, .05}, UpdateRaidHealthMethod, L["HealthFrequencyTip"]},
    {},--blank
    {4, "UFs", "RaidHPMode", L["HealthValueType"].."*", true, {DISABLE, L["ShowHealthPercent"], L["ShowHealthCurrent"], L["ShowHealthLoss"], L["ShowHealthLossPercent"]}, UpdateRaidTextScale, L["100PercentTip"]},
    {4, "UFs", "ShowRoleMode", L["ShowRoleMode"], nil, {ALL, DISABLE, L["HideDPSRole"]}},
    {3, "UFs", "RaidTextScale", L["UFTextScale"].."*", true, {.8, 1.5, .05}, UpdateRaidTextScale},
    {1, "UFs", "ShowSolo", L["ShowSolo"].."*", nil, nil, UpdateAllHeaders, L["ShowSoloTip"]},
    {1, "UFs", "SmartRaid", G.HeaderTag..L["SmartRaid"].."*", true, nil, UpdateAllHeaders, L["SmartRaidTip"]},
    {1, "UFs", "TeamIndex", L["RaidFrame TeamIndex"].."*", nil, nil, UpdateTeamIndex},
    {1, "UFs", "HideTip", L["HideTooltip"].."*", true, nil, UpdateRaidTextScale, L["HideTooltipTip"]},
    {1, "UFs", "RCCName", L["ClassColor Name"].."*", nil, nil, UpdateRaidTextScale},
}

G.TabList["GroupFrames"] = options