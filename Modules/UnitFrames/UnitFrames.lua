local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = Core:GetModule("UnitFrames")

function UF:SetUnitFrameSize(frame)
    local unit = frame.mystyle

    local width
    local height
    if UF.IsPlayerOrTarget(frame) then
        width = Config.DB["UFs"]["PlayerWidth"]
        height = Config.DB["UFs"]["PlayerHeight"]
    else
        width = Config.DB["UFs"][unit.."Width"]
        local healthHeight = Config.DB["UFs"][unit.."Height"]
        local powerHeight = Config.DB["UFs"][unit.."PowerHeight"]
        height = healthHeight + (powerHeight or 0)
    end

    frame:SetSize(width, height)
end

local function CreatePlayer(frame)
    frame.mystyle = "Player"
	UF:SetUnitFrameSize(frame)

    UF:CreateHeader(frame)
    UF:CreateHealthBar(frame)
	UF:CreateHealthAndNameText(frame)
	UF:CreatePowerBar(frame)
	UF:CreatePowerText(frame)
	UF:CreateCastbar(frame)
	UF:CreateRaidMark(frame)
	UF:CreateIcons(frame)
	UF:CreateHealPrediction(frame)
	--UF:CreateAdditionalPowerPower(frame)
	--UF:CreateClassPower(frame)
	UF:CreateAuras(frame)
	--UF:EclipseBar(frame)
    UF:ReskinMirrorBars()
end

local function CreateTarget(frame)
    frame.mystyle = "Target"
	UF:SetUnitFrameSize(frame)

    UF:CreateHeader(frame)
	UF:CreateHealthBar(frame)
	UF:CreateHealthAndNameText(frame)
	UF:CreatePowerBar(frame)
	UF:CreatePowerText(frame)
	UF:CreateCastbar(frame)
	UF:CreateRaidMark(frame)
	UF:CreateIcons(frame)
	UF:CreateHealPrediction(frame)
	UF:CreateAuras(frame)
end

local function CreateToT(frame)
    frame.mystyle = "ToT"
	UF:SetUnitFrameSize(frame)

    UF:CreateHeader(frame)
	UF:CreateHealthBar(frame)
	UF:CreateHealthAndNameText(frame)
    UF:CreatePowerBar(frame)
	UF:CreateRaidMark(frame)
	UF:CreateAuras(frame)
end

local function CreateFocus(frame)
    frame.mystyle = "Focus"
	UF:SetUnitFrameSize(frame)

    UF:CreateHeader(frame)
	UF:CreateHealthBar(frame)
	UF:CreateHealthAndNameText(frame)
    UF:CreatePowerBar(frame)
    UF:CreatePowerText(frame)
	UF:CreateCastbar(frame)
	UF:CreateRaidMark(frame)
	UF:CreateIcons(frame)
	UF:CreateHealPrediction(frame)
	UF:CreateAuras(frame)
end

local function CreateFocusTarget(frame)
    frame.mystyle = "FocusTarget"
	UF:SetUnitFrameSize(frame)

    UF:CreateHeader(frame)
	UF:CreateHealthBar(frame)
	UF:CreateHealthAndNameText(frame)
    UF:CreatePowerBar(frame)
	UF:CreateRaidMark(frame)
end

local function CreatePet(frame)
    frame.mystyle = "Pet"
	UF:SetUnitFrameSize(frame)

    UF:CreateHeader(frame)
	UF:CreateHealthBar(frame)
	UF:CreateHealthAndNameText(frame)
    UF:CreatePowerBar(frame)
	UF:CreateRaidMark(frame)
	UF:CreateAuras(frame)
	UF:CreateSparkleCastbar(frame)
end

