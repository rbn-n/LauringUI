local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local format, max = format, max
local GetNetStats = GetNetStats
local GetNetIpTypes = GetNetIpTypes
local GetCVarBool = GetCVarBool
local GetAvailableBandwidth = GetAvailableBandwidth
local GetDownloadedPercentage = GetDownloadedPercentage
local GetFileStreamingStatus = GetFileStreamingStatus
local GetBackgroundLoadingStatus = GetBackgroundLoadingStatus
local UNKNOWN = UNKNOWN

local ipTypes = {"IPv4", "IPv6"}
local entered

local function colorLatency(latency)
	if latency < 250 then
		return "|cff0CD809"..latency
	elseif latency < 500 then
		return "|cffE8DA0F"..latency
	else
		return "|cffD80909"..latency
	end
end

local function RefreshTooltip(self)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["Latency"], 0, 0.6, 1)
	GameTooltip:AddLine(" ")

	local _, _, latencyHome, latencyWorld = GetNetStats()
	GameTooltip:AddDoubleLine(L["Home Latency"], colorLatency(latencyHome).."|r ms", 0.6, 0.8, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L["World Latency"], colorLatency(latencyWorld).."|r ms", 0.6, 0.8, 1, 1, 1, 1)

	if GetCVarBool("useIPv6") then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes()
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Home Protocol"], ipTypes[ipTypeHome] or UNKNOWN, 0.6, 0.8, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["World Protocol"], ipTypes[ipTypeWorld] or UNKNOWN, 0.6, 0.8, 1, 1, 1, 1)
	end

	local downloading = GetFileStreamingStatus() ~= 0 or GetBackgroundLoadingStatus() ~= 0
	if downloading then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Bandwidth"], format("%.2f Mbps", GetAvailableBandwidth()), 0.6, 0.8, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Download"], format("%.2f%%", GetDownloadedPercentage() * 100), 0.6, 0.8, 1, 1, 1, 1)
	end

	GameTooltip:Show()
end


local function UpdateLatency(self)
	local _, _, latencyHome, latencyWorld = GetNetStats()
	local latency = max(latencyHome, latencyWorld)
	self.Text:SetText(L["Latency"]..": "..colorLatency(latency))
end

local function OnEnter(self)
    entered = true
    local _, anchor, offset = module:GetTooltipAnchor(self)
    GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
    RefreshTooltip(self)
end

local function OnLeave()
	entered = false
	GameTooltip:Hide()
end

local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 1 then
		self.timer = 0
		UpdateLatency(self)
		if entered then
			OnEnter(self)
		end
	end
end

module:RegisterDataText("Latency", {
	panel = module.CentralBottomPanel,
	anchor = "LEFT",
	events = { "PLAYER_ENTERING_WORLD", "VARIABLES_LOADED" },
	onEvent = UpdateLatency,
	onUpdate = OnUpdate,
	onEnter = OnEnter,
	onLeave = OnLeave,
})
