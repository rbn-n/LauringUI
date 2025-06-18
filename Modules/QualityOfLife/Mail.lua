local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local QoL = Core:GetModule("QoL")

local wipe, select, pairs, tonumber = wipe, select, pairs, tonumber
local strsplit, strfind, tinsert = strsplit, strfind, tinsert
local InboxItemCanDelete, DeleteInboxItem, TakeInboxMoney, TakeInboxItem = InboxItemCanDelete, DeleteInboxItem, TakeInboxMoney, TakeInboxItem
local GetInboxNumItems, GetInboxHeaderInfo, GetInboxItem = GetInboxNumItems, GetInboxHeaderInfo, GetInboxItem
local GetSendMailPrice, GetMoney = GetSendMailPrice, GetMoney
local C_Timer_After = C_Timer.After
local C_Mail_HasInboxMoney = C_Mail.HasInboxMoney
local C_Mail_IsCommandPending = C_Mail.IsCommandPending
local ATTACHMENTS_MAX_RECEIVE, ERR_MAIL_DELETE_ITEM_ERROR = ATTACHMENTS_MAX_RECEIVE, ERR_MAIL_DELETE_ITEM_ERROR
local NORMAL_STRING = GUILDCONTROL_OPTION16
local OPENING_STRING = OPEN_ALL_MAIL_BUTTON_OPENING

local mailIndex, timeToWait, totalCash, inboxItems = 0, .15, 0, {}
local isGoldCollecting

function QoL:MailBox_DelectClick()
	local selectedID = self.id + (InboxFrame.pageNum-1)*7
	if InboxItemCanDelete(selectedID) then
		DeleteInboxItem(selectedID)
	else
		UIErrorsFrame:AddMessage(DB.InfoColor..ERR_MAIL_DELETE_ITEM_ERROR)
	end
end

function QoL:MailItem_AddDelete(i)
	local bu = CreateFrame("Button", nil, self)
	bu:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", -10, 5)
	bu:SetSize(16, 16)
	Core.PixelIcon(bu, 136813, true)
	bu.id = i
	bu:SetScript("OnClick", QoL.MailBox_DelectClick)
	Core.AddTooltip(bu, "ANCHOR_RIGHT", DELETE, "system")
end

function QoL:InboxItem_OnEnter()
	wipe(inboxItems)

	local itemAttached = select(8, GetInboxHeaderInfo(self.index))
	if itemAttached then
		for attachID = 1, 12 do
			local _, itemID, _, itemCount = GetInboxItem(self.index, attachID)
			if itemCount and itemCount > 0 then
				inboxItems[itemID] = (inboxItems[itemID] or 0) + itemCount
			end
		end

		if itemAttached > 1 then
			GameTooltip:AddLine(L["Attach List"])
			for itemID, count in pairs(inboxItems) do
				local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemID)
				if itemName then
					local r, g, b = C_Item.GetItemQualityColor(itemQuality)
					GameTooltip:AddDoubleLine(" |T"..itemTexture..":12:12:0:0:50:50:4:46:4:46|t "..itemName, count, r, g, b)
				end
			end
			GameTooltip:Show()
		end
	end
end

function QoL:MailBox_CollectGold()
	if mailIndex > 0 then
		if not C_Mail_IsCommandPending() then
			if C_Mail_HasInboxMoney(mailIndex) then
				TakeInboxMoney(mailIndex)
			end
			mailIndex = mailIndex - 1
		end
		C_Timer_After(timeToWait, QoL.MailBox_CollectGold)
	else
		isGoldCollecting = false
		QoL:UpdateOpeningText()
	end
end

function QoL:MailBox_CollectAllGold()
	if isGoldCollecting then return end
	if totalCash == 0 then return end

	isGoldCollecting = true
	mailIndex = GetInboxNumItems()
	QoL:UpdateOpeningText(true)
	QoL:MailBox_CollectGold()
end

function QoL:TotalCash_OnEnter()
	local numItems = GetInboxNumItems()
	if numItems == 0 then return end

	for i = 1, numItems do
		totalCash = totalCash + select(5, GetInboxHeaderInfo(i))
	end

	if totalCash > 0 then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["TotalGold"])
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(Core:FormatGold(totalCash, true), 1,1,1)
		GameTooltip:Show()
	end
end

function QoL:TotalCash_OnLeave()
	Core:HideTooltip()
	totalCash = 0
end

function QoL:UpdateOpeningText(opening)
	if opening then
		QoL.GoldButton:SetText(OPENING_STRING)
	else
		QoL.GoldButton:SetText(NORMAL_STRING)
	end
end

function QoL:MailBox_CreatButton(parent, width, height, text, anchor)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width, height)
	button:SetPoint(unpack(anchor))
	button:SetText(text)

	return button
end

function QoL:CollectGoldButton()
	OpenAllMail:ClearAllPoints()
	OpenAllMail:SetPoint("TOPLEFT", InboxFrame, "TOPLEFT", 50, -35)

	local button = QoL:MailBox_CreatButton(InboxFrame, 120, 24, "", {"LEFT", OpenAllMail, "RIGHT", 3, 0})
	button:SetScript("OnClick", QoL.MailBox_CollectAllGold)
	button:HookScript("OnEnter", QoL.TotalCash_OnEnter)
	button:HookScript("OnLeave", QoL.TotalCash_OnLeave)

	QoL.GoldButton = button
	QoL:UpdateOpeningText()
end

