local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local Loot = Core:RegisterModule("Loot")
----------------------------
-- Improved Loot Frame, by Cybeloras
-- RayUI Loot, by fgprodigal
----------------------------
local _G = getfenv(0)
local select, format = select, format
local min, max, floor, upper = math.min, math.max, math.floor, string.upper
local GetNumLootItems, GetLootSlotLink, GetLootSlotInfo = GetNumLootItems, GetLootSlotLink, GetLootSlotInfo
local LootButton1, LootFrame_Update, LootFrameCloseButton = LootButton1, LootFrame_Update, LootFrameCloseButton

local AceTimer = _G.LibStub("AceTimer-3.0")

function AceTimer:WaitFunc(elapse)
    local i = 1
    while i <= #AceTimer.WaitTable do
        local data = AceTimer.WaitTable[i]
        if data[1] > elapse then
            data[1], i = data[1] - elapse, i + 1
        else
            tremove(AceTimer.WaitTable, i)
            data[2](unpack(data[3]))

            if #AceTimer.WaitTable == 0 then
                AceTimer.WaitFrame:Hide()
            end
        end
    end
end

AceTimer.WaitTable = {}
AceTimer.WaitFrame = CreateFrame("Frame", "LauringUI_WaitFrame", _G.UIParent)
AceTimer.WaitFrame:SetScript("OnUpdate", AceTimer.WaitFunc)

function AceTimer:Delay(delay, func, ...)
    if type(delay) ~= "number" or type(func) ~= "function" then
        return false
    end

    if delay < 0.01 then delay = 0.01 end

    if select("#", ...) <= 0 then
        C_Timer.After(delay, func)
    else
        tinsert(AceTimer.WaitTable,{delay,func,{...}})
        AceTimer.WaitFrame:Show()
    end

    return true
end

local function AnnounceLoot(chn)
	for i = 1, GetNumLootItems() do
		local link = GetLootSlotLink(i)
		local quality = select(5, GetLootSlotInfo(i))
		if link and quality and quality >= Config.DB["Loot"]["AnnounceRarity"] then
			SendChatMessage(format("- %s", link), chn)
		end
	end
end

local function Announce(chn)
	local nums = GetNumLootItems()
	if nums == 0 then return end
	if Config.DB["Loot"]["AnnounceTitle"] then
		if UnitIsPlayer("target") or not UnitExists("target") then
			SendChatMessage(format("*** %s ***", L["Loots in chest"]), chn)
		else
			SendChatMessage(format("*** %s%s ***", UnitName("target"), L["Loots"]), chn)
		end
	end
	if IsInInstance() or chn ~= "say" then
		AceTimer:Delay(.1, AnnounceLoot, chn)
	else
		AnnounceLoot(chn)
	end
end

function Loot:OnLogin()
	if not Config.DB["Loot"]["Enable"] then return end

	local width = 200
	local spacing = 4
	local buttonHeight = LootButton1:GetHeight() + spacing
	local baseHeight = LootFrame:GetHeight() - (buttonHeight * LOOTFRAME_NUMBUTTONS) - 41

	LootFrame:SetWidth(width)
	LootFrame.title = LootFrame:CreateFontString(nil, "OVERLAY")
	LootFrame.title:SetFont(DB.Font[1], DB.Font[2]+2, DB.Font[3])
	LootFrame.title:SetPoint("TOPLEFT", 3, -4)
	LootFrame.title:SetPoint("TOPRIGHT", -105, -4)
	LootFrame.title:SetHeight(16)
	LootFrame.title:SetJustifyH("LEFT")

	-- hide blizz loot frame title
	for i = 1, LootFrame:GetNumRegions() do
		local region = select(i, LootFrame:GetRegions())
		if region.GetText and region:GetText() == ITEMS then
			region:Hide()
		end
	end

	hooksecurefunc("LootFrame_Show", function(self)
		local maxButtons = floor(UIParent:GetHeight() / LootButton1:GetHeight() * 0.7)

		local num = GetNumLootItems()

		if self.AutoLootTable then
			num = #self.AutoLootTable
		end

		self.AutoLootDelay = 0.4 + (num * 0.05)

		num = min(num, maxButtons)

		self:SetHeight(baseHeight + (max(num, 1) * buttonHeight))

		for i = 1, num do
			local button = _G["LootButton"..i]
			if i == 1 then
				button:ClearAllPoints()
				button:SetPoint("TOPLEFT", 9, -30)
			end
			if i > LOOTFRAME_NUMBUTTONS then
				if not button then
					button = CreateFrame(ItemButtonMixin and "ItemButton" or "Button", "LootButton"..i, self, "LootButtonTemplate", i)
				end
				LOOTFRAME_NUMBUTTONS = i
			end
			if i > 1 then
				button:ClearAllPoints()
				button:SetPoint("TOP", "LootButton"..(i-1), "BOTTOM", 0, -spacing)
			end

			local text = _G["LootButton"..i.."Text"]
			text:SetSize(140,38)
		end

		if UnitExists("target") and UnitIsDead("target") then
			LootFrame.title:SetText(UnitName("target"))
		else
			LootFrame.title:SetText(ITEMS)
		end

		if GetCVar("lootUnderMouse") == "1" then
			local x, y = GetCursorPosition()
			x = x / self:GetEffectiveScale()
			y = y / self:GetEffectiveScale()
			local posX = x - 175
			local posY = y + 25
			if num > 0 then
				posX = x - 40
				posY = y + 55
				posY = posY + 40
			end
			if posY < 350 then
				posY = 350
			end
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", posX, posY - 38)
		end

		LootFrame_Update()
	end)

	hooksecurefunc("LootFrame_UpdateButton", function(index)
		local bu = _G["LootButton"..index]
		if bu and not bu.styled then
			for _, child in pairs {bu:GetChildren()} do
				if (child.backdropInfo and child.backdropInfo.bgFile == DB.bdTex) and (not bu.bg or bu.bg ~= child) then
					child:SetPoint("BOTTOMRIGHT", LootFrame:GetWidth() - 55, 0)
					bu.styled = true
					break
				end
			end
		end
	end)

	if not Config.DB["Loot"]["Announce"] then return end

	local chn = { "say", "guild", "party", "raid"}
	local chncolor = {
		say = { 1, 1, 1},
		guild = { .25, 1, .25},
		party = { 2/3, 2/3, 1},
		raid = { 1, .5, 0},
	}

	LootFrame.announce = {}
	for i = 1, #chn do
		LootFrame.announce[i] = CreateFrame("Button", nil, LootFrame)
		LootFrame.announce[i]:SetSize(17, 17)
		Core.PixelIcon(LootFrame.announce[i], DB.StatusBarTexture, true)
		Core.CreateSD(LootFrame.announce[i])
		LootFrame.announce[i].Icon:SetVertexColor(unpack(chncolor[chn[i]]))
		LootFrame.announce[i]:SetPoint("RIGHT", i==1 and LootFrameCloseButton or LootFrame.announce[i-1], "LEFT", -3, 0)
		LootFrame.announce[i]:SetScript("OnClick", function() Announce(chn[i]) end)
		LootFrame.announce[i]:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
			GameTooltip:ClearLines()
			GameTooltip:AddLine(L["Announce Loots to"].._G[upper(chn[i])])
			GameTooltip:Show()
		end)
		LootFrame.announce[i]:SetScript("OnLeave", Core.HideTooltip)
	end
end