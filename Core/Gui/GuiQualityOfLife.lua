local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

local function UpdateZoomLevel()
	Core:GetModule("QoL"):UpdateZoomLevel()
end

local function UpdateErrorFilter()
	Core:GetModule("QoL"):UpdateErrorFilter()
end

local function UpdateLootFaster()
	Core:GetModule("QoL"):UpdateLootFaster()
end

local function UpdateRaidWorldMarkers()
	Core:GetModule("QoL"):RaidWorldMarks_UpdateGrid()
end


local options = {
    {3, "ACCOUNT", "UIScale", L["Setup UIScale"], nil, {.4, 1.15, .01}, nil, L["UIScaleTip"]},
    {3, "QoL", "ZoomLevel", L["ZoomLevel"].."*", true, {1, 3.4, .1}, UpdateZoomLevel},
    {},--blank
    {1, "QoL", "ShowItemQuality", L["Show ItemQuality"]},
    {1, "QoL", "ShowItemLevel", L["Show ItemLevel"]},
    {},--blank
    {1, "QoL", "LootFaster", L["Faster Loot"].."*", nil, nil, UpdateLootFaster},
    {1, "QoL", "ErrorFilter", L["Error Filter"].."*", true, nil, UpdateErrorFilter},
    {1, "QoL", "EnableMail", L["Mail Tool"]},
    {1, "QoL", "DeleteHelper", L["DeleteHelper"].."*", true},
    {1, "QoL", "TaxiDismount", L["TaxiDismount"].."*", nil, nil, nil, L["TaxiDismountTip"]},
    {4, "QoL", "RaidWorldMarksType", L["ShowRaidWorldMarks"].."*", nil, {L["Grids"], L["Horizontal"], L["Vertical"], DISABLE}, UpdateRaidWorldMarkers, L["ShowRaidWorldMarksTip"]},
    {3, "QoL", "RaidWorldMarksSize", L["RaidWorldMarksSize"].."*", true, {20, 50, 1}, UpdateRaidWorldMarkers},
}

G.TabList["Quality of Life"] = options