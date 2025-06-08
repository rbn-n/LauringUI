local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local format = string.format
local wipe = table.wipe or wipe
local ipairs = ipairs
local sort = table.sort
local insert = table.insert
local next = next

-- WoW API
local collectgarbage = collectgarbage
local gcinfo = gcinfo
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local GetAddOnInfo = C_AddOns and C_AddOns.GetAddOnInfo or GetAddOnInfo
local IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local GetNumAddOns = C_AddOns and C_AddOns.GetNumAddOns or GetNumAddOns

local infoTable = {}

-- Format memory usage into human-readable string
local function FormatMemory(value)
	if value > 1024 then
		return format("%.1f MB", value / 1024)
	else
		return format("%.0f KB", value)
	end
end

local function BuildAddonList()
	local numAddons = GetNumAddOns()
	if #infoTable == numAddons then return end

	wipe(infoTable)
	for i = 1, numAddons do
		local _, title, _, loadable = GetAddOnInfo(i)
		if loadable and title then
			insert(infoTable, { i, title, 0 })
		end
	end
end

local function UpdateMemoryUsage()
	UpdateAddOnMemoryUsage()

	local total = 0
	for _, data in ipairs(infoTable) do
		if IsAddOnLoaded(data[1]) then
			local mem = GetAddOnMemoryUsage(data[1]) or 0
			data[3] = mem
			total = total + mem
		end
	end

	sort(infoTable, function(a, b)
		return a[3] > b[3]
	end)

	return total
end

local function OnEvent(self)
	if not next(infoTable) then BuildAddonList() end
	local total = UpdateMemoryUsage()
	self.Text:SetText(L["System"] .. ": " .. FormatMemory(total))
end

local function OnEnter(self)
	if not next(infoTable) then BuildAddonList() end
	local total = UpdateMemoryUsage()

	local _, anchor, offset = module:GetTooltipAnchor(self)
	GameTooltip:SetOwner(self, "ANCHOR_" .. anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["System"], 0.6, 0.8, 1)
	GameTooltip:AddDoubleLine(L["Total Memory"], FormatMemory(total), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddLine(" ")

	local shown = 0
	local maxShown = 15
	for _, data in ipairs(infoTable) do
		if shown >= maxShown then break end
		if IsAddOnLoaded(data[1]) then
			GameTooltip:AddDoubleLine(data[2], FormatMemory(data[3]), 1, 1, 1, 1, 1, 1)
			shown = shown + 1
		end
	end

	if #infoTable > maxShown then
		GameTooltip:AddLine(format("...%d more", #infoTable - maxShown), 0.6, 0.8, 1)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["LeftClickToCollect"], 0.7, 0.7, 0.7)
	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

local updateInterval = 10
local elapsed = 0

local function OnUpdate(self, delta)
	elapsed = elapsed + delta
	if elapsed >= updateInterval then
		if not next(infoTable) then BuildAddonList() end
		local total = UpdateMemoryUsage()
		self.Text:SetText(L["System"] .. ": " .. FormatMemory(total))
		elapsed = 0
	end
end

local function OnMouseUp(self, button)
	if button == "LeftButton" then
		local before = gcinfo()
		collectgarbage("collect")
		local freed = before - gcinfo()
		print(format("|cff66C6FF%s:|r %s", L["Collect Memory"], FormatMemory(freed)))

		OnEvent(self)  -- Update displayed memory
		OnEnter(self)  -- Refresh tooltip (if visible)
	end
end

module:RegisterDataText("System", {
	panel = module.CentralBottomPanel,
	anchor = "RIGHT",
	events = {
		"PLAYER_ENTERING_WORLD",
		"ADDON_LOADED",
	},
	onEvent = OnEvent,
	onEnter = OnEnter,
	onLeave = OnLeave,
	onMouseUp = OnMouseUp,
	onUpdate = OnUpdate,
})
