local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local format, tonumber = format, tonumber
local date = date
local select = select

-- WoW API
local GetCVarBool = GetCVarBool
local GetGameTime = GetGameTime
local GameTime_GetLocalTime = GameTime_GetLocalTime
local GameTime_GetGameTime = GameTime_GetGameTime
local SecondsToTime = SecondsToTime
local RequestRaidInfo = RequestRaidInfo
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceInfo = GetSavedInstanceInfo
local CalendarTime = C_DateAndTime.GetCurrentCalendarTime

-- Time formatting
local function GetFormattedTime()
	local hour, minute
	if GetCVarBool("timeMgrUseLocalTime") then
		hour, minute = tonumber(date("%H")), tonumber(date("%M"))
	else
		hour, minute = GetGameTime()
	end

	local use24 = GetCVarBool("timeMgrUseMilitaryTime")
	if use24 then
		return format("%02d:%02d", hour, minute)
	else
		local suffix = hour < 12 and "AM" or "PM"
		if hour == 0 then
			hour = 12
		elseif hour > 12 then
			hour = hour - 12
		end
		return format("%02d:%02d %s", hour, minute, suffix)
	end
end

-- Shared update
local function UpdateTime(self)
	self.Text:SetText(DB.MyColor .. GetFormattedTime())
end

-- Update every 5 seconds
local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 5 then
		UpdateTime(self)
		self.timer = 0
	end
end

-- Immediate update on event
local function OnEvent(self)
	UpdateTime(self)
end

-- Tooltip
local function OnEnter(self)
	RequestRaidInfo()

	local _, anchor, offset = module:GetTooltipAnchor(self)
	GameTooltip:SetOwner(self, "ANCHOR_" .. anchor, 0, offset)
	GameTooltip:ClearLines()

	local today = CalendarTime()
	GameTooltip:AddLine(format(FULLDATE, CALENDAR_WEEKDAY_NAMES[today.weekday], CALENDAR_FULLDATE_MONTH_NAMES[today.month], today.monthDay, today.year), 0, .6, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Local Time"], GameTime_GetLocalTime(true), .6, .8, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Realm Time"], GameTime_GetGameTime(true), .6, .8, 1, 1, 1, 1)

	local r, g, b
	local titleShown = false
	local function AddTitle(text)
		if not titleShown then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(text .. ":", .6, .8, 1)
			titleShown = true
		end
	end

	-- Mythic+ instances
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, diff, locked, extended = GetSavedInstanceInfo(i)
		if diff == 23 and (locked or extended) then
			AddTitle(DUNGEON_DIFFICULTY3 .. " " .. DUNGEONS)
			r, g, b = extended and .3 or 1, extended and 1 or 1, extended and .3 or 1
			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	-- Raid lockouts
	titleShown = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, _, locked, extended, _, isRaid, _, diffName = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) then
			AddTitle(RAID_INFO)
			r, g, b = extended and .3 or 1, extended and 1 or 1, extended and .3 or 1
			GameTooltip:AddDoubleLine(name .. " - " .. diffName, SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(DB.LeftButton .. L["Toggle Calendar"], "", .6, .8, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(DB.RightButton .. L["Toggle Clock"], "", .6, .8, 1, 1, 1, 1)
	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

local function OnMouseUp(_, btn)
	if btn == "RightButton" then
		TimeManager_LoadUI()
		if TimeManager_Toggle then
			TimeManager_Toggle()
		end
	else
		ToggleCalendar()
	end
end

-- Register datatext
module:RegisterDataText("Time", {
	panel = module.RightBottomPanel,
	anchor = "LEFT",
	events = { "PLAYER_ENTERING_WORLD" },
	onEvent = OnEvent,
	onUpdate = OnUpdate,
	onEnter = OnEnter,
	onLeave = OnLeave,
	onMouseUp = OnMouseUp,
})
