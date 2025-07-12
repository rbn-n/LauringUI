local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = Core:GetModule("UnitFrames")
local Nameplates = Core:GetModule("Nameplates")

local x1, x2, y1, y2 = unpack(DB.TexCoord)

UF.AuraDirections = {
	[1] = {name = L["RIGHT_DOWN"], initialAnchor = "TOPLEFT", relAnchor = "BOTTOMLEFT", x = 0, y = -1, growthX = "RIGHT", growthY = "DOWN"},
	[2] = {name = L["RIGHT_UP"], initialAnchor = "BOTTOMLEFT", relAnchor = "TOPLEFT", x = 0, y = 1, growthX = "RIGHT", growthY = "UP"},
	[3] = {name = L["LEFT_DOWN"], initialAnchor = "TOPRIGHT", relAnchor = "BOTTOMRIGHT", x = 0, y = -1, growthX = "LEFT", growthY = "DOWN"},
	[4] = {name = L["LEFT_UP"], initialAnchor = "BOTTOMRIGHT", relAnchor = "TOPRIGHT", x = 0, y = 1, growthX = "LEFT", growthY = "UP"},
}

local auraUFs = {
	["Player"] = "Player",
	["Target"] = "Target",
    ["ToT"] = "ToT",
	["Pet"] = "Pet",
	["Focus"] = "Focus",
}

function UF:ConfigureAuras(auras)
	local value = auras.__value
	auras.numBuffs = Config.DB["UFs"][value.."BuffType"] ~= 1 and Config.DB["UFs"][value.."NumBuff"] or 0
	auras.numDebuffs = Config.DB["UFs"][value.."DebuffType"] ~= 1 and Config.DB["UFs"][value.."NumDebuff"] or 0
	auras.iconsPerRow = Config.DB["UFs"][value.."AurasPerRow"]
	auras.showDebuffType = Config.DB["UFs"]["DebuffColor"]
	auras.desaturateDebuff = Config.DB["UFs"]["Desaturate"]
end

function UF:UpdateAuraDirection(frame, auras)
	local direction = Config.DB["UFs"][auras.__value.."AuraDirection"]
	local yOffset = Config.DB["UFs"][auras.__value.."AuraOffset"]
	local value = UF.AuraDirections[direction]
	auras.initialAnchor = value.initialAnchor
	auras["growth-x"] = value.growthX
	auras["growth-y"] = value.growthY
	auras:ClearAllPoints()
	auras:SetPoint(value.initialAnchor, frame, value.relAnchor, value.x, value.y * yOffset)
end

local function AuraIconSize(width, iconsPerRow, spacing)
	return (width - (iconsPerRow - 1) * spacing) / iconsPerRow
end

function UF:UpdateAuraContainer(frame, auras, maxAuras)
	local width = frame:GetWidth()
	local iconsPerRow = auras.iconsPerRow
	local maxLines = iconsPerRow and Core:Round(maxAuras/iconsPerRow) or 2
	auras.size = iconsPerRow and AuraIconSize(width, iconsPerRow, auras.spacing) or auras.size
	auras:SetWidth(width)
	auras:SetHeight((auras.size + auras.spacing) * maxLines)

	local fontSize = auras.fontSize or auras.size*.6
	for i = 1, #auras do
		local button = auras[i]
		if button then
			if button.timer then Core.SetFontSize(button.timer, fontSize) end
			if button.count then Core.SetFontSize(button.count, fontSize) end
		end
	end
end

function UF.PreUpdateAura(element)
	element.hasTheDot = nil
end

function UF.PostUpdateGapIcon(_, _, icon)
	if icon.iconbg and icon.iconbg:IsShown() then
		icon.iconbg:Hide()
	end
end

function UF:UpdateIconTexCoord(width, height)
	local ratio = height / width
	local mult = (1 - ratio) / 2
	self.icon:SetTexCoord(x1, x2, y1 + mult, y2 - mult)
end

function UF.PostCreateIcon(element, button)
	local fontSize = element.fontSize or element.size*.6
	local parentFrame = CreateFrame("Frame", nil, button)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)
	button.count = Core.CreateFS(parentFrame, fontSize, "", false, "BOTTOMRIGHT", 6, -3)
	button.cd:SetReverse(true)
	local needShadow = true
	if element.__owner.mystyle == "raid" and not Config.DB["UFs"]["RaidBuffIndicator"] then
		needShadow = false
	end
	button.iconbg = Core.ReskinIcon(button.icon, needShadow)

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetColorTexture(1, 1, 1, .25)
	button.HL:SetAllPoints()

	button.overlay:SetTexture(nil)
	button.stealable:SetAtlas("bags-newitem")

	if element.disableCooldown then
		hooksecurefunc(button, "SetSize", UF.UpdateIconTexCoord)
		button.timer = Core.CreateFS(button, fontSize, "")
		button.timer:ClearAllPoints()
		button.timer:SetPoint("LEFT", button, "TOPLEFT", -2, 0)
		button.count:ClearAllPoints()
		button.count:SetPoint("RIGHT", button, "BOTTOMRIGHT", 5, 0)
	end
