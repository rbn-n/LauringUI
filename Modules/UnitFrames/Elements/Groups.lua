local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local oUF = ns.oUF

local UF = Core:GetModule("UnitFrames")

local backdrop = {edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1}

UF.PartyDirections = {
	[1] = {name = L["GO_DOWN"], point = "TOP", xOffset = 0, yOffset = -5, initAnchor = "TOPLEFT"},
	[2] = {name = L["GO_UP"], point = "BOTTOM", xOffset = 0, yOffset = 5, initAnchor = "BOTTOMLEFT"},
	[3] = {name = L["GO_RIGHT"], point = "LEFT", xOffset = 5, yOffset = 0, initAnchor = "TOPLEFT"},
	[4] = {name = L["GO_LEFT"], point = "RIGHT", xOffset = -5, yOffset = 0, initAnchor = "TOPRIGHT"},
}

UF.RaidDirections = {
	[1] = {name = L["DOWN_RIGHT"], point = "TOP", xOffset = 0, yOffset = -5, initAnchor = "TOPLEFT", relAnchor = "TOPRIGHT", x = 5, y = 0, columnAnchorPoint = "LEFT", multX = 1, multY = -1},
	[2] = {name = L["DOWN_LEFT"], point = "TOP", xOffset = 0, yOffset = -5, initAnchor = "TOPRIGHT", relAnchor = "TOPLEFT", x = -5, y = 0, columnAnchorPoint = "RIGHT", multX = -1, multY = -1},
	[3] = {name = L["UP_RIGHT"], point = "BOTTOM", xOffset = 0, yOffset = 5, initAnchor = "BOTTOMLEFT", relAnchor = "BOTTOMRIGHT", x = 5, y = 0, columnAnchorPoint = "LEFT", multX = 1, multY = 1},
	[4] = {name = L["UP_LEFT"], point = "BOTTOM", xOffset = 0, yOffset = 5, initAnchor = "BOTTOMRIGHT", relAnchor = "BOTTOMLEFT", x = -5, y = 0, columnAnchorPoint = "RIGHT", multX = -1, multY = 1},
	[5] = {name = L["RIGHT_DOWN"], point = "LEFT", xOffset = 5, yOffset = 0, initAnchor = "TOPLEFT", relAnchor = "BOTTOMLEFT", x = 0, y = -5, columnAnchorPoint = "TOP", multX = 1, multY = -1},
	[6] = {name = L["RIGHT_UP"], point = "LEFT", xOffset = 5, yOffset = 0, initAnchor = "BOTTOMLEFT", relAnchor = "TOPLEFT", x = 0, y = 5, columnAnchorPoint = "BOTTOM", multX = 1, multY = 1},
	[7] = {name = L["LEFT_DOWN"], point = "RIGHT", xOffset = -5, yOffset = 0, initAnchor = "TOPRIGHT", relAnchor = "BOTTOMRIGHT", x = 0, y = -5, columnAnchorPoint = "TOP", multX = -1, multY = -1},
	[8] = {name = L["LEFT_UP"], point = "RIGHT", xOffset = -5, yOffset = 0, initAnchor = "BOTTOMRIGHT", relAnchor = "TOPRIGHT", x = 0, y = 5, columnAnchorPoint = "BOTTOM", multX = -1, multY = 1},
}

function UF:UpdateTargetBorder()
	if UnitIsUnit("target", self.unit) then
		self.TargetBorder:Show()
	else
		self.TargetBorder:Hide()
	end
end

function UF:CreateTargetBorder(frame)
	local targetBorder = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	targetBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
	targetBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
	targetBorder:SetBackdrop(backdrop)
	targetBorder:SetFrameLevel(2)
	targetBorder:SetBackdropBorderColor(.7, .7, .7, 1)
	targetBorder:Hide()

	frame.TargetBorder = targetBorder
	frame:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateTargetBorder, true)
	frame:RegisterEvent("GROUP_ROSTER_UPDATE", UF.UpdateTargetBorder, true)
end

function UF:UpdateThreatBorder(_, unit)
	if unit ~= self.unit then return end

	local element = self.ThreatIndicator
	local status = UnitThreatSituation(unit)

	if status and status > 1 then
		local r, g, b = GetThreatStatusColor(status)
		element:SetBackdropBorderColor(r, g, b)
		element:Show()
	else
		element:Hide()
	end
end

function UF:CreateThreatBorder(frame)
	local threatIndicator = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	threatIndicator:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
	threatIndicator:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
	threatIndicator:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 2})
	threatIndicator:SetFrameLevel(1)
	threatIndicator:Hide()

	frame.ThreatIndicator = threatIndicator
	frame.ThreatIndicator.Override = UF.UpdateThreatBorder
end

function UF:UpdateRaidTextScale()
	local scale = Config.DB["UFs"]["RaidTextScale"]
	for _, frame in pairs(oUF.objects) do
		if frame.mystyle == "Raid" or frame.mystyle == "Raid10" then
			UF:SetPartyAndRaidName(frame.nameText, frame)
			frame.nameText:SetScale(scale)
			--frame.healthValue:SetScale(scale)
			--frame.healthValue:UpdateTag()
			if frame.powerText then frame.powerText:SetScale(scale) end
			--UF:UpdateHealthBarColor(frame, true)
			UF:UpdatePowerBarColor(frame, true)
			UF.UpdateFrameNameTag(frame)
			frame.disableTooltip = Config.DB["UFs"]["HideTip"]
		end
	end
end