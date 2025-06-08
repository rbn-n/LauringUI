local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local oUF = ns.oUF
local module = Core:GetModule("Infobars")

local format, sort, floor, select = string.format, table.sort, math.floor, select
local GetInventoryItemLink, GetInventoryItemDurability, GetInventoryItemTexture = GetInventoryItemLink, GetInventoryItemDurability, GetInventoryItemTexture
local GetMoney, GetRepairAllCost, RepairAllItems, CanMerchantRepair = GetMoney, GetRepairAllCost, RepairAllItems, CanMerchantRepair
local IsInGuild, CanGuildBankRepair, GetGuildBankWithdrawMoney = IsInGuild, CanGuildBankRepair, GetGuildBankWithdrawMoney
local IsShiftKeyDown = IsShiftKeyDown
local C_Timer_After = C_Timer.After
local GameTooltip = GameTooltip
local NONE = NONE
local DURABILITY = DURABILITY
local INVTYPE_HEAD, INVTYPE_SHOULDER, INVTYPE_CHEST, INVTYPE_WAIST = INVTYPE_HEAD, INVTYPE_SHOULDER, INVTYPE_CHEST, INVTYPE_WAIST
local INVTYPE_WRIST, INVTYPE_WEAPONMAINHAND, INVTYPE_WEAPONOFFHAND, INVTYPE_RANGED = INVTYPE_WRIST, INVTYPE_WEAPONMAINHAND, INVTYPE_WEAPONOFFHAND, INVTYPE_RANGED
local gsub = string.gsub
local mod = math.fmod

local repairCostString = gsub(REPAIR_COST, HEADER_COLON, ":")

local cachedRepairCost = 0
local maxDurability = 1000
local equipmentSlots = {
	{1, INVTYPE_HEAD, maxDurability},
	{3, INVTYPE_SHOULDER, maxDurability},
	{5, INVTYPE_CHEST, maxDurability},
	{6, INVTYPE_WAIST, maxDurability},
	{9, INVTYPE_WRIST, maxDurability},
	{10, L["Hands"], maxDurability},
	{7, INVTYPE_LEGS, maxDurability},
	{8, L["Feet"], maxDurability},
	{16, INVTYPE_WEAPONMAINHAND, maxDurability},
	{17, INVTYPE_WEAPONOFFHAND, maxDurability},
	{18, INVTYPE_RANGED, maxDurability},
}

local isShown, isBankEmpty, repairAllCost, canRepair

local function SortSlots(a, b)
	return (a[3] == b[3] and a[1] < b[1]) or (a[3] < b[3])
end

local function UpdateAllSlots()
	local numSlots = 0
	for i = 1, #equipmentSlots do
		local slot = equipmentSlots[i][1]
		equipmentSlots[i][3] = 1000
		if GetInventoryItemLink("player", slot) then
			local cur, max = GetInventoryItemDurability(slot)
			if cur then
				equipmentSlots[i][3] = cur / max
				numSlots = numSlots + 1
			end
			local texture = GetInventoryItemTexture("player", slot) or 134400
			equipmentSlots[i][4] = "|T" .. texture .. ":13:15:0:0:50:50:4:46:4:46|t"
		end
	end
	sort(equipmentSlots, SortSlots)
	return numSlots
end

local function GetDurabilityColor(cur, max)
	return oUF:RGBColorGradient(cur, max, 1, 0, 0, 1, 1, 0, 0, 1, 0)
end