local function CreateBoss(frame)
    frame.mystyle = "Boss"
	UF:SetUnitFrameSize(frame)

    UF:CreateHeader(frame)
	UF:CreateHealthBar(frame)
	UF:CreateHealthAndNameText(frame)
	UF:CreatePowerBar(frame)
	UF:CreatePowerText(frame)
	UF:CreateCastbar(frame)
	UF:CreateRaidMark(frame)
    UF:CreateAltPower(frame)
	UF:CreateBuffs(frame)
	UF:CreateDebuffs(frame)
end

local function CreateArena(frame)
    frame.mystyle = "Arena"
	UF:SetUnitFrameSize(frame)

    UF:CreateHeader(frame)
	UF:CreateHealthBar(frame)
	UF:CreateHealthAndNameText(frame)
	UF:CreatePowerBar(frame)
	UF:CreatePowerText(frame)
	UF:CreateCastbar(frame)
	UF:CreateRaidMark(frame)
	UF:CreateBuffs(frame)
	UF:CreateDebuffs(frame)
end

local UFRangeAlpha = {insideAlpha = 1, outsideAlpha = .4}
local function CreateGroup(frame)
    frame.Range = UFRangeAlpha
	frame.disableTooltip = Config.DB["UFs"]["Hide"..frame.mystyle.."Tooltip"]

    UF:CreateHeader(frame, true)
	UF:CreateHealthBar(frame)
	UF:CreateHealthAndNameText(frame)
	UF:CreatePowerBar(frame)
	UF:CreateRaidMark(frame)
	UF:CreateIcons(frame)
	UF:CreateTargetBorder(frame)
	UF:CreateRaidIcons(frame)
	UF:CreateHealPrediction(frame)
	UF:CreateThreatBorder(frame)
end

local function CreateParty(frame)
    frame.mystyle = "Party"

    CreateGroup(frame)
end

local function CreateRaid10(frame)
    frame.mystyle = "Raid10"
end

local function CreateRaid(frame)
    frame.mystyle = "Raid"

    CreateGroup(frame)
end

local function CreatePartyPet(frame)
	frame.mystyle = "PartyPet"
	frame.Range = UFRangeAlpha
	frame.disableTooltip = Config.DB["UFs"]["HidePartyPetTooltip"]

	UF:CreateHeader(frame, true)
	UF:CreateHealthBar(frame)
	UF:CreateHealthAndNameText(frame)
    UF:CreatePowerBar(frame)
	UF:CreateRaidMark(frame)
	UF:CreateTargetBorder(frame)
	UF:CreateHealPrediction(frame)
	UF:CreateThreatBorder(frame)
end

local function GetPartyVisibility()
	local visibility = "[group:party,nogroup:raid] show;hide"
	if Config.DB["UFs"]["SmartRaid"] then
		visibility = "[@raid6,noexists,group] show;hide"
	end
	if Config.DB["UFs"]["ShowSolo"] then
		visibility = "[nogroup] show;"..visibility
	end
	return visibility
end

local function GetRaidVisibility()
	local visibility
	if Config.DB["UFs"]["PartyFrame"] then
		if Config.DB["UFs"]["SmartRaid"] then
			visibility = "[@raid6,exists] show;hide"
		else
			visibility = "[group:raid] show;hide"
		end
	else
		if Config.DB["UFs"]["ShowGroupSolo"] then
			visibility = "show"
		else
			visibility = "[group] show;hide"
		end
	end
	return visibility
end

local function GetPartyPetVisibility()
	local visibility
	if Config.DB["UFs"]["PartyPetVisability"] == 1 then
		if Config.DB["UFs"]["SmartRaid"] then
			visibility = "[@raid6,noexists,group] show;hide"
		else
			visibility = "[group:party,nogroup:raid] show;hide"
		end
	elseif Config.DB["UFs"]["PartyPetVisability"] == 2 then
		if Config.DB["UFs"]["SmartRaid"] then
			visibility = "[@raid6,exists] show;hide"
		else
			visibility = "[group:raid] show;hide"
		end
	elseif Config.DB["UFs"]["PartyPetVisability"] == 3 then
		visibility = "[group] show;hide"
	end
	if Config.DB["UFs"]["ShowGroupSolo"] then
		visibility = "[nogroup] show;"..visibility
	end
	return visibility
