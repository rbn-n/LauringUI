local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")
local guiTab, guiFrame = {}, nil
G.GuiPage = {}
G.NeedUIReload = nil

local pairs, ipairs, tinsert = pairs, ipairs, tinsert

local function ScrollBarHook(self, delta)
	local scrollBar = self.ScrollBar
	scrollBar:SetValue(scrollBar:GetValue() - delta * 35)
end

local function SelectTab(tabName)
	for name in pairs(G.TabList) do
		if tabName == name then
			guiTab[name]:SetBackdropColor(DB.r, DB.g, DB.b, .3)
			guiTab[name].checked = true
			G.GuiPage[name]:Show()
		else
			guiTab[name]:SetBackdropColor(0, 0, 0, .3)
			guiTab[name].checked = false
			G.GuiPage[name]:Hide()
		end
	end
end

local function TabOnClick(self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
	SelectTab(self.index)
end

local function TabOnEnter(self)
	if self.checked then return end
	self:SetBackdropColor(DB.r, DB.g, DB.b, .3)
end

local function TabOnLeave(self)
	if self.checked then return end
	self:SetBackdropColor(0, 0, 0, .3)
end

function CreateTab(parent, i, name)
	local tab = CreateFrame("Button", nil, parent, "BackdropTemplate")
	tab:SetPoint("TOPLEFT", 20, -30*i - 20 + Config.PixelMultiplexer)
	tab:SetSize(130, 28)
	Core.CreateBD(tab, .3)
	Core.CreateFS(tab, 15, name, "system", "LEFT", 10, 0)
	tab.index = name

	tab:SetScript("OnClick", TabOnClick)
	tab:SetScript("OnEnter", TabOnEnter)
	tab:SetScript("OnLeave", TabOnLeave)

	return tab
end

local orderedTabs = {
    L["UnitFrames"],
    L["GroupFrames"],
    L["Castbars"],
    L["Bags"],
    L["Chat"],
    L["Loot"],
    L["Maps"],
    L["Quests"],
    L["Tooltips"],
    L["Quality of Life"],
    L["Profile"],
}

local function OpenGUI()
    if guiFrame then guiFrame:Show() return end

    guiFrame = CreateFrame("Frame", "LauringUIGui", UIParent)
    tinsert(UISpecialFrames, "LauringUIGui")
    guiFrame:SetSize(800, 600)
	guiFrame:SetPoint("CENTER")
	guiFrame:SetFrameStrata("HIGH")
	guiFrame:SetFrameLevel(10)
    Core.CreateMF(guiFrame)
    Core:CreateBackdrop(guiFrame)
	Core:CreateBorder(guiFrame, 1.1)
	Core:CreateShadow(guiFrame, 5)
    Core.CreateFS(guiFrame, 18, "LauringUI", true, "TOP", 0, -10)

    local unlock = Core.CreateButton(guiFrame, 130, 20, "Unlock UI")
	unlock:SetPoint("BOTTOMLEFT", 20, 15)
	unlock:SetScript("OnClick", function()
		guiFrame:Hide()
		SlashCmdList["LAURINGUI_MOVER"]()
	end)

    local close = Core.CreateButton(guiFrame, 80, 20, CLOSE)
	close:SetPoint("BOTTOMRIGHT", -20, 15)
	close:SetScript("OnClick", function() guiFrame:Hide() end)

    local ok = Core.CreateButton(guiFrame, 80, 20, OKAY)
	ok:SetPoint("RIGHT", close, "LEFT", -5, 0)
	ok:SetScript("OnClick", function()
		Core:SetupUIScale()
		guiFrame:Hide()
		StaticPopup_Show("RELOAD_LAURINGUI")
	end)

	for i, name in ipairs(orderedTabs) do
		guiTab[name] = CreateTab(guiFrame, i, name)

		G.GuiPage[name] = CreateFrame("ScrollFrame", nil, guiFrame, "UIPanelScrollFrameTemplate")
		G.GuiPage[name]:SetPoint("TOPLEFT", 160, -50)
		G.GuiPage[name]:SetSize(610, 500)
		Core.CreateBDFrame(G.GuiPage[name], .3)
		G.GuiPage[name]:Hide()

		G.GuiPage[name].child = CreateFrame("Frame", nil, G.GuiPage[name])
		G.GuiPage[name].child:SetSize(610, 1)
		G.GuiPage[name]:SetScrollChild(G.GuiPage[name].child)
		Core.ReskinScroll(G.GuiPage[name].ScrollBar)
		G.GuiPage[name]:SetScript("OnMouseWheel", ScrollBarHook)

		G:CreateOption(name, G.GuiPage)
	end

    G:CreateProfileGUI(G.GuiPage["Profile"])

    local function showLater(event)
		if event == "PLAYER_REGEN_DISABLED" then
			if guiFrame:IsShown() then
				guiFrame:Hide()
				Core:RegisterEvent("PLAYER_REGEN_ENABLED", showLater)
			end
		else
			guiFrame:Show()
			Core:UnregisterEvent(event, showLater)
		end
	end
	Core:RegisterEvent("PLAYER_REGEN_DISABLED", showLater)

	SelectTab("UnitFrames")
end

function G:OnLogin()
	SLASH_LAURINGUI1 = "/lauring"
	SLASH_LAURINGUI2 = "/lauringui"
	SlashCmdList["LAURINGUI"] = function()
		if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end
		OpenGUI()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	end
end

