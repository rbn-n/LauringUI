local _, ns = ...
local Core, C, L, DB = unpack(ns)

local module = Core:GetModule("Infobars")
local info = {}
local guildTable = {}
local infoFrame, gName, gOnline, gRank
local r, g, b = DB.r, DB.g, DB.b
local tinsert, wipe, sort, floor = table.insert, table.wipe, table.sort, math.floor
local format, unpack = string.format, unpack
local InviteToGroup = InviteToGroup

local function GetStatusTexture(status, mobile)
	if mobile then
		if status == 1 then
			return "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14|t"
		elseif status == 2 then
			return "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14|t"
		else
			return ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)
		end
    end

    if status == 1 then
        return DB.AFKTex
    elseif status == 2 then
        return DB.DNDTex
    else
        return " "
    end
end

local function CreateGuildButton(parent, index)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(305, 20)
	button:SetPoint("TOPLEFT", 0, -(index - 1) * 20)
	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(r, g, b, .2)

	button.level = Core:CreateFS(button, 13)
	button.level:SetPoint("TOP", button, "TOPLEFT", 16, -4)

	button.class = button:CreateTexture(nil, "ARTWORK")
	button.class:SetPoint("LEFT", 35, 0)
	button.class:SetSize(16, 16)
	button.class:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")

	button.name = Core:CreateFS(button, 13)
	button.name:SetPoint("LEFT", 65, 0)
	button.name:SetPoint("RIGHT", button, "LEFT", 185, 0)
	button.name:SetJustifyH("LEFT")

	button.zone = Core:CreateFS(button, 13)
	button.zone:SetPoint("LEFT", button, "RIGHT", -120, 0)
	button.zone:SetPoint("RIGHT", -2, 0)
	button.zone:SetJustifyH("RIGHT")

	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", function(self, btn)
		local name = guildTable[self.index][3]
		if btn == "LeftButton" then
			if IsAltKeyDown() then
				InviteToGroup(name)
			elseif IsShiftKeyDown() then
				local editBox = ChatEdit_ChooseBoxForSend()
				ChatEdit_ActivateChat(editBox)
				editBox:Insert(name)
				editBox:HighlightText()
			end
		else
			ChatFrame_OpenChat("/w "..name.." ", SELECTED_DOCK_FRAME)
		end
	end)

	return button
end

local function UpdateButton(button)
	local index = button.index
	local level, class, name, zone, status = unpack(guildTable[index])
	local levelColor = Core.HexRGB(GetQuestDifficultyColor(level))
	local nameColor = Core.HexRGB(Core:ClassColor(class))
	local zoneColor = DB.GreyColor
	if UnitInRaid(name) or UnitInParty(name) then
		zoneColor = DB.InfoColor
	elseif GetRealZoneText() == zone then
		zoneColor = "|cff4cff4c"
	end

	button.level:SetText(levelColor .. level)
	Core:ClassIconTexCoord(button.class, class)
	button.name:SetText(nameColor .. name .. status)
	button.zone:SetText(zoneColor .. zone)
end

local function SortGuild()
	sort(guildTable, function(a, b)
		return a[3] < b[3]
	end)
end

local function RefreshGuild()
	if not IsInGuild() then return end
	C_GuildInfo.GuildRoster()

	wipe(guildTable)
	local total, _, allOnline = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")
	if not guildName then return end

	gName:SetText("|cff0099ff<"..(guildName or "")..">")
	gOnline:SetText(format(DB.InfoColor.."%s: %d", GUILD_ONLINE_LABEL, allOnline or 0))
	gRank:SetText(DB.InfoColor..RANK..": "..(guildRank or ""))

	for i = 1, total do
		local name, _, _, level, _, zone, _, _, connected, status, class, _, _, mobile = GetGuildRosterInfo(i)
		if connected or mobile then
			if mobile and not connected then
				zone = REMOTE_CHAT
			end
			tinsert(guildTable, {
				level,
				class,
				Ambiguate(name, "none"),
				zone or UNKNOWN,
				GetStatusTexture(status, mobile),
			})
		end
	end

	SortGuild()
