local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:RegisterModule("Chat")

local BNGetFriendInfoByID, BNGetGameAccountInfo, InviteToGroup = BNGetFriendInfoByID, BNGetGameAccountInfo, InviteToGroup
local GetItemStats = GetItemStats

local maxLines = 2048
local chatEditboxes = {}

local function GetSocketTexture(socket, count)
	return strrep("|TInterface\\ItemSocketingFrame\\UI-EmptySocket-"..socket..":0|t", count)
end

local sockets = {
	["BLUE"] = true,
	["RED"] = true,
	["YELLOW"] = true,
	["COGWHEEL"] = true,
	["HYDRAULIC"] = true,
	["META"] = true,
	["PRISMATIC"] = true,
}

function module.IsItemWithGem(link)
	local text = ""
	local stats = GetItemStats(link)
	for stat, count in pairs(stats) do
		local socket = strmatch(stat, "EMPTY_SOCKET_(%S+)")
		if socket and sockets[socket] then
			text = text..GetSocketTexture(socket, count)
		end
	end
	return text
end

local function StyleChatPanel(name, chatFrame)
	local panel = CreateFrame("Frame", name, UIParent)
	panel:SetFrameStrata(chatFrame:GetFrameStrata())
	panel:SetFrameLevel(chatFrame:GetFrameLevel() - 1)
	Core:StyleFrame(panel)
	return panel
end

local function PositionChatFrame(frame, anchorTo, offsetX, offsetY)
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", anchorTo, "TOPLEFT", offsetX, offsetY)
	frame:SetWidth(Config.DB.Chat.Width)
	frame:SetHeight(Config.DB.Chat.Height)
end

local function WatchFrame(frame, frameToWatch, onHideAndShow)
	local function update()
		frame:SetSize(frameToWatch:GetWidth(), frameToWatch:GetHeight())
		frame:ClearAllPoints()

		local point, relativeTo, relativePoint, x, y = frameToWatch:GetPoint()
		if point then
			frame:SetPoint(point, relativeTo, relativePoint, x, y)
		end
	end

	update()

	frameToWatch:HookScript("OnSizeChanged", update)
	frameToWatch:HookScript("OnUpdate", update)

	if onHideAndShow then
		frameToWatch:HookScript("OnShow", function() frame:Show() update() end)
		frameToWatch:HookScript("OnHide", function() frame:Hide() end)
	end
end

function module:UpdateChatSize()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		frame:SetSize(Config.DB.Chat.Width, Config.DB.Chat.Height)
	end
end

local function UpdateEditBoxAnchor(editBox)
	local parent = editBox.__owner
	editBox:ClearAllPoints()
	local leftBottomPanel = Core:GetModule("Infobars").LeftBottomPanel
	if Config.DB["Chat"]["BottomEditBox"] then
		WatchFrame(editBox, leftBottomPanel)
	else
		editBox:SetSize(leftBottomPanel:GetWidth(), leftBottomPanel:GetHeight())
		editBox:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 4, 26)
		editBox:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -15, 50)
	end
end

local function UpdateEditboxFont(editbox)
	editbox:SetFont(DB.Font[1], Config.DB["Chat"]["EditBoxFontSize"], "")
	editbox.header:SetFont(DB.Font[1], Config.DB["Chat"]["EditBoxFontSize"], "")
end

function module:ToggleEditBoxAnchor()
	for _, editBox in pairs(chatEditboxes) do
		UpdateEditboxFont(editBox)
		UpdateEditBoxAnchor(editBox)
	end
end

function module:TabSetAlpha(alpha)
	if self.glow:IsShown() and alpha ~= 1 then
		self:SetAlpha(1)
	elseif alpha < .4 then
		self:SetAlpha(.4)
	end
end

function module:ToggleChatFrameTextures(frame)
	frame:DisableDrawLayer("BORDER")
	frame:DisableDrawLayer("BACKGROUND")
end

