local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local UF = Core:GetModule("UnitFrames")
local oUF = ns.oUF

local GetSpecialization = GetSpecialization or C_SpecializationInfo.GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo or C_SpecializationInfo.GetSpecializationInfo

local function GetPlayerDispellableTypes()
	local _, class = UnitClass("player")
	if not class then return {} end

	local dispels = {}

	local specIndex = GetSpecialization()
	if not specIndex then return dispels end

	local _, _, _, _, role = GetSpecializationInfo(specIndex)

	-- Define dispels based on class and role
	if class == "PRIEST" then
		dispels.MAGIC = true
		dispels.DISEASE = true

	elseif class == "PALADIN" then
		dispels.POISON = true
		dispels.DISEASE = true
		if role == "HEALER" then
			dispels.MAGIC = true
		end

	elseif class == "SHAMAN" then
		dispels.CURSE = true
		if role == "HEALER" then
			dispels.MAGIC = true
		end

	elseif class == "DRUID" then
		dispels.CURSE = true
		dispels.POISON = true
		if role == "HEALER" then
			dispels.MAGIC = true
		end

	elseif class == "MONK" then
		dispels.POISON = true
		dispels.DISEASE = true
		if role == "HEALER" then
			dispels.MAGIC = true
		end
	end

	-- Filter with your color table
	local filtered = {}
	for debuffType in pairs(dispels) do
		local color = DB.DebuffHighlightColors[debuffType]
		if color then
			filtered[debuffType] = color
		end
	end

	return filtered
end

function UF:PostUpdate_DebuffHighlight(object, debuffType, _, wasFiltered, _, color)
	if debuffType and not wasFiltered and color then
		if object.DBHGlow then
			object.DBHGlow:SetBackdropBorderColor(color.r, color.g, color.b, color.a or 0.5)
		else
			object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, color.a or 0.5)
		end
	else
		if object.DBHGlow then
			object.DBHGlow:SetBackdropBorderColor(0, 0, 0, 0)
		else
			object.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
		end
	end
end

function UF:ToggleDebuffHighlight()
	for _, frame in pairs(oUF.objects) do
		if frame.DebuffHighlight then
			if Config.DB.UFs.EnableDebuffHighlight then
				frame.DebuffHighlight:Show()
				if frame.DBHGlow then frame.DBHGlow:Show() end
			else
				frame.DebuffHighlight:Hide()
				if frame.DBHGlow then frame.DBHGlow:Hide() end
			end
		end
	end
end

function UF:CreateDebuffHighlight(frame)
    if not Config.DB.UFs.EnableDebuffHighlight then return end

    local debuffHighlight = frame.Health:CreateTexture(nil, "OVERLAY")
    debuffHighlight:SetAllPoints(frame.Health)
    debuffHighlight:SetTexture(DB.DebuffIconBorder)
    debuffHighlight:SetBlendMode("ADD")
    debuffHighlight:SetVertexColor(0, 0, 0, 0) -- start hidden

    frame.DebuffHighlight = debuffHighlight
    frame.DebuffHighlightAlpha = 0.5
    frame.DebuffHighlightFilter = true
    frame.DebuffHighlightFilterTable = GetPlayerDispellableTypes()
    debuffHighlight.PostUpdate = UF.PostUpdate_DebuffHighlight

    -- Optional glow
    Core:CreateShadow(frame, 1)
    local shadow = frame.__shadow
    frame.__shadow = nil
    shadow:Hide()
    frame.DBHGlow = shadow

    if frame.Health then
        debuffHighlight:SetParent(frame.Health)
        frame.DBHGlow:SetParent(frame.Health)
    end

	Core:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", function(unit)
		if unit ~= "player" then return end

		for _, oUFObject in pairs(oUF.objects) do
			if oUFObject.DebuffHighlight then
				oUFObject.DebuffHighlightFilterTable = GetPlayerDispellableTypes()
			end
		end
	end)
end