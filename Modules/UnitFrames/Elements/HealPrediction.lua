local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local UF = Core:GetModule("UnitFrames")

function UF:CreateHealPrediction(self)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetAllPoints()

	local mhpb = frame:CreateTexture(nil, "BORDER", nil, 5)
	mhpb:SetWidth(1)
	mhpb:SetTexture(DB.StatusBarTexture)
	mhpb:SetVertexColor(0, 1, 0, .5)

	local ohpb = frame:CreateTexture(nil, "BORDER", nil, 5)
	ohpb:SetWidth(1)
	ohpb:SetTexture(DB.StatusBarTexture)
	ohpb:SetVertexColor(0, 1, 1, .5)

	self.HealPredictionAndAbsorb = {
		myBar = mhpb,
		otherBar = ohpb,
		maxOverflow = 1,
	}

	self.predicFrame = frame
end