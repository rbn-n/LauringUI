local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

function module:CreateCentralBottomPanel()
    local actionBarPanel = module.ActionBarPanel
    local panelHeight = 20

    local panel = CreateFrame("Frame", "LauringUICentralBottomPanel", UIParent)
    panel:SetFrameStrata("LOW")
    panel:SetHeight(panelHeight)
    panel:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 5)

    module:StylePanel(panel)

    if actionBarPanel then
        local function SyncSize()
            panel:SetWidth(actionBarPanel:GetWidth())
        end
        SyncSize()
        actionBarPanel:HookScript("OnSizeChanged", SyncSize)
    else
        panel:SetWidth(850)
    end

    module.CentralBottomPanel = panel
end
