local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local Tooltip = Core:GetModule("Tooltips")


local wipe, tinsert, tconcat = table.wipe, table.insert, table.concat
local IsInGroup, IsInRaid, GetNumGroupMembers = IsInGroup, IsInRaid, GetNumGroupMembers
local UnitExists, UnitIsUnit, UnitIsDeadOrGhost, UnitName = UnitExists, UnitIsUnit, UnitIsDeadOrGhost, UnitName

local targetTable = {}

function Tooltip:ScanTargets()
	if not Config.DB["Tooltips"]["TargetedBy"] then return end
	if not IsInGroup() then return end

	local _, unit = self:GetUnit()
	if not UnitExists(unit) then return end

	wipe(targetTable)

	local isInRaid = IsInRaid()
	for i = 1, GetNumGroupMembers() do
		local member = (isInRaid and "raid"..i or "party"..i)
		if UnitIsUnit(unit, member.."target") and not UnitIsUnit("player", member) and not UnitIsDeadOrGhost(member) then
			local color = Core.HexRGB(Core.UnitColor(member))
			local name = color..UnitName(member).."|r"
			tinsert(targetTable, name)
		end
	end

	if #targetTable > 0 then
		GameTooltip:AddLine(L["Targeted By"]..DB.InfoColor.."("..#targetTable..")|r "..tconcat(targetTable, ", "), nil, nil, nil, 1)
	end
end

function Tooltip:TargetedInfo()
	GameTooltip:HookScript("OnTooltipSetUnit", Tooltip.ScanTargets)
end