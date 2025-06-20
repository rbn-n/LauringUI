local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")
local _G = _G

function G:SetUnitFrameSize(frame, UF)
    UF:SetUnitFrameSize(frame)
    local unit = frame.mystyle

	local healthHeight = UF:CalculateHealthHeight(frame)
	local powerHeight = unit == "Target" and Config.DB["UFs"]["PlayerPowerHeight"] or Config.DB["UFs"][unit.."PowerHeight"]
	local nameOffset = Config.DB["UFs"][unit.."NameOffset"]
	local powerOffset = Config.DB["UFs"][unit.."PowerOffset"]

	frame.Health:SetHeight(healthHeight)

    if frame.nameText and nameOffset then
		frame.nameText:SetPoint("LEFT", 3, nameOffset)
		frame.nameText:SetWidth(frame:GetWidth()*(nameOffset == 0 and .55 or 1))
	end

    if powerHeight == 0 or UF.HidePower(frame) then
		if frame:IsElementEnabled("Power") then
			frame:DisableElement("Power")
			if frame.powerText then frame.powerText:Hide() end
		end
	else
		if not frame:IsElementEnabled("Power") then
			frame:EnableElement("Power")
			frame.Power:ForceUpdate()
			if frame.powerText then frame.powerText:Show() end
		end

		frame.Power:SetHeight(powerHeight)
		if frame.powerText and powerOffset then
			frame.powerText:SetPoint("RIGHT", -3, powerOffset)
		end
	end
end

