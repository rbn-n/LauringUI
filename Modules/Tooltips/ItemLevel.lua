local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local Tooltip = Core:GetModule("Tooltips")

-- Credit: Cloudy Unit Info, by Cloudyfa
local select, max, strfind, format, strsplit = select, math.max, string.find, string.format, string.split
local GetTime, CanInspect, NotifyInspect, ClearInspectPlayer, IsShiftKeyDown = GetTime, CanInspect, NotifyInspect, ClearInspectPlayer, IsShiftKeyDown
local UnitGUID, UnitClass, UnitIsUnit, UnitIsPlayer, UnitIsVisible, UnitIsDeadOrGhost, UnitOnTaxi = UnitGUID, UnitClass, UnitIsUnit, UnitIsPlayer, UnitIsVisible, UnitIsDeadOrGhost, UnitOnTaxi
local GetInventoryItemTexture, GetInventoryItemLink, GetItemGem, GetAverageItemLevel = GetInventoryItemTexture, GetInventoryItemLink, GetItemGem, GetAverageItemLevel
local HEIRLOOMS = _G.HEIRLOOMS

local levelPrefix = STAT_AVERAGE_ITEM_LEVEL..": "..DB.InfoColor
local isPending = LFG_LIST_LOADING
local resetTime, frequency = 900, .5
local cache, currentUNIT, currentGUID = {}, nil, nil

function Tooltip:InspectOnUpdate(elapsed)
	self.elapsed = (self.elapsed or frequency) + elapsed
	if self.elapsed > frequency then
		self.elapsed = 0
		self:Hide()
		ClearInspectPlayer()

		if currentUNIT and UnitGUID(currentUNIT) == currentGUID then
			Core:RegisterEvent("INSPECT_READY", Tooltip.GetInspectInfo)
			NotifyInspect(currentUNIT)
		end
	end
end

local updater = CreateFrame("Frame")
updater:SetScript("OnUpdate", Tooltip.InspectOnUpdate)
updater:Hide()

local lastTime = 0
function Tooltip:GetInspectInfo(...)
	if self == "UNIT_INVENTORY_CHANGED" then
		local thisTime = GetTime()
		if thisTime - lastTime > .1 then
			lastTime = thisTime

			local unit = ...
			if UnitGUID(unit) == currentGUID then
				Tooltip:InspectUnit(unit, true)
			end
		end
	elseif self == "INSPECT_READY" then
		local guid = ...
		if guid == currentGUID then
			local level = Tooltip:GetUnitItemLevel(currentUNIT)
			cache[guid].level = level
			cache[guid].getTime = GetTime()

			if level then
				Tooltip:SetupItemLevel(level)
			else
				Tooltip:InspectUnit(currentUNIT, true)
			end
		end
		Core:UnregisterEvent(self, Tooltip.GetInspectInfo)
	end
end
Core:RegisterEvent("UNIT_INVENTORY_CHANGED", Tooltip.GetInspectInfo)

function Tooltip:SetupItemLevel(level)
	local _, unit = GameTooltip:GetUnit()
	if not unit or UnitGUID(unit) ~= currentGUID then return end

	local levelLine
	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft"..i]
		local text = line:GetText()
		if text and strfind(text, levelPrefix) then
			levelLine = line
		end
	end

	level = levelPrefix..(level or isPending)
	if levelLine then
		levelLine:SetText(level)
	else
		GameTooltip:AddLine(level)
	end
end

function Tooltip:GetUnitItemLevel(unit)
	if not unit or UnitGUID(unit) ~= currentGUID then return end

	local class = select(2, UnitClass(unit))
	local ilvl, boa, total, mainhand, offhand, ranged = 0, 0, 0, 0, 0, 0
	local delay

	for i = 1, 18 do
		if i ~= 4 then
			local itemTexture = GetInventoryItemTexture(unit, i)

			if itemTexture then
				local itemLink = GetInventoryItemLink(unit, i)

				if not itemLink then
					delay = true
				else
					local _, _, quality, level, _, _, _, _, slot = C_Item.GetItemInfo(itemLink)
					if (not quality) or (not level) then
						delay = true
					else
						if quality == Enum.ItemQuality.Heirloom then
							boa = boa + 1
						end


						if unit ~= "player" then
							level = Core.GetItemLevel(itemLink) or level
							if i < 16 then
								total = total + level
							elseif i == 16 then
								mainhand = level
							elseif i == 17 then
								offhand = level
							elseif i == 18 then
								ranged = level
							end
						end
					end
				end
			end
		end
	end

	if not delay then
		if unit == "player" then
			ilvl = select(2, GetAverageItemLevel())
		else
			--[[
				 Note: We have to unify iLvl with others who use MerInspect,
				 although it seems incorrect for Hunter with two melee weapons.
			]]
			if mainhand > 0 and offhand > 0 then
				total = total + mainhand + offhand
			elseif offhand > 0 and ranged > 0 then
				total = total + offhand + ranged
			else
				total = total + max(mainhand, offhand, ranged) * 2
			end
			ilvl = total / 16
		end

		if ilvl > 0 then ilvl = format("%.1f", ilvl) end
		if boa > 0 then ilvl = ilvl.." |cff00ccff("..boa..HEIRLOOMS..")" end
	else
		ilvl = nil
	end

	return ilvl
end

function Tooltip:InspectUnit(unit, forced)
	local level

	if UnitIsUnit(unit, "player") then
		level = self:GetUnitItemLevel("player")
		self:SetupItemLevel(level)
	else
		if not unit or UnitGUID(unit) ~= currentGUID then return end
		if not UnitIsPlayer(unit) then return end

		local currentDB = cache[currentGUID]
		level = currentDB.level
		self:SetupItemLevel(level)

		if not Config.DB["Tooltips"]["SpecLevelByShift"] and IsShiftKeyDown() then forced = true end
		if level and not forced and (GetTime() - currentDB.getTime < resetTime) then updater.elapsed = frequency return end
		if not UnitIsVisible(unit) or UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then return end
		if InspectFrame and InspectFrame:IsShown() then return end

		self:SetupItemLevel()
		updater:Show()
	end
end

function Tooltip:InspectUnitItemLevel(unit)
	if not Config.DB["Tooltips"]["SpecLevelByShift"] then return end
	if not IsShiftKeyDown() then return end

	if not unit or not CanInspect(unit) then return end
	currentUNIT, currentGUID = unit, UnitGUID(unit)
	if not cache[currentGUID] then cache[currentGUID] = {} end

	Tooltip:InspectUnit(unit)
end