local function OnEvent(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent(event)
	end

	if UpdateAllSlots() > 0 then
		local percent = floor(equipmentSlots[1][3] * 100)
		local r, g, b = GetDurabilityColor(percent, 100)
		self.Text:SetFormattedText("%s: %s%%|r", L["D"], Core.HexRGB(r, g, b) .. percent)
	else
		self.Text:SetText(L["D"] .. ": " .. DB.MyColor .. NONE)
	end

	cachedRepairCost = 0
	Core.ScanTip:SetOwner(UIParent, "ANCHOR_NONE")  -- only once here

	for i = 1, #equipmentSlots do
		if equipmentSlots[i][3] ~= 1000 then
			cachedRepairCost = cachedRepairCost +
			select(3, Core.ScanTip:SetInventoryItem("player", equipmentSlots[i][1]))
		end
	end
end

local repairList = {
	[0] = "|cffff5555" .. VIDEO_OPTIONS_DISABLED,
	[1] = "|cff55ff55" .. VIDEO_OPTIONS_ENABLED,
	[2] = "|cffffff55" .. L["NFG"]
}

local function OnEnter(self)
	local anchor, offset = module:GetTooltipAnchor(self)
	GameTooltip:SetOwner(self, "ANCHOR_" .. anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(DURABILITY, " ", 0, .6, 1, 0, .6, 1)
	GameTooltip:AddLine(" ")

	local totalCost = 0
	for i = 1, #equipmentSlots do
		if equipmentSlots[i][3] ~= 1000 then
			local cur = floor(equipmentSlots[i][3] * 100)
			equipmentSlots[i][4] = equipmentSlots[i][4] or ""
			GameTooltip:AddDoubleLine(equipmentSlots[i][4] .. equipmentSlots[i][2], cur .. "%", 1, 1, 1, GetDurabilityColor(cur, 100))
			Core.ScanTip:SetOwner(UIParent, "ANCHOR_NONE")
			totalCost = totalCost + select(3, Core.ScanTip:SetInventoryItem("player", equipmentSlots[i][1]))
		end
	end

	if totalCost > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(repairCostString, module:FormatGold(totalCost), .6, .8, 1, 1, 1, 1)
	end

	GameTooltip:AddLine(" ")
    local repairType = LauringUIAccountDB["RepairType"] or 0
    GameTooltip:AddDoubleLine(" ", DB.LeftButton .. L["Auto Repair"] .. ": " .. repairList[repairType] .. " ", 1, 1, 1, .6, .8, 1)
	GameTooltip:Show()
end

local function OnMouseUp(self, btn)
	if btn == "MiddleButton" then
		LauringUIAccountDB["RepairType"] = mod(LauringUIAccountDB["RepairType"] + 1, 3)
		OnEnter(self)
	elseif btn == "LeftButton" then
		local current = LauringUIAccountDB["RepairType"] or 0
		if current == 0 then
			LauringUIAccountDB["RepairType"] = 1
		else
			LauringUIAccountDB["RepairType"] = 0
		end
		OnEnter(self)
	end
end

local function OnLeave()
	GameTooltip:Hide()
end

local function DelayFunc()
	if isBankEmpty then
		AutoRepair(true)
	else
		print(format(DB.InfoColor .. "%s|r%s", L["Guild repair"], module:FormatGold(repairAllCost, true)))
	end
end

function AutoRepair(override)
	if isShown and not override then return end
	isShown, isBankEmpty = true, false

	local myMoney = GetMoney()
	repairAllCost, canRepair = GetRepairAllCost()

	if canRepair and repairAllCost > 0 then
        local withdrawLimit = GetGuildBankWithdrawMoney() or 0
		if not override and LauringUIAccountDB["RepairType"] == 1 and IsInGuild() and CanGuildBankRepair() and withdrawLimit >= repairAllCost then
			RepairAllItems(true)
		elseif myMoney > repairAllCost then
			RepairAllItems()
			print(format(DB.InfoColor .. "%s|r%s", L["Repair cost"], module:FormatGold(repairAllCost, true)))
			return
		else
			print(format("%s%s", DB.InfoColor, L["Repair error"]))
			return
		end
		C_Timer_After(.5, DelayFunc)
	end
end

local function CheckBankFund(_, msgType)
	if msgType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then
		isBankEmpty = true
	end
end

local function MerchantClose()
	isShown = false
	Core:UnregisterEvent("UI_ERROR_MESSAGE", CheckBankFund)
	Core:UnregisterEvent("MERCHANT_CLOSED", MerchantClose)
end

local function MerchantShow()
	if not LauringUIAccountDB["Help"]["AutoRepair"] then
		Core:ShowHelpTip(MerchantFrame, L["AutoRepairInfo"], "RIGHT", 20, 0, nil, "AutoRepair")
	end

	if IsShiftKeyDown() or LauringUIAccountDB["RepairType"] == 0 or not CanMerchantRepair() then return end
	AutoRepair()
	Core:RegisterEvent("UI_ERROR_MESSAGE", CheckBankFund)
	Core:RegisterEvent("MERCHANT_CLOSED", MerchantClose)
end

Core:RegisterEvent("MERCHANT_SHOW", MerchantShow)

module:RegisterDataText("Durability", {
	panel = module.RightBottomPanel,
	anchor = "LEFT",
	events = {
		"UPDATE_INVENTORY_DURABILITY",
		"PLAYER_ENTERING_WORLD"
	},
	onEvent = OnEvent,
	onEnter = OnEnter,
	onLeave = OnLeave,
	onMouseUp = OnMouseUp,
})