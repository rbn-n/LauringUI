local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local UF = Core:GetModule("UnitFrames")

function UF:CreateAurasIndicator(frame)
	local auraSize = 18

	local auraFrame = CreateFrame("Frame", nil, frame)
	auraFrame:SetSize(1, 1)
	auraFrame:SetPoint("RIGHT", -15, 0)
	auraFrame.instAura = Config.DB["UFs"]["InstanceAuras"]
	auraFrame.dispellType = Config.DB["UFs"]["DispellType"]

	auraFrame.buttons = {}
	local prevAura
	for i = 1, 2 do
		local button = CreateFrame("Frame", nil, auraFrame)
		button:SetSize(auraSize, auraSize)
		button:SetFrameLevel(frame:GetFrameLevel() + 3)
		Core.PixelIcon(button)
		Core.CreateSD(button, 3, true)
		button.__shadow:SetFrameLevel(frame:GetFrameLevel() + 2)
		button:Hide()

		button:SetScript("OnEnter", UF.AuraButton_OnEnter)
		button:SetScript("OnLeave", Core.HideTooltip)

		local parentFrame = CreateFrame("Frame", nil, button)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(button:GetFrameLevel() + 6)
		button.count = Core.CreateFS(parentFrame, 12, "", false, "BOTTOMRIGHT", 6, -3)
		button.timer = Core.CreateFS(button, 12, "", false, "CENTER", 1, 0)
		button.glowFrame = Core.CreateGlowFrame(button, auraSize)

		if not prevAura then
			button:SetPoint("RIGHT")
		else
			button:SetPoint("RIGHT", prevAura, "LEFT", -5, 0)
		end
		prevAura = button
		auraFrame.buttons[i] = button
	end

	frame.AurasIndicator = auraFrame
	frame.AurasIndicator.Debuffs = UF.DebuffList

	UF.AurasIndicatorUpdateOptions(frame)
end

function UF:AurasIndicatorUpdateOptions()
	local auras = self.AurasIndicator
	if not auras then return end

	auras.instAura = Config.DB["UFs"]["InstanceAuras"]
	auras.dispellType = Config.DB["UFs"]["DispellType"]
	local scale = Config.DB["UFs"]["RaidDebuffScale"]
	local disableMouse = Config.DB["UFs"]["AuraClickThru"]

	for i = 1, 2 do
		local button = auras.buttons[i]
		if button then
			button:SetScale(scale)
			button:EnableMouse(not disableMouse)
		end
	end
end

function UF:CreateBuffsIndicator(frame)
	local buffFrame = CreateFrame("Frame", nil, frame)
	buffFrame:SetSize(1, 1)
	buffFrame:SetPoint("BOTTOMRIGHT", -Config.PixelMultiplexer, Config.PixelMultiplexer)
	buffFrame:SetFrameLevel(5)

	buffFrame.buttons = {}
	local prevBuff
	for i = 1, 3 do
		local button = CreateFrame("Frame", nil, buffFrame)
		Core.PixelIcon(button)
		button:SetScript("OnEnter", UF.AuraButton_OnEnter)
		button:SetScript("OnLeave", Core.HideTooltip)
		button:Hide()

		local parentFrame = CreateFrame("Frame", nil, button)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)
		button.count = Core.CreateFS(parentFrame, 10, "", false, "BOTTOMRIGHT", 6, -3)

		button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.cd:SetAllPoints()
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(true)

		if not prevBuff then
			button:SetPoint("BOTTOMRIGHT", frame.Health)
		else
			button:SetPoint("RIGHT", prevBuff, "LEFT")
		end
		prevBuff = button
		buffFrame.buttons[i] = button
	end

	frame.BuffsIndicator = buffFrame

	UF.BuffsIndicatorUpdateOptions(frame)
end

function UF:BuffsIndicatorUpdateOptions()
	local buffs = self.BuffsIndicator
	if not buffs then return end

	buffs.enable = Config.DB["UFs"]["ShowRaidBuff"]
	local size = Config.DB["UFs"]["RaidBuffSize"]
	local disableMouse = Config.DB["UFs"]["BuffClickThru"]

	for i = 1, 3 do
		local button = buffs.buttons[i]
		if button then
			button:SetSize(size, size)
			button:EnableMouse(not disableMouse)
		end
	end
end

function UF:CreateDebuffsIndicator(frame)
	local debuffFrame = CreateFrame("Frame", nil, frame)
	debuffFrame:SetSize(1, 1)
	debuffFrame:SetPoint("BOTTOMLEFT", Config.PixelMultiplexer, Config.PixelMultiplexer)

	debuffFrame.buttons = {}
	local prevDebuff
	for i = 1, 3 do
		local button = CreateFrame("Frame", nil, debuffFrame)
		Core.PixelIcon(button)
		button:SetScript("OnEnter", UF.AuraButton_OnEnter)
		button:SetScript("OnLeave", Core.HideTooltip)
		button:Hide()

		local cd = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
		cd:SetAllPoints()
		cd:SetReverse(true)
		button.cd = cd

		local parentFrame = CreateFrame("Frame", nil, button)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(button:GetFrameLevel() + 6)
		button.count = Core.CreateFS(parentFrame, 12, "", false, "BOTTOMRIGHT", 6, -3)

		button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.cd:SetAllPoints()
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(true)

		if not prevDebuff then
			button:SetPoint("BOTTOMLEFT", frame.Health)
		else
			button:SetPoint("LEFT", prevDebuff, "RIGHT")
		end
		prevDebuff = button
		debuffFrame.buttons[i] = button
	end

	frame.DebuffsIndicator = debuffFrame

	UF.DebuffsIndicatorUpdateOptions(frame)
end

function UF:DebuffsIndicatorUpdateOptions()
	local debuffs = self.DebuffsIndicator
	if not debuffs then return end

	debuffs.enable = Config.DB["UFs"]["ShowRaidDebuff"]
	local size = Config.DB["UFs"]["RaidDebuffSize"]
	local disableMouse = Config.DB["UFs"]["DebuffClickThru"]

	for i = 1, 3 do
		local button = debuffs.buttons[i]
		if button then
			button:SetSize(size, size)
			button:EnableMouse(not disableMouse)
		end
	end
end