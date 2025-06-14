local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

local function UpdateMinimapScale()
	Core:GetModule("Maps"):UpdateMinimapScale()
end

local function ShowCalendar()
	Core:GetModule("Maps"):ShowCalendar()
end

local options = {
    {1, "Map", "DisableMinimap", "|cffff0000"..L["DisableMinimap"], nil, nil, nil, L["DisableMinimapTip"]},
    {3, "Map", "MinimapScale", L["Minimap Scale"].."*", nil, {.5, 3, .1}, UpdateMinimapScale},
    {3, "Map", "MinimapSize", L["Minimap Size"].."*", true, {100, 500, 1}, UpdateMinimapScale},
    {1, "Map", "Calendar", L["MinimapCalendar"].."*", true, nil, ShowCalendar, L["MinimapCalendarTip"]},
    {1, "Map", "CombatPulse", L["Minimap Pulse"]},
    {1, "Map", "WhoPings", L["Show WhoPings"], true},
    {1, "Map", "EasyVolume", L["EasyVolume"], nil, nil, nil, L["EasyVolumeTip"]},
    {1, "Map", "ShowRecycleBin", L["Show RecycleBin"]},
    {2, "ACCOUNT", "IgnoredButtons", L["IgnoredButtons"], nil, nil, nil, L["IgnoredButtonsTip"]},
}

G.TabList["Maps"] = options