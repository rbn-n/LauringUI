local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local function UpdatePanel(panel, bar)
    if not bar:IsShown() then
        panel:Hide()
        return
    end

    panel:Show()

    local padding = 4
    local width = ((bar:GetWidth() * 30) * 0.95) + padding
    local height = ((bar:GetHeight() * 2) * 0.95) + padding
    panel:SetSize(width, height)

    panel:ClearAllPoints()
    panel:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", -(padding / 2), -(padding / 2))
end

function module:CreateActionBarPanel()
    if not C_AddOns.IsAddOnLoaded("Bartender4") then return end

    local bar1 = _G["BT4Button1"]
    if not bar1 then return end

    local panel = CreateFrame("Frame", "LauringUIActionBarPanel", UIParent)
    panel:SetFrameStrata("LOW")
    module:StylePanel(panel)

    UpdatePanel(panel, bar1)

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("ACTIONBAR_SHOWGRID")
    eventFrame:RegisterEvent("ACTIONBAR_HIDEGRID")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:SetScript("OnEvent", function()
        UpdatePanel(panel, bar1)
    end)

    module.ActionBarPanel = panel
end
