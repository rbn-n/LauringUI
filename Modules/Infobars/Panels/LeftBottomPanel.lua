local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

function module:CreateLeftBottomPanel()
    local chatFrame = ChatFrame1
    local panelHeight = 20
    local panelOffsetX, panelOffsetY = 5, 5 -- distance from screen edges

    local panel = CreateFrame("Frame", "LauringUILeftBottomPanel", UIParent)
    panel:SetHeight(panelHeight)
    panel:SetWidth(chatFrame:GetWidth())
    panel:SetFrameStrata("LOW")

    module:StylePanel(panel)

    panel:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", panelOffsetX, panelOffsetY)

    chatFrame:HookScript("OnSizeChanged", function()
        panel:SetWidth(chatFrame:GetWidth())
    end)

    module.LeftBottomPanel = panel
end
