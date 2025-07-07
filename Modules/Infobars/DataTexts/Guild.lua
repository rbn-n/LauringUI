local _, ns = ...
local Core, C, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local guildTable = {}
local gName, gOnline, gRank

local wipe, sort, format = table.wipe, table.sort, format
local SELECTED_DOCK_FRAME = SELECTED_DOCK_FRAME
local LEVEL_ABBR, CLASS_ABBR, NAME, ZONE, RANK, REMOTE_CHAT = LEVEL_ABBR, CLASS_ABBR, NAME, ZONE, RANK, REMOTE_CHAT
local IsAltKeyDown, IsShiftKeyDown, InviteToGroup, Ambiguate = IsAltKeyDown, IsShiftKeyDown, InviteToGroup, Ambiguate
local MailFrame, MailFrameTab_OnClick, SendMailNameEditBox = MailFrame, MailFrameTab_OnClick, SendMailNameEditBox
local ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat, ChatFrame_OpenChat, ChatFrame_GetMobileEmbeddedTexture = ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat, ChatFrame_OpenChat, ChatFrame_GetMobileEmbeddedTexture
local GetNumGuildMembers, GetGuildInfo, GetGuildRosterInfo, IsInGuild = GetNumGuildMembers, GetGuildInfo, GetGuildRosterInfo, IsInGuild
local GetQuestDifficultyColor, GetRealZoneText, UnitInRaid, UnitInParty = GetQuestDifficultyColor, GetRealZoneText, UnitInRaid, UnitInParty
local HybridScrollFrame_GetOffset, HybridScrollFrame_Update = HybridScrollFrame_GetOffset, HybridScrollFrame_Update
local C_GuildInfo_GuildRoster = C_GuildInfo.GuildRoster

local numMembers = 0

local function RefreshGuildPanel()
	C_GuildInfo_GuildRoster()

	wipe(guildTable)
	local count = 0
	local total, numOnline, allOnline = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")

	gName:SetText("|cff0099ff<"..(guildName or "")..">")
	gOnline:SetText(format(DB.InfoColor.."%s:".." %d/%d", GUILD_ONLINE_LABEL, (allOnline or numOnline), total))
	gRank:SetText(DB.InfoColor..RANK..": "..(guildRank or ""))

	for i = 1, total do
		local name, _, _, level, _, zone, _, _, connected, status, class, _, _, mobile = GetGuildRosterInfo(i)
		if connected or mobile then
			if mobile and not connected then
				zone = REMOTE_CHAT
				if status == 1 then
					status = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t"
				elseif status == 2 then
					status = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t"
				else
					status = ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)
				end
			else
				if status == 1 then
					status = DB.AFKTex
				elseif status == 2 then
					status = DB.DNDTex
				else
					status = " "
				end
			end
			if not zone then zone = UNKNOWN end

			count = count + 1

			if not guildTable[count] then guildTable[count] = {} end
			guildTable[count][1] = level
			guildTable[count][2] = class
			guildTable[count][3] = Ambiguate(name, "none")
			guildTable[count][4] = zone
			guildTable[count][5] = status
		end
	end

	numMembers = count
end

local function UpdateInfoFrameAnchor(self)
	local relFrom, relTo, offset = module:GetTooltipAnchor(self)
	module.GuildFrame:ClearAllPoints()
	module.GuildFrame:SetPoint(relFrom, self, relTo, 0, offset)
end

