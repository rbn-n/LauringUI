local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = Core:GetModule("UnitFrames")

local counterOffsets = {
	["TOPRIGHT"] = {{-3, -1}, {"RIGHT", "LEFT", 2, 0}},
	["BOTTOMRIGHT"] = {{-3, -1}, {"RIGHT", "LEFT", 2, 0}}
}

local anchors = {"TOPRIGHT", "BOTTOMRIGHT"}

UF.CornerSpells = {}
UF.CornerSpellsByName = {}
function UF:UpdateCornerSpells()
	wipe(UF.CornerSpells)

	-- Always include "true"-flagged spells from any class
	for class, spells in pairs(Config.CornerBuffs) do
		for spellID, value in pairs(spells) do
			local anchor, alwaysShow = unpack(value)
			if alwaysShow == true then
				UF.CornerSpells[spellID] = {anchor, true}
			end
		end
	end

	-- Then include player's class spells (overwrites above if same spellID)
	local classBuffs = Config.CornerBuffs[DB.MyClass]
	if classBuffs then
		for spellID, value in pairs(classBuffs) do
			local modData = LauringUIAccountDB["CornerSpells"][DB.MyClass]
			if not (modData and modData[spellID]) then
				UF.CornerSpells[spellID] = {value[1], value[2]}
			end
		end
	end

	-- Apply user overrides (stored in SavedVariables)
	for spellID, value in pairs(LauringUIAccountDB["CornerSpells"][DB.MyClass] or {}) do
		if next(value) then
			UF.CornerSpells[spellID] = {value[1], value[2]}
		end
	end

	-- Convert to name-based lookup
	wipe(UF.CornerSpellsByName)
	for spellID, value in pairs(UF.CornerSpells) do
		local name = GetSpellInfo(spellID)
		if name then
			UF.CornerSpellsByName[name] = value
		end
	end
end

function UF:CornerBuffsHideButtons()
	local spells = self.SpellsIndicator
	if not spells then return end

	for _, group in pairs(spells) do
		for _, button in ipairs(group) do
			button:Hide()
		end
	end
end

function UF:CornerBuffsOnUpdate(elapsed)
	Core.CooldownOnUpdate(self, elapsed, true)
end

function UF:CornerBuffsUpdateButton(button, aura)
	if aura.duration and aura.duration > 0 then
		button.cd:SetCooldown(aura.expiration - aura.duration, aura.duration)
		button.cd:Show()
	else
		button.cd:Hide()
	end
	button.icon:SetTexture(aura.texture)
	button.count:SetText(aura.count > 1 and aura.count or "")
	button:Show()
end

function UF:RefreshBuffIndicator(buff)
	buff:SetScript("OnUpdate", nil)
	--buff.timer:Hide()
	buff.count:ClearAllPoints()
	buff.count:SetPoint("BOTTOMRIGHT", unpack(counterOffsets[buff.anchor][1]))
	buff.icon:SetVertexColor(1, 1, 1)
	buff.icon:Show()
	buff.cd:Show()
	buff.bg:Show()
end

function UF:CornerBuffsUpdateOptions()
	local spells = self.SpellsIndicator
	if not spells then return end

	for _, group in pairs(spells) do
		for _, button in ipairs(group) do
			button:SetScale(Config.DB["UFs"]["CornerBuffsScale"])
			UF:RefreshBuffIndicator(button)
		end
	end
end

local maxPerAnchor = 3

function UF:CreateSpellsIndicator(frame)
	local spellSize = Config.DB["UFs"]["RaidSpellSize"] or 20
	local spacing = 2        -- Horizontal spacing between buffs
	local edgeOffset = 1     -- First-buff edge nudge (X)
	local bottomYOffset = 1  -- Additional Y offset for bottom anchors
	local buttons = {}

	for _, anchor in pairs(anchors) do
		buttons[anchor] = {}

		local isLeft = anchor == "TOPLEFT" or anchor == "BOTTOMLEFT"
		local isBottom = anchor == "BOTTOMLEFT" or anchor == "BOTTOMRIGHT"
		local direction = isLeft and 1 or -1
		local yOffset = isBottom and bottomYOffset or -1

		for i = 1, maxPerAnchor do
			local button = CreateFrame("Frame", nil, frame.Health)
			button:SetFrameLevel(frame:GetFrameLevel() + 10)
			button:SetSize(spellSize, spellSize)

			local xOffset = (i - 1) * (spellSize + spacing) * direction
			if i == 1 then
				xOffset = xOffset + (edgeOffset * direction)
			end

			button:SetPoint(anchor, frame.Health, anchor, xOffset, yOffset)

			button.icon = button:CreateTexture(nil, "BORDER")
			button.icon:SetAllPoints()
			button.bg = Core.ReskinIcon(button.icon)

			button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
			button.cd:SetAllPoints()
			button.cd:SetReverse(true)
			button.cd:SetHideCountdownNumbers(true)

			--button.timer = Core.CreateFS(button, 12, "", false, "CENTER", -counterOffsets[anchor][2][3], 0)
			button.count = Core.CreateFS(button, 10, "")

			button.anchor = anchor
			button.index = i
			button:Hide()

			UF:RefreshBuffIndicator(button)
			tinsert(buttons[anchor], button)
		end
	end

	frame.SpellsIndicator = buttons
	UF.CornerBuffsUpdateOptions(frame)
end

