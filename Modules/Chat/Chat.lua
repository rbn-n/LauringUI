local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:RegisterModule("Chat")

local chatWidth, chatHeight = 575, 250 -- You can adjust these defaults

local function StyleChatPanel(name, chatFrame)
	local panel = CreateFrame("Frame", name, UIParent)
	panel:SetFrameStrata(chatFrame:GetFrameStrata())
	panel:SetFrameLevel(chatFrame:GetFrameLevel() - 1)
	Core:GetModule("Infobars"):StylePanel(panel)
	return panel
end

local function PositionChatFrame(frame, anchorTo, offsetX, offsetY)
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", anchorTo, "TOPLEFT", offsetX, offsetY)
	frame:SetWidth(chatWidth)
	frame:SetHeight(chatHeight)
end

local function WatchFrame(panel, chatFrame)
	local function update()
		panel:SetSize(chatFrame:GetWidth(), chatFrame:GetHeight())
		panel:ClearAllPoints()
		local point, relativeTo, relativePoint, x, y = chatFrame:GetPoint()
		if point then
			panel:SetPoint(point, relativeTo, relativePoint, x, y)
		end
	end

	update()

	chatFrame:HookScript("OnSizeChanged", update)
	chatFrame:HookScript("OnUpdate", update)
	chatFrame:HookScript("OnShow", function() panel:Show() update() end)
	chatFrame:HookScript("OnHide", function() panel:Hide() end)
end

function module:OnLogin()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		frame:SetSize(chatWidth, chatHeight)
	end

	local cf1 = ChatFrame1
	local leftPanel = Core:GetModule("Infobars").LeftBottomPanel
	PositionChatFrame(cf1, leftPanel, 0, 6)

	local leftChatPanel = StyleChatPanel("LauringUIChatPanelLeft", cf1)
	WatchFrame(leftChatPanel, cf1)

	local cf5 = ChatFrame5
	if cf5 and cf5:IsShown() then
		local rightPanel = Core:GetModule("Infobars").RightBottomPanel
		PositionChatFrame(cf5, rightPanel, 0, 6)

		local rightChatPanel = StyleChatPanel("LauringUIChatPanelRight", cf5)
		WatchFrame(rightChatPanel, cf5)
	end
end
