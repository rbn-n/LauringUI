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
    {1, "Minimap", "Enable", G.HeaderTag..L["EnableMinimap"], nil, nil, nil, L["EnableMinimapTip"]},
    {3, "Minimap", "Scale", L["Minimap Scale"].."*", nil, {.5, 3, .1}, UpdateMinimapScale},
    {3, "Minimap", "Size", L["Minimap Size"].."*", true, {100, 500, 1}, UpdateMinimapScale},
    {1, "Minimap", "ShowCalendar", L["MinimapCalendar"].."*", nil, nil, ShowCalendar, L["MinimapCalendarTip"]},
    {1, "Minimap", "ShowCombatPulse", L["Minimap Pulse"], true},
    {1, "Minimap", "ShowWhoPings", L["Show WhoPings"], nil},
    {1, "Minimap", "EnableEasyVolume", L["EasyVolume"], true, nil, nil, L["EasyVolumeTip"]},
    {1, "Minimap", "ShowRecycleBin", L["Show RecycleBin"]},
    --{2, "ACCOUNT", "IgnoredButtons", L["IgnoredButtons"], nil, nil, nil, L["IgnoredButtonsTip"]},
}

G.TabList["Maps"] = options