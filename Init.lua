local addonName, ns = ...
ns[1] = {}			-- Core
ns[2] = {}			-- Config
ns[3] = {}			-- L, Locales
ns[4] = {}			-- DB

LauringUIDB, LauringUIAccountDB, LauringUICharacterDB = {}, {}, {}

local Core, Config, L, DB = unpack(ns)
local pairs, next, tinsert = pairs, next, table.insert
local min, max = math.min, math.max
local CombatLogGetCurrentEventInfo, GetPhysicalScreenSize = CombatLogGetCurrentEventInfo, GetPhysicalScreenSize

GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata -- deprecated

-- Events
local events = {}

local host = CreateFrame("Frame")
host:SetScript("OnEvent", function(_, event, ...)
	for func in pairs(events[event]) do
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			func(event, CombatLogGetCurrentEventInfo())
		else
			func(event, ...)
		end
	end
end)

function Core:RegisterEvent(event, func, unit1, unit2)
	if not events[event] then
		events[event] = {}
		if unit1 then
			host:RegisterUnitEvent(event, unit1, unit2)
		else
			host:RegisterEvent(event)
		end
	end

	events[event][func] = true
end

function Core:UnregisterEvent(event, func)
	local funcs = events[event]
	if funcs and funcs[func] then
		funcs[func] = nil

		if not next(funcs) then
			events[event] = nil
			host:UnregisterEvent(event)
		end
	end
end

local modules, initQueue = {}, {}

function Core:RegisterModule(name)
	if modules[name] then
		print("Module <"..name.."> already registered.")
	return end

	local module = {}
	module.name = name
	modules[name] = module

	tinsert(initQueue, module)
	return module
end

function Core:GetModule(name)
	if not modules[name] then print("Module <"..name.."> does not exist.") return end

	return modules[name]
end

local function GetBestScale()
	local scale = max(.4, min(1.15, 768 / DB.ScreenHeight))
	return Core:Round(scale, 2)
end

function Core:SetupUIScale(init)
	if LauringUIAccountDB["LockUIScale"] then LauringUIAccountDB["UIScale"] = GetBestScale() end
	local scale = LauringUIAccountDB["UIScale"]

	if init then
		local pixel = 1
		local ratio = 768 / DB.ScreenHeight
		Config.PixelMultiplexer = (pixel / scale) - ((pixel - ratio) / scale)
	elseif not InCombatLockdown() then
		if scale >= .64 then
			SetCVar("uiscale", scale) -- Fix blizzard chatframe offset
		end
		UIParent:SetScale(scale)
	end
end

local isScaling = false
local function UpdatePixelScale(event)
	if isScaling then return end
	isScaling = true

	if event == "UI_SCALE_CHANGED" then
		DB.ScreenWidth, DB.ScreenHeight = GetPhysicalScreenSize()
	end
	Core:SetupUIScale(true)
	Core:SetupUIScale()

	isScaling = false
end


Core:RegisterEvent("PLAYER_LOGIN", function()
    SetCVar("useUiScale", "1") -- Fix blizzard chatframe offset
	Core:SetupUIScale()
	Core:RegisterEvent("UI_SCALE_CHANGED", UpdatePixelScale)
	Core:SetSmoothingAmount(LauringUIAccountDB["SmoothAmount"])
	Config.Margin = 3

    for i = 1, #initQueue do
		local module = initQueue[i]

		if module.OnLogin then
			xpcall(module.OnLogin, geterrorhandler(), module)
		else
			print("Module <"..module.name.."> did not load (missing OnLogin).")
		end
	end

    Core.Modules = modules

    C_CVar.RegisterCVar("addonProfilerEnabled", 1)
	C_CVar.SetCVar("addonProfilerEnabled", 0)
end)

_G[addonName] = ns