function QoL:MailBox_CollectAttachment()
	for i = 1, ATTACHMENTS_MAX_RECEIVE do
		local attachmentButton = OpenMailFrame.OpenMailAttachments[i]
		if attachmentButton:IsShown() then
			TakeInboxItem(InboxFrame.openMailID, i)
			C_Timer_After(timeToWait, QoL.MailBox_CollectAttachment)
			return
		end
	end
end

function QoL:MailBox_CollectCurrent()
	if OpenMailFrame.cod then
		UIErrorsFrame:AddMessage(DB.InfoColor..L["MailIsCOD"])
		return
	end

	local currentID = InboxFrame.openMailID
	if C_Mail_HasInboxMoney(currentID) then
		TakeInboxMoney(currentID)
	end
	QoL:MailBox_CollectAttachment()
end

function QoL:CollectCurrentButton()
	local button = QoL:MailBox_CreatButton(OpenMailFrame, 82, 22, L["TakeAll"], {"RIGHT", "OpenMailReplyButton", "LEFT", -1, 0})
	button:SetScript("OnClick", QoL.MailBox_CollectCurrent)
end

function QoL:LastMailSaver()
	local mailSaverCheckBox = CreateFrame("CheckButton", nil, SendMailFrame, "OptionsBaseCheckButtonTemplate")
	mailSaverCheckBox:SetHitRectInsets(0, 0, 0, 0)
	mailSaverCheckBox:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 0, 0)
	mailSaverCheckBox:SetSize(24, 24)
	Core.ReskinCheckBox(mailSaverCheckBox)
	mailSaverCheckBox.bg:SetBackdropBorderColor(1, .8, 0, .5)

	mailSaverCheckBox:SetChecked(Config.DB["QoL"]["MailSaver"])
	mailSaverCheckBox:SetScript("OnClick", function(self)
		Config.DB["QoL"]["MailSaver"] = self:GetChecked()
	end)
	Core.AddTooltip(mailSaverCheckBox, "ANCHOR_TOP", L["SaveMailTarget"])

	local resetPending
	hooksecurefunc("SendMailFrame_SendMail", function()
		if Config.DB["QoL"]["MailSaver"] then
			Config.DB["QoL"]["MailTarget"] = SendMailNameEditBox:GetText()
			resetPending = true
		else
			resetPending = nil
		end
	end)

	hooksecurefunc(SendMailNameEditBox, "SetText", function(self, text)
		if resetPending and text == "" then
			resetPending = nil
			self:SetText(Config.DB["QoL"]["MailTarget"])
		end
	end)

	SendMailFrame:HookScript("OnShow", function()
		if Config.DB["QoL"]["MailSaver"] then
			SendMailNameEditBox:SetText(Config.DB["QoL"]["MailTarget"])
		end
	end)
end

function QoL:ArrangeDefaultElements()
	InboxTooMuchMail:ClearAllPoints()
	InboxTooMuchMail:SetPoint("BOTTOM", MailFrame, "TOP", 0, 5)

	SendMailNameEditBox:SetWidth(155)
	SendMailNameEditBoxMiddle:SetWidth(146)
	SendMailCostMoneyFrame:SetAlpha(0)

	SendMailMailButton:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:ClearLines()
		local sendPrice = GetSendMailPrice()
		local colorStr = "|cffffffff"
		if sendPrice > GetMoney() then colorStr = "|cffff0000" end
		GameTooltip:AddLine(SEND_MAIL_COST..colorStr..Core:FormatGold(sendPrice, true))
		GameTooltip:Show()
	end)
	SendMailMailButton:HookScript("OnLeave", Core.HideTooltip)
end

function QoL:MailBox()
	if not Config.DB["QoL"]["EnableMail"] then return end
	if C_AddOns.IsAddOnLoaded("Postal") then return end

	-- Delete buttons
	for i = 1, 7 do
		local itemButton = _G["MailItem"..i.."Button"]
		QoL.MailItem_AddDelete(itemButton, i)
	end

	-- Tooltips for multi-items
	hooksecurefunc("InboxFrameItem_OnEnter", QoL.InboxItem_OnEnter)

	-- Elements
	QoL:ArrangeDefaultElements()
	QoL:CollectGoldButton()
	QoL:CollectCurrentButton()
	QoL:LastMailSaver()
end
QoL:RegisterQoL("MailBox", QoL.MailBox)

-- Temp fix for GM mails
function OpenAllMail:AdvanceToNextItem()
	local foundAttachment = false
	while ( not foundAttachment ) do
		local _, _, _, _, _, CODAmount, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(self.mailIndex)
		local itemID = select(2, GetInboxItem(self.mailIndex, self.attachmentIndex))
		local hasBlacklistedItem = self:IsItemBlacklisted(itemID)
		local hasCOD = CODAmount and CODAmount > 0
		local hasMoneyOrItem = C_Mail.HasInboxMoney(self.mailIndex) or HasInboxItem(self.mailIndex, self.attachmentIndex)
		if ( not hasBlacklistedItem and not isGM and not hasCOD and hasMoneyOrItem ) then
			foundAttachment = true
		else
			self.attachmentIndex = self.attachmentIndex - 1
			if ( self.attachmentIndex == 0 ) then
				break
			end
		end
	end

	if ( not foundAttachment ) then
		self.mailIndex = self.mailIndex + 1
		self.attachmentIndex = ATTACHMENTS_MAX
		if ( self.mailIndex > GetInboxNumItems() ) then
			return false
		end

		return self:AdvanceToNextItem()
	end

	return true
end