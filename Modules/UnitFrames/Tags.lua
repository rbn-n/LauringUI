local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local oUF = ns.oUF
local format, floor = string.format, math.floor
local AFK, DND, DEAD, PLAYER_OFFLINE, LEVEL = AFK, DND, DEAD, PLAYER_OFFLINE, LEVEL
local ALTERNATE_POWER_INDEX = ALTERNATE_POWER_INDEX or 10
local UnitIsDeadOrGhost, UnitIsConnected, UnitIsTapDenied, UnitIsPlayer = UnitIsDeadOrGhost, UnitIsConnected, UnitIsTapDenied, UnitIsPlayer
local UnitHealth, UnitHealthMax, UnitPower, UnitPowerType = UnitHealth, UnitHealthMax, UnitPower, UnitPowerType
local UnitClass, UnitReaction, UnitLevel, UnitClassification = UnitClass, UnitReaction, UnitLevel, UnitClassification
local UnitIsAFK, UnitIsDND, UnitIsDead, UnitIsGhost = UnitIsAFK, UnitIsDND, UnitIsDead, UnitIsGhost
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local GetSpellInfo, UnitIsFeignDeath = GetSpellInfo, UnitIsFeignDeath

local FEIGN_DEATH
local function GetFeignDeathTag()
	if not FEIGN_DEATH then
		FEIGN_DEATH = GetSpellInfo(5384)
	end
	return FEIGN_DEATH
end

local function ColorPercent(value)
	local r, g, b
	if value < 20 then
		r, g, b = 1, .1, .1
	elseif value < 35 then
		r, g, b = 1, .5, 0
	elseif value < 80 then
		r, g, b = 1, .9, .3
	else
		r, g, b = 1, 1, 1
	end
	return Core.HexRGB(r, g, b)..value
end

local function ValueAndPercent(cur, per)
	if per < 100 then
		return Core.Numb(cur).." | "..ColorPercent(per)
	else
		return Core.Numb(cur)
	end
end

local function GetCurrentAndMax(cur, max)
	if cur == max then
		return Core.Numb(max)
	else
		return Core.Numb(cur).." | "..Core.Numb(max)
	end
end

oUF.Tags.Methods["VariousHP"] = function(unit, _, arg1)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) or UnitIsFeignDeath(unit) then
		if arg1 == "cleanpercent" then return "" end
		return oUF.Tags.Methods["DDG"](unit)
	end

	if not arg1 then return end
	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	local per = max == 0 and 0 or Core:Round(cur/max * 100, 1)

	if arg1 == "currentpercent" then
		return ValueAndPercent(cur, per)
	elseif arg1 == "currentmax" then
		return GetCurrentAndMax(cur, max)
	elseif arg1 == "current" then
		return Core.Numb(cur)
	elseif arg1 == "percent" then
		return per < 100 and ColorPercent(per)
	elseif arg1 == "cleanpercent" then
		return per < 100 and Core:Round(per)
	elseif arg1 == "loss" then
		local loss = max - cur
		return loss ~= 0 and Core.Numb(loss)
	elseif arg1 == "losspercent" then
		local loss = max - cur
		return loss ~= 0 and Core:Round(loss/max*100, 1)
	end
