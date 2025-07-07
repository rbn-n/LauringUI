local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local format, sort, wipe, unpack, tinsert = string.format, table.sort, table.wipe, unpack, table.insert
local C_Timer_After = C_Timer.After
local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local BNet_GetValidatedCharacterName = BNet_GetValidatedCharacterName
local BNet_GetClientEmbeddedAtlas = BNet_GetClientEmbeddedAtlas
local CanCooperateWithGameAccount, GetRealZoneText, GetQuestDifficultyColor = CanCooperateWithGameAccount, GetRealZoneText, GetQuestDifficultyColor
local BNGetNumFriends, BNGetFriendInfo, BNGetGameAccountInfo, BNGetNumFriendGameAccounts, BNGetFriendGameAccountInfo = BNGetNumFriends, BNGetFriendInfo, BNGetGameAccountInfo, BNGetNumFriendGameAccounts, BNGetFriendGameAccountInfo
local HybridScrollFrame_GetOffset, HybridScrollFrame_Update = HybridScrollFrame_GetOffset, HybridScrollFrame_Update
local BNET_CLIENT_WOW, UNKNOWN, GUILD_ONLINE_LABEL, CHARACTER_FRIEND = BNET_CLIENT_WOW, UNKNOWN, GUILD_ONLINE_LABEL, CHARACTER_FRIEND
local FRIENDS_TEXTURE_ONLINE, FRIENDS_TEXTURE_AFK, FRIENDS_TEXTURE_DND = FRIENDS_TEXTURE_ONLINE, FRIENDS_TEXTURE_AFK, FRIENDS_TEXTURE_DND
local EXPANSION_NAME0 = EXPANSION_NAME0
local WOW_PROJECT_ID = WOW_PROJECT_ID or 14
local WOW_PROJECT_60 = WOW_PROJECT_CLASSIC or 2
local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE or 1
local CLIENT_WOW_DIFF = "WoV"

local updateRequest, prevTime
local friendTable, bnetTable = {}, {}
local activeZone, inactiveZone = "|cff4cff4c", DB.GreyColor
local noteString = "|T"..DB.CopyTexture..":12|t %s"
local broadcastString = "|TInterface\\FriendsFrame\\BroadcastIcon:12|t %s (%s)"
local onlineString = gsub(ERR_FRIEND_ONLINE_SS, ".+h", "")
local offlineString = gsub(ERR_FRIEND_OFFLINE_S, "%%s", "")
local numFriends, onlineFriends, numBNet, onlineBNet, totalOnline, totalFriends = 0, 0, 0, 0, 0, 0

local menuList = {
	[1] = {text = L["Join or Invite"], isTitle = true, notCheckable = true}
}

local function SortFriends(a, b)
	if a[1] and b[1] then
		return a[1] < b[1]
	end
end

local function SortBNetFriends(a, b)
	if DB.MyFaction == "Alliance" then
		return a[5] == b[5] and a[4] < b[4] or a[5] > b[5]
	else
		return a[5] == b[5] and a[4] > b[4] or a[5] > b[5]
	end
end

local function RefreshFriendsPanel()
	numFriends = C_FriendList_GetNumFriends() or 0
	onlineFriends = C_FriendList_GetNumOnlineFriends() or 0
	numBNet, onlineBNet = BNGetNumFriends()
	totalOnline = onlineFriends + onlineBNet
	totalFriends = numFriends + numBNet
end

local function BuildFriendTable(num)
	wipe(friendTable)

	for i = 1, num do
		local info = C_FriendList_GetFriendInfoByIndex(i)
		if info and info.connected then
			local status = FRIENDS_TEXTURE_ONLINE
			if info.afk then
				status = FRIENDS_TEXTURE_AFK
			elseif info.dnd then
				status = FRIENDS_TEXTURE_DND
			end
			local class = DB.ClassList[info.className]
			tinsert(friendTable, {info.name, info.level, class, info.area, status, info.notes})
		end
	end

	sort(friendTable, SortFriends)
end