end

local filteredStyle = {
	["target"] = true,
	["boss"] = true,
	["arena"] = true,
}

local dispellType = {
	["Magic"] = true,
	[""] = true,
}

function UF.PostUpdateIcon(element, unit, button, _, _, duration, expiration, debuffType)
	if duration then button.iconbg:Show() end

	local style = element.__owner.mystyle
	if style == "Nameplate" then
		button:SetSize(element.size, element.size * Config.DB["Nameplates"]["SizeRatio"])
	else
		button:SetSize(element.size, element.size)
	end

	if element.desaturateDebuff and button.isDebuff and filteredStyle[style] and not button.isPlayer then
		button.icon:SetDesaturated(true)
	else
		button.icon:SetDesaturated(false)
	end

	if element.showDebuffType and button.isDebuff then
		local color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none
		button.iconbg:SetBackdropBorderColor(color[1], color[2], color[3])
	else
		button.iconbg:SetBackdropBorderColor(0, 0, 0)
	end

	if element.alwaysShowStealable and dispellType[debuffType] and not UnitIsPlayer(unit) and (not button.isDebuff) then
		button.stealable:Show()
	end

	if element.disableCooldown then
		if duration and duration > 0 then
			button.expiration = expiration
			button:SetScript("OnUpdate", Core.CooldownOnUpdate)
			button.timer:Show()
		else
			button:SetScript("OnUpdate", nil)
			button.timer:Hide()
		end
	end
end

local IsCasterPlayer = {
	["player"] = true,
	["pet"] = true,
	["vehicle"] = true,
}

function UF.CustomFilter(element, unit, button, name, _, _, debuffType, _, _, caster, isStealable, _, spellID, _, _, _, nameplateShowAll)
	local style = element.__owner.mystyle

	if style == "Nameplate" or style == "Boss" or style == "Arena" then
		if Config.DB["Nameplates"]["ColorByDot"] and IsCasterPlayer[caster] and Config.DB["Nameplates"]["DotSpells"][spellID] then
			element.hasTheDot = true
		end

		if element.__owner.plateType == "NameOnly" then
			return Nameplates.NameplateWhite[spellID]
		elseif Nameplates.NameplateBlack[spellID] then
			return false
		elseif (element.showStealableBuffs and isStealable or element.alwaysShowStealable and dispellType[debuffType]) and not UnitIsPlayer(unit) and (not button.isDebuff) then
			return true
		elseif Nameplates.NameplateWhite[spellID] then
			return true
		else
			local auraFilter = Config.DB["Nameplates"]["AuraFilter"]
			return (auraFilter == 3 and nameplateShowAll) or (auraFilter ~= 1 and IsCasterPlayer[caster])
		end
	else
		return (element.onlyShowPlayer and button.isPlayer) or (not element.onlyShowPlayer and name)
	end
end

function UF.UnitCustomFilter(element, _, button, name, _, _, _, _, _, _, isStealable)
	local value = element.__value
	if button.isDebuff then
		if Config.DB["UFs"][value.."DebuffType"] == 2 then
			return name
		elseif Config.DB["UFs"][value.."DebuffType"] == 3 then
			return button.isPlayer
		end
	else
		if Config.DB["UFs"][value.."BuffType"] == 2 then
			return name
		elseif Config.DB["UFs"][value.."BuffType"] == 3 then
			return isStealable
		end
	end
end

function UF:CreateAuras(frame)
	local mystyle = frame.mystyle

    local auras = CreateFrame("Frame", nil, frame)
	auras:SetFrameLevel(frame:GetFrameLevel() + 2)
	auras.gap = true
	auras.initialAnchor = "TOPLEFT"
	auras["growth-y"] = "DOWN"
	auras.spacing = 3
	auras.tooltipAnchor = "ANCHOR_BOTTOMLEFT"

	if auraUFs[mystyle] then
		auras.__value = auraUFs[mystyle]
		UF:ConfigureAuras(auras)
		UF:UpdateAuraDirection(frame, auras)
		auras.CustomFilter = UF.UnitCustomFilter
	elseif mystyle == "Nameplate" then
		auras.initialAnchor = "BOTTOMLEFT"
		auras["growth-y"] = "UP"
		auras:SetPoint("BOTTOMLEFT", frame.nameText, "TOPLEFT", 0, 5)
		auras.numTotal = Config.DB["Nameplates"]["MaxAuras"]
		auras.size = Config.DB["Nameplates"]["AuraSize"]
		auras.fontSize = Config.DB["Nameplates"]["FontSize"]
		auras.showDebuffType = Config.DB["Nameplates"]["DebuffColor"]
		auras.desaturateDebuff = Config.DB["Nameplates"]["Desaturate"]
		auras.gap = false
		auras.disableMouse = true
		auras.disableCooldown = true
		auras.spacing = 5
		auras.CustomFilter = UF.CustomFilter
	end

	UF:UpdateAuraContainer(frame, auras, auras.numTotal or auras.numBuffs + auras.numDebuffs)
	auras.showStealableBuffs = true
	auras.PostCreateIcon = UF.PostCreateIcon
	auras.PostUpdateIcon = UF.PostUpdateIcon
	auras.PostUpdateGapIcon = UF.PostUpdateGapIcon
	auras.PreUpdate = UF.PreUpdateAura

	frame.Auras = auras
