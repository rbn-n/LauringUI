local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local module = Core:GetModule("Infobars")

local pairs = pairs
local wipe = table.wipe
local GameTooltip = GameTooltip
local MiniMapMailFrame = MiniMapMailFrame
local HasNewMail = HasNewMail
local GetLatestThreeSenders = GetLatestThreeSenders

local AUCTION_HOUSE = AUCTION_HOUSE
local GREEN = "|cff00ff00"
local WHITE = "|cffffffff"

local hasNewMail
local mailSenders = {}

local function UpdateMail(self)
	hasNewMail = HasNewMail()
	wipe(mailSenders)

	if hasNewMail then
		local _, sender1, sender2 = GetLatestThreeSenders()
		if sender1 then mailSenders[sender1] = true end
		if sender2 then mailSenders[sender2] = true end

		-- Add Auction House if system mail
		local icon = MiniMapMailFrame.icon
		if icon and icon:IsShown() and icon:GetTexture() == 133469 then
			mailSenders[AUCTION_HOUSE] = true
		end

		self.Text:SetText(GREEN .. L["New Mail"])
	else
		self.Text:SetText(WHITE .. L["No Mail"])
	end
end

local function OnEnter(self)
	local _, anchor, offset = module:GetTooltipAnchor(self)
	GameTooltip:SetOwner(self, "ANCHOR_" .. anchor, 0, offset)
	GameTooltip:ClearLines()

	if hasNewMail and next(mailSenders) then
		GameTooltip:AddLine(L["Unread Mail from"], 0, 0.6, 1)
		for sender in pairs(mailSenders) do
			GameTooltip:AddLine(sender, 1, 1, 1)
		end
	else
		GameTooltip:AddLine(L["No unread mail"], 1, 1, 1)
	end

	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

module:RegisterDataText("Mail", {
	panel = module.RightPanel,
	anchor = "LEFT",
	events = {
		"UPDATE_PENDING_MAIL",
		"PLAYER_ENTERING_WORLD",
	},
	onEvent = UpdateMail,
	onEnter = OnEnter,
	onLeave = OnLeave,
})
