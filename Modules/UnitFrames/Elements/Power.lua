local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = Core:GetModule("UnitFrames")

-- Custom colors
oUF.colors.smooth = {1, 0, 0, .85, .8, .45, .1, .1, .1}
oUF.colors.debuff.none = {0, 0, 0}

local function ReplacePowerColor(name, index, color)
	oUF.colors.power[name] = color
	oUF.colors.power[index] = oUF.colors.power[name]
end
ReplacePowerColor("MANA", 0, {0, .4, 1})
ReplacePowerColor("SOUL_SHARDS", 7, {.58, .51, .79})
ReplacePowerColor("HOLY_POWER", 9, {.88, .88, .06})
ReplacePowerColor("CHI", 12, {0, 1, .59})
ReplacePowerColor("ARCANE_CHARGES", 16, {.41, .8, .94})
ReplacePowerColor("SHADOW_ORBS", 28, {.61, .38, 1})

function UF:UpdatePowerBarColor(frame, force)
	local power = frame.Power
	if not power then return end

    power.colorClass = true
	power.colorPower = false
    power.colorReaction = true

	if power.SetColorTapping then
		power:SetColorTapping(true)
	else
		power.colorTapping = (true)
	end

	if power.SetColorDisconnected then
		power:SetColorDisconnected(true)
	else
		power.colorDisconnected = (true)
	end

	local r, g, b = power:GetStatusBarColor()
	local alpha = 0.8
	power:SetStatusBarColor(r, g, b, alpha)

	if power.bg then
		power.bg:SetVertexColor(r, g, b, 0.15)
	end
end

function UF:CreatePowerBar(frame)
    if UF.HidePower(frame) then return end

    local power = CreateFrame("StatusBar", nil, frame)

    if UF.IsPlayerOrTarget(frame) then
        power:SetPoint("LEFT")
        power:SetPoint("RIGHT")
        power:SetPoint("TOP", frame.Health, "BOTTOM" , 0, -Config.DB.UFs.PlayerPowerOffset)
    else
        power:SetPoint("BOTTOMLEFT", frame)
	    power:SetPoint("BOTTOMRIGHT", frame)
    end

    local powerHeight = Config.DB["UFs"][frame.mystyle.."PowerHeight"]
	if frame.mystyle == "Target" then
		powerHeight = Config.DB["UFs"]["PlayerPowerHeight"]
	end

    power:SetHeight(powerHeight)
    power:SetStatusBarTexture(DB.StatusBarTexture2)
	power:SetFrameLevel(frame:GetFrameLevel() - 2)

    local background = power:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Buttons\\WHITE8x8")
    background:SetAllPoints(power)

    Core:SmoothBar(power)
    power.frequentUpdates = true

	Core:CreateHealthBorder(power, 1)
    Core:CreateShadow(power, 5)

    frame.Power = power
    frame.Power.bg = background

	UF:UpdatePowerBarColor(frame)
end

function UF:UpdateFramePowerTag(frame)
    if UF.HidePower(frame) then return end

	local valueType = UF.VariousTagIndex[Config.DB["UFs"][frame.mystyle.."MPTag"]]

	frame:Tag(frame.powerText, "[color][VariousMP("..valueType..")]")
	frame.powerText:UpdateTag()
end

function UF:CreatePowerText(frame)
    if UF.HidePower(frame) then return end

    local textFrame = CreateFrame("Frame", nil, frame)
	textFrame:SetAllPoints(frame.Power)

    local fontSize = Config.DB["UFs"][frame.mystyle.."FontSize"]
    local powerText = Core.CreateFS(textFrame, fontSize - 2, "", false, "RIGHT", -3, 2)
    powerText:SetPoint("RIGHT", -3, 0)

    frame.powerText = powerText
    UF:UpdateFramePowerTag(frame)
end

function UF.PostUpdateAltPower(element, _, cur, _, max)
	if cur and max then
		local perc = floor((cur / max) * 100)
		if perc < 35 then
			element:SetStatusBarColor(0, 1, 0)
		elseif perc < 70 then
			element:SetStatusBarColor(1, 1, 0)
		else
			element:SetStatusBarColor(1, 0, 0)
		end
	end
end

function UF:CreateAltPower(frame)
	local bar = CreateFrame("StatusBar", nil, frame)
	bar:SetStatusBarTexture(DB.StatusBarTexture)
	bar:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -3)
	bar:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -3)
	bar:SetHeight(2)

    Core:CreateBorder(bar, 1)
    Core:CreateBackdrop(bar)

	local text = Core.CreateFS(bar, 14, "")
	text:SetJustifyH("CENTER")
	frame:Tag(text, "[altpower]")

	frame.AlternativePower = bar
	frame.AlternativePower.PostUpdate = UF.PostUpdateAltPower
end

function UF.PostUpdateAddPower(element, _, cur, max)
	if element.Text and max > 0 then
		local perc = cur / max * 100
		if perc == 100 then
			perc = ""
			element:SetAlpha(0)
		else
			perc = format("%d%%", perc)
			element:SetAlpha(1)
		end
		element.Text:SetText(perc)
	end
end

function UF:CreateAdditionalPower(frame)
	if not Config.DB["UFs"]["ShowAdditionalPower"] then return end
	if DB.MyClass ~= "DRUID" then return end

	local bar = CreateFrame("StatusBar", nil, frame)
	bar:SetOrientation("VERTICAL")
	bar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 3, 0)
	bar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 3, 0)
	bar:SetWidth(4)
	bar:SetStatusBarTexture(DB.StatusBarTexture2)
	Core:StyleFrame(bar)
	bar.colorPower = true
	Core:SmoothBar(bar)

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.StatusBarTexture2)
	bg.multiplier = .25

	local text = Core.CreateFS(bar, 12, "", false, "CENTER", 0, 0)

	frame.AdditionalPower = bar
	frame.AdditionalPower.bg = bg
	frame.AdditionalPower.Text = text
	frame.AdditionalPower.Text:Hide()
	frame.AdditionalPower.PostUpdate = UF.PostUpdateAddPower
	frame.AdditionalPower.frequentUpdates = true
end

function UF:CheckPowerBars()
	for _, frame in pairs(oUF.objects) do
		if frame.Power and frame.Power.wasHidden then
			frame:DisableElement("Power")
			if frame.powerText then frame.powerText:Hide() end
		end
	end
end