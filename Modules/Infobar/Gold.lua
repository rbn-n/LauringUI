local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobar")

local INFO = module:RegisterInfobar("Gold", Config.Infobar.GoldPosition)

local format, pairs, wipe, unpack = string.format, pairs, table.wipe, unpack
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local GetMoney = GetMoney
local C_Timer_After, IsControlKeyDown, IsShiftKeyDown = C_Timer.After, IsControlKeyDown, IsShiftKeyDown
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local CalculateTotalNumberOfFreeBagSlots = CalculateTotalNumberOfFreeBagSlots
local slotString = L["Bags"]..": %s%d"

local profit, spent, oldMoney = 0, 0, 0
local myName, myRealm = DB.MyName, DB.MyRealm

local crossRealms = GetAutoCompleteRealms()
if not crossRealms or #crossRealms == 0 then
	crossRealms = {[1]=myRealm}
end

StaticPopupDialogs["RESETGOLD"] = {
	text = L["Are you sure to reset the gold count?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		for _, realm in pairs(crossRealms) do
			if LauringUIAccountDB["TotalGold"][realm] then
				wipe(LauringUIAccountDB["TotalGold"][realm])
			end
		end
		LauringUIAccountDB["TotalGold"][myRealm][myName] = {GetMoney(), DB.MyClass}
	end,
	whileDead = 1,
}

local menuList = {
	{text = Core.HexRGB(1, .8, 0)..REMOVE_WORLD_MARKERS.."!!!", notCheckable = true, func = function() StaticPopup_Show("RESETGOLD") end},
}

local function getClassIcon(class)
	local c1, c2, c3, c4 = unpack(CLASS_ICON_TCOORDS[class])
	c1, c2, c3, c4 = (c1+.03)*50, (c2-.03)*50, (c3+.03)*50, (c4-.03)*50
	local classStr = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:13:15:0:-1:50:50:"..c1..":"..c2..":"..c3..":"..c4.."|t "
	return classStr or ""
end

local function getSlotString()
	local num = CalculateTotalNumberOfFreeBagSlots()
	if num < 10 then
		return format(slotString, "|cffff0000", num)
	else
		return format(slotString, "|cff00ff00", num)
	end
end

INFO.eventList = {
	"PLAYER_MONEY",
	"SEND_MAIL_MONEY_CHANGED",
	"SEND_MAIL_COD_CHANGED",
	"PLAYER_TRADE_MONEY",
	"TRADE_MONEY_CHANGED",
	"PLAYER_ENTERING_WORLD",
}

INFO.onEvent = function(self, event, arg1)
	if event == "PLAYER_ENTERING_WORLD" then
		oldMoney = GetMoney()
		self:UnregisterEvent(event)

		if LauringUIAccountDB["ShowSlots"] then
			self:RegisterEvent("BAG_UPDATE")
		end
	elseif event == "BAG_UPDATE" then
		if arg1 < 0 or arg1 > 4 then return end
	end

	local newMoney = GetMoney()
	local change = newMoney - oldMoney	-- Positive if we gain money
	if oldMoney > newMoney then			-- Lost Money
		spent = spent - change
	else								-- Gained Moeny
		profit = profit + change
	end
	if LauringUIAccountDB["ShowSlots"] then
		self.text:SetText(getSlotString())
	else
		self.text:SetText(module:GetMoneyString(newMoney))
	end

	if not LauringUIAccountDB["TotalGold"][myRealm] then LauringUIAccountDB["TotalGold"][myRealm] = {} end
	if not LauringUIAccountDB["TotalGold"][myRealm][myName] then LauringUIAccountDB["TotalGold"][myRealm][myName] = {} end
	LauringUIAccountDB["TotalGold"][myRealm][myName][1] = GetMoney()
	LauringUIAccountDB["TotalGold"][myRealm][myName][2] = DB.MyClass

	oldMoney = newMoney
end

local RebuildCharList

local function clearCharGold(_, realm, name)
	LauringUIAccountDB["TotalGold"][realm][name] = nil
	DropDownList1:Hide()
	RebuildCharList()
end

function RebuildCharList()
	for i = 2, #menuList do
		if menuList[i] then wipe(menuList[i]) end
	end

	local charList = {}
	for _, realm in pairs(crossRealms) do
		if LauringUIAccountDB["TotalGold"][realm] then
			for name, value in pairs(LauringUIAccountDB["TotalGold"][realm]) do
				if not (realm == myRealm and name == myName) then
					table.insert(charList, {
						realm = realm,
						name = name,
						gold = value[1],
						class = value[2],
					})
				end
			end
		end
	end

	table.sort(charList, function(a, b)
		return a.gold > b.gold
	end)

	local index = 1
	for _, entry in ipairs(charList) do
		index = index + 1
		if not menuList[index] then menuList[index] = {} end
		menuList[index].text = Core.HexRGB(Core.ClassColor(entry.class))..Ambiguate(entry.name.."-"..entry.realm, "none")
		menuList[index].notCheckable = true
		menuList[index].arg1 = entry.realm
		menuList[index].arg2 = entry.name
		menuList[index].func = clearCharGold
	end
end

INFO.onMouseUp = function(self, btn)
	if btn == "RightButton" then
		if IsControlKeyDown() then
			if not menuList[1].created then
				RebuildCharList()
				menuList[1].created = true
			end
			EasyMenu(menuList, Core.EasyMenu, self, -80, 100, "MENU", 1)
		else
			LauringUIAccountDB["ShowSlots"] = not LauringUIAccountDB["ShowSlots"]
			if LauringUIAccountDB["ShowSlots"] then
				self:RegisterEvent("BAG_UPDATE")
			else
				self:UnregisterEvent("BAG_UPDATE")
			end
			self:onEvent()
		end
	elseif btn == "MiddleButton" then
		LauringUIAccountDB["AutoSell"] = not LauringUIAccountDB["AutoSell"]
		self:onEnter()
	else
		if LauringUIAccountDB["ShowSlots"] then
			ToggleAllBags()
		else
			--if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
			ToggleCharacter("TokenFrame")
		end
	end
end

local replacedTextures = {
	[136998] = "Interface\\PVPFrame\\PVP-Currency-Alliance",
	[137000] = "Interface\\PVPFrame\\PVP-Currency-Horde",
}

INFO.onEnter = function(self)
	local _, anchor, offset = module:GetTooltipAnchor(INFO)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(CURRENCY, 0,.6,1)
	GameTooltip:AddLine(" ")

	GameTooltip:AddLine(L["Session"], .6,.8,1)
	GameTooltip:AddDoubleLine(L["Earned"], module:GetMoneyString(profit, true), 1,1,1, 1,1,1)
	GameTooltip:AddDoubleLine(L["Spent"], module:GetMoneyString(spent, true), 1,1,1, 1,1,1)
	if profit < spent then
		GameTooltip:AddDoubleLine(L["Deficit"], module:GetMoneyString(spent-profit, true), 1,0,0, 1,1,1)
	elseif profit > spent then
		GameTooltip:AddDoubleLine(L["Profit"], module:GetMoneyString(profit-spent, true), 0,1,0, 1,1,1)
	end
	GameTooltip:AddLine(" ")

	local charList, totalGold = {}, 0
	for _, realm in pairs(crossRealms) do
		local thisRealmList = LauringUIAccountDB["TotalGold"][realm]
		if thisRealmList then
			for name, v in pairs(thisRealmList) do
				local gold, class = unpack(v)
				table.insert(charList, {
					fullName = Ambiguate(name.."-"..realm, "none"),
					gold = gold,
					class = class,
				})
				totalGold = totalGold + gold
			end
		end
	end

	table.sort(charList, function(a, b)
		return a.gold > b.gold -- highest first
	end)

	GameTooltip:AddLine(L["RealmCharacter"], .6,.8,1)
	for _, entry in ipairs(charList) do
		local r, g, b = Core.ClassColor(entry.class)
		GameTooltip:AddDoubleLine(
			getClassIcon(entry.class)..entry.fullName,
			module:GetMoneyString(entry.gold),
			r,g,b, 1,1,1
		)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(TOTAL..":", module:GetMoneyString(totalGold), .6,.8,1, 1,1,1)

	for i = 1, GetNumWatchedTokens() do
		local name, count, icon, currencyID = GetBackpackCurrencyInfo(i)
		if name and i == 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(CURRENCY..":", .6,.8,1)
		end
		if name and count then
			local total = C_CurrencyInfo_GetCurrencyInfo(currencyID).maxQuantity
			icon = replacedTextures[icon] or icon
			local iconTexture = " |T"..icon..":13:15:0:0:50:50:4:46:4:46|t"
			if total > 0 then
				GameTooltip:AddDoubleLine(name, count.."/"..total..iconTexture, 1,1,1, 1,1,1)
			else
				GameTooltip:AddDoubleLine(name, count..iconTexture, 1,1,1, 1,1,1)
			end
		end
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Switch Mode"].." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.ScrollButton..L["AutoSell Junk"]..": "..(LauringUIAccountDB["AutoSell"] and "|cff55ff55"..VIDEO_OPTIONS_ENABLED or "|cffff5555"..VIDEO_OPTIONS_DISABLED).." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", "CTRL +"..DB.RightButton..L["Reset Gold"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

INFO.onLeave = Core.HideTooltip

-- Auto selljunk
local sellCount, stop, cache = 0, true, {}
local errorText = _G.ERR_VENDOR_DOESNT_BUY

local function stopSelling(tell)
	stop = true
	if sellCount > 0 and tell then
		print(format("|cff99CCFF%s|r%s", L["Selljunk Calculate"], module:GetMoneyString(sellCount, true)))
	end
	sellCount = 0
end

local function StartSelling()
	if stop then return end
	for bag = 0, 4 do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			if stop then return end
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info then
				local quality, link, noValue, itemID = info.quality, info.hyperlink, info.hasNoValue, info.itemID
				if link and not noValue and (quality == 0 or LauringUIAccountDB["CustomJunkList"][itemID]) and not cache["b"..bag.."s"..slot] then
					cache["b"..bag.."s"..slot] = true
					C_Container.UseContainerItem(bag, slot)
					C_Timer_After(.15, StartSelling)
					return
				end
			end
		end
	end
end

local function UpdateSelling(event, ...)
	if not LauringUIAccountDB["AutoSell"] then return end

	local _, arg = ...
	if event == "MERCHANT_SHOW" then
		if IsShiftKeyDown() then return end
		stop = false
		wipe(cache)
		StartSelling()
		Core:RegisterEvent("UI_ERROR_MESSAGE", UpdateSelling)
	elseif event == "UI_ERROR_MESSAGE" and arg == errorText then
		stopSelling(false)
	elseif event == "MERCHANT_CLOSED" then
		stopSelling(true)
	end
end

Core:RegisterEvent("MERCHANT_SHOW", UpdateSelling)
Core:RegisterEvent("MERCHANT_CLOSED", UpdateSelling)