end

function UF:ConfigureBuffAndDebuff(element, isDebuff)
	local value = element.__value
	local vType = isDebuff and "Debuff" or "Buff"
	element.num = Config.DB["UFs"][value..vType.."Type"] ~= 1 and Config.DB["UFs"][value.."Num"..vType] or 0
	element.iconsPerRow = Config.DB["UFs"][value..vType.."PerRow"]
	element.showDebuffType = Config.DB["UFs"]["DebuffColor"]
	element.desaturateDebuff = Config.DB["UFs"]["DebuffsDesaturate"]
end

function UF:CreateBuffs(frame)
	local buffs = CreateFrame("Frame", nil, frame)
	buffs:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 5)
	buffs.initialAnchor = "BOTTOMLEFT"
	buffs["growth-x"] = "RIGHT"
	buffs["growth-y"] = "UP"
	buffs.spacing = 3
	buffs.tooltipAnchor = "ANCHOR_BOTTOMLEFT"

	buffs.__value = "Boss"
	UF:ConfigureBuffAndDebuff(buffs)
	buffs.CustomFilter = UF.UnitCustomFilter

	UF:UpdateAuraContainer(frame, buffs, buffs.num)
	buffs.showStealableBuffs = true
	buffs.PostCreateIcon = UF.PostCreateIcon
	buffs.PostUpdateIcon = UF.PostUpdateIcon

	frame.Buffs = buffs
end

function UF:CreateDebuffs(frame)
	local debuffs = CreateFrame("Frame", nil, frame)
	debuffs.spacing = 3
	debuffs.initialAnchor = "TOPRIGHT"
	debuffs["growth-x"] = "LEFT"
	debuffs["growth-y"] = "DOWN"
	debuffs.tooltipAnchor = "ANCHOR_BOTTOMLEFT"
	debuffs.showDebuffType = true
	debuffs:SetPoint("TOPRIGHT", frame, "TOPLEFT", -5, 0)
	debuffs.__value = "Boss"
	UF:ConfigureBuffAndDebuff(debuffs, true)
	debuffs.CustomFilter = UF.UnitCustomFilter

	UF:UpdateAuraContainer(frame, debuffs, debuffs.num)
	debuffs.PostCreateIcon = UF.PostCreateIcon
	debuffs.PostUpdateIcon = UF.PostUpdateIcon

	frame.Debuffs = debuffs
end

function UF:ToggleUFAuras(frame, enable)
	if not frame then return end
	if enable then
		if not frame:IsElementEnabled("Auras") then
			frame:EnableElement("Auras")
		end
	else
		if frame:IsElementEnabled("Auras") then
			frame:DisableElement("Auras")
			frame.Auras:ForceUpdate()
		end
	end
end

function UF:ToggleAllAuras()
	local enable = Config.DB["UFs"]["ShowAuras"]
	UF:ToggleUFAuras(_G.oUF_Player, enable)
	UF:ToggleUFAuras(_G.oUF_Target, enable)
	UF:ToggleUFAuras(_G.oUF_Focus, enable)
	UF:ToggleUFAuras(_G.oUF_ToT, enable)
end

function UF:RefreshUFAuras(frame)
	if not frame then return end
	local element = frame.Auras
	if not element then return end

	UF:ConfigureAuras(element)
	UF:UpdateAuraContainer(frame, element, element.numBuffs + element.numDebuffs)
	UF:UpdateAuraDirection(frame, element)
	element:ForceUpdate()
end

function UF:RefreshBuffAndDebuff(frame)
	if not frame then return end

	local buffs = frame.Buffs
	if buffs then
		UF:ConfigureBuffAndDebuff(buffs)
		UF:UpdateAuraContainer(frame, buffs, buffs.num)
		buffs:ForceUpdate()
	end

	local debuffs = frame.Debuffs
	if debuffs then
		UF:ConfigureBuffAndDebuff(debuffs, true)
		UF:UpdateAuraContainer(frame, debuffs, debuffs.num)
		debuffs:ForceUpdate()
	end
end

function UF:UpdateUFAuras()
	UF:RefreshUFAuras(_G.oUF_Player)
	UF:RefreshUFAuras(_G.oUF_Target)
	UF:RefreshUFAuras(_G.oUF_Focus)
	UF:RefreshUFAuras(_G.oUF_ToT)
	UF:RefreshUFAuras(_G.oUF_Pet)

	for i = 1, 5 do
		UF:RefreshBuffAndDebuff(_G["oUF_Boss"..i])
		UF:RefreshBuffAndDebuff(_G["oUF_Arena"..i])
	end
end