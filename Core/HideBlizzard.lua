local _, ns = ...
local Core, Config, L, DB = unpack(ns)

function Core:Dummy()
    return
end

Core.HiddenFrame = CreateFrame("Frame")
Core.HiddenFrame:Hide()

function Core:HideObject()
    if self.UnregisterAllEvents then
        self:UnregisterAllEvents()
        self:SetParent(Core.HiddenFrame)
    else
        self.Show = self.Hide
    end
    self:Hide()
end

local blizzTextures = {
    "Inset",
    "inset",
    "InsetFrame",
    "LeftInset",
    "RightInset",
    "NineSlice",
    "BG",
    "Bg",
    "border",
    "Border",
    "Background",
    "BorderFrame",
    "bottomInset",
    "BottomInset",
    "bgLeft",
    "bgRight",
    "FilligreeOverlay",
    "PortraitOverlay",
    "ArtOverlayFrame",
    "Portrait",
    "portrait",
    "ScrollFrameBorder",
    "ScrollUpBorder",
    "ScrollDownBorder",
}

function Core:RemoveBlizzTextures(kill)
    local frameName = self.GetName and self:GetName()
    for _, texture in pairs(blizzTextures) do
        local blizzFrame = self[texture] or (frameName and _G[frameName .. texture])
        if blizzFrame then
            Core.RemoveBlizzTextures(blizzFrame, kill)
        end
    end

    if self.GetNumRegions then
        for i = 1, self:GetNumRegions() do
            local region = select(i, self:GetRegions())
            if region and region.IsObjectType and region:IsObjectType("Texture") then
                if kill and type(kill) == "boolean" then
                    Core.HideObject(region)
                elseif tonumber(kill) then
                    if kill == 0 then
                        region:SetAlpha(0)
                    elseif i ~= kill then
                        region:SetTexture("")
                        region:SetAtlas("")
                    end
                else
                    region:SetTexture("")
                    region:SetAtlas("")
                end
            end
        end
    end
end

function Core:HideDefaultRaidFrame()
    if CompactRaidFrameManager_SetSetting then
        CompactRaidFrameManager_SetSetting("IsShown", "0")
        UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:SetParent(Core.HiddenFrame)
    end
end

function Core:KillEditMode(object)
    object.HighlightSystem = Core.Dummy
    object.ClearHighlight = Core.Dummy
end