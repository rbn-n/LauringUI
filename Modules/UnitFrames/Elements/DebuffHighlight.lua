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

	local filtered = {}
	for debuffType in pairs(dispels) do
		local color = DB.DebuffHighlightColors[debuffType]
		if color then
			filtered[debuffType] = color
		end
	end

	return filtered
end

local function PostUpdateDebuffHighlight(frame, debuffType, _, wasFiltered, _, color)
	if debuffType and not wasFiltered and color then
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

function UF:CreateDebuffHighlight(frame)
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
	frame.DebuffHighlight.PostUpdate = PostUpdateDebuffHighlight

	Core:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", function(unit)
		if unit ~= "player" then return end
		for _, oUFObject in pairs(oUF.objects) do
			if oUFObject.DebuffHighlight then
				oUFObject.DebuffHighlightFilterTable = GetPlayerDispellableTypes()
			end
		end
	end)
end