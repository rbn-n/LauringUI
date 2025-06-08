local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local UF = Core:GetModule("UnitFrames")
local GetSpellInfo = GetSpellInfo

local counterOffsets = {
	["TOPLEFT"] = {{6, 1}, {"LEFT", "RIGHT", -2, 0}},
	["TOPRIGHT"] = {{-6, 1}, {"RIGHT", "LEFT", 2, 0}},
	["BOTTOMLEFT"] = {{6, 1},{"LEFT", "RIGHT", -2, 0}},
	["BOTTOMRIGHT"] = {{-6, 1}, {"RIGHT", "LEFT", 2, 0}},
	["LEFT"] = {{6, 1}, {"LEFT", "RIGHT", -2, 0}},
	["RIGHT"] = {{-6, 1}, {"RIGHT", "LEFT", 2, 0}},
	["TOP"] = {{0, 0}, {"RIGHT", "LEFT", 2, 0}},
	["BOTTOM"] = {{0, 0}, {"RIGHT", "LEFT", 2, 0}},
}

UF.CornerSpells = {}
UF.CornerSpellsByName = {}
function UF:UpdateCornerSpells()
	wipe(UF.CornerSpells)

	for spellID, value in pairs(Config.CornerBuffs[DB.MyClass]) do
		local modData = LauringUIAccountDB["CornerSpells"][DB.MyClass]
		if not (modData and modData[spellID]) then
			local r, g, b = unpack(value[2])
			UF.CornerSpells[spellID] = {value[1], {r, g, b}, value[3]}
		end
	end

	for spellID, value in pairs(LauringUIAccountDB["CornerSpells"][DB.MyClass]) do
		if next(value) then
			local r, g, b = unpack(value[2])
			UF.CornerSpells[spellID] = {value[1], {r, g, b}, value[3]}
		end
	end

	-- By name
	wipe(UF.CornerSpellsByName)

	for spellID, value in pairs(UF.CornerSpells) do
		local name = GetSpellInfo(spellID)
		if name then
			UF.CornerSpellsByName[name] = value
		end
	end
end

function UF:RefreshBuffIndicator(buff)
	if Config.DB["UFs"]["BuffIndicatorType"] == 3 then
		local point, anchorPoint, x, y = unpack(counterOffsets[buff.anchor][2])
		buff.timer:Show()
		buff.count:ClearAllPoints()
		buff.count:SetPoint(point, buff.timer, anchorPoint, x, y)
		buff.icon:Hide()
		buff.cd:Hide()
		buff.bg:Hide()
	else
		buff:SetScript("OnUpdate", nil)
		buff.timer:Hide()
		buff.count:ClearAllPoints()
		buff.count:SetPoint("CENTER", unpack(counterOffsets[buff.anchor][1]))
		if Config.DB["UFs"]["BuffIndicatorType"] == 1 then
			buff.icon:SetTexture(DB.bdTex)
		else
			buff.icon:SetVertexColor(1, 1, 1)
		end
		buff.icon:Show()
		buff.cd:Show()
		buff.bg:Show()
	end
end

local anchors = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}

function UF:CreateSpellsIndicator(frame)
	local spellSize = Config.DB["UFs"]["RaidSpellSize"] or 10

	local buttons = {}
	for _, anchor in pairs(anchors) do
		local button = CreateFrame("Frame", nil, frame.Health)
		button:SetFrameLevel(frame:GetFrameLevel()+10)
		button:SetSize(spellSize, spellSize)
		button:SetPoint(anchor)
		button:Hide()

		button.icon = button:CreateTexture(nil, "BORDER")
		button.icon:SetAllPoints()
		button.bg = Core.ReskinIcon(button.icon)

		button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.cd:SetAllPoints()
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(true)

		button.timer = Core.CreateFS(button, 12, "", false, "CENTER", -counterOffsets[anchor][2][3], 0)
		button.count = Core.CreateFS(button, 12, "")

		button.anchor = anchor
		buttons[anchor] = button

		UF:RefreshBuffIndicator(button)
	end

	frame.SpellsIndicator = buttons

	UF.SpellsIndicatorUpdateOptions(frame)
end

function UF:SpellsIndicatorUpdateOptions()
	local spells = self.SpellsIndicator
	if not spells then return end

	for _, button in pairs(spells) do
		button:SetScale(Config.DB["UFs"]["BuffIndicatorScale"])
		UF:RefreshBuffIndicator(button)
	end
end