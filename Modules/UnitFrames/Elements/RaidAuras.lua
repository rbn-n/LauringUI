local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = Core:GetModule("UnitFrames")

local invalidPrio = -1

function UF:CreateRaidAuras(frame)
	UF:CreateAurasIndicator(frame)
	UF:CreateSpellsIndicator(frame)
	UF:CreateDebuffsIndicator(frame)

	local raidAuras = CreateFrame("Frame", nil, frame)
	raidAuras:SetSize(1, 1)
	raidAuras:SetPoint("CENTER")

	frame.RaidAuras = raidAuras
	frame.RaidAuras.PostUpdate = UF.RaidAurasPostUpdate
end

function UF.RaidAurasPostUpdate(element, unit)
	local self = element.__owner
	local auras = self.AurasIndicator
	local spells = self.SpellsIndicator
	local debuffs = self.DebuffsIndicator

	local enableSpells = Config.DB["UFs"]["RaidBuffIndicator"]
	local auraIndex, debuffIndex = 0, 0
	local numBuffs = element.buffList.num
	local numDebuffs = element.debuffList.num

	element.isInCombat = UnitAffectingCombat("player")

	if Config.DB["UFs"]["InstanceAuraDispellType"] ~= 3 or Config.DB["UFs"]["ShowInstanceAuras"] then
		UF.AurasIndicator_UpdatePriority(self, numDebuffs, unit)
		UF.AurasIndicator_HideButtons(self)

		for i = 1, numDebuffs do
			local button = auras.buttons[i]
			if not button then break end

			local aura = element.debuffList[i]
			if aura.priority > invalidPrio then
				auraIndex = auraIndex + 1
				UF:AurasIndicator_UpdateButton(button, aura)
			end
		end
	end

	UF.SpellsIndicator_HideButtons(self)

	for i = auraIndex + 1, numDebuffs do
		local aura = element.debuffList[i]
		local value = enableSpells and not Config.CornerBlackList[aura.spellID] and (UF.CornerSpells[aura.spellID] or UF.CornerSpellsByName[aura.name])
		if value and (value[2] or aura.isPlayerAura) then
			local group = spells[value[1]]
			if group then
				for j = 1, #group do
					local button = group[j]
					if not button:IsShown() then
						UF:SpellsIndicator_UpdateButton(button, aura)
						break
					end
				end
			end
		elseif debuffs.enable and debuffIndex < 4 and UF.DebuffsIndicator_Filter(element, aura) then
			debuffIndex = debuffIndex + 1
			UF.DebuffsIndicator_UpdateButton(self, debuffIndex, aura)
		end
	end

	UF.DebuffsIndicator_HideButtons(self, debuffIndex + 1, 3)

	for i = 1, numBuffs do
		local aura = element.buffList[i]
		local value = enableSpells and not Config.CornerBlackList[aura.spellID] and (UF.CornerSpells[aura.spellID] or UF.CornerSpellsByName[aura.name])
		if value and (value[2] or aura.isPlayerAura) then
			local group = spells[value[1]]
			if group then
				for j = 1, #group do
					local button = group[j]
					if not button:IsShown() then
						UF:SpellsIndicator_UpdateButton(button, aura)
						break
					end
				end
			end
		end
	end

	if self.DebuffHighlight and Config.DB.UFs.EnableDebuffHighlight then
		UF:CheckForDispellableAura(self, unit)
	end
end


function UF:RaidAuras_UpdateOptions()
	for _, frame in pairs(oUF.objects) do
		if UF.IsPartyOrRaid(frame) then
			UF.AurasIndicator_UpdateOptions(frame)
			UF.SpellsIndicator_UpdateOptions(frame)
			UF.DebuffsIndicator_UpdateOptions(frame)
		end
	end
end