local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local UF = Core:GetModule("UnitFrames")

function UF:CalculateHealthHeight(frame)
    local mystyle = frame.mystyle

    if UF.HidePower(frame) then
        return Config.DB["UFs"][mystyle.."Height"]
    end

    if (UF.IsPlayerOrTarget(frame)) then
        return Config.DB["UFs"]["PlayerHeight"] - Config.DB["UFs"]["PlayerPowerOffset"] - Config.DB["UFs"]["PlayerPowerHeight"]
    elseif frame.raidLayout then
        return Config.DB["UFs"][frame.raidLayout.."Height"] - Config.DB["UFs"][frame.raidLayout.."PowerHeight"]
    elseif Config.DB["UFs"][mystyle.."PowerHeight"] then
        return Config.DB["UFs"][mystyle.."Height"] - Config.DB["UFs"][mystyle.."PowerHeight"]
    end

    return Config.DB["UFs"][mystyle.."Height"]
end

function UF:CreateHealthBar(frame)
    local health = CreateFrame("StatusBar", nil, frame)
    health:SetPoint("TOPLEFT", frame)
	health:SetPoint("TOPRIGHT", frame)

    local healthHeight = UF:CalculateHealthHeight(frame)
    health:SetHeight(healthHeight)
    health:SetStatusBarTexture(DB.StatusBarTexture)
    health:SetStatusBarColor(.1, .1, .1, 0.7)
    health:SetFrameLevel(frame:GetFrameLevel() - 2)

    local background = health:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Buttons\\WHITE8x8")
    background:SetAllPoints(health)

    Core:SmoothBar(health)
	health.frequentUpdates = true

    Core:CreateHealthBorder(health, 1)
    Core:CreateShadow(health, 5)

    frame.Health = health
    frame.Health.bg = background
    frame.Health.PostUpdate = UF.HealthPostUpdate
end

function UF:UpdateFrameNameTag(frame)
    if not frame then return end
	local name = frame.nameText
	if not name then return end

	local mystyle = frame.mystyle

	local colorNameTag = "[color][abbrevname]"

	if mystyle == "Player" then
		frame:Tag(name, colorNameTag.."[afkdnd]")
	elseif mystyle == "Target" then
		frame:Tag(name, "[fulllevel] "..colorNameTag.."[afkdnd]")
    elseif UF.IsPartyOrRaid(frame) then
		frame:Tag(name, "[nameOrCondition]")
	elseif mystyle == "Arena" then
		frame:Tag(name, colorNameTag)
    elseif mystyle == "Focus"  or mystyle == "ToT" or mystyle == "FocusTarget" then
        frame:Tag(name, "[color][abbrevname:short]")
	else
		frame:Tag(name, "[nplevel]"..colorNameTag)
	end

	name:UpdateTag()
    UF:UpdateFrameNameVisibility(frame)
end

function UF:SetPartyAndRaidName(name, frame)
    name:SetJustifyH("CENTER")
    name:SetPoint("CENTER", frame, "CENTER", 0, 0)
end

local function CreateNameText(frame, textFrame)
    local fontSize = Config.DB["UFs"][frame.mystyle.."FontSize"]
    local name = Core.CreateFS(textFrame, fontSize)
    frame.nameText = name
	name:SetJustifyH("LEFT")

    if UF.IsPlayerOrTarget(frame) then
        name:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", Config.DB.UFs.PlayerNameOffset, 0)
    elseif UF.IsPartyOrRaid(frame)  then
        UF:SetPartyAndRaidName(name, frame)
    else
        name:SetPoint("LEFT", frame, "LEFT", 2, 0)
    end

    UF:UpdateFrameNameTag(frame)
end

function UF:UpdateFrameNameVisibility(frame)
    local hideFrameName = Config.DB["UFs"]["Hide"..frame.mystyle.."Name"]
    if hideFrameName == nil then return end

    if hideFrameName then
        frame.nameText:Hide()
    else
        frame.nameText:Show()
    end
end

function UF:UpdateFrameHealthTag(frame)
    if UF.IsPartyOrRaid(frame) then return end

    local valueType = UF.VariousTagIndex[Config.DB["UFs"][frame.mystyle.."HPTag"]]

	frame:Tag(frame.healthValue, "[VariousHP("..valueType..")]")
    frame.healthValue:UpdateTag()
end

local function CreateHealthText(frame, textFrame)
    if UF.IsPartyOrRaid(frame) then return end

    local fontSize = Config.DB["UFs"][frame.mystyle.."FontSize"]
    local healthText

    if UF.IsPlayerOrTarget(frame) then
        healthText = Core.CreateFS(textFrame, fontSize)
        healthText:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 0)
    else
        healthText = Core.CreateFS(textFrame, fontSize)
        healthText:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    end

    frame.healthValue = healthText

    if UF.IsPlayerOrTarget(frame) then
        local percentHPText = Core.CreateFS(textFrame, fontSize - 2)
        frame.percentHealthValue = percentHPText

        percentHPText:SetPoint("RIGHT", frame.Health:GetStatusBarTexture())
        frame:Tag(percentHPText, "[VariousHP(cleanpercent)]")
    end

    UF:UpdateFrameHealthTag(frame)
end

function UF:CreateHealthAndNameText(frame)
	local textFrame = CreateFrame("Frame", nil, frame)
	textFrame:SetAllPoints(frame.Health)

    CreateNameText(frame, textFrame)
    CreateHealthText(frame, textFrame)
end

function UF.HealthPostUpdate(element, unit, cur, max)
    local self = element.__owner
    local r, g, b

    local disconnected = not UnitIsConnected(unit)
    local dead = UnitIsDead(unit)
    local ghost = UnitIsGhost(unit)

    if disconnected or dead or ghost then
        element:SetValue(max)
        if disconnected then
            element:SetStatusBarColor(0, 0, 0, 0.6)
        elseif ghost then
            element:SetStatusBarColor(1, 1, 1, 0.6)
        elseif dead then
            element:SetStatusBarColor(1, 0, 0, 0.7)
        end

        element.bg:SetVertexColor(0.5, 0.5, 0.5, 0.3)
        return
    end

    if UnitIsPlayer(unit) then
        local class = select(2, UnitClass(unit))
        local color = self.colors.class[class]
        if color then
            r, g, b = color[1], color[2], color[3]
        end
    else
        local reaction = UnitReaction(unit, "player")
        if reaction then
            local color = self.colors.reaction[reaction]
            if color then
                r, g, b = color[1], color[2], color[3]
            end
        end
    end

    if not r then
        r, g, b = 1, 1, 1
    end

    element:SetStatusBarColor(.1, .1, .1, 0.7)
    element.bg:SetVertexColor(r, g, b, 0.35)
end