end

local function ResetHeaderPoints(header)
	for i = 1, header:GetNumChildren() do
		select(i, header:GetChildren()):ClearAllPoints()
	end
end

function UF:SetupParty()
    if not Config.DB["UFs"]["ShowParty"] then return end

    local partyMover
    local party

    oUF:RegisterStyle("Party", CreateParty)
    oUF:SetActiveStyle("Party")

    local function CreatePartyHeader(name, width, height)
        local group = oUF:SpawnHeader(name, nil, nil,
            "showPlayer", true,
            "showSolo", true,
            "showParty", true,
            "showRaid", true,
            "sortMethod", "INDEX",
            "columnAnchorPoint", "LEFT",
            "oUF-initialConfigFunction", ([[
                self:SetWidth(%d)
                self:SetHeight(%d)
            ]]):format(width, height))
        return group
    end

    function UF:CreateAndUpdatePartyHeader()
        local index = Config.DB["UFs"]["PartyDirection"]
        local sortData = UF.PartyDirections[index]
        local partyWidth, partyHeight = Config.DB["UFs"]["PartyWidth"], Config.DB["UFs"]["PartyHeight"]
        local partyFrameHeight = partyHeight + Config.DB["UFs"]["PartyPowerHeight"]
        local spacing = Config.DB["UFs"]["PartySpacing"]
        local sortByRole = Config.DB["UFs"]["PartySortByRole"]
        local sortAscending = Config.DB["UFs"]["PartySortAscending"]

        if not party then
            party = CreatePartyHeader("oUF_Party", partyWidth, partyFrameHeight)
            party.groupType = "party"
            tinsert(UF.headers, party)
            RegisterStateDriver(party, "visibility", GetPartyVisibility())
            partyMover = Core.Mover(party, L["PartyFrame"], "PartyFrame", { "LEFT", UIParent, 350, 0 })
        end

        local moverWidth = index < 3 and partyWidth or (partyWidth + spacing) * 5 - spacing
        local moverHeight = index < 3 and (partyFrameHeight + spacing) * 5 - spacing or partyFrameHeight
        partyMover:SetSize(moverWidth, moverHeight)
        party:ClearAllPoints()
        party:SetPoint(sortData.initAnchor, partyMover)

        ResetHeaderPoints(party)
        party:SetAttribute("point", sortData.point)
        party:SetAttribute("xOffset", sortData.xOffset / 5 * spacing)
        party:SetAttribute("yOffset", sortData.yOffset / 5 * spacing)
        party:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
        party:SetAttribute("groupBy", sortByRole and "ASSIGNEDROLE")
        party:SetAttribute("sortDir", sortAscending and "ASC" or "DESC")
    end

    UF:CreateAndUpdatePartyHeader()

    if not Config.DB["UFs"]["ShowPartyPets"] then return end

    local partyPet, petMover
    oUF:RegisterStyle("PartyPet", CreatePartyPet)
    oUF:SetActiveStyle("PartyPet")

    local function CreatePetGroup(name, width, height)
        local group = oUF:SpawnHeader(name, "SecureGroupPetHeaderTemplate", nil,
            "showPlayer", true,
            "showSolo", true,
            "showParty", true,
            "showRaid", true,
            "columnSpacing", 5,
            "oUF-initialConfigFunction", ([[
                self:SetWidth(%d)
                self:SetHeight(%d)
            ]]):format(width, height))
        return group
    end

    function UF:UpdatePartyPetHeader()
        local petWidth, petHeight = Config.DB["UFs"]["PartyPetWidth"], Config.DB["UFs"]["PartyPetHeight"]
        local petFrameHeight = petHeight
        local petsPerColumn = Config.DB["UFs"]["PartyPetPerColumn"]
        local maxColumns = Config.DB["UFs"]["PartyPetMaxColumn"]
        local index = Config.DB["UFs"]["PartyPetDirection"]
        local sortData = UF.RaidDirections[index]

        if not partyPet then
            partyPet = CreatePetGroup("oUF_PartyPet", petWidth, petFrameHeight)
            partyPet.groupType = "pet"
            tinsert(UF.headers, partyPet)
            RegisterStateDriver(partyPet, "visibility", GetPartyPetVisibility())
            petMover = Core.Mover(partyPet, L["PartyPetFrame"], "PartyPet", { "TOPLEFT", partyMover, "BOTTOMLEFT", 0, -5 })
        end
        ResetHeaderPoints(partyPet)

        partyPet:SetAttribute("point", sortData.point)
        partyPet:SetAttribute("xOffset", sortData.xOffset)
        partyPet:SetAttribute("yOffset", sortData.yOffset)
        partyPet:SetAttribute("columnAnchorPoint", sortData.columnAnchorPoint)
        partyPet:SetAttribute("unitsPerColumn", petsPerColumn)
        partyPet:SetAttribute("maxColumns", maxColumns)

        local moverWidth = (petWidth + 5) * maxColumns - 5
        local moverHeight = (petFrameHeight + 5) * petsPerColumn - 5
        if index > 4 then
            moverWidth = (petWidth + 5) * petsPerColumn - 5
            moverHeight = (petFrameHeight + 5) * maxColumns - 5
        end
        petMover:SetSize(moverWidth, moverHeight)
        partyPet:ClearAllPoints()
        partyPet:SetPoint(sortData.initAnchor, petMover)
    end

    UF:UpdatePartyPetHeader()
