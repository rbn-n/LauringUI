local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local BNGetNumFriends, BNGetFriendInfo = BNGetNumFriends, BNGetFriendInfo
local format = format
local UNKNOWN = UNKNOWN
local GameTooltip = GameTooltip

local FRIENDS_TOOLTIP_MAX = 20 -- limit how many friends to show in tooltip

-- Remove mobile and status icon stuff entirely

local function UpdateTooltip(frame)
	GameTooltip:SetOwner(frame, module:GetTooltipAnchor(frame))
	GameTooltip:ClearLines()

	local onlineFriends = 0
	local numFriends = C_FriendList_GetNumFriends()

	for i = 1, numFriends do
		local info = C_FriendList_GetFriendInfoByIndex(i)
		if info and info.connected then
			local classColor = Core.HexRGB(Core:ClassColor(info.className) or {r=1,g=1,b=1})
			GameTooltip:AddDoubleLine(
				format("%s%s|r", classColor, info.name),
				format("%d %s", info.level or 0, info.area or UNKNOWN)
			)
			onlineFriends = onlineFriends + 1
			if onlineFriends >= FRIENDS_TOOLTIP_MAX then
				GameTooltip:AddLine(format(L["And %d more friends..."], numFriends - onlineFriends), 0.7, 0.7, 0.7)
				break
			end
		end
	end

	local numBNet = BNGetNumFriends()
	local onlineBNet = 0
	if numBNet > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Battle.net Friends"], 0, 1, 0)

		for i = 1, numBNet do
			local _, accountName, battleTag, isOnline, _, _, _, _, _, toonName, _, _, _, _, className, _, zoneName, level = BNGetFriendInfo(i)
			if isOnline then
				local classColor = Core.HexRGB(Core:ClassColor(className) or {r=1,g=1,b=1})
				local displayName = toonName or battleTag or accountName or UNKNOWN
				GameTooltip:AddDoubleLine(
					format("%s%s|r", classColor, displayName),
					format("%d %s", level or 0, zoneName or UNKNOWN)
				)
				onlineBNet = onlineBNet + 1
				if onlineBNet >= FRIENDS_TOOLTIP_MAX then
					GameTooltip:AddLine(format(L["And %d more bnet friends..."], numBNet - onlineBNet), 0.7, 0.7, 0.7)
					break
				end
			end
		end
	end

	GameTooltip:Show()
end

local function OnEvent(self)
	local numFriends = C_FriendList_GetNumFriends() or 0
	local numBNet = BNGetNumFriends() or 0

	local onlineFriends = 0
	for i = 1, numFriends do
		local info = C_FriendList_GetFriendInfoByIndex(i)
		if info and info.connected then
			onlineFriends = onlineFriends + 1
		end
	end

	local onlineBNet = 0
	for i = 1, numBNet do
		local _, _, _, isOnline = BNGetFriendInfo(i)
		if isOnline then
			onlineBNet = onlineBNet + 1
		end
	end

	local totalOnline = onlineFriends + onlineBNet
	local classColor = Core.HexRGB(Core:ClassColor(DB.MyClass))
	self.Text:SetText(format("%s: %s%d|r", L["Friends"], classColor, totalOnline))
end

local function OnEnter(self)
	UpdateTooltip(self)
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