local function BuildBNetTable(num)
	wipe(bnetTable)

	for i = 1, num do
		local _, accountName, battleTag, _, charName, gameID, _, isOnline, _, isAFK, isDND, broadcastText, note, _, broadcastTime = BNGetFriendInfo(i)
		if isOnline then
			local _, _, client, realmName, _, factionName, _, class, _, zoneName, level, gameText, _, _, _, _, _, isGameAFK, isGameBusy, _, wowProjectID = BNGetGameAccountInfo(gameID)

			charName = BNet_GetValidatedCharacterName(charName, battleTag, client)
			class = DB.ClassList[class]

			local status, infoText
			if isAFK or isGameAFK then
				status = FRIENDS_TEXTURE_AFK
			elseif isDND or isGameBusy then
				status = FRIENDS_TEXTURE_DND
			else
				status = FRIENDS_TEXTURE_ONLINE
			end
			if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID then
				if not zoneName or zoneName == "" then
					infoText = UNKNOWN
				else
					infoText = zoneName
				end
			else
				if wowProjectID == WOW_PROJECT_MAINLINE then
					infoText = CHARACTER_FRIEND
				elseif wowProjectID == WOW_PROJECT_60 then
					infoText = EXPANSION_NAME0
				else
					infoText = gameText
				end
			end
			if client == BNET_CLIENT_WOW and wowProjectID ~= WOW_PROJECT_ID then client = CLIENT_WOW_DIFF end

			tinsert(bnetTable, {i, accountName, charName, factionName, client, realmName, status, class, level, infoText, note, broadcastText, broadcastTime})
		end
	end

	sort(bnetTable, SortBNetFriends)
end

local function UpdateInfoFrameAnchor(self)
	local relFrom, relTo, offset = module:GetTooltipAnchor(self)
	module.FriendsFrame:ClearAllPoints()
	module.FriendsFrame:SetPoint(relFrom, self, relTo, 0, offset)
end

local function IsHidablePanel(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > .1 then
		if not module.FriendsFrame:IsMouseOver() then
			self:Hide()
			self:SetScript("OnUpdate", nil)
		end

		self.timer = 0
	end
end

local function UpdateButton(button)
	local index = button.index

	if index <= onlineFriends then
		local name, level, class, area, status = unpack(friendTable[index])
		button.status:SetTexture(status)
		local zoneColor = GetRealZoneText() == area and activeZone or inactiveZone
		local levelColor = Core.HexRGB(GetQuestDifficultyColor(level))
		local classColor = DB.ClassColors[class] or levelColor
		button.name:SetText(format("%s%s|r %s%s", levelColor, level, Core.HexRGB(classColor), name))
		button.zone:SetText(format("%s%s", zoneColor, area))
		C_Texture.SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium)
		--button.gameIcon:SetAtlas(BNet_GetBattlenetClientAtlas(BNET_CLIENT_WOW))

		button.isBNet = nil
		button.data = friendTable[index]
	else
		local bnetIndex = index-onlineFriends
		local _, accountName, charName, factionName, client, _, status, class, _, infoText = unpack(bnetTable[bnetIndex])

		button.status:SetTexture(status)
		local zoneColor = inactiveZone
		local name = inactiveZone..charName
		if client == BNET_CLIENT_WOW then
			local color = DB.ClassColors[class] or GetQuestDifficultyColor(1)
			name = Core.HexRGB(color)..charName
			zoneColor = GetRealZoneText() == infoText and activeZone or inactiveZone
		end
		button.name:SetText(format("%s%s|r (%s|r)", DB.InfoColor, accountName, name))
		button.zone:SetText(format("%s%s", zoneColor, infoText))
		if client == CLIENT_WOW_DIFF then
			C_Texture.SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium)
			--button.gameIcon:SetAtlas(BNet_GetBattlenetClientAtlas(BNET_CLIENT_WOW))
		elseif client == BNET_CLIENT_WOW then
			button.gameIcon:SetTexture("Interface\\FriendsFrame\\PlusManz-"..factionName)
		else
			C_Texture.SetTitleIconTexture(button.gameIcon, client, Enum.TitleIconVersion.Medium)
			--button.gameIcon:SetAtlas(BNet_GetBattlenetClientAtlas(client))
		end

		button.isBNet = true
		button.data = bnetTable[bnetIndex]
	end