end

function UF:SetupRaid()
    local raidMover

    oUF:RegisterStyle("Raid", CreateRaid)
    oUF:SetActiveStyle("Raid")

    local function CreateRaidGroup(name, i, width, height)
        local group = oUF:SpawnHeader(name, nil, nil,
        "showPlayer", true,
        "showSolo", true,
        "showParty", true,
        "showRaid", true,
        "groupFilter", tostring(i),
        "groupingOrder", "1,2,3,4,5,6,7,8",
        "groupBy", "GROUP",
        "sortMethod", "INDEX",
        "maxColumns", 1,
        "unitsPerColumn", 5,
        "columnSpacing", 5,
        "columnAnchorPoint", "LEFT",
        "oUF-initialConfigFunction", ([[
            self:SetWidth(%d)
            self:SetHeight(%d)
        ]]):format(width, height))
        return group
    end

    local teamIndexes = {}
    local teamIndexAnchor = {
        [1] = { "BOTTOM", "TOP", 0, 5 },
        [2] = { "BOTTOM", "TOP", 0, 5 },
        [3] = { "TOP", "BOTTOM", 0, -5 },
        [4] = { "TOP", "BOTTOM", 0, -5 },
        [5] = { "RIGHT", "LEFT", -5, 0 },
        [6] = { "RIGHT", "LEFT", -5, 0 },
        [7] = { "LEFT", "RIGHT", 5, 0 },
        [8] = { "LEFT", "RIGHT", 5, 0 },
    }

    local function UpdateTeamIndex(teamIndex, showIndex, direc)
        if not showIndex then
            teamIndex:Hide()
        else
            teamIndex:Show()
            teamIndex:ClearAllPoints()
            local anchor = teamIndexAnchor[direc]
            teamIndex:SetPoint(anchor[1], teamIndex.__owner, anchor[2], anchor[3], anchor[4])
        end
    end

    local function CreateTeamIndex(header)
        local showIndex = Config.DB["UFs"]["TeamIndex"]
        local direc = Config.DB["UFs"]["RaidDirection"]
        local parent = _G[header:GetName() .. "UnitButton1"]
        if parent and not parent.teamIndex then
            local teamIndex = Core.CreateFS(parent, 14, header.index)
            teamIndex:SetTextColor(.6, .8, 1)
            teamIndex.__owner = parent
            UpdateTeamIndex(teamIndex, showIndex, direc)
            teamIndexes[header.index] = teamIndex

            parent.teamIndex = teamIndex
        end
    end

    function UF:UpdateRaidTeamIndex()
        local showIndex = Config.DB["UFs"]["TeamIndex"]
        local direc = Config.DB["UFs"]["RaidDirection"]
        for _, teamIndex in pairs(teamIndexes) do
            UpdateTeamIndex(teamIndex, showIndex, direc)
        end
    end

    local groups = {}

    function UF:CreateAndUpdateRaidHeader()
        local index = Config.DB["UFs"]["RaidDirection"]
        local rows = Config.DB["UFs"]["RaidRows"]
        local numGroups = Config.DB["UFs"]["NumRaidGroups"]
        local raidWidth, raidHeight = Config.DB["UFs"]["RaidWidth"], Config.DB["UFs"]["RaidHeight"]
        local raidFrameHeight = raidHeight + Config.DB["UFs"]["RaidPowerHeight"]
        local indexSpacing = Config.DB["UFs"]["TeamIndex"] and 20 or 0
        local spacing = Config.DB["UFs"]["RaidSpacing"]

        local sortData = UF.RaidDirections[index]
        for i = 1, numGroups do
            local group = groups[i]
            if not group then
                group = CreateRaidGroup("oUF_Raid" .. i, i, raidWidth, raidFrameHeight)
                group.index = i
                group.groupType = "raid"
                tinsert(UF.headers, group)
                RegisterStateDriver(group, "visibility", "show")
                RegisterStateDriver(group, "visibility", GetRaidVisibility())
                CreateTeamIndex(group)

                groups[i] = group
            end

            if not raidMover and i == 1 then
                raidMover = Core.Mover(groups[i], L["RaidFrame"], "RaidFrame", { "TOPLEFT", UIParent, 35, -50 })
            end

            local groupWidth = index < 5 and raidWidth + spacing or (raidWidth + spacing) * 5
            local groupHeight = index < 5 and (raidFrameHeight + spacing) * 5 or raidFrameHeight + spacing
            local numX = ceil(numGroups / rows)
            local numY = min(rows, numGroups)
            local indexSpacings = indexSpacing * (numY - 1)
            if index < 5 then
                raidMover:SetSize(groupWidth * numX - spacing, groupHeight * numY - spacing + indexSpacings)
            else
                raidMover:SetSize(groupWidth * numY - spacing + indexSpacings, groupHeight * numX - spacing)
            end

            ResetHeaderPoints(group)
            group:SetAttribute("point", sortData.point)
            group:SetAttribute("xOffset", sortData.xOffset / 5 * spacing)
            group:SetAttribute("yOffset", sortData.yOffset / 5 * spacing)

            group:ClearAllPoints()
            if i == 1 then
                group:SetPoint(sortData.initAnchor, raidMover)
            elseif (i - 1) % rows == 0 then
                group:SetPoint(sortData.initAnchor, groups[i - rows], sortData.relAnchor, sortData.x / 5 * spacing,
                    sortData.y / 5 * spacing)
            else
                local x = floor((i - 1) / rows)
                local y = (i - 1) % rows
                if index < 5 then
                    group:SetPoint(sortData.initAnchor, raidMover, sortData.initAnchor, sortData.multX * groupWidth * x,
                        sortData.multY * (groupHeight + indexSpacing) * y)
                else
                    group:SetPoint(sortData.initAnchor, raidMover, sortData.initAnchor,
                        sortData.multX * (groupWidth + indexSpacing) * y, sortData.multY * groupHeight * x)
                end
            end
        end

        for i = 1, 8 do
            local group = groups[i]
            if group then
                group.__disabled = i > Config.DB["UFs"]["NumRaidGroups"]
            end
        end
    end

    UF:CreateAndUpdateRaidHeader(true)
    UF:UpdateRaidTeamIndex()
    UF:UpdateRaidHealthMethod()