G.HealthValues = {DISABLE, L["ShowHealthDefault"], L["ShowHealthCurMax"], L["ShowHealthCurrent"], L["ShowHealthPercent"], L["ShowHealthLoss"], L["ShowHealthLossPercent"]}
local function SetupUnitFrame(guiPage)
	local guiName = "LauringUI_UnitFrameSetup"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(guiPage, guiName, L["UnitFrame Size"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local widthSliderRange = {75, 500}

	local UF = Core:GetModule("UnitFrames")

	local mainFrames = {_G.oUF_Player, _G.oUF_Target}
	local function UpdatePlayerSize()
		for _, mainFrame in pairs(mainFrames) do
			G:SetUnitFrameSize(mainFrame, UF)
			UF:UpdateFrameHealthTag(mainFrame)
			UF:UpdateFramePowerTag(mainFrame)
		end
		UF:UpdateUFAuras()
	end

	local focusFrame = _G.oUF_Focus
	local function UpdateFocusSize()
		if focusFrame then
			G:SetUnitFrameSize(focusFrame, UF)
			UF:UpdateFrameHealthTag(focusFrame)
			UF:UpdateFramePowerTag(focusFrame)
		end
	end

	local subFrames = {_G.oUF_Pet, _G.oUF_ToT, _G.oUF_FocusTarget}
	local function UpdateSubFramesSize()
		for _, subFrame in pairs(subFrames) do
			G:SetUnitFrameSize(subFrame, UF)
			UF:UpdateFrameHealthTag(subFrame)
		end
	end

	local function UpdateBossSize()
		for _, oufFrame in pairs(ns.oUF.objects) do
			if oufFrame.mystyle == "Boss" or oufFrame.mystyle == "Arena" then
				G:SetUnitFrameSize(oufFrame, UF)
				UF:UpdateFrameHealthTag(oufFrame)
				UF:UpdateFramePowerTag(oufFrame)
			end
		end
	end

	local options = {
		[1] = { L["Player&Target"], UpdatePlayerSize },
		[2] = { L["ToT"], UpdateSubFramesSize },
		[3] = { L["Focus"], UpdateFocusSize },
		[4] = { L["FocusTarget"], UpdateSubFramesSize },
		[5] = { L["Pet"], UpdateSubFramesSize },
		[6] = { L["Arena"], UpdateBossSize },
		[7] = { L["Boss"], UpdateBossSize },
	}

	local defaultValues = {}
	for _, option in pairs(options) do
		local name = option[1] == L["Player&Target"] and "Player" or option[1]

		defaultValues[name] = {
			 Config.DB["UFs"][name.."Width"],
			 Config.DB["UFs"][name.."Height"],
			 Config.DB["UFs"][name.."PowerHeight"],
			 Config.DB["UFs"][name.."HPTag"],
			 Config.DB["UFs"][name.."MPTag"],
			 Config.DB["UFs"][name.."PowerOffset"],
			 Config.DB["UFs"][name.."NameOffset"],
			}
	end

	local function CreateOptionGroup(parent, offset, value, func)
		value = value == L["Player&Target"] and "Player" or value
		G:CreateOptionTitle(parent, "", offset)
		G:CreateOptionSlider(parent, L["Width"], widthSliderRange[1], widthSliderRange[2], defaultValues[value][1], offset-50, value.."Width", func)
		G:CreateOptionSlider(parent, L["Height"], 15, 50, defaultValues[value][2], offset-120, value.."Height", func)

		if value == "Player" then
			G:CreateOptionSlider(parent, L["Power Height"], 0, 30, defaultValues[value][3], offset-190, value.."PowerHeight", func)
			local playerAndTarget = { "Player", "Target" }
			for i, playerOrTarget in ipairs(playerAndTarget) do
				local offsetExtender = i == 1 and 0 or 210
				G:CreateOptionDropdown(parent, L["HealthValueType"], offset-260-offsetExtender, G.HealthValues, L["100PercentTip"], "UFs", playerOrTarget.."HPTag", defaultValues[value][4], func)
				G:CreateOptionDropdown(parent, L["PowerValueType"], offset-330-offsetExtender, G.HealthValues, L["100PercentTip"], "UFs", playerOrTarget.."MPTag", defaultValues[value][5], func)
				G:CreateOptionCheck(parent, offset-400-offsetExtender, "Hide"..playerOrTarget.."Power", "UFs", "Hide"..playerOrTarget.."Power", func)
			end
		elseif value ~= "Pet" and value ~= "ToT" and value ~= "FocusTarget" then
			G:CreateOptionDropdown(parent, L["HealthValueType"], offset-190, G.HealthValues, L["100PercentTip"], "UFs", value.."HPTag", defaultValues[value][4], func)
			G:CreateOptionCheck(parent, offset-260, "Hide"..value.."Power", "UFs", "Hide"..value.."Power", func)
			G:CreateOptionDropdown(parent, L["PowerValueType"], offset-330, G.HealthValues, L["100PercentTip"], "UFs", value.."MPTag", defaultValues[value][5], func)
            G:CreateOptionSlider(parent, L["Power Height"], 0, 30, defaultValues[value][3], offset-400, value.."PowerHeight", func)
		else
			G:CreateOptionDropdown(parent, L["HealthValueType"], offset-190, G.HealthValues, L["100PercentTip"], "UFs", value.."HPTag", defaultValues[value][4], func)
		end
	end

	local labels = {}
	for i, v in ipairs(options) do
		labels[i] = v[1]
	end

	local dd = G:CreateDropdown(scroll.child, "", 40, -15, labels, nil, 180, 28)
	dd:SetFrameLevel(20)
	dd.Text:SetText(options[1][1])
	dd:SetBackdropBorderColor(1, .8, 0, .5)
	dd.panels = {}

    for i = 1, #options do
		local panel = CreateFrame("Frame", nil, scroll.child)
		panel:SetSize(260, 1)
		panel:SetPoint("TOP", 0, -30)
		panel:Hide()
        CreateOptionGroup(panel, -10, options[i][1], options[i][2])

		dd.panels[i] = panel
		dd.options[i]:HookScript("OnClick", G.ToggleOptionsPanel)
	end

	G.ToggleOptionsPanel(dd.options[1])
end

local function SetupUFAuras(guiPage)
	local UF = Core:GetModule("UnitFrames")
	local guiName = "LauringUI_UnitFrameAurasSetup"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local extraGUI = G:CreateExtraGUI(guiPage, guiName, L["ShowAuras"].."*")
	local scroll = G:CreateScroll(extraGUI, 260, 540)

	local parent, offset = scroll.child, -10

	local defaultData = {
		["Player"] = {1, 1, 9, 20, 20},
		["Target"] = {2, 2, 9, 20, 20},
		["Focus"] = {3, 2, 9, 20, 20},
		["ToT"] = {1, 1, 5, 6, 6},
		["Pet"] = {1, 1, 5, 6, 6},
		["Boss"] = {2, 3, 6, 6, 6},
	}

	local buffOptions = {DISABLE, L["ShowAll"], L["ShowDispell"]}
	local debuffOptions = {DISABLE, L["ShowAll"], L["BlockOthers"]}
	local growthOptions = {}
	for i = 1, 4 do
		growthOptions[i] = UF.AuraDirections[i].name
	end

	local function CreateOptionGroup(parent, offset, value, func, isBoss)
		local default = defaultData[value]
		G:CreateOptionTitle(parent, "", offset)
		if isBoss then
			offset = offset + 130
		else
			G:CreateOptionDropdown(parent, L["GrowthDirection"], offset-50, growthOptions, "", "UFs", value.."AuraDirection", 1, func)
			G:CreateOptionSlider(parent, L["yOffset"], 0, 200, 10, offset-110, value.."AuraOffset", func)
		end
		G:CreateOptionDropdown(parent, L["BuffType"], offset-180, buffOptions, nil, "UFs", value.."BuffType", default[1], func)
		G:CreateOptionDropdown(parent, L["DebuffType"], offset-240, debuffOptions, nil, "UFs", value.."DebuffType", default[2], func)
		G:CreateOptionSlider(parent, L["MaxBuffs"], 1, 40, default[4], offset-300, value.."NumBuff", func)
		G:CreateOptionSlider(parent, L["MaxDebuffs"], 1, 40, default[5], offset-370, value.."NumDebuff", func)
		if isBoss then
			G:CreateOptionSlider(parent, "Buff "..L["IconsPerRow"], 5, 20, default[3], offset-440, value.."BuffPerRow", func)
			G:CreateOptionSlider(parent, "Debuff "..L["IconsPerRow"], 5, 20, default[3], offset-510, value.."DebuffPerRow", func)
		else
			G:CreateOptionSlider(parent, L["IconsPerRow"], 5, 20, default[3], offset-440, value.."AurasPerRow", func)
		end
	end

	G:CreateOptionTitle(parent, GENERAL, offset)
	G:CreateOptionCheck(parent, offset-35, L["DesaturateIcon"], "UFs", "Desaturate", UF.UpdateUFAuras, L["DesaturateIconTip"])
	G:CreateOptionCheck(parent, offset-70, L["DebuffColor"], "UFs", "DebuffColor", UF.UpdateUFAuras, L["DebuffColorTip"])

	local options = {
		[1] = L["PlayerUF"],
		[2] = L["TargetUF"],
		[3] = L["TotUF"],
		[4] = L["PetUF"],
		[5] = L["FocusUF"],
		[6] = L["BossFrame"],
	}

	local data = {
		[1] = "Player",
		[2] = "Target",
		[3] = "ToT",
		[4] = "Pet",
		[5] = "Focus",
		[6] = "Boss",
	}

	local dd = G:CreateDropdown(scroll.child, "", 40, -135, options, nil, 180, 28)
	dd:SetFrameLevel(20)
	dd.Text:SetText(options[1])
	dd:SetBackdropBorderColor(1, .8, 0, .5)
	dd.panels = {}

	for i = 1, #options do
		local panel = CreateFrame("Frame", nil, scroll.child)
		panel:SetSize(260, 1)
		panel:SetPoint("TOP", 0, -30)
		panel:Hide()
		CreateOptionGroup(panel, -130, data[i], UF.UpdateUFAuras, i == 6)

		dd.panels[i] = panel
		dd.options[i]:HookScript("OnClick", G.ToggleOptionsPanel)
	end

	G.ToggleOptionsPanel(dd.options[1])
end

local function SetupUnitFrameFunc()
	SetupUnitFrame(G.GuiPage["UnitFrames"])
end

local function SetupUFAurasFunc()
	SetupUFAuras(G.GuiPage["UnitFrames"])
end

local function ToggleAllAuras()
	Core:GetModule("UnitFrames"):ToggleAllAuras()
end

local function ToggleDebuffHighlight()
	Core:GetModule("UnitFrames"):ToggleDebuffHighlight()
end

local function UpdateUFTextScale()
	Core:GetModule("UnitFrames"):UpdateTextScale()
end

local options = {
    {1, "UFs", "Enable", G.HeaderTag..L["Enable UFs"], nil, SetupUnitFrameFunc, nil, L["HideUFWarning"]},
    {3, "UFs", "UFTextScale", L["UFTextScale"].."*", true, {.8, 1.5, .05}, UpdateUFTextScale, nil, nil, true},
    {1, "UFs", "ShowArena", L["Arena Frame"], nil},
    {1, "UFs", "ShowAuras", L["ShowAuras"].."*", nil, SetupUFAurasFunc, ToggleAllAuras},
    {1, "UFs", "EnableDebuffHighlight", L["DebuffHighlight"].."*", true, nil, ToggleDebuffHighlight, L["DebuffHighlightTip"]},
	{}, -- blank
	{1, "UFs", "ShowAdditionalPower", G.HeaderTag..L["ShowAdditionalPower"], nil, nil, nil, L["ShowAdditionalPowerTip"]},
	{1, "UFs", "ShowClassPower", G.HeaderTag..L["ShowClassPower"], nil, nil, nil, L["ShowClassPowerTip"]},
	{1, "UFs", "ShowRuneTimer", L["UFs RuneTimer"], true},
	{3, "UFs", "ClassPowerWidth", L["Width"], nil, {100, 400, 1}, UpdateUFTextScale},
	{3, "UFs", "ClassPowerHeight", L["Height"], true, { 2, 30, 1}, UpdateUFTextScale},
	{3, "UFs", "ClassPowerxOffset", L["xOffset"], nil, {-20, 200, 1}, UpdateUFTextScale},
	{3, "UFs", "ClassPoweryOffset", L["yOffset"], true, {-200, 20, 1}, UpdateUFTextScale},
}

G.TabList["UnitFrames"] = options