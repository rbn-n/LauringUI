local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

local function SetUnitFrameSize(frame, UF)
    UF:SetUnitFrameSize(frame)
    local unit = frame.mystyle

	local healthHeight = UF.CalculateHealthHeight(frame)
	local powerHeight = Config.DB["UFs"][unit.."PowerHeight"]
	local nameOffset = Config.DB["UFs"][unit.."NameOffset"]
	local powerOffset = Config.DB["UFs"][unit.."PowerOffset"]

	frame.Health:SetHeight(healthHeight)

    if frame.nameText and nameOffset then
		frame.nameText:SetPoint("LEFT", 3, nameOffset)
		frame.nameText:SetWidth(frame:GetWidth()*(nameOffset == 0 and .55 or 1))
	end

    if powerHeight == 0 or UF:HidePower(frame) then
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
function SetupUnitFrame(guiPage)
	local guiName = "LauringUI_UnitFrameSetup"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(guiPage, guiName, L["UnitFrame Size"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local widthSliderRange = {100, 500}

	local options = {
		[1] = L["Player"],
		[2] = L["Target"],
		[3] = L["ToT"],
		[4] = L["Focus"],
		[5] = L["FocusTarget"],
		[6] = L["Pet"],
		[7] = L["Arena"],
		[8] = L["Boss"],
	}

	-- local defaultValues = {

	-- for _, name in pairs(options) do

	-- end

	local defaultValues = { -- healthWidth, healthHeight, powerHeight, healthTag, powerTag, powerOffset, nameOffset
		["Player"] = {272, 42, 10, 2, 4, 4, 0},
		["ToT"] = {125, 24, 2, 5, 0}, -- nameOffset on 5th
		["Focus"] = {125, 24, 2, 2, 4, 2, 0},
		["FocusTarget"] = {200, 22, 2, 2, 4, 2, 0},
		["Pet"] = {125, 24, 3, 5, 0}, -- nameOffset on 5th
		["Arena"] = {150, 22, 2, 5, 5, 2, 0},
		["Boss"] = {150, 22, 2, 5, 5, 2, 0},
	}

	local UF = Core:GetModule("UnitFrames")

	local function CreateOptionGroup(parent, offset, value, func)
		G:CreateOptionTitle(parent, "", offset)
		local defaultValue = value == "Target" and "Player" or value
		G:CreateOptionDropdown(parent, L["HealthValueType"], offset-50, G.HealthValues, L["100PercentTip"], "UFs", value.."HPTag", defaultValues[defaultValue][4], func)
		local mult = 0
		if value ~= "Pet" and value ~= "ToT" and value ~= "FocusTarget" then
			mult = 170
			G:CreateOptionCheck(parent, offset-90, "Hide"..value.."Power", "UFs", "Hide"..value.."Power", func)
			G:CreateOptionDropdown(parent, L["PowerValueType"], offset-150, G.HealthValues, L["100PercentTip"], "UFs", value.."MPTag", defaultValues[defaultValue][5], func)
            G:CreateOptionSlider(parent, L["Power Height"], 0, 30, defaultValues[defaultValue][3], offset-210, defaultValue.."PowerHeight", func)
		end
		-- (parent, title, minV, maxV, defaultV, yOffset, value, func, key)
		G:CreateOptionSlider(parent, L["Width"], widthSliderRange[1], widthSliderRange[2], defaultValues[defaultValue][1], offset-110-mult, defaultValue.."Width", func)
		G:CreateOptionSlider(parent, L["Height"], 15, 50, defaultValues[defaultValue][2], offset-180-mult, defaultValue.."Height", func)
	end

	local mainFrames = {_G.oUF_Player, _G.oUF_Target}
	local function updatePlayerSize()
		for _, mainFrame in pairs(mainFrames) do
			SetUnitFrameSize(mainFrame, UF)
			UF.UpdateFrameHealthTag(mainFrame)
			UF.UpdateFramePowerTag(mainFrame)
		end
		UF:UpdateUFAuras()
	end

	local function updateFocusSize()
		local focusFrame = _G.oUF_Focus
		if focusFrame then
            SetUnitFrameSize(focusFrame, UF)
			UF.UpdateFrameHealthTag(focusFrame)
			UF.UpdateFramePowerTag(focusFrame)
		end
	end

	local subFrames = {_G.oUF_Pet, _G.oUF_ToT, _G.oUF_FocusTarget}
	local function updatePetSize()
		for _, subFrame in pairs(subFrames) do
            SetUnitFrameSize(subFrame, UF)
			UF.UpdateFrameHealthTag(subFrame)
		end
	end

	local function updateBossSize()
		for _, oufFrame in pairs(ns.oUF.objects) do
			if oufFrame.mystyle == "Boss" or oufFrame.mystyle == "Arena" then
                SetUnitFrameSize(oufFrame, UF)
				UF.UpdateFrameHealthTag(oufFrame)
				UF.UpdateFramePowerTag(oufFrame)
			end
		end
	end

	local data = {
		[1] = {"Player", updatePlayerSize},
		[2] = {"Target", updatePlayerSize},
		[3] = {"ToT", updatePetSize},
		[4] = {"Focus", updateFocusSize},
		[5] = {"FocusTarget", updatePetSize},
		[6] = {"Pet", updatePetSize},
		[7] = {"Arena", updateBossSize},
		[8] = {"Boss", updateBossSize},
	}

	local dd = G:CreateDropdown(scroll.child, "", 40, -15, options, nil, 180, 28)
	dd:SetFrameLevel(20)
	dd.Text:SetText(options[1])
	dd:SetBackdropBorderColor(1, .8, 0, .5)
	dd.panels = {}

    for i = 1, #options do
		local panel = CreateFrame("Frame", nil, scroll.child)
		panel:SetSize(260, 1)
		panel:SetPoint("TOP", 0, -30)
		panel:Hide()
        CreateOptionGroup(panel, -10, data[i][1], data[i][2])

		dd.panels[i] = panel
		dd.options[i]:HookScript("OnClick", G.ToggleOptionsPanel)
	end

	G.ToggleOptionsPanel(dd.options[1])
end

local function SetupUFAuras(guiPage)
	local guiName = "LauringUI_UnitFrameAurasSetup"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local extraGUI = G:CreateExtraGUI(guiPage, guiName, L["ShowAuras"].."*")
	local scroll = G:CreateScroll(extraGUI, 260, 540)

	local UF = Core:GetModule("UnitFrames")
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
			G:CreateOptionDropdown(parent, L["GrowthDirection"], offset-50, growthOptions, "", "UFs", value.."AuraDirec", 1, func)
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

local function UpdateUFTextScale()
	Core:GetModule("UnitFrames"):UpdateTextScale()
end

local options = {
    {1, "UFs", "Enable", G.HeaderTag..L["Enable UFs"], nil, SetupUnitFrameFunc, nil, L["HideUFWarning"]},
    {1, "UFs", "Arena", L["Arena Frame"], true},
    {1, "UFs", "ShowAuras", L["ShowAuras"].."*", nil, SetupUFAurasFunc, ToggleAllAuras},
    {3, "UFs", "UFTextScale", L["UFTextScale"].."*", nil, {.8, 1.5, .05}, UpdateUFTextScale},
}

G.TabList["UnitFrames"] = options