local function IsHidablePanel(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > .1 then
		if not module.GuildFrame:IsMouseOver() then
			self:Hide()
			self:SetScript("OnUpdate", nil)
		end

		self.timer = 0
	end
end

local function UpdateGuildPanelButton(button)
	local index = button.index
	local level, class, name, zone, status = unpack(guildTable[index])

	local levelcolor = Core.HexRGB(GetQuestDifficultyColor(level))
	button.level:SetText(levelcolor..level)

	Core.ClassIconTexCoord(button.class, class)

	local namecolor = Core.HexRGB(Core.ClassColor(class))
	button.name:SetText(namecolor..name..status)

	local zonecolor = DB.GreyColor
	if UnitInRaid(name) or UnitInParty(name) then
		zonecolor = DB.InfoColor
	elseif GetRealZoneText() == zone then
		zonecolor = "|cff4cff4c"
	end
	button.zone:SetText(zonecolor..zone)
end

local function UpdateGuildPanel()
	local scrollFrame = module.GuildFrame.scrollFrame
	local usedHeight = 0
	local buttons = scrollFrame.buttons
	local height = scrollFrame.buttonHeight
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for i = 1, #buttons do
		local button = buttons[i]
		local index = offset + i
		if index <= numMembers then
			button.index = index
			UpdateGuildPanelButton(button)
			usedHeight = usedHeight + height
			button:Show()
		else
			button.index = nil
			button:Hide()
		end
	end
	HybridScrollFrame_Update(scrollFrame, numMembers * height, usedHeight)
end

local function RosterButtonOnClick(self, btn)
	local name = guildTable[self.index][3]
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			InviteToGroup(name)
		elseif IsShiftKeyDown() then
			if MailFrame:IsShown() then
				MailFrameTab_OnClick(nil, 2)
				SendMailNameEditBox:SetText(name)
				SendMailNameEditBox:HighlightText()
			else
				local editBox = ChatEdit_ChooseBoxForSend()
				local hasText = (editBox:GetText() ~= "")
				ChatEdit_ActivateChat(editBox)
				editBox:Insert(name)
				if not hasText then editBox:HighlightText() end
			end
		end
	else
		ChatFrame_OpenChat("/w "..name.." ", SELECTED_DOCK_FRAME)
	end
end


local function CreateButton(parent, index)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(305, 20)
	button:SetPoint("TOPLEFT", 0, - (index-1) *20)
	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(DB.r, DB.g, DB.b, .2)

	button.level = Core.CreateFS(button, 13, "Level", false)
	button.level:SetPoint("TOP", button, "TOPLEFT", 16, -4)
	button.class = button:CreateTexture(nil, "ARTWORK")
	button.class:SetPoint("LEFT", 35, 0)
	button.class:SetSize(16, 16)
	button.class:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
	button.name = Core.CreateFS(button, 13, "Name", false, "LEFT", 65, 0)
	button.name:SetPoint("RIGHT", button, "LEFT", 185, 0)
	button.name:SetJustifyH("LEFT")
	button.zone = Core.CreateFS(button, 13, "Zone", false, "RIGHT", -2, 0)
	button.zone:SetPoint("LEFT", button, "RIGHT", -120, 0)
	button.zone:SetJustifyH("RIGHT")

	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", RosterButtonOnClick)

	return button
end

local function OnMouseWheel(self, delta)
	local scrollBar = self.scrollBar
	local step = delta * self.buttonHeight
	if IsShiftKeyDown() then
		step = step * 15
	end
	scrollBar:SetValue(scrollBar:GetValue() - step)
	UpdateGuildPanel()
end

local function SortRosters(a, b)
	if a and b then
		return a[1] < b[1]
	end
end

local function SortGuildPanel()
	sort(guildTable, SortRosters)
	UpdateGuildPanel()
end

local function OnEvent(self, event, arg1)
	if not IsInGuild() then
		self.Text:SetText(GUILD..": "..DB.MyColor..NONE)
		return
	end

	if event == "GUILD_ROSTER_UPDATE" then
		if arg1 then C_GuildInfo_GuildRoster() end
	end

	local _, numOnline, allOnline = GetNumGuildMembers()
	self.Text:SetText(GUILD..": "..DB.MyColor..(allOnline or numOnline))

	if module.GuildFrame and module.GuildFrame:IsShown() then
		RefreshGuildPanel()
		SortGuildPanel()
	end
end

local function InitGuildPanel(self)
	if module.GuildFrame then
		module.GuildFrame:Show()
		UpdateInfoFrameAnchor(self)
		return
	end

	module.GuildFrame = CreateFrame("Frame", "LauringUIGuildInfobar", self)
	module.GuildFrame:SetSize(335, 495)
	UpdateInfoFrameAnchor(self)
	module.GuildFrame:SetClampedToScreen(true)
	module.GuildFrame:SetFrameStrata("TOOLTIP")
	local bg = Core.SetBD(module.GuildFrame)
	bg:SetBackdropColor(0, 0, 0, .5)

	module.GuildFrame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", IsHidablePanel)
	end)

	gName = Core.CreateFS(module.GuildFrame, 16, "Guild", true, "TOPLEFT", 15, -10)
	gOnline = Core.CreateFS(module.GuildFrame, 13, "Online", false, "TOPLEFT", 15, -35)
	gRank = Core.CreateFS(module.GuildFrame, 13, "Rank", false, "TOPLEFT", 15, -51)

	local bu = {}
	local width = {30, 35, 126, 126}
	for i = 1, 4 do
		bu[i] = CreateFrame("Button", nil, module.GuildFrame)
		bu[i]:SetSize(width[i], 22)
		bu[i]:SetFrameLevel(module.GuildFrame:GetFrameLevel() + 3)
		if i == 1 then
			bu[i]:SetPoint("TOPLEFT", 12, -75)
		else
			bu[i]:SetPoint("LEFT", bu[i-1], "RIGHT", -2, 0)
		end
		bu[i].HL = bu[i]:CreateTexture(nil, "HIGHLIGHT")
		bu[i].HL:SetAllPoints(bu[i])
		bu[i].HL:SetColorTexture(DB.r, DB.g, DB.b, .2)
		bu[i].index = i
		bu[i]:SetScript("OnClick", SortGuildPanel)
	end
	Core.CreateFS(bu[1], 13, LEVEL_ABBR)
	Core.CreateFS(bu[2], 13, CLASS_ABBR)
	Core.CreateFS(bu[3], 13, NAME, false, "LEFT", 5, 0)
	Core.CreateFS(bu[4], 13, ZONE, false, "RIGHT", -5, 0)

	Core.CreateFS(module.GuildFrame, 13, DB.LineString, false, "BOTTOMRIGHT", -12, 58)
	local whspInfo = DB.InfoColor..DB.RightButton..L["Whisper"]
	Core.CreateFS(module.GuildFrame, 13, whspInfo, false, "BOTTOMRIGHT", -15, 42)
	local invtInfo = DB.InfoColor.."ALT +"..DB.LeftButton..L["Invite"]
	Core.CreateFS(module.GuildFrame, 13, invtInfo, false, "BOTTOMRIGHT", -15, 26)
	local copyInfo = DB.InfoColor.."SHIFT +"..DB.LeftButton..L["Copy Name"]
	Core.CreateFS(module.GuildFrame, 13, copyInfo, false, "BOTTOMRIGHT", -15, 10)

	local scrollFrame = CreateFrame("ScrollFrame", "LauringUIGuildInfobarScrollFrame", module.GuildFrame, "HybridScrollFrameTemplate")
	scrollFrame:SetSize(305, 320)
	scrollFrame:SetPoint("TOPLEFT", 10, -100)
	module.GuildFrame.scrollFrame = scrollFrame

	local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
	scrollBar.doNotHide = true
	Core.ReskinScroll(scrollBar)
	scrollFrame.scrollBar = scrollBar

	local scrollChild = scrollFrame.scrollChild
	local numButtons = 16 + 1
	local buttonHeight = 22
	local buttons = {}
	for i = 1, numButtons do
		buttons[i] = CreateButton(scrollChild, i)
	end

	scrollFrame.buttons = buttons
	scrollFrame.buttonHeight = buttonHeight
	scrollFrame.update = UpdateGuildPanel
	scrollFrame:SetScript("OnMouseWheel", OnMouseWheel)
	scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * buttonHeight)
	scrollFrame:SetVerticalScroll(0)
	scrollFrame:UpdateScrollChildRect()
	scrollBar:SetMinMaxValues(0, numButtons * buttonHeight)
	scrollBar:SetValue(0)
end

local function OnEnter(self)
	if not IsInGuild() then return end
	if module.FriendsFrame and module.FriendsFrame:IsShown() then
		module.FriendsFrame:Hide()
	end

	InitGuildPanel(self)
	RefreshGuildPanel()
	SortGuildPanel()
end

local function OnLeave()
	if not module.GuildFrame then return end
	C_Timer.After(0.1, function()
		if not module.GuildFrame:IsMouseOver() then
			module.GuildFrame:Hide()
		end
	end)
end

local function OnMouseUp()
	if not IsInGuild() then return end
	if module.GuildFrame then module.GuildFrame:Hide() end
	ToggleGuildFrame()
end

module:RegisterDataText("Guild", {
	panel = module.RightPanel,
	anchor = "LEFT",
	events = {
		"PLAYER_ENTERING_WORLD",
		"GUILD_ROSTER_UPDATE",
		"PLAYER_GUILD_UPDATE",
	},
	onEvent = OnEvent,
	onEnter = OnEnter,
	onLeave = OnLeave,
	onMouseUp = OnMouseUp,
})
