local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobar")

local INFO = module:RegisterInfobar("Guild", Config.Infobar.GuildPosition)

INFO.guildTable = {}
local infoFrame, gName, gOnline, gRank

local wipe, sort, format, select = table.wipe, table.sort, format, select
local SELECTED_DOCK_FRAME = SELECTED_DOCK_FRAME
local LEVEL_ABBR, CLASS_ABBR, NAME, ZONE, RANK, REMOTE_CHAT = LEVEL_ABBR, CLASS_ABBR, NAME, ZONE, RANK, REMOTE_CHAT
local IsAltKeyDown, IsShiftKeyDown, InviteToGroup, C_Timer_After, Ambiguate, MouseIsOver = IsAltKeyDown, IsShiftKeyDown, InviteToGroup, C_Timer.After, Ambiguate, MouseIsOver
local MailFrame, MailFrameTab_OnClick, SendMailNameEditBox = MailFrame, MailFrameTab_OnClick, SendMailNameEditBox
local ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat, ChatFrame_OpenChat, ChatFrame_GetMobileEmbeddedTexture = ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat, ChatFrame_OpenChat, ChatFrame_GetMobileEmbeddedTexture
local GetNumGuildMembers, GetGuildInfo, GetGuildRosterInfo, IsInGuild = GetNumGuildMembers, GetGuildInfo, GetGuildRosterInfo, IsInGuild
local GetQuestDifficultyColor, GetRealZoneText, UnitInRaid, UnitInParty = GetQuestDifficultyColor, GetRealZoneText, UnitInRaid, UnitInParty
local HybridScrollFrame_GetOffset, HybridScrollFrame_Update = HybridScrollFrame_GetOffset, HybridScrollFrame_Update
local C_GuildInfo_GuildRoster = C_GuildInfo.GuildRoster

local function rosterButtonOnClick(self, btn)
	local name = INFO.guildTable[self.index][3]
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

function INFO:GuildPanel_CreateButton(parent, index)
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
	button:SetScript("OnClick", rosterButtonOnClick)

	return button
end

function INFO:GuildPanel_UpdateButton(button)
	local index = button.index
	local level, class, name, zone, status = unpack(INFO.guildTable[index])

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

function INFO:GuildPanel_Update()
	local scrollFrame = LauringUIGuildInfobarScrollFrame
	local usedHeight = 0
	local buttons = scrollFrame.buttons
	local height = scrollFrame.buttonHeight
	local numMemberButtons = infoFrame.numMembers
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for i = 1, #buttons do
		local button = buttons[i]
		local index = offset + i
		if index <= numMemberButtons then
			button.index = index
			INFO:GuildPanel_UpdateButton(button)
			usedHeight = usedHeight + height
			button:Show()
		else
			button.index = nil
			button:Hide()
		end
	end
	HybridScrollFrame_Update(scrollFrame, numMemberButtons*height, usedHeight)
end

function INFO:GuildPanel_OnMouseWheel(delta)
	local scrollBar = self.scrollBar
	local step = delta*self.buttonHeight
	if IsShiftKeyDown() then
		step = step*15
	end
	scrollBar:SetValue(scrollBar:GetValue() - step)
	INFO:GuildPanel_Update()
end

local function sortRosters(a, b)
	if a and b then
		if LauringUIAccountDB["GuildSortOrder"] then
			return a[LauringUIAccountDB["GuildSortBy"]] < b[LauringUIAccountDB["GuildSortBy"]]
		else
			return a[LauringUIAccountDB["GuildSortBy"]] > b[LauringUIAccountDB["GuildSortBy"]]
		end
	end
end

function INFO:GuildPanel_SortUpdate()
	sort(INFO.guildTable, sortRosters)
	INFO:GuildPanel_Update()
end

local function sortHeaderOnClick(self)
	LauringUIAccountDB["GuildSortBy"] = self.index
	LauringUIAccountDB["GuildSortOrder"] = not LauringUIAccountDB["GuildSortOrder"]
	INFO:GuildPanel_SortUpdate()
end

