local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local UF = Core:GetModule("UnitFrames")

local function PostUpdateRole(element, role)
	if role == "DAMAGER" then
		element:Hide()
	else
		element:Show()
		Core.ReskinSmallRole(element, role)
	end

	local frame = element.__owner
	if frame then
		UF:UpdatePartyAndRaidNameAnchor(frame)
	end
end

function UF:CreateIcons(frame)
	local mystyle = frame.mystyle
	if mystyle == "Player" then
		local combat = frame:CreateTexture(nil, "OVERLAY")
		combat:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -9, 0)
		combat:SetSize(15, 15)
		combat:SetTexture("Interface\\WORLDSTATEFRAME\\CombatSwords")
		combat:SetTexCoord(0, .5, 0, .5)
		combat:SetVertexColor(.8, 0, 0)
		frame.CombatIndicator = combat

		local leaderIcon = frame:CreateTexture(nil, "OVERLAY")
		leaderIcon:SetPoint("TOPLEFT", frame, 0, 3)
		leaderIcon:SetSize(13, 13)
		frame.LeaderIndicator = leaderIcon

	elseif mystyle == "Target" then
		local quest = frame:CreateTexture(nil, "OVERLAY")
		quest:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 8)
		quest:SetSize(16, 16)
		frame.QuestIndicator = quest
	elseif UF.IsPartyOrRaid(frame)  then
		local roleIcon = frame:CreateTexture(nil, "OVERLAY")
		roleIcon:SetPoint("TOPLEFT", frame, 0, 0)
		roleIcon:SetSize(15, 15)
		roleIcon.PostUpdate = PostUpdateRole
		frame.GroupRoleIndicator = roleIcon

		-- Disable legacy raid role icons
		frame:DisableElement("MainTankIndicator")
		frame:DisableElement("MainAssistIndicator")

		local masterlooterIcon = frame:CreateTexture(nil, "OVERLAY")
		masterlooterIcon:SetPoint("RIGHT", frame, "RIGHT")
		masterlooterIcon:SetSize(11, 11)
		frame.MasterLooterIndicator = masterlooterIcon

		local leaderIcon = frame:CreateTexture(nil, "OVERLAY")
		leaderIcon:SetPoint("TOPLEFT", frame, 0, 10)
		leaderIcon:SetSize(15, 15)
		frame.LeaderIndicator = leaderIcon

		local assistIcon = frame:CreateTexture(nil, "OVERLAY")
		assistIcon:SetPoint("TOPLEFT", frame, -1, 10)
		assistIcon:SetSize(12, 12)
		frame.AssistantIndicator = assistIcon
	end

	local parentFrame = CreateFrame("Frame", nil, frame)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(5)
	local phase = parentFrame:CreateTexture(nil, "OVERLAY")
	phase:SetPoint("CENTER", frame.Health)
	phase:SetSize(24, 24)
	frame.PhaseIndicator = phase
end

function UF:CreateRaidIcons(frame)
	local parent = CreateFrame("Frame", nil, frame)
	parent:SetAllPoints()
	parent:SetFrameLevel(frame:GetFrameLevel() + 2)

	local readyCheck = parent:CreateTexture(nil, "OVERLAY")
	readyCheck:SetSize(16, 16)
	readyCheck:SetPoint("CENTER", 0, 0)
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