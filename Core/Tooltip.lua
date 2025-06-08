local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local tip = CreateFrame("GameTooltip", "LauringUI_ScanTooltip", nil, "GameTooltipTemplate")
tip:SetOwner(UIParent, "ANCHOR_NONE")

for i = 1, 10 do
    local left = tip:CreateFontString("$parentTextLeft"..i, nil, "GameTooltipText")
    local right = tip:CreateFontString("$parentTextRight"..i, nil, "GameTooltipText")
    tip:AddFontStrings(left, right)
end

for i = 1, 5 do
    tip["Texture"..i] = tip:CreateTexture("LauringUI_ScanTooltipTexture"..i, "ARTWORK")
end

Core.ScanTip = tip


function Core:HideTooltip()
    GameTooltip:Hide()
end

local function Tooltip_OnEnter(self)
    GameTooltip:SetOwner(self, self.anchor)
    GameTooltip:ClearLines()
    if self.title then
        GameTooltip:AddLine(self.title)
    end
    if tonumber(self.text) then
        GameTooltip:SetSpellByID(self.text)
    elseif self.text then
        local r, g, b = 1, 1, 1
        if self.color == "class" then
            r, g, b = DB.r, DB.g, DB.b
        elseif self.color == "system" then
            r, g, b = 1, .8, 0
        elseif self.color == "info" then
            r, g, b = .6, .8, 1
        end
        GameTooltip:AddLine(self.text, r, g, b, 1)
    end
    GameTooltip:Show()
end

function Core:AddTooltip(anchor, text, color, showTips)
    self.anchor = anchor
    self.text = text
    self.color = color
    if showTips then self.title = L["Tips"] end
    self:SetScript("OnEnter", Tooltip_OnEnter)
    self:SetScript("OnLeave", Core.HideTooltip)
end