function module:SkinChatFrame()
	if not self or self.styled then return end

	local name = self:GetName()
	local _, fontSize = self:GetFont()
	self:SetFont(DB.Font[1], fontSize, DB.Font[3])
	self:SetShadowColor(0, 0, 0, 0)

	self:SetClampRectInsets(0, 0, 0, 0)
	self:SetClampedToScreen(false)
	if self:GetMaxLines() < maxLines then
		self:SetMaxLines(maxLines)
	end

	local editBox = _G[name.."EditBox"]
	editBox:SetAltArrowKeyMode(false)
	editBox:SetClampedToScreen(true)
	editBox.__owner = self
	UpdateEditBoxAnchor(editBox)
	Core.RemoveBlizzTextures(editBox, 2)
	Core:StyleFrame(editBox)
	UpdateEditboxFont(editBox)
	tinsert(chatEditboxes, editBox)

	local lang = _G[name.."EditBoxLanguage"]
	lang:GetRegions():SetAlpha(0)
	lang:SetPoint("TOPLEFT", editBox, "TOPRIGHT", 5, 0)
	lang:SetPoint("BOTTOMRIGHT", editBox, "BOTTOMRIGHT", 29, 0)
	Core.SetBD(lang)

	local tab = _G[name.."Tab"]
	tab:SetAlpha(1)
	tab.Text:SetFont(DB.Font[1], DB.Font[2]+2, DB.Font[3])
	tab.Text:SetShadowColor(0, 0, 0, 0)
	Core.RemoveBlizzTextures(tab, 7)
	hooksecurefunc(tab, "SetAlpha", module.TabSetAlpha)

	local minimize = _G[name.."MinimizeButton"]
	if minimize then
		Core.ReskinCollapse(minimize)
		minimize:GetNormalTexture():SetAlpha(0)
		minimize:GetPushedTexture():SetAlpha(0)
		minimize.__texture:DoCollapse(false)
		minimize:ClearAllPoints()
		minimize:SetPoint("CENTER", self, "TOPLEFT", -2, -3)
	end

	self.buttonFrame:SetAlpha(0)
	self.buttonFrame:SetScale(.0001)
	Core.HideObject(self.ScrollToBottomButton)
	module:ToggleChatFrameTextures(self)

	self.oldAlpha = self.oldAlpha or 0 -- fix blizz error, need reviewed

	if self == GeneralDockManager.primary then
		local messageFrame = CommunitiesFrame and CommunitiesFrame.Chat and CommunitiesFrame.Chat.MessageFrame
		if messageFrame then
			messageFrame:SetFont(DB.Font[1], fontSize, DB.Font[3])
		end
	end

	self.styled = true
end

function module:ReskinChat()
	for i = 1, NUM_CHAT_WINDOWS do
		local chatframe = _G["ChatFrame"..i]
		module.SkinChatFrame(chatframe)
		ChatFrame_RemoveMessageGroup(chatframe, "CHANNEL")
	end

	hooksecurefunc("FCF_OpenTemporaryWindow", function()
		for _, chatFrameName in ipairs(CHAT_FRAMES) do
			local frame = _G[chatFrameName]
			if frame.isTemporary then
				module.SkinChatFrame(frame)
			end
		end
	end)
end

local function SetChatClassColors()
	for _, info in pairs(CHAT_CONFIG_CHAT_LEFT) do
		if info.type then
			SetChatColorNameByClass(info.type, true)
		end
	end
	local channels = {GetChannelList()}
	for i = 1, #channels, 3 do
		SetChatColorNameByClass("CHANNEL"..channels[i], true)
	end
end

local whisperList = {}
function module:UpdateWhisperKeywords()
	Core.SplitList(whisperList, Config.DB["Chat"]["WhisperInviteKeywords"], true)
end

function module.OnChatWhisper(event, ...)
	local msg, author, _, _, _, _, _, _, _, _, _, guid, presenceID = ...
	for word in pairs(whisperList) do
		if (not IsInGroup() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and strlower(msg) == strlower(word) then
			if event == "CHAT_MSG_BN_WHISPER" then
				local gameID = select(6, BNGetFriendInfoByID(presenceID))
				if gameID then
					local _, charName, _, realmName = BNGetGameAccountInfo(gameID)
					if CanCooperateWithGameAccount(gameID) and (not Config.DB["Chat"]["WhisperInviteGuildOnly"] or module:IsUnitInGuild(charName.."-"..realmName)) then
						BNInviteFriend(gameID)
					end
				end
			else
				if not Config.DB["Chat"]["WhisperInviteGuildOnly"] or IsGuildMember(guid) then
					InviteToGroup(author)
				end
			end
		end
	end
end

function module:WhisperInvite()
	if not Config.DB["Chat"]["WhisperInvite"] then return end
	module:UpdateWhisperKeywords()
	Core:RegisterEvent("CHAT_MSG_WHISPER", module.OnChatWhisper)
	Core:RegisterEvent("CHAT_MSG_BN_WHISPER", module.OnChatWhisper)
end

local function SetFontForExtraElementsInChatTabMenu()
	-- Extra elements in chat tab menu
	do
		-- Font size
		local function IsSelected(height)
			local _, fontHeight = FCF_GetCurrentChatFrame():GetFont()
			return height == floor(fontHeight + .5)
		end

		local function SetSelected(height)
			FCF_SetChatWindowFontSize(nil, FCF_GetChatFrameByID(CURRENT_CHAT_FRAME_ID), height)
		end

		Menu.ModifyMenu("MENU_FCF_TAB", function(self, rootDescription, data)
			local fontSizeSubmenu = rootDescription:CreateButton(DB.InfoColor..L["MoreFontSize"])
			for i = 10, 30 do
				fontSizeSubmenu:CreateRadio((format(FONT_SIZE_TEMPLATE, i)), IsSelected, SetSelected, i)
			end
		end)
	end
end

function module:OnLogin()
	self:ReskinChat()

	SetCVar("chatStyle", "classic")
	SetCVar("chatMouseScroll", 1) -- enable mousescroll
	CombatLogQuickButtonFrame_CustomTexture:SetTexture(nil)

	SetChatClassColors()
	module:ChannelRename()
	module:ChatCopy()
	module:UrlCopy()
	module:WhisperInvite()

	self:UpdateChatSize()

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
		WatchFrame(rightChatPanel, cf5, true)
	end

	SetFontForExtraElementsInChatTabMenu()
end