end

local function UpdateFriendsPanel()
	local scrollFrame = module.FriendsFrame.scrollFrame
	local usedHeight = 0
	local buttons = scrollFrame.buttons
	local height = scrollFrame.buttonHeight
	local numFriendButtons = totalOnline
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for i = 1, #buttons do
		local button = buttons[i]
		local index = offset + i
		if index <= numFriendButtons then
			button.index = index
			UpdateButton(button)
			usedHeight = usedHeight + height
			button:Show()
		else
			button.index = nil
			button:Hide()
		end
	end

	HybridScrollFrame_Update(scrollFrame, numFriendButtons*height, usedHeight)
end

local function InviteFunc(_, bnetIDGameAccount, guid)
	FriendsFrame_InviteOrRequestToJoin(guid, bnetIDGameAccount)
end

local function ButtonOnClick(self, btn)
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			if self.isBNet then
				local index = 2
				if #menuList > 1 then
					for i = 2, #menuList do
						wipe(menuList[i])
					end
				end

				local numGameAccounts = BNGetNumFriendGameAccounts(self.data[1])
				local lastGameAccountID, lastGameAccountGUID
				if numGameAccounts > 0 then
					for i = 1, numGameAccounts do
						local _, charName, client, _, _, _, _, class, _, _, _, _, _, _, _, bnetIDGameAccount, _, _, _, guid = BNGetFriendGameAccountInfo(self.data[1], i)
						if client == BNET_CLIENT_WOW and CanCooperateWithGameAccount(bnetIDGameAccount) then
							if not menuList[index] then menuList[index] = {} end
							menuList[index].text = Core.HexRGB(Core.ClassColor(DB.ClassList[class]))..charName
							menuList[index].notCheckable = true
							menuList[index].arg1 = bnetIDGameAccount
							menuList[index].arg2 = guid
							menuList[index].func = InviteFunc
							lastGameAccountID = bnetIDGameAccount
							lastGameAccountGUID = guid

							index = index + 1
						end
					end
				end

				if index == 2 then return end
				if index == 3 then
					FriendsFrame_InviteOrRequestToJoin(lastGameAccountGUID, lastGameAccountID)
				else
					EasyMenu(menuList, Core.EasyMenu, self, 0, 0, "MENU", 1)
				end
			else
				InviteToGroup(self.data[1])
			end
		end
	else
		if self.isBNet then
			ChatFrame_SendBNetTell(self.data[2])
		else
			ChatFrame_SendTell(self.data[1], SELECTED_DOCK_FRAME)
		end
	end
end

