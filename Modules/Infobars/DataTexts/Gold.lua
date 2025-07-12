local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local profit, spent, oldMoney = 0, 0, 0
local showSession = false
local myRealm, myName, myClass = DB.MyRealm, DB.MyName, DB.MyClass

local function UpdateStoredGold(money)
	LauringUIAccountDB.TotalGold = LauringUIAccountDB.TotalGold or {}
	LauringUIAccountDB.TotalGold[myRealm] = LauringUIAccountDB.TotalGold[myRealm] or {}
	LauringUIAccountDB.TotalGold[myRealm][myName] = {money, myClass}
end

local function ResetSession()
	profit, spent = 0, 0
end

local function WipeGoldData()
	LauringUIAccountDB.TotalGold = {}
	LauringUIAccountDB.TotalGold[myRealm] = {}
	LauringUIAccountDB.TotalGold[myRealm][myName] = {GetMoney(), myClass}
end

local firstUpdateDone = false

local function UpdateText(self)
	local money = GetMoney()
	local displayAmount = showSession and (profit - spent) or money
	self.Text:SetText(Core:FormatGold(displayAmount, true))
end

local function OnEvent(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		oldMoney = GetMoney()
		UpdateStoredGold(oldMoney)
		UpdateText(self) -- <=== Force show gold now
		self:UnregisterEvent(event)
		return
	end

	local money = GetMoney()
	local change = money - oldMoney

	if firstUpdateDone then
		if change > 0 then
			profit = profit + change
		elseif change < 0 then
			spent = spent - change
		end
	else
		firstUpdateDone = true
	end

	oldMoney = money
	UpdateStoredGold(money)
	UpdateText(self)
end

local function OnEnter(self)
	local anchor, offset = module:GetTooltipAnchor(self)
	GameTooltip:SetOwner(self, "ANCHOR_" .. anchor, 0, offset)
	GameTooltip:ClearLines()

	GameTooltip:AddLine(CURRENCY, 0.6, 0.8, 1)
	GameTooltip:AddLine(" ")

	GameTooltip:AddLine(L["Session"], 0.6, 0.8, 1)
	GameTooltip:AddDoubleLine(L["Earned"], Core:FormatGold(profit, true), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Spent"], Core:FormatGold(spent, true), 1, 1, 1, 1, 1, 1)

	if profit > spent then
		GameTooltip:AddDoubleLine(L["Profit"], Core:FormatGold(profit - spent, true), 0, 1, 0, 1, 1, 1)
	elseif spent > profit then
		GameTooltip:AddDoubleLine(L["Deficit"], Core:FormatGold(spent - profit, true), 1, 0, 0, 1, 1, 1)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["RealmCharacter"], 0.6, 0.8, 1)

	local total = 0
	for realm, chars in pairs(LauringUIAccountDB.TotalGold or {}) do
		for name, data in pairs(chars) do
			local money, class = unpack(data)
			local color = DB.ClassColors[class] or { r = 1, g = 1, b = 1 }
			GameTooltip:AddDoubleLine(name .. " - " .. realm, Core:FormatGold(money), color.r, color.g, color.b, 1, 1, 1)
			total = total + money
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(TOTAL .. ":", Core:FormatGold(total), 0.6, 0.8, 1, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(DB.LeftButton .. "+ALT " .. L["Reset Gold"], "", 0.7, 0.7, 0.7)
	GameTooltip:AddDoubleLine(DB.RightButton .. "+ALT " .. L["Reset Session"], "", 0.7, 0.7, 0.7)

	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

local function OnMouseUp(self, button)
	if button == "RightButton" then
		if IsAltKeyDown() then
			ResetSession()
		else
			showSession = not showSession
		end
		OnEvent(self)
	elseif button == "LeftButton" and IsAltKeyDown() then
		WipeGoldData()
		OnEvent(self)
	end
end

module:RegisterDataText("Gold", {
	panel = module.RightBottomPanel,
	anchor = "RIGHT",
	events = {
		"PLAYER_MONEY",
		"SEND_MAIL_MONEY_CHANGED",
		"SEND_MAIL_COD_CHANGED",
		"PLAYER_TRADE_MONEY",
		"TRADE_MONEY_CHANGED",
		"PLAYER_ENTERING_WORLD",
	},
	onEvent = OnEvent,
	onEnter = OnEnter,
	onLeave = OnLeave,
	onMouseUp = OnMouseUp,
})
