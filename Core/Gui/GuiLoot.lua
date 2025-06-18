local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")
local LauringUI_LootRoll = _G.LauringUI_LootRoll

local quality = {
	[1] = ITEM_QUALITY_COLORS[1].hex .. ITEM_QUALITY1_DESC .. "|r",
	[2] = ITEM_QUALITY_COLORS[2].hex .. ITEM_QUALITY2_DESC .. "|r",
	[3] = ITEM_QUALITY_COLORS[3].hex .. ITEM_QUALITY3_DESC .. "|r",
	[4] = ITEM_QUALITY_COLORS[4].hex .. ITEM_QUALITY4_DESC .. "|r",
}

local function HideLootRoll()
	if LauringUI_LootRoll and LauringUI_LootRoll:IsShown() then
		LauringUI_LootRoll:Hide()
	end
end

local function UpdateLootRoll()
	Core:GetModule("Loot"):UpdateLootRollTest()
end

local options = {
    {1, "Loot", "Enable", G.HeaderTag..L["LootEnhancedEnable"], nil, nil, nil, L["LootEnhancedTip"]},
    {1, "Loot", "Announce", L["LootAnnounceButton"]},
    {1, "Loot", "AnnounceTitle", L["Announce Target Name"].."*"},
    {4, "Loot", "AnnounceRarity", L["Rarity Threshold"].."*", true, quality},
    {},
    {1, "Loot", "Enable", G.HeaderTag..L["LootRoll"], nil, nil, nil, L["LootRollTip"], {OnHide = HideLootRoll}},
    {1, "Loot", "ItemLevel", L["Item Level"].."*", nil, nil, UpdateLootRoll},
    {1, "Loot", "ItemQuality", L["Item Quality"].."*", true, nil, UpdateLootRoll},
    {4, "Loot", "Style", L["Style"], false, {L["Style 1"], L["Style 2"]}, UpdateLootRoll},
    {4, "Loot", "Direction", L["GrowthDirection"], true, {L["Up"], L["Down"]}},
    {3, "Loot", "Width", L["Width"], false, {200, 500, 1}, UpdateLootRoll},
    {3, "Loot", "Height", L["Height"], true, {20, 50, 1}, UpdateLootRoll},
}

G.TabList["Loot"] = options