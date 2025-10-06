local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local tip = CreateFrame("GameTooltip", "LauringUI_ScanTooltip", nil, "GameTooltipTemplate")
Core.ScanTip = tip
-- tip:SetOwner(UIParent, "ANCHOR_NONE")

-- for i = 1, 10 do
--     local left = tip:CreateFontString("$parentTextLeft"..i, nil, "GameTooltipText")
--     local right = tip:CreateFontString("$parentTextRight"..i, nil, "GameTooltipText")
--     tip:AddFontStrings(left, right)
-- end

-- for i = 1, 5 do
--     tip["Texture"..i] = tip:CreateTexture("LauringUI_ScanTooltipTexture"..i, "ARTWORK")
-- end

-- Core.ScanTip = tip


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

local pendingNPCs, nameCache, callbacks = {}, {}, {}
local loadingStr = "..."
local pendingFrame = CreateFrame("Frame")
pendingFrame:Hide()
pendingFrame:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed > 1 then
        if next(pendingNPCs) then
            for npcID, count in pairs(pendingNPCs) do
                if count > 2 then
                    nameCache[npcID] = UNKNOWN
                    if callbacks[npcID] then
                        callbacks[npcID](UNKNOWN)
                    end
                    pendingNPCs[npcID] = nil
                else
                    local name = Core.GetNPCName(npcID, callbacks[npcID])
                    if name and name ~= loadingStr then
                        pendingNPCs[npcID] = nil
                    else
                        pendingNPCs[npcID] = pendingNPCs[npcID] + 1
                    end
                end
            end
        else
            self:Hide()
        end

        self.elapsed = 0
    end
end)

function Core.GetNPCName(npcID, callback)
    local name = nameCache[npcID]
    if not name then
        tip:SetOwner(UIParent, "ANCHOR_NONE")
        tip:SetHyperlink(format("unit:Creature-0-0-0-0-%d", npcID))
        name = _G.LauringUI_ScanTooltipTextLeft1:GetText() or loadingStr
        if name == loadingStr then
            if not pendingNPCs[npcID] then
                pendingNPCs[npcID] = 1
                pendingFrame:Show()
            end
        else
            nameCache[npcID] = name
        end
    end
    if callback then
        callback(name)
        callbacks[npcID] = callback
    end

    return name
end

local iLvlDB = {}
local itemLevelString = "^"..gsub(ITEM_LEVEL, "%%d", "")

function Core:InspectItemTextures()
    if not tip.gems then
        tip.gems = {}
    else
        wipe(tip.gems)
    end

    for i = 1, 5 do
        local tex = _G["LauringUI_ScanTooltipTexture"..i]
        local texture = tex and tex:IsShown() and tex:GetTexture()
        if texture then
            tip.gems[i] = texture
        end
    end

    return tip.gems
end

function Core:GetEnchantText(link, slotInfo)
    local enchantID = tonumber(strmatch(link, "item:%d+:(%d+):"))
    if enchantID then
        --[[for i = 1, tip:NumLines() do
            local line = _G["NDui_ScanTooltipTextLeft"..i]
            if not line then break end

            local text = line:GetText()
            if text then
                if i == 1 and text == RETRIEVING_ITEM_INFO then
                    return "tooSoon"
                elseif i ~= 1 then
                    local r, g, b = line:GetTextColor()
                    r = B:Round(r, 3)
                    g = B:Round(g, 3)
                    b = B:Round(b, 3)
                    if not (r == 1 and g == 1 and b == 1) then
                        return text
                    end
                end
            end
        end]]
        return "+"
    end
	end

function Core.GetItemLevel(link, arg1, arg2, fullScan)
    if fullScan then
        tip:SetOwner(UIParent, "ANCHOR_NONE")
        tip:SetInventoryItem(arg1, arg2)

        if not tip.slotInfo then tip.slotInfo = {} else wipe(tip.slotInfo) end

        local slotInfo = tip.slotInfo
        slotInfo.gems = Core:InspectItemTextures()
        slotInfo.enchantText = Core:GetEnchantText(link, slotInfo)

        return slotInfo
    else
        if iLvlDB[link] then return iLvlDB[link] end

        tip:SetOwner(UIParent, "ANCHOR_NONE")
        if arg1 and type(arg1) == "string" then
            tip:SetInventoryItem(arg1, arg2)
        elseif arg1 and type(arg1) == "number" then
            tip:SetBagItem(arg1, arg2)
        else
            tip:SetHyperlink(link)
        end

        local firstLine = _G.LauringUI_ScanTooltipTextLeft1:GetText()
        if firstLine == RETRIEVING_ITEM_INFO then
            return "tooSoon"
        end

        for i = 2, 5 do
            local line = _G["LauringUI_ScanTooltipTextLeft"..i]
            if not line then break end

            local text = line:GetText()
            local found = text and strfind(text, itemLevelString)
            if found then
                local level = strmatch(text, "(%d+)%)?$")
                iLvlDB[link] = tonumber(level)
                break
            end
        end

        return iLvlDB[link]
    end
end