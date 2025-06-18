local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

local options = {
    {3, "Tooltips", "Scale", L["Tooltip Scale"].."*", nil, {.5, 1.5, .1}},
    {4, "Tooltips", "Anchor", L["TipAnchor"].."*", true, {L["TOPLEFT"], L["TOPRIGHT"], L["BOTTOMLEFT"], L["BOTTOMRIGHT"]}, nil, L["TipAnchorTip"]},
    {1, "Tooltips", "HideJunkGuild", L["HideJunkGuild"].."*"},
    {1, "Tooltips", "HideRealm", L["Hide Realm"].."*", true},
    {1, "Tooltips", "TargetedBy", L["Show TargetedBy"].."*",},
    {1, "Tooltips", "ItemQuality", L["ShowItemQuality"].."*", true},
    {1, "Tooltips", "SpecLevelByShift", L["Show SpecLevelByShift"].."*"},
}

G.TabList["Tooltips"] = options