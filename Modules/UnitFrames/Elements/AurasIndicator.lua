local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = Core:GetModule("UnitFrames")

UF.DebuffList = {}

local instanceName = nil

local function CheckInstance()
	instanceName = IsInInstance() and GetInstanceInfo()
end

function UF.SortAuraTable(a, b)
	if a and b then
		return a.priority == b.priority and a.expiration > b.expiration or a.priority > b.priority
	end
end

function UF:UpdateRaidDebuffs()
	wipe(UF.DebuffList)
	for instName, value in pairs(Config.RaidDebuffs) do
		for spell, priority in pairs(value) do
			if not (LauringUIAccountDB["RaidDebuffs"][instName] and LauringUIAccountDB["RaidDebuffs"][instName][spell]) then
				if not UF.DebuffList[instName] then UF.DebuffList[instName] = {} end
				UF.DebuffList[instName][spell] = priority
			end
		end
	end
	for instName, value in pairs(LauringUIAccountDB["RaidDebuffs"]) do
		for spell, priority in pairs(value) do
			if priority > 0 then
				if not UF.DebuffList[instName] then UF.DebuffList[instName] = {} end
				UF.DebuffList[instName][spell] = priority
			end
		end
	end
end

function UF:AurasIndicator_HideButtons()
	local auras = self.AurasIndicator
	if auras then
		auras.buttons[1]:Hide()
		auras.buttons[2]:Hide()
	end
end

function UF:AurasIndicator_UpdateButton(button, aura)
	local icon, count, duration, expiration = aura.texture, aura.count, aura.duration, aura.expiration
	button.unit, button.index, button.filter = aura.unit, aura.index, aura.filter

	if button.Icon then
		button.Icon:SetTexture(icon)
	end
	if button.count then
		button.count:SetText(count > 1 and count or "")
	end
	if button.timer then
		button.duration = duration
		if duration and duration > 0 then
			button.expiration = expiration
			button:SetScript("OnUpdate", Core.CooldownOnUpdate)
			button.timer:Show()
		else
			button:SetScript("OnUpdate", nil)
			button.timer:Hide()
		end
	end
	if button.cd then
		if duration and duration > 0 then
			button.cd:SetCooldown(expiration - duration, duration)
			button.cd:Show()
		else
			button.cd:Hide()
		end
	end

	if button.glowFrame then
		if aura.priority == 6 then
			Core.ShowOverlayGlow(button.glowFrame)
		else
			Core.HideOverlayGlow(button.glowFrame)
		end
	end
	button:Show()
end

function UF:AurasIndicator_UpdatePriority(numDebuffs, unit)
	local auras = self.AurasIndicator
	local raidAuras = self.RaidAuras

	for i = 1, numDebuffs do
		local aura = raidAuras.debuffList[i]

		if auras.instAura then
			local instPrio
			local debuffList = instanceName and auras.Debuffs[instanceName] or auras.Debuffs[0]
			if debuffList then
				instPrio = debuffList[aura.spellID]
			end

			if instPrio and (instPrio == 6 or instPrio > aura.priority) then
				aura.priority = instPrio
			end
		end
	end

	sort(raidAuras.debuffList, UF.SortAuraTable)
end

function UF:AuraButton_OnEnter()
	if not self.index then return end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	GameTooltip:ClearLines()
	GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
	GameTooltip:Show()
end

function UF:AurasIndicator_UpdateOptions()
	local auras = self.AurasIndicator
	if not auras then return end

	auras.instAura = Config.DB["UFs"]["ShowInstanceAuras"]
	auras.dispellType = Config.DB["UFs"]["InstanceAuraDispellType"]
	local scale = Config.DB["UFs"]["InstanceAuraScale"]
	local disableMouse = Config.DB["UFs"]["InstanceAuraClickThrough"]

	for i = 1, 2 do
		local button = auras.buttons[i]
		if button then
			button:SetScale(scale)
			button:EnableMouse(not disableMouse)
		end
	end
end

function UF:CreateAurasIndicator(frame)
	local auraSize = 18
	local spacing = 4
	local numButtons = 2

	local auraFrame = CreateFrame("Frame", nil, frame)
	auraFrame:SetSize((auraSize + spacing) * numButtons, auraSize)
	auraFrame:SetPoint("BOTTOM", frame.Health, "BOTTOM", 0, 3)
	auraFrame:SetFrameLevel(frame:GetFrameLevel() + 5)
	auraFrame.instAura = Config.DB["UFs"]["ShowInstanceAuras"]
	auraFrame.dispellType = Config.DB["UFs"]["InstanceAuraDispellType"]

	auraFrame.buttons = {}

	for i = 1, numButtons do
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

		auraFrame.buttons[i] = button
	end

	-- Position buttons centered horizontally in auraFrame
	for i = 1, numButtons do
		local button = auraFrame.buttons[i]
		button:ClearAllPoints()

		if numButtons % 2 == 1 then
			local centerIndex = math.ceil(numButtons / 2)
			local offset = (i - centerIndex) * (auraSize + spacing)
			button:SetPoint("CENTER", auraFrame, "CENTER", offset, 0)
		else
			local centerOffset = ((i - (numButtons / 2 + 0.5)) + 0.5) * (auraSize + spacing)
			button:SetPoint("CENTER", auraFrame, "CENTER", centerOffset, 0)
		end
	end

	frame.AurasIndicator = auraFrame
	frame.AurasIndicator.Debuffs = UF.DebuffList

	UF.AurasIndicator_UpdateOptions(frame)
end

function UF:UpdateRaidInfo()
	CheckInstance()
	Core:RegisterEvent("PLAYER_ENTERING_WORLD", CheckInstance)
	UF:UpdateRaidDebuffs()
end