end

local function BuildGuildFrame()
	if infoFrame then infoFrame:Show() return end

	infoFrame = CreateFrame("Frame", "LauringUIGuildFrame", UIParent)
	infoFrame:SetSize(335, 495)
	module:PlaceTooltip(infoFrame, info)

	local bg = Core:SetBackdrop(infoFrame)
	bg:SetBackdropColor(0, 0, 0, .7)

	infoFrame:SetClampedToScreen(true)
	infoFrame:SetFrameStrata("TOOLTIP")

	infoFrame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", function(self, elapsed)
			self.timer = (self.timer or 0) + elapsed
			if self.timer > 0.1 and not self:IsMouseOver() then
				self:Hide()
				self:SetScript("OnUpdate", nil)
				self.timer = 0
			end
		end)
	end)

	gName = Core:CreateFS(infoFrame, 16, "TOPLEFT", 15, -10)
	gOnline = Core:CreateFS(infoFrame, 13, "TOPLEFT", 15, -35)
	gRank = Core:CreateFS(infoFrame, 13, "TOPLEFT", 15, -51)

	local scrollFrame = CreateFrame("ScrollFrame", nil, infoFrame, "HybridScrollFrameTemplate")
	scrollFrame:SetSize(305, 320)
	scrollFrame:SetPoint("TOPLEFT", 10, -100)
	infoFrame.scrollFrame = scrollFrame

	local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
	scrollBar.doNotHide = true
	scrollFrame.scrollBar = scrollBar
	Core:ReskinScroll(scrollBar)

	local scrollChild = scrollFrame.scrollChild
	local numButtons = 17
	local buttonHeight = 22
	local buttons = {}

	for i = 1, numButtons do
		buttons[i] = CreateGuildButton(scrollChild, i)
	end

	scrollFrame.buttons = buttons
	scrollFrame.buttonHeight = buttonHeight
	scrollFrame.update = function()
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		local usedHeight = 0

		for i = 1, #buttons do
			local index = offset + i
			local button = buttons[i]
			if index <= #guildTable then
				button.index = index
				UpdateButton(button)
				usedHeight = usedHeight + buttonHeight
				button:Show()
			else
				button:Hide()
			end
		end

		HybridScrollFrame_Update(scrollFrame, #guildTable * buttonHeight, usedHeight)
	end

	scrollFrame:SetScript("OnMouseWheel", function(self, delta)
		local step = delta * scrollFrame.buttonHeight
		if IsShiftKeyDown() then step = step * 15 end
		scrollFrame.scrollBar:SetValue(scrollFrame.scrollBar:GetValue() - step)
		scrollFrame:update()
	end)

	scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * buttonHeight)
	scrollFrame:SetVerticalScroll(0)
	scrollFrame:UpdateScrollChildRect()
end

local function OnEvent(self, event, arg1)
	if not IsInGuild() then
		self.Text:SetText(GUILD..": "..DB.MyColor..NONE)
		return
	end

	if event == "GUILD_ROSTER_UPDATE" and arg1 then
		C_GuildInfo.GuildRoster()
	end

	local _, _, allOnline = GetNumGuildMembers()
	self.Text:SetText(GUILD..": "..DB.MyColor..(allOnline or 0))

	if infoFrame and infoFrame:IsShown() then
		RefreshGuild()
		infoFrame.scrollFrame:update()
	end
end

local function OnEnter()
	if not IsInGuild() then return end
	BuildGuildFrame()
	RefreshGuild()
	infoFrame.scrollFrame:update()
end

local function OnLeave()
	if not infoFrame then return end
	C_Timer.After(0.1, function()
		if not infoFrame:IsMouseOver() then
			infoFrame:Hide()
		end
	end)
end

local function OnMouseUp()
	if not IsInGuild() then return end
	if infoFrame then infoFrame:Hide() end
	ToggleFriendsFrame(3) -- Guild tab
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
