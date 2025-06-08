local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")


function module:CreateRightBottomPanel()
    local panelHeight = 20
    local panelOffsetX, panelOffsetY = -5, 5

    local panel = CreateFrame("Frame", "LauringUIRightBottomPanel", UIParent)
    panel:SetHeight(panelHeight)
    panel:SetFrameStrata("LOW")

    panel:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", panelOffsetX, panelOffsetY)
    module:StylePanel(panel)

    local leftPanel = module.LeftBottomPanel
    if leftPanel then
        panel:SetWidth(leftPanel:GetWidth())

        leftPanel:HookScript("OnSizeChanged", function()
            panel:SetWidth(leftPanel:GetWidth())
        end)
    end

    module.RightBottomPanel = panel
end