local function ButtonOnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", module.FriendsFrame, "TOPRIGHT", 5, 0)
	GameTooltip:ClearLines()
	if self.isBNet then
		GameTooltip:AddLine(L["BN"], 0,.6,1)
		GameTooltip:AddLine(" ")

		local index, accountName, _, _, _, _, _, _, _, _, note, broadcastText, broadcastTime = unpack(self.data)
		local numGameAccounts = BNGetNumFriendGameAccounts(index)
		for i = 1, numGameAccounts do
			local _, charName, client, realmName, _, faction, _, class, _, zoneName, level, gameText, _, _, _, _, _, _, _, _, wowProjectID = BNGetFriendGameAccountInfo(index, i)
			local clientString = BNet_GetClientEmbeddedAtlas(client, 16)
			if client == BNET_CLIENT_WOW then
				realmName = (DB.MyRealm == realmName or realmName == "") and "" or "-"..realmName

				-- Get realm name from gameText
				if wowProjectID == WOW_PROJECT_MAINLINE then
					local zone, realm = strmatch(gameText, "(.-)%s%-%s(.+)")
					if realm then
						gameText, realmName = zone, "-"..realm
					end
				elseif wowProjectID == WOW_PROJECT_60 then
					gameText = zoneName
				end

				class = DB.ClassList[class]
				local classColor = Core.HexRGB(Core.ClassColor(class))
				if faction == "Horde" then
					clientString = "|TInterface\\FriendsFrame\\PlusManz-Horde:16:|t"
				elseif faction == "Alliance" then
					clientString = "|TInterface\\FriendsFrame\\PlusManz-Alliance:16:|t"
				end
				GameTooltip:AddLine(format("%s%s %s%s%s", clientString, level, classColor, charName, realmName))

				if wowProjectID ~= WOW_PROJECT_ID then zoneName = "*"..gameText end
				GameTooltip:AddLine(format("%s%s", inactiveZone, zoneName))
			else
				GameTooltip:AddLine(format("|cffffffff%s%s", clientString, accountName))
				if gameText ~= "" then
					GameTooltip:AddLine(format("%s%s", inactiveZone, gameText))
				end
			end
		end

		if note and note ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(format(noteString, note), 1,.8,0)
		end

		if broadcastText and broadcastText ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(format(broadcastString, broadcastText, FriendsFrame_GetLastOnline(broadcastTime)), .3,.6,.8, 1)
		end
	else
		GameTooltip:AddLine(L["WoW"], 1,.8,0)
		GameTooltip:AddLine(" ")
		local name, level, class, area, _, note = unpack(self.data)
		local classColor = Core.HexRGB(Core.ClassColor(class))
		GameTooltip:AddLine(format("%s %s%s", level, classColor, name))
		GameTooltip:AddLine(format("%s%s", inactiveZone, area))

		if note and note ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(format(noteString, note), 1,.8,0)
		end
	end
	GameTooltip:Show()
end

local function CreateButton(parent, index)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(370, 20)
	button:SetPoint("TOPLEFT", 0, - (index-1) *20)
	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(DB.r, DB.g, DB.b, .2)

	button.status = button:CreateTexture(nil, "ARTWORK")
	button.status:SetPoint("LEFT", button, 5, 0)
	button.status:SetSize(16, 16)

	button.name = Core.CreateFS(button, 13, "Tag (name)", false, "LEFT", 25, 0)
	button.name:SetPoint("RIGHT", button, "LEFT", 230, 0)
	button.name:SetJustifyH("LEFT")
	button.name:SetTextColor(.5, .7, 1)

	button.zone = Core.CreateFS(button, 13, "Zone", false, "RIGHT", -28, 0)
	button.zone:SetPoint("LEFT", button, "RIGHT", -130, 0)
	button.zone:SetJustifyH("RIGHT")

	button.gameIcon = button:CreateTexture(nil, "ARTWORK")
	button.gameIcon:SetPoint("RIGHT", button, -8, 0)
	button.gameIcon:SetSize(16, 16)

	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", ButtonOnClick)
	button:SetScript("OnEnter", ButtonOnEnter)
	button:SetScript("OnLeave", Core.HideTooltip)

	return button
end

local function OnMouseWheel(self, delta)
	local scrollBar = self.scrollBar
	local step = delta * self.buttonHeight
	if IsShiftKeyDown() then
		step = step * 19
	end
	scrollBar:SetValue(scrollBar:GetValue() - step)
	UpdateFriendsPanel()
end

