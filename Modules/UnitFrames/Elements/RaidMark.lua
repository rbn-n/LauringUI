local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local UF = Core:GetModule("UnitFrames")

function UF:CreateRaidMark(frame)
	local raidMark = frame:CreateTexture(nil, "OVERLAY")

    local size = 15
    if UF.IsPartyOrRaid(frame) then
		raidMark:SetPoint("TOP", frame, 0, 10)
	elseif UF.IsPlayerOrTarget(frame) then
        size = 20
        raidMark:SetPoint("BOTTOM", frame, "BOTTOM", 0, 2)
    elseif frame.mystyle == "nameplate" then
        size = 32
		raidMark:SetPoint("BOTTOMRIGHT", frame, "TOPLEFT", 0, 3)
    else
        raidMark:SetPoint("CENTER", frame, "TOP")
	end

	raidMark:SetSize(size, size)
	frame.RaidTargetIndicator = raidMark
end