local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local UF = Core:GetModule("UnitFrames")

local function PostUpdateRole(element, role)
	if element:IsShown() then
		if role == "DAMAGER" then
			element:Hide()
			return
		end

		Core.ReskinSmallRole(element, role)
	end
end

function UF:CreateIcons(frame)
	local mystyle = frame.mystyle
	if mystyle == "Player" then
		local combat = frame:CreateTexture(nil, "OVERLAY")
		combat:SetPoint("CENTER", frame, "BOTTOMLEFT")
		combat:SetSize(20, 20)
		combat:SetTexture("Interface\\WORLDSTATEFRAME\\CombatSwords")
		combat:SetTexCoord(0, .5, 0, .5)
		combat:SetVertexColor(.8, 0, 0)
		frame.CombatIndicator = combat
	elseif mystyle == "Target" then
		local quest = frame:CreateTexture(nil, "OVERLAY")
		quest:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 8)
		quest:SetSize(16, 16)
		frame.QuestIndicator = quest
	end

	local parentFrame = CreateFrame("Frame", nil, frame)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(5)
	local phase = parentFrame:CreateTexture(nil, "OVERLAY")
	phase:SetPoint("CENTER", frame.Health)
	phase:SetSize(24, 24)
	frame.PhaseIndicator = phase

	local roleIcon = frame:CreateTexture(nil, "OVERLAY")
    if UF.IsPartyOrRaid(frame)  then
        roleIcon:SetPoint("TOPRIGHT", frame, 5, 5)
    else
        roleIcon:SetPoint("TOPRIGHT", frame, 0, 8)
    end
    roleIcon:SetSize(15, 15)
    roleIcon.PostUpdate = PostUpdateRole
    frame.GroupRoleIndicator = roleIcon

	local leaderIcon = frame:CreateTexture(nil, "OVERLAY")
	leaderIcon:SetPoint("TOPLEFT", frame, -1, 8)
	leaderIcon:SetSize(12, 12)
	frame.LeaderIndicator = leaderIcon

	local assistIcon = frame:CreateTexture(nil, "OVERLAY")
	assistIcon:SetPoint("TOPLEFT", frame, -1, 8)
	assistIcon:SetSize(12, 12)
	frame.AssistantIndicator = assistIcon

	local masterlooterIcon = frame:CreateTexture(nil, "OVERLAY")
	masterlooterIcon:SetPoint("LEFT", frame, "RIGHT")
	masterlooterIcon:SetSize(12, 12)
	frame.MasterLooterIndicator = masterlooterIcon
end

function UF:CreateRaidIcons(frame)
	local parent = CreateFrame("Frame", nil, frame)
	parent:SetAllPoints()
	parent:SetFrameLevel(frame:GetFrameLevel() + 2)

	local readyCheck = parent:CreateTexture(nil, "OVERLAY")
	readyCheck:SetSize(16, 16)
	readyCheck:SetPoint("BOTTOM", 0, 1)
	frame.ReadyCheckIndicator = readyCheck

	local resurrect = parent:CreateTexture(nil, "OVERLAY")
	resurrect:SetSize(20, 20)
	resurrect:SetPoint("CENTER", frame, 1, 0)
	frame.ResurrectIndicator = resurrect

	local role = parent:CreateTexture(nil, "OVERLAY")
	role:SetSize(12, 12)
	if frame.GroupRoleIndicator then
		role:SetPoint("RIGHT", frame.GroupRoleIndicator, "LEFT")
	else
		role:SetPoint("TOPRIGHT", frame, 5, 5)
	end
	frame.RaidRoleIndicator = role
end