local function InitFriendsPanel(self)
	if module.FriendsFrame then
		module.FriendsFrame:Show()
		UpdateInfoFrameAnchor(self)
		return
	end

	module.FriendsFrame = CreateFrame("Frame", "LauringUIFriendsFrame", self)
	module.FriendsFrame:SetSize(400, 495)
	UpdateInfoFrameAnchor(self)
	module.FriendsFrame:SetClampedToScreen(true)
	module.FriendsFrame:SetFrameStrata("DIALOG")
	local bg = Core.SetBD(module.FriendsFrame)
	bg:SetBackdropColor(0, 0, 0, .4)

	module.FriendsFrame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", IsHidablePanel)
	end)

	Core.CreateFS(module.FriendsFrame, 16, "|cff0099ff"..FRIENDS_LIST, nil, "TOPLEFT", 15, -10)
	module.FriendsFrame.friendCountText = Core.CreateFS(module.FriendsFrame, 14, "-/-", nil, "TOPRIGHT", -15, -12)
	module.FriendsFrame.friendCountText:SetTextColor(0, .6, 1)

	local scrollFrame = CreateFrame("ScrollFrame", "LauringUIFriendsInfobarScrollFrame", module.FriendsFrame, "HybridScrollFrameTemplate")
	scrollFrame:SetSize(370, 400)
	scrollFrame:SetPoint("TOPLEFT", 10, -35)
	module.FriendsFrame.scrollFrame = scrollFrame

	local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
	scrollBar.doNotHide = true
	Core.ReskinScroll(scrollBar)
	scrollFrame.scrollBar = scrollBar

	local scrollChild = scrollFrame.scrollChild
	local numButtons = 20 + 1
	local buttonHeight = 22
	local buttons = {}
	for i = 1, numButtons do
		buttons[i] = CreateButton(scrollChild, i)
	end

	scrollFrame.buttons = buttons
	scrollFrame.buttonHeight = buttonHeight
	scrollFrame.update = UpdateFriendsPanel
	scrollFrame:SetScript("OnMouseWheel", OnMouseWheel)
	scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * buttonHeight)
	scrollFrame:SetVerticalScroll(0)
	scrollFrame:UpdateScrollChildRect()
	scrollBar:SetMinMaxValues(0, numButtons * buttonHeight)
	scrollBar:SetValue(0)

	Core.CreateFS(module.FriendsFrame, 13, DB.LineString, false, "BOTTOMRIGHT", -12, 42)
	local whspInfo = DB.InfoColor..DB.RightButton..L["Whisper"]
	Core.CreateFS(module.FriendsFrame, 13, whspInfo, false, "BOTTOMRIGHT", -15, 26)
	local invtInfo = DB.InfoColor.."ALT +"..DB.LeftButton..L["Invite"]
	Core.CreateFS(module.FriendsFrame, 13, invtInfo, false, "BOTTOMRIGHT", -15, 10)
end


local function UpdateTooltip(self)
	local thisTime = GetTime()
	if not prevTime or (thisTime-prevTime > 5) then
		RefreshFriendsPanel()
		prevTime = thisTime
	end

	if totalOnline == 0 then
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPLEFT", UIParent, 15, -30)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(FRIENDS_LIST, format("%s: %s/%s", GUILD_ONLINE_LABEL, totalOnline, totalFriends), 0,.6,1, 0,.6,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["No Online"], 1,1,1)
		GameTooltip:Show()
		return
	end

	if not updateRequest then
		if numFriends > 0 then BuildFriendTable(numFriends) end
		if numBNet > 0 then BuildBNetTable(numBNet) end
		updateRequest = true
	end

	if module.GuildFrame and module.GuildFrame:IsShown() then
		module.GuildFrame:Hide()
	end

	InitFriendsPanel(self)
	UpdateFriendsPanel()
	module.FriendsFrame.friendCountText:SetText(format("%s: %s/%s", GUILD_ONLINE_LABEL, totalOnline, totalFriends))
end

local function OnEnter(self)
	UpdateTooltip(self)
end

local function OnEvent(self, event, arg1)
	if event == "CHAT_MSG_SYSTEM" then
		if not strfind(arg1, onlineString) and not strfind(arg1, offlineString) then return end
	end

	RefreshFriendsPanel()
	self.Text:SetText(format("%s: "..DB.MyColor.."%d", FRIENDS, totalOnline))

	updateRequest = false
	if module.FriendsFrame and module.FriendsFrame:IsShown() then
		OnEnter()
	end
end


local function OnLeave()
	GameTooltip:Hide()
end

local function OnMouseUp(self, btn)
	ToggleFriendsFrame(1)
end

module:RegisterDataText("Friends", {
	panel = module.RightPanel,
	anchor = "LEFT",
	events = {
		"PLAYER_ENTERING_WORLD",
		"FRIENDLIST_UPDATE",
		"BN_CONNECTED",
		"BN_INFO_CHANGED",
	},
	onEvent = OnEvent,
	onEnter = OnEnter,
	onLeave = OnLeave,
	onMouseUp = OnMouseUp,
})