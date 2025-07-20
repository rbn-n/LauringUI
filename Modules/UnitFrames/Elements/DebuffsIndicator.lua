local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = Core:GetModule("UnitFrames")

local SpellGetVisibilityInfo = SpellGetVisibilityInfo

UF.RaidDebuffsBlack = {}
function UF:UpdateRaidDebuffsBlack()
	wipe(UF.RaidDebuffsBlack)

	for spellID in pairs(Config.RaidDebuffsBlack) do
		local name = GetSpellInfo(spellID)
		if name then
			if LauringUIAccountDB["RaidDebuffsBlack"][spellID] == nil then
				UF.RaidDebuffsBlack[spellID] = true
			end
		end
	end

	for spellID, value in pairs(LauringUIAccountDB["RaidDebuffsBlack"]) do
		if value then
			UF.RaidDebuffsBlack[spellID] = true
		end
	end
end

function UF:DebuffsIndicator_HideButtons(from, to)
	for i = from, to do
		local button = self.DebuffsIndicator.buttons[i]
		if button then
			button:Hide()
		end
	end
end

function UF:DebuffsIndicator_UpdateButton(debuffIndex, aura)
	local button = self.DebuffsIndicator.buttons[debuffIndex]
	if not button then return end

	button.unit, button.index, button.filter = aura.unit, aura.index, aura.filter
	if button.cd then
		if aura.duration and aura.duration > 0 then
			button.cd:SetCooldown(aura.expiration - aura.duration, aura.duration)
			button.cd:Show()
		else
			button.cd:Hide()
		end
	end

	if button.bg then
		if aura.isDebuff then
			local color = oUF.colors.debuff[aura.debuffType] or oUF.colors.debuff.none
			button.bg:SetBackdropBorderColor(color[1], color[2], color[3])
		else
			button.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end

	if button.Icon then button.Icon:SetTexture(aura.texture) end
	if button.count then button.count:SetText(aura.count > 1 and aura.count or "") end

	button:Show()
end

function UF.DebuffsIndicator_Filter(raidAuras, aura)
	local spellID = aura.spellID
	if UF.RaidDebuffsBlack[spellID] then
		return false
	elseif aura.isBossAura then
		return true
	else
		local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, raidAuras.isInCombat and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
		if hasCustom then
			return showForMySpec or (alwaysShowMine and aura.isPlayerAura)
		else
			return true
		end
	end
end

function UF:DebuffsIndicator_UpdateOptions()
	local debuffs = self.DebuffsIndicator
	if not debuffs then return end

	debuffs.enable = Config.DB["UFs"]["ShowBlizzardDebuff"]
	local size = Config.DB["UFs"]["BlizzardDebuffSize"]
	local disableMouse = Config.DB["UFs"]["DebuffClickThrough"]

	for i = 1, 3 do
		local button = debuffs.buttons[i]
		if button then
			button:SetSize(size, size)
			button:EnableMouse(not disableMouse)
		end
	end
end

function UF:CreateDebuffsIndicator(frame)
	local debuffFrame = CreateFrame("Frame", nil, frame)
	local size = Config.DB["UFs"]["BlizzardDebuffSize"] or 20
	local spacing = 2
	local maxButtons = 3

	-- Position frame inside Health, slightly above bottom
	debuffFrame:SetSize((size + spacing) * maxButtons, size)
	debuffFrame:SetPoint("BOTTOM", frame.Health, "BOTTOM", 0, 2)
	debuffFrame:SetFrameLevel(frame:GetFrameLevel() + 5)

	debuffFrame.buttons = {}

	for i = 1, maxButtons do
		local button = CreateFrame("Frame", nil, debuffFrame)
		button:SetSize(size, size)
		Core.PixelIcon(button)
		button:SetScript("OnEnter", UF.AuraButton_OnEnter)
		button:SetScript("OnLeave", Core.HideTooltip)
		button:Hide()

		local cd = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
		cd:SetAllPoints()
		cd:SetReverse(true)
		cd:SetHideCountdownNumbers(true)
		button.cd = cd

		local overlay = CreateFrame("Frame", nil, button)
		overlay:SetAllPoints()
		overlay:SetFrameLevel(button:GetFrameLevel() + 6)
		button.count = Core.CreateFS(overlay, 12, "", false, "BOTTOMRIGHT", 6, -3)

		debuffFrame.buttons[i] = button
	end

	-- Center buttons horizontally inside debuffFrame
	for i = 1, maxButtons do
		local button = debuffFrame.buttons[i]
		button:ClearAllPoints()

		if maxButtons % 2 == 1 then -- odd total buttons
			local centerIndex = math.ceil(maxButtons / 2)
			local offset = (i - centerIndex) * (size + spacing)
			button:SetPoint("CENTER", debuffFrame, "CENTER", offset, 0)
		else -- even number of buttons
			local centerOffset = ((i - (maxButtons / 2 + 0.5)) + 0.5) * (size + spacing)
			button:SetPoint("CENTER", debuffFrame, "CENTER", centerOffset, 0)
		end
	end

	frame.DebuffsIndicator = debuffFrame
	UF.DebuffsIndicator_UpdateOptions(frame)
end