end

function UF:OnLogin()
    oUF:RegisterStyle("Player", CreatePlayer)
    oUF:RegisterStyle("Target", CreateTarget)
    oUF:RegisterStyle("ToT", CreateToT)
    oUF:RegisterStyle("Focus", CreateFocus)
    oUF:RegisterStyle("FocusTarget", CreateFocusTarget)
    oUF:RegisterStyle("Pet", CreatePet)

    oUF:SetActiveStyle("Player")
    local player = oUF:Spawn("player", "oUF_Player")
    Core.Mover(player, L["PlayerUF"], "PlayerUF", Config.UFs.PlayerPosition)
    UF.ToggleCastBar(player, "Player")

    oUF:SetActiveStyle("Target")
    local target = oUF:Spawn("target", "oUF_Target")
    Core.Mover(target, L["TargetUF"], "TargetUF", Config.UFs.TargetPosition)
    UF.ToggleCastBar(target, "Target")

    oUF:SetActiveStyle("ToT")
    local tot = oUF:Spawn("targettarget", "oUF_ToT")
    Core.Mover(tot, L["TotUF"], "TotUF", Config.UFs.ToTPosition)

    oUF:SetActiveStyle("Pet")
    local pet = oUF:Spawn("pet", "oUF_Pet")
    Core.Mover(pet, L["PetUF"], "PetUF", Config.UFs.PetPosition)

    oUF:SetActiveStyle("Focus")
    local focus = oUF:Spawn("focus", "oUF_Focus")
    Core.Mover(focus, L["FocusUF"], "FocusUF", Config.UFs.FocusPosition)
    UF.ToggleCastBar(focus, "Focus")

    oUF:SetActiveStyle("FocusTarget")
    local focustarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
    Core.Mover(focustarget, L["FotUF"], "FotUF", {"TOPLEFT", oUF_Focus, "TOPRIGHT", 5, 0})

    oUF:RegisterStyle("Boss", CreateBoss)
    oUF:SetActiveStyle("Boss")
    local boss = {}
    for i = 1, 5 do
        boss[i] = oUF:Spawn("boss"..i, "oUF_Boss"..i)
        local moverWidth, moverHeight = boss[i]:GetWidth(), boss[i]:GetHeight()+8
        local title = i > 5 and "Boss"..i or L["BossFrame"]..i
        if i == 1 then
            boss[i].mover = Core.Mover(boss[i], title, "Boss1", {"RIGHT", UIParent, "RIGHT", -350, -90}, moverWidth, moverHeight)
        elseif i == 6 then
            boss[i].mover = Core.Mover(boss[i], title, "Boss"..i, {"BOTTOMLEFT", boss[1].mover, "BOTTOMRIGHT", 50, 0}, moverWidth, moverHeight)
        else
            boss[i].mover = Core.Mover(boss[i], title, "Boss"..i, {"BOTTOMLEFT", boss[i-1], "TOPLEFT", 0, 50}, moverWidth, moverHeight)
        end
    end

    if Config.DB["UFs"]["ShowArena"] then
        oUF:RegisterStyle("Arena", CreateArena)
        oUF:SetActiveStyle("Arena")
        local arena = {}
        for i = 1, 5 do
            arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
            arena[i]:SetPoint("TOPLEFT", boss[i].mover)
        end
    end

    UF:ToggleAllAuras()
    UF:CheckPowerBars()
    --UF:UpdateRaidInfo()

    SetCVar("predictedHealth", 1)
    Core:HideDefaultRaidFrame()

    UF.headers = {}
    UF:SetupParty()
    UF:SetupRaid()
end