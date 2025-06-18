local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

local function SetupBagFilter(parent)
	local guiName = "LauringUI_BagFilterSetup"
	local exatraGuis = G:ToggleExtraGUI(guiName)
	if exatraGuis[guiName] then return end

	local panel = G:CreateExtraGUI(parent, guiName, L["BagFilterSetup"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local filterOptions = {
		[1] = "FilterJunk",
		[2] = "FilterConsumable",
		[3] = "FilterAmmo",
		[4] = "FilterEquipment",
		[5] = "FilterEquipSet",
		[6] = "FilterLegendary",
		[7] = "FilterFavourite",
		[8] = "FilterGoods",
		[9] = "FilterQuest",
		[10] = "FilterCollection",
		[11] = "FilterBOE",
	}

	local BAG = Core:GetModule("Bags")

    local function UpdateAllBags()
		BAG:UpdateAllBags()
	end

	local offset = 10
	for _, value in ipairs(filterOptions) do
		G:CreateOptionCheck(scroll, -offset, L[value], "Bags", value, UpdateAllBags)
		offset = offset + 35
	end
end

local function UpdateBagStatus()
	Core:GetModule("Bags"):UpdateAllBags()
end

local function SetupBagFilterFunc()
	SetupBagFilter(G.GuiPage["Bags"])
end

local function UpdateBagSortOrder()
	SetSortBagsRightToLeft(Config.DB["Bags"]["BagSortMode"] == 1)
end

local function UpdateBagAnchor()
	Core:GetModule("Bags"):UpdateAllAnchors()
end

local function UpdateBagSize()
	Core:GetModule("Bags"):UpdateBagSize()
end

local options = {
    {1, "Bags", "Enable", G.HeaderTag..L["Enable Bags"]},
    {},--blank
    {1, "Bags", "GatherEmpty", L["Bags GatherEmpty"].."*", nil, nil, UpdateBagStatus},
    {1, "Bags", "ItemFilter", L["Bags ItemFilter"].."*", true, SetupBagFilterFunc, UpdateBagStatus},
    {1, "Bags", "SpecialBagsColor", L["SpecialBagsColor"].."*", nil, nil, UpdateBagStatus, L["SpecialBagsColorTip"]},
    {1, "Bags", "ShowNewItem", L["Bags ShowNewItem"], true},
    {1, "Bags", "BagsiLvl", L["Bags Itemlevel"].."*", nil, nil, UpdateBagStatus},
    {3, "Bags", "iLvlToShow", L["iLvlToShow"].."*", nil, {1, 500, 1}, nil, L["iLvlToShowTip"]},
    {4, "Bags", "BagSortMode", L["BagSortMode"].."*", true, {L["Forward"], L["Backward"], DISABLE}, UpdateBagSortOrder},
    {},--blank
    {3, "Bags", "BagsPerRow", L["BagsPerRow"].."*", nil, {1, 20, 1}, UpdateBagAnchor, L["BagsPerRowTip"]},
    {3, "Bags", "BankPerRow", L["BankPerRow"].."*", true, {1, 20, 1}, UpdateBagAnchor, L["BankPerRowTip"]},
    {3, "Bags", "IconSize", L["Bags IconSize"].."*", nil, {20, 50, 1}, UpdateBagSize},
    {3, "Bags", "FontSize", L["Bags FontSize"].."*", true, {10, 50, 1}, UpdateBagSize},
    {3, "Bags", "BagsWidth", L["Bags Width"].."*", false, {10, 40, 1}, UpdateBagSize},
    {3, "Bags", "BankWidth", L["Bank Width"].."*", true, {10, 40, 1}, UpdateBagSize},
}

G.TabList["Bags"] = options