local function isPanelCanHide(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > .1 then
		if not infoFrame:IsMouseOver() then
			self:Hide()
			self:SetScript("OnUpdate", nil)
		end

		self.timer = 0
	end
end

local function updateInfoFrameAnchor(frame)
	local relFrom, relTo, offset = module:GetTooltipAnchor(INFO)
	frame:ClearAllPoints()
	frame:SetPoint(relFrom, INFO, relTo, 0, offset)
end

function INFO:GuildPanel_Init()
	if infoFrame then
		infoFrame:Show()
		updateInfoFrameAnchor(infoFrame)
		return
	end

	infoFrame = CreateFrame("Frame", "LauringUIGuildInfobar", INFO)
	infoFrame:SetSize(335, 495)
	updateInfoFrameAnchor(infoFrame)
	infoFrame:SetClampedToScreen(true)
	infoFrame:SetFrameStrata("TOOLTIP")
	local bg = Core.SetBD(infoFrame)
	bg:SetBackdropColor(0, 0, 0, .7)

	infoFrame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", isPanelCanHide)
	end)

	gName = Core.CreateFS(infoFrame, 16, "Guild", true, "TOPLEFT", 15, -10)
	gOnline = Core.CreateFS(infoFrame, 13, "Online", false, "TOPLEFT", 15, -35)
	gRank = Core.CreateFS(infoFrame, 13, "Rank", false, "TOPLEFT", 15, -51)

	local bu = {}
	local width = {30, 35, 126, 126}
	for i = 1, 4 do
		bu[i] = CreateFrame("Button", nil, infoFrame)
		bu[i]:SetSize(width[i], 22)
		bu[i]:SetFrameLevel(infoFrame:GetFrameLevel() + 3)
		if i == 1 then
			bu[i]:SetPoint("TOPLEFT", 12, -75)
		else
			bu[i]:SetPoint("LEFT", bu[i-1], "RIGHT", -2, 0)
		end
		bu[i].HL = bu[i]:CreateTexture(nil, "HIGHLIGHT")
		bu[i].HL:SetAllPoints(bu[i])
		bu[i].HL:SetColorTexture(DB.r, DB.g, DB.b, .2)
		bu[i].index = i
		bu[i]:SetScript("OnClick", sortHeaderOnClick)
	end
	Core.CreateFS(bu[1], 13, LEVEL_ABBR)
	Core.CreateFS(bu[2], 13, CLASS_ABBR)
	Core.CreateFS(bu[3], 13, NAME, false, "LEFT", 5, 0)
	Core.CreateFS(bu[4], 13, ZONE, false, "RIGHT", -5, 0)

	Core.CreateFS(infoFrame, 13, DB.LineString, false, "BOTTOMRIGHT", -12, 58)
	local whspInfo = DB.InfoColor..DB.RightButton..L["Whisper"]
	Core.CreateFS(infoFrame, 13, whspInfo, false, "BOTTOMRIGHT", -15, 42)
	local invtInfo = DB.InfoColor.."ALT +"..DB.LeftButton..L["Invite"]
	Core.CreateFS(infoFrame, 13, invtInfo, false, "BOTTOMRIGHT", -15, 26)
	local copyInfo = DB.InfoColor.."SHIFT +"..DB.LeftButton..L["Copy Name"]
	Core.CreateFS(infoFrame, 13, copyInfo, false, "BOTTOMRIGHT", -15, 10)

	local scrollFrame = CreateFrame("ScrollFrame", "LauringUIGuildInfobarScrollFrame", infoFrame, "HybridScrollFrameTemplate")
	scrollFrame:SetSize(305, 320)
	scrollFrame:SetPoint("TOPLEFT", 10, -100)
	infoFrame.scrollFrame = scrollFrame

	local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
	scrollBar.doNotHide = true
	Core.ReskinScroll(scrollBar)
	scrollFrame.scrollBar = scrollBar

	local scrollChild = scrollFrame.scrollChild
	local numButtons = 16 + 1
	local buttonHeight = 22
	local buttons = {}
	for i = 1, numButtons do
		buttons[i] = INFO:GuildPanel_CreateButton(scrollChild, i)
	end

	scrollFrame.buttons = buttons
	scrollFrame.buttonHeight = buttonHeight
	scrollFrame.update = INFO.GuildPanel_Update
	scrollFrame:SetScript("OnMouseWheel", INFO.GuildPanel_OnMouseWheel)
	scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * buttonHeight)
	scrollFrame:SetVerticalScroll(0)
	scrollFrame:UpdateScrollChildRect()
	scrollBar:SetMinMaxValues(0, numButtons * buttonHeight)
	scrollBar:SetValue(0)
end

C_Timer_After(5, function()
	if IsInGuild() then C_GuildInfo_GuildRoster() end
end)

function INFO:GuildPanel_Refresh()
	C_GuildInfo_GuildRoster()

	wipe(INFO.guildTable)
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

			if not INFO.guildTable[count] then INFO.guildTable[count] = {} end
			INFO.guildTable[count][1] = level
			INFO.guildTable[count][2] = class
			INFO.guildTable[count][3] = Ambiguate(name, "none")
			INFO.guildTable[count][4] = zone
			INFO.guildTable[count][5] = status
		end
	end

	infoFrame.numMembers = count
end

INFO.eventList = {
	"PLAYER_ENTERING_WORLD",
	"GUILD_ROSTER_UPDATE",
	"PLAYER_GUILD_UPDATE",
}

INFO.onEvent = function(self, event, arg1)
	if not IsInGuild() then
		self.text:SetText(GUILD..": "..DB.MyColor..NONE)
		return
	end

	if event == "GUILD_ROSTER_UPDATE" then
		if arg1 then C_GuildInfo_GuildRoster() end
	end

	local _, numOnline, allOnline = GetNumGuildMembers()
	self.text:SetText(GUILD..": "..DB.MyColor..(allOnline or numOnline))

	if infoFrame and infoFrame:IsShown() then
		INFO:GuildPanel_Refresh()
		INFO:GuildPanel_SortUpdate()
	end
end

INFO.onEnter = function()
	if not IsInGuild() then return end
	if LauringUIFriendsFrame and LauringUIFriendsFrame:IsShown() then
		LauringUIFriendsFrame:Hide()
	end

	INFO:GuildPanel_Init()
	INFO:GuildPanel_Refresh()
	INFO:GuildPanel_SortUpdate()
end

local function delayLeave()
	if MouseIsOver(infoFrame) then return end
	infoFrame:Hide()
end

INFO.onLeave = function()
	if not infoFrame then return end
	C_Timer_After(.1, delayLeave)
end

INFO.onMouseUp = function()
	--if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel

	if not IsInGuild() then return end
	infoFrame:Hide()
	ToggleGuildFrame()
	if not CommunitiesFrame then LoadAddOn("Blizzard_Communities") end
	if CommunitiesFrame then ToggleFrame(CommunitiesFrame) end
end