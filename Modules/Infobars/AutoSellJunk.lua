local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local C_Timer_After = C_Timer.After
local sellCount, stop, cache = 0, true, {}
local errorText = _G.ERR_VENDOR_DOESNT_BUY

local function StopSelling(tell)
	stop = true
	if sellCount > 0 and tell then
		print(format("|cff99CCFF%s|r%s", L["Selljunk Calculate"], module:FormatGold(sellCount, true)))
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
				local quality, noValue = info.quality, info.hasNoValue
				if not noValue and quality == 0 then
					local slotKey = "b" .. bag .. "s" .. slot
					if not cache[slotKey] then
						cache[slotKey] = true
						local itemValue = select(11, C_Item.GetItemInfo(info.itemID)) or 0
						sellCount = sellCount + itemValue * info.stackCount
						C_Container.UseContainerItem(bag, slot)
						C_Timer_After(0.15, StartSelling)
						return
					end
				end
			end
		end
	end
end

local function UpdateSelling(event, ...)
	local _, arg = ...
	if event == "MERCHANT_SHOW" then
		if IsShiftKeyDown() then return end
		stop = false
		wipe(cache)
		StartSelling()
		Core:RegisterEvent("UI_ERROR_MESSAGE", UpdateSelling)
	elseif event == "UI_ERROR_MESSAGE" and arg == errorText then
		StopSelling(false)
	elseif event == "MERCHANT_CLOSED" then
		StopSelling(true)
	end
end

Core:RegisterEvent("MERCHANT_SHOW", UpdateSelling)
Core:RegisterEvent("MERCHANT_CLOSED", UpdateSelling)