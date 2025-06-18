local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local profit, spent, oldMoney = 0, 0, 0
local showSession = false

local function UpdateStoredGold()
	local realm, name, class = DB.MyRealm, DB.MyName, DB.MyClass
	LauringUIDB.gold = LauringUIDB.gold or {}
	LauringUIDB.gold[realm] = LauringUIDB.gold[realm] or {}
	LauringUIDB.gold[realm][name] = {
		money = GetMoney(),
		class = class,
	}
end

local function ResetSession()
	profit, spent = 0, 0
end

local function WipeGoldData()
	local realm, name, class = DB.MyRealm, DB.MyName, DB.MyClass
	local current = {
		money = GetMoney(),
		class = class,
	}

	LauringUIDB.gold = {}
	LauringUIDB.gold[realm] = {}
	LauringUIDB.gold[realm][name] = current
end

local function OnEvent(self)
	local newMoney = GetMoney()

	if not oldMoney then
		oldMoney = newMoney
		UpdateStoredGold()
	else
		local change = newMoney - oldMoney
		if change > 0 then
			profit = profit + change
		elseif change < 0 then
			spent = spent - change
		end

		oldMoney = newMoney
		UpdateStoredGold()
	end

	self.Text:SetText(showSession and Core:FormatGold(profit - spent) or Core:FormatGold(newMoney))
end

local function OnEnter(self)
	local anchor, offset = module:GetTooltipAnchor(self)
	GameTooltip:SetOwner(self, "ANCHOR_" .. anchor, 0, offset)
	GameTooltip:ClearLines()

	GameTooltip:AddLine("Gold", 0.6, 0.8, 1)
	GameTooltip:AddLine(" ")

	GameTooltip:AddLine("Session", 0.8, 0.8, 0.8)
	GameTooltip:AddDoubleLine("Earned:", Core:FormatGold(profit), 1, 1, 1)
	GameTooltip:AddDoubleLine("Spent:", Core:FormatGold(spent), 1, 1, 1)

	local net = profit - spent
	if net >= 0 then
		GameTooltip:AddDoubleLine("Profit:", Core:FormatGold(net), 0, 1, 0)
	else
		GameTooltip:AddDoubleLine("Deficit:", Core:FormatGold(-net), 1, 0, 0)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Characters", 0.8, 0.8, 0.8)

	local total = 0
	for realm, players in pairs(LauringUIDB.gold or {}) do
		for name, data in pairs(players) do
			local class = data.class
			local money = data.money
			local color = DB.ClassColors[class] or { r = 1, g = 1, b = 1 }
			GameTooltip:AddDoubleLine(name .. " - " .. realm, Core:FormatGold(money), color.r, color.g, color.b, 1, 1, 1)
			total = total + money
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Total:", Core:FormatGold(total), 0.6, 0.8, 1, 1, 1, 1)

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(DB.LeftButton .. "+ALT " .. "Reset All Character Gold", "", 0.7, 0.7, 0.7, 0.7, 0.7, 0.7)
	GameTooltip:AddDoubleLine(DB.RightButton .. "+ALT " .. "Reset Session", "", 0.7, 0.7, 0.7, 0.7, 0.7, 0.7)

	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

local function OnMouseUp(self, button)
	if button == "RightButton" then
		if IsAltKeyDown() then
			ResetSession()
		end
		OnEvent(self)
	elseif button == "LeftButton" then
		if IsAltKeyDown() then
			WipeGoldData()
			OnEvent(self)
		end
	end
end

module:RegisterDataText("Gold", {
	panel = module.RightBottomPanel,
	anchor = "LEFT",
	events = { "PLAYER_MONEY", "PLAYER_ENTERING_WORLD" },
	onEvent = OnEvent,
	onEnter = OnEnter,
	onLeave = OnLeave,
	onMouseUp = OnMouseUp,
})
