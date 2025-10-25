local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local UF = Core:GetModule("UnitFrames")
local oUF = ns.oUF

local function GetPlayerDispellableTypes()
	if not DB.MyClass then return {} end
	if not DB.Role then return {} end
	local class = DB.MyClass
	local role = DB.Role

	local dispels = {}

	if class == "PRIEST" then
		dispels.Magic = true
		dispels.Disease = true

	elseif class == "PALADIN" then
		dispels.Poison = true
		dispels.Disease = true
		if role == "HEALER" then
			dispels.Magic = true
		end

	elseif class == "SHAMAN" then
		dispels.Curse = true
		if role == "HEALER" then
			dispels.Magic = true
		end

	elseif class == "DRUID" then
		dispels.Curse = true
		dispels.Poison = true
		if role == "HEALER" then
			dispels.Magic = true
		end

	elseif class == "MONK" then
		dispels.Poison = true
		dispels.Disease = true
		if role == "HEALER" then
			dispels.Magic = true
		end
	end

	local filtered = {}
	for debuffType in pairs(dispels) do
		local color = DB.DebuffHighlightColors[debuffType]
		if color then
			filtered[debuffType] = color
		end
	end

	return filtered
end


function UF:CheckForDispellableAura(frame, unit)
	local dispellableTypes = frame.DebuffHighlightFilterTable
	if not dispellableTypes then return end

	local foundType
	for i = 1, 40 do
		local name, _, _, debuffType = UnitAura(unit, i, "HARMFUL")
		if not name then break end

		if debuffType then
			if dispellableTypes[debuffType] then
				foundType = debuffType
				break
			end
		end
	end

	if foundType then
		local color = dispellableTypes[foundType] or DB.DebuffHighlightColors[foundType] or {r = 0.3, g = 0.3, b = 1}
		frame.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, frame.DebuffHighlightAlpha or 0.5)
	else
		frame.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
	end
end

function UF:ToggleDebuffHighlight()
	for _, frame in pairs(oUF.objects) do
		if frame.DebuffHighlight then
			if Config.DB.UFs.EnableDebuffHighlight then
				frame.DebuffHighlight:Show()
			else
				frame.DebuffHighlight:Hide()
			end
		end
	end
end

local function OnUnitAura(self, _, unit)
	if unit == self.unit then
		UF:CheckForDispellableAura(self, unit)
	end
end

function UF:CreateDebuffHighlight(frame, registerUnitAuraEvent)
	if not Config.DB.UFs.EnableDebuffHighlight then return end

	local dbh = frame.Health:CreateTexture(nil, "OVERLAY")
	dbh:SetAllPoints(frame.Health)
	dbh:SetTexture("Interface\\Buttons\\WHITE8x8")
	dbh:SetBlendMode("ADD")
	dbh:SetVertexColor(0, 0, 0, 0)

	frame.DebuffHighlight = dbh
	frame.DebuffHighlightAlpha = 0.5
	frame.DebuffHighlightFilter = true
	frame.DebuffHighlightFilterTable = GetPlayerDispellableTypes()

	Core:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", function(_, unit)
		if unit ~= "player" then return end
		for _, oUFObject in pairs(oUF.objects) do
			if oUFObject.DebuffHighlight then
				oUFObject.DebuffHighlightFilterTable = GetPlayerDispellableTypes()
			end
		end
	end)

	if registerUnitAuraEvent then
		frame:RegisterEvent("UNIT_AURA", OnUnitAura)
	end
end