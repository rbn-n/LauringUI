local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = Core:RegisterModule("UnitFrames")

local UnitFrame_OnEnter, UnitFrame_OnLeave = UnitFrame_OnEnter, UnitFrame_OnLeave

UF.VariousTagIndex = {
	[1] = "",
	[2] = "currentpercent",
	[3] = "currentmax",
	[4] = "current",
	[5] = "percent",
	[6] = "loss",
	[7] = "losspercent",
}

function UF:SetUnitFrameSize(frame)
    local unit = frame.mystyle

    local width
    local height
    if UF.IsPlayerOrTarget(frame) then
        width = Config.DB["UFs"]["PlayerWidth"]
        height = Config.DB["UFs"]["PlayerHeight"]
	elseif frame.raidLayout then
		width = Config.DB["UFs"][frame.raidLayout.."Width"]
		height = Config.DB["UFs"][frame.raidLayout.."Height"]
	else
        width = Config.DB["UFs"][unit.."Width"]
		height = Config.DB["UFs"][unit.."Height"]
    end

    frame:SetSize(width, height)
end

function UF.HidePower(frame)
    local mystyle = frame.mystyle
	return Config.DB["UFs"]["Hide"..mystyle.."Power"]
end

function UF.IsPlayerOrTarget(frame)
    return frame.mystyle == "Player" or frame.mystyle == "Target"
end

function UF.IsPartyOrRaid(frame)
    return frame.mystyle == "Party" or frame.mystyle == "Raid"
end

local function UF_OnEnter(frame)
	if not frame.disableTooltip then
		UnitFrame_OnEnter(frame)
	end
	frame.Highlight:Show()
end

local function UF_OnLeave(frame)
	if not frame.disableTooltip then
		UnitFrame_OnLeave(frame)
	end
	frame.Highlight:Hide()
end

function UF:CreateHeader(frame, onKeyDown)
	local highlight = frame:CreateTexture(nil, "OVERLAY")
	highlight:SetAllPoints()
	highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	highlight:SetTexCoord(0, 1, .5, 1)
	highlight:SetVertexColor(.5, .5, .5, .1)
	highlight:SetBlendMode("ADD")
	highlight:Hide()
	frame.Highlight = highlight

	frame:RegisterForClicks(onKeyDown and "AnyDown" or "AnyUp")
	frame:HookScript("OnEnter", UF_OnEnter)
	frame:HookScript("OnLeave", UF_OnLeave)
end

function UF:UpdateRaidHealthMethod()
	for _, frame in pairs(oUF.objects) do
		if UF.IsPartyOrRaid(frame) then
			frame:SetHealthUpdateMethod(Config.DB["UFs"]["FrequentHealth"])
			frame:SetHealthUpdateSpeed(max(.02, Config.DB["UFs"]["HealthFrequency"]))
			frame.Health:ForceUpdate()
		end
	end
end

local textScaleFrames = {
	["Player"] = true,
	["Target"] = true,
	["Focus"] = true,
	["Pet"] = true,
	["ToT"] = true,
	["FocusTarget"] = true,
	["Boss"] = true,
	["Arena"] = true,
}

function UF:UpdateTextScale()
	local scale = Config.DB["UFs"]["UFTextScale"]
	for _, frame in pairs(oUF.objects) do
		local style = frame.mystyle
		if style and textScaleFrames[style] then
			frame.nameText:SetScale(scale)
			frame.healthValue:SetScale(scale)
			if frame.powerText then frame.powerText:SetScale(scale) end
			local castbar = frame.Castbar
			if castbar then
				if castbar.Text then castbar.Text:SetScale(scale) end
				if castbar.Time then castbar.Time:SetScale(scale) end
				if castbar.Lag then castbar.Lag:SetScale(scale) end
			end
			--UF:UpdateHealthBarColor(frame, true)
			UF:UpdatePowerBarColor(frame, true)
			UF.UpdateFrameNameTag(frame)
		end
	end
end