end
oUF.Tags.Events["VariousHP"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE"

oUF.Tags.Methods["VariousMP"] = function(unit, _, arg1)
	local cur, max = UnitPower(unit), UnitPowerMax(unit)
	local per = max == 0 and 0 or Core:Round(cur/max * 100)

	if arg1 == "currentpercent" then
		return ValueAndPercent(cur, per)
	elseif arg1 == "currentmax" then
		return GetCurrentAndMax(cur, max)
	elseif arg1 == "current" then
		return Core.Numb(cur)
	elseif arg1 == "percent" then
		return per < 100 and ColorPercent(per)
	elseif arg1 == "loss" then
		local loss = max - cur
		return loss ~= 0 and Core.Numb(loss)
	elseif arg1 == "losspercent" then
		local loss = max - cur
		return loss ~= 0 and Core:Round(loss/max*100, 1)
    end
end
oUF.Tags.Events["VariousMP"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["color"] = function(unit)
	local class = select(2, UnitClass(unit))
	local reaction = UnitReaction(unit, "player")

	if UnitIsTapDenied(unit) then
		return Core.HexRGB(oUF.colors.tapped)
	elseif UnitIsPlayer(unit) then
		return Core.HexRGB(oUF.colors.class[class])
	elseif reaction then
		return Core.HexRGB(oUF.colors.reaction[reaction])
	else
		return Core.HexRGB(1, 1, 1)
	end
end
oUF.Tags.Events["color"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_FACTION UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

local function IsAfkOrDnd(unit)
	if UnitIsAFK(unit) then
		return "|cffCFCFCF <"..AFK..">|r"
	elseif UnitIsDND(unit) then
		return "|cffCFCFCF <"..DND..">|r"
	else
		return ""
	end
end

oUF.Tags.Methods["afkdnd"] = function(unit)
	return IsAfkOrDnd(unit)
end
oUF.Tags.Events["afkdnd"] = "PLAYER_FLAGS_CHANGED"

local function IsDdg(unit)
	if UnitIsFeignDeath(unit) then
		return "|cff99ccff"..GetFeignDeathTag().."|r"
	elseif UnitIsDead(unit) then
		return "|cffCFCFCF"..DEAD.."|r"
	elseif UnitIsGhost(unit) then
		return "|cffCFCFCF"..L["Ghost"].."|r"
	elseif not UnitIsConnected(unit) then
		return "|cffCFCFCF"..PLAYER_OFFLINE.."|r"
	end
end

oUF.Tags.Methods["DDG"] = function(unit)
	return IsDdg(unit)
end
oUF.Tags.Events["DDG"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

-- Level tags
oUF.Tags.Methods["fulllevel"] = function(unit)
	local level = UnitLevel(unit)
	local color = Core.HexRGB(GetCreatureDifficultyColor(level))
	if level > 0 then
		level = color..level.."|r"
	else
		level = "|cffff0000??|r"
	end
	local str = level

	local class = UnitClassification(unit)
	if not UnitIsConnected(unit) then
		str = "??"
	elseif class == "worldboss" then
		str = "|cffff0000Boss|r"
	elseif class == "rareelite" then
		str = level.."|cff0080ffR|r+"
	elseif class == "elite" then
		str = level.."+"
	elseif class == "rare" then
		str = level.."|cff0080ffR|r"
	end

	return str
end
oUF.Tags.Events["fulllevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

-- RaidFrame tags
local healthModeType = {
	[2] = "percent",
	[3] = "current",
	[4] = "loss",
	[5] = "losspercent",
}
oUF.Tags.Methods["raidhp"] = function(unit)
	local healthType = healthModeType[Config.DB["UFs"]["RaidHPMode"]]
	return oUF.Tags.Methods["VariousHP"](unit, _, healthType)
end
oUF.Tags.Events["raidhp"] = oUF.Tags.Events["VariousHP"]

-- Nameplate tags
oUF.Tags.Methods["nppp"] = function(unit)
	local per = oUF.Tags.Methods["perpp"](unit)
	local color
	if per > 85 then
		color = Core.HexRGB(1, .1, .1)
	elseif per > 50 then
		color = Core.HexRGB(1, 1, .1)
	else
		color = Core.HexRGB(.8, .8, 1)
	end
	per = color..per.."|r"

	return per
end
oUF.Tags.Events["nppp"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER"

oUF.Tags.Methods["nplevel"] = function(unit)
	local level = UnitLevel(unit)
	if level and level ~= UnitLevel("player") then
		if level > 0 then
			return Core.HexRGB(GetCreatureDifficultyColor(level))..level.."|r "
		else
			return "|cffff0000??|r "
		end
	else
		return ""
	end
end
oUF.Tags.Events["nplevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP"

local NPClassifies = {
	rare = "  ",
	elite = "  ",
	rareelite = "  ",
	worldboss = "  ",
}
oUF.Tags.Methods["nprare"] = function(unit)
	local class = UnitClassification(unit)
	return class and NPClassifies[class]
end
oUF.Tags.Events["nprare"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["pppower"] = function(unit)
	local cur = UnitPower(unit)
	local per = oUF.Tags.Methods["perpp"](unit) or 0
	if UnitPowerType(unit) == 0 then
		return per
	else
		return cur
	end
end
oUF.Tags.Events["pppower"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["tarname"] = function(unit)
	local tarUnit = unit.."target"
	if UnitExists(tarUnit) then
		return Core.HexRGB(Core.UnitColor(tarUnit))..UnitName(tarUnit)
	end
end
oUF.Tags.Events["tarname"] = "UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE UNIT_HEALTH_FREQUENT"

-- AltPower value tag
oUF.Tags.Methods["altpower"] = function(unit)
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	local max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
	if max > 0 and not UnitIsDeadOrGhost(unit) then
		return format("%s%%", floor(cur/max*100 + .5))
	end
end
oUF.Tags.Events["altpower"] = "UNIT_POWER_UPDATE"

-- Eclipse power for Druid
local POWERTYPE_BALANCE = Enum.PowerType.Balance or 26
oUF.Tags.Methods["cureclipse"] = function(unit)
	local textFormat = GetEclipseDirection() == "sun" and "|cff4d85e6%s>" or "|cffccd199<%s"
	local max = UnitPowerMax("player", POWERTYPE_BALANCE)
	return format(textFormat, (max == 0 and 0) or math.abs(UnitPower("player", POWERTYPE_BALANCE)))
end
oUF.Tags.Events["cureclipse"] = "UNIT_POWER_FREQUENT ECLIPSE_DIRECTION_CHANGE"

oUF.Tags.Methods["abbrevname"] = function(unit)
	local name = UnitName(unit)
	if not name then return "" end

	if #name <= 20 then
		return name
	end

	local parts = {}
	for word in name:gmatch("%S+") do
		tinsert(parts, word)
	end

	local last = tremove(parts) -- Remove and save last word
	for i, word in ipairs(parts) do
		parts[i] = strsub(word, 1, 1) .. "."
	end

	tinsert(parts, last)
	return table.concat(parts, " ")
end

oUF.Tags.Events["abbrevname"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["abbrevname:short"] = function(unit)
	local name = UnitName(unit)
	if not name then return "" end

	if #name <= 10 then
		return name
	end

	local parts = {}
	for word in name:gmatch("%S+") do
		tinsert(parts, word)
	end

	local last = tremove(parts) -- Remove and save last word
	for i, word in ipairs(parts) do
		parts[i] = strsub(word, 1, 1) .. "."
	end

	tinsert(parts, last)
	return table.concat(parts, " ")
end

oUF.Tags.Events["abbrevname:short"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["nameOrCondition"] = function(unit)
	local isDdg = IsDdg(unit)
	if isDdg then
		return isDdg
	end

	if UnitIsAFK(unit) then
		return "|cffCFCFCF <"..AFK..">|r"
	end

	local color = oUF.Tags.Methods["color"](unit) or ""
	local abbrev = oUF.Tags.Methods["abbrevname"](unit)
	return color .. abbrev
end

oUF.Tags.Events["nameOrCondition"] = table.concat({
	"PLAYER_FLAGS_CHANGED",
	"UNIT_HEALTH_FREQUENT",
	"UNIT_MAXHEALTH",
	"UNIT_NAME_UPDATE",
	"UNIT_CONNECTION",
	"UNIT_FACTION",
}, " ")