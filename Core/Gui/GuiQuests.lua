local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

local options = {
    {1, "Quests", "Tracker", G.HeaderTag..L["EnableQuestsTracker"]},
}

G.TabList["Quests"] = options