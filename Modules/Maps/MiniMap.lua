local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local oUF = ns.oUF

local module = Core:RegisterModule("Maps")

local pairs = pairs
local UIFrameFadeOut, UIFrameFadeIn = UIFrameFadeOut, UIFrameFadeIn
local C_Timer_After = C_Timer.After

local MiniMapTracking, MiniMapTrackingBackground, MiniMapTrackingButtonBorder, MiniMapTrackingIcon, MiniMapTrackingIconOverlay = MiniMapTracking, MiniMapTrackingBackground, MiniMapTrackingButtonBorder, MiniMapTrackingIcon, MiniMapTrackingIconOverlay
local MiniMapTrackingButton, MiniMapLFGFrame, MiniMapLFGFrameBorder, MiniMapInstanceDifficulty, GuildInstanceDifficulty, Minimap_OnClick = MiniMapTrackingButton, MiniMapLFGFrame, MiniMapLFGFrameBorder, MiniMapInstanceDifficulty, GuildInstanceDifficulty, Minimap_OnClick
local MiniMapBattlefieldFrame, MAX_BATTLEFIELD_QUEUES = MiniMapBattlefieldFrame, MAX_BATTLEFIELD_QUEUES
local MiniMapMailFrame = MiniMapMailFrame

function module:CombatPulse()
	if not Config.DB["Minimap"]["Enable"] then return end
	if not Config.DB["Minimap"]["ShowCombatPulse"] then return end

	local bg = Core.SetBD(Minimap)
	bg:SetFrameStrata("BACKGROUND")

	local anim = bg:CreateAnimationGroup()
	anim:SetLooping("BOUNCE")
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(.8)
	anim.fader:SetToAlpha(.2)
	anim.fader:SetDuration(1)
	anim.fader:SetSmoothing("OUT")

	local function updateMinimapAnim(event)
		if event == "PLAYER_REGEN_DISABLED" then
			bg:SetBackdropBorderColor(1, 0, 0)
			anim:Play()
		elseif not InCombatLockdown() then
			anim:Stop()
			bg:SetBackdropBorderColor(0, 0, 0)
		end
	end

	Core:RegisterEvent("PLAYER_REGEN_ENABLED", updateMinimapAnim)
	Core:RegisterEvent("PLAYER_REGEN_DISABLED", updateMinimapAnim)
end

function module:WhoPingsMyMap()
	if not Config.DB["Minimap"]["ShowWhoPings"] then return end

	local f = CreateFrame("Frame", nil, Minimap)
	f:SetAllPoints()
	f.text = Core.CreateFS(f, 12, "", false, "TOP", 0, -3)

	local anim = f:CreateAnimationGroup()
	anim:SetScript("OnPlay", function() f:SetAlpha(1) end)
	anim:SetScript("OnFinished", function() f:SetAlpha(0) end)
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(1)
	anim.fader:SetToAlpha(0)
	anim.fader:SetDuration(3)
	anim.fader:SetSmoothing("OUT")
	anim.fader:SetStartDelay(3)

	Core:RegisterEvent("MINIMAP_PING", function(_, unit)
		if unit == "player" then return end
		local class = select(2, UnitClass(unit))
		local r, g, b = Core.ClassColor(class)
		local name = GetUnitName(unit)
		anim:Stop()
		f.text:SetText(name)
		f.text:SetTextColor(r, g, b)
		anim:Play()
	end)
end

function module:ShowCalendar()
	if not Config.DB["Minimap"]["Enable"] then return end
	if not Config.DB["Minimap"]["ShowCalendar"] then return end

	GameTimeFrame:Hide()

	local date = CreateFrame("Button", nil, Minimap)
	date:SetPoint("RIGHT", MiniMapTrackingButton, "TOPRIGHT", 0, 2)
	date:SetSize(25, 25)
	date.Text = Core.CreateFS(date, 16, "", "BOTTOMRIGHT")
	date.Text:SetPoint("CENTER", 1, 0)

	date:SetScript("OnClick", function()
		if not InCombatLockdown() then
			if ToggleCalendar then
				ToggleCalendar()
			end
		end
	end)

	local function updateDate()
		local d = C_DateAndTime.GetCurrentCalendarTime().monthDay
		date.Text:SetText(d)
	end

	date:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
	date:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
	date:RegisterEvent("PLAYER_ENTERING_WORLD")
	date:SetScript("OnEvent", updateDate)
end

function module:HandleTracking()
	Minimap:SetScript("OnMouseUp", function(_, btn)
		if btn == "RightButton" then
			local trackingButton = _G.MiniMapTrackingButton
            if trackingButton and trackingButton:IsShown() then
                trackingButton:Click()
            end
		elseif btn == "MiddleButton" then
			if ToggleCalendar then
				ToggleCalendar()
			end
		else
			Minimap_OnClick(Minimap)
		end
	end)
end

local function GetVolumeColor(cur)
	local r, g, b = oUF:RGBColorGradient(cur, 100, 1, 1, 1, 1, .8, 0, 1, 0, 0)
	return r, g, b
end

local function GetCurrentVolume()
	return Core:Round(GetCVar("Sound_MasterVolume") * 100)
end

function module:OnMouseWheel(zoom)
	if IsControlKeyDown() and module.VolumeText then
		local value = GetCurrentVolume()
		local mult = IsAltKeyDown() and 100 or 5
		value = value + zoom * mult
		if value > 100 then value = 100 end
		if value < 0 then value = 0 end

		SetCVar("Sound_MasterVolume", tostring(value / 100))
		module.VolumeText:SetText(value)
		module.VolumeText:SetTextColor(GetVolumeColor(value))
		module.VolumeAnim:Stop()
		module.VolumeAnim:Play()
	else
		if zoom > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end
end

function module:EasyVolume()
	if not Config.DB["Minimap"]["Enable"] then return end
	if not Config.DB["Minimap"]["EnableEasyVolume"] then return end

	local frame = CreateFrame("Frame", nil, Minimap)
	frame:SetAllPoints()
	local text = Core.CreateFS(frame, 30)

	local anim = frame:CreateAnimationGroup()
	anim:SetScript("OnPlay", function() frame:SetAlpha(1) end)
	anim:SetScript("OnFinished", function() frame:SetAlpha(0) end)
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(1)
	anim.fader:SetToAlpha(0)
	anim.fader:SetDuration(3)
	anim.fader:SetSmoothing("OUT")
	anim.fader:SetStartDelay(1)

	module.VolumeText = text
	module.VolumeAnim = anim

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", module.OnMouseWheel)
end

function module:HideDefaultFrames()
	local frames = {
		"MinimapBorderTop",
		"MinimapNorthTag",
		"MinimapBorder",
		"MinimapZoneTextButton",
		"MinimapZoomOut",
		"MinimapZoomIn",
		"MiniMapWorldMapButton",
		"MiniMapMailBorder",
		"MinimapToggleButton",
		"GameTimeFrame",
	}

	for _, v in pairs(frames) do
		local frame = _G[v]
		if frame then
			Core.HideObject(_G[v])
		end
	end

	MinimapCluster:EnableMouse(false)
	Core:KillEditMode(MinimapCluster)
	MinimapCluster:SetAllPoints(Minimap)
	MinimapCluster.BorderTop:Hide()
end

function module:RecycleBin()
	if not Config.DB["Minimap"]["ShowRecycleBin"] then return end

	local blackList = {
		["GameTimeFrame"] = true,
		["MiniMapLFGFrame"] = true,
		["BattlefieldMinimap"] = true,
		["MinimapBackdrop"] = true,
		["TimeManagerClockButton"] = true,
		["FeedbackUIButton"] = true,
		["HelpOpenTicketButton"] = true,
		["MiniMapBattlefieldFrame"] = true,
		["QueueStatusMinimapButton"] = true,
		["GarrisonLandingPageMinimapButton"] = true,
		["MinimapZoneTextButton"] = true,
		["RecycleBinFrame"] = true,
		["RecycleBinToggleButton"] = true,
	}

	local function updateRecycleTip(bu)
		bu.text = DB.RightButton..L["AutoHide"]..": "..(LauringUIAccountDB["AutoRecycle"] and "|cff55ff55"..VIDEO_OPTIONS_ENABLED or "|cffff5555"..VIDEO_OPTIONS_DISABLED)
	end

	local button = CreateFrame("Button", "RecycleBinToggleButton", Minimap)
	button:SetSize(MiniMapTrackingButton:GetSize())
	button:SetPoint("RIGHT", MiniMapTracking, "LEFT", 10, 0)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetAllPoints()
	button.Icon:SetTexture(DB.RecycleBinTexture)
	button:SetHighlightTexture(DB.RecycleBinTexture)
	button.title = DB.InfoColor..L["Minimap RecycleBin"]
	button:SetFrameLevel(999)
	Core.AddTooltip(button, "ANCHOR_LEFT")
	updateRecycleTip(button)

	local width, height, alpha = 220, 40, .5
	local bin = CreateFrame("Frame", "RecycleBinFrame", UIParent)
	bin:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", -3, 10)
	bin:SetSize(width, height)
	bin:Hide()

	local tex = Core.SetGradient(bin, "H", 0, 0, 0, 0, alpha, width, height)
	tex:SetPoint("CENTER")
	local topLine = Core.SetGradient(bin, "H", DB.r, DB.g, DB.b, 0, alpha, width, Config.PixelMultiplexer)
	topLine:SetPoint("BOTTOM", bin, "TOP")
	local bottomLine = Core.SetGradient(bin, "H", DB.r, DB.g, DB.b, 0, alpha, width, Config.PixelMultiplexer)
	bottomLine:SetPoint("TOP", bin, "BOTTOM")
	local rightLine = Core.SetGradient(bin, "V", DB.r, DB.g, DB.b, alpha, alpha, Config.PixelMultiplexer, height + Config.PixelMultiplexer * 2)
	rightLine:SetPoint("LEFT", bin, "RIGHT")

	local function hideBinButton()
		bin:Hide()
	end
	local function clickFunc(force)
		if force == 1 or LauringUIAccountDB["AutoRecycle"] then
			UIFrameFadeOut(bin, .5, 1, 0)
			C_Timer_After(.5, hideBinButton)
		end
	end

	local ignoredButtons = {
		["GatherMatePin"] = true,
		["HandyNotes.-Pin"] = true,
		["Guidelime"] = true,
		["QuestieFrame"] = true,
		["TTMinimapButton"] = true,
	}
	Core.SplitList(ignoredButtons, LauringUIAccountDB["IgnoredButtons"])

	local function isButtonIgnored(name)
		for addonName in pairs(ignoredButtons) do
			if strmatch(name, addonName) then
				return true
			end
		end
	end

	local isGoodLookingIcon = {}

	local iconsPerRow = 10
	local rowMult = iconsPerRow/2 - 1
	local currentIndex, pendingTime, timeThreshold = 0, 5, 12
	local buttons, numMinimapChildren = {}, 0
	local removedTextures = {
		[136430] = true,
		[136467] = true,
	}

	local function ReskinMinimapButton(child, name)
		for j = 1, child:GetNumRegions() do
			local region = select(j, child:GetRegions())
			if region:IsObjectType("Texture") then
				local texture = region:GetTexture() or ""
				if removedTextures[texture] or strfind(texture, "Interface\\CharacterFrame") or strfind(texture, "Interface\\Minimap") then
					region:SetTexture(nil)
					region:Hide() -- hide CircleMask
				end
				if not region.__ignored then
					region:ClearAllPoints()
					region:SetAllPoints()
				end
				if not isGoodLookingIcon[name] then
					region:SetTexCoord(unpack(DB.TexCoord))
				end
			end
			child:SetSize(34, 34)
			Core.CreateSD(child, 3, 3)
		end

		tinsert(buttons, child)
	end

	local function KillMinimapButtons()
		for _, child in pairs(buttons) do
			if not child.styled then
				child:SetParent(bin)
				if child:HasScript("OnDragStop") then child:SetScript("OnDragStop", nil) end
				if child:HasScript("OnDragStart") then child:SetScript("OnDragStart", nil) end
				if child:HasScript("OnClick") then child:HookScript("OnClick", clickFunc) end

				if child:IsObjectType("Button") then
					child:SetHighlightTexture(DB.BackgroundTexture) -- prevent nil function
					child:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				elseif child:IsObjectType("Frame") then
					child.highlight = child:CreateTexture(nil, "HIGHLIGHT")
					child.highlight:SetAllPoints()
					child.highlight:SetColorTexture(1, 1, 1, .25)
				end

				-- Naughty Addons
				local name = child:GetName()
				if name == "DBMMinimapButton" then
					child:SetScript("OnMouseDown", nil)
					child:SetScript("OnMouseUp", nil)
				elseif name == "BagSync_MinimapButton" then
					child:HookScript("OnMouseUp", clickFunc)
				elseif name == "WIM3MinimapButton" then
					child.SetParent = Core.Dummy
					child:SetFrameStrata("DIALOG")
					child.SetFrameStrata = Core.Dummy
				end

				child.styled = true
			end
		end
	end

	local function CollectRubbish()
		local numChildren = Minimap:GetNumChildren()
		if numChildren ~= numMinimapChildren then
			for i = 1, numChildren do
				local child = select(i, Minimap:GetChildren())
				local name = child and child.GetName and child:GetName()
				if name and not child.isExamed and not blackList[name] then
					if (child:IsObjectType("Button") or strmatch(strupper(name), "BUTTON")) and not isButtonIgnored(name) then
						ReskinMinimapButton(child, name)
					end
					child.isExamed = true
				end
			end

			numMinimapChildren = numChildren
		end

		KillMinimapButtons()

		currentIndex = currentIndex + 1
		if currentIndex < timeThreshold then
			C_Timer_After(pendingTime, CollectRubbish)
		end
	end

	local shownButtons = {}
	local function SortRubbish()
		if #buttons == 0 then return end

		wipe(shownButtons)
		for _, button in pairs(buttons) do
			if next(button) and button:IsShown() then -- fix for fuxking AHDB
				tinsert(shownButtons, button)
			end
		end

		local numShown = #shownButtons
		local row = numShown == 0 and 1 or Core:Round((numShown + rowMult) / iconsPerRow)
		local newHeight = row*37 + 3
		bin:SetHeight(newHeight)
		tex:SetHeight(newHeight)
		rightLine:SetHeight(newHeight + 2* Config.PixelMultiplexer)

		for index, button in pairs(shownButtons) do
			button:ClearAllPoints()
			if index == 1 then
				button:SetPoint("BOTTOMRIGHT", bin, -3, 3)
			elseif row > 1 and mod(index, row) == 1 or row == 1 then
				button:SetPoint("RIGHT", shownButtons[index - row], "LEFT", -3, 0)
			else
				button:SetPoint("BOTTOM", shownButtons[index - 1], "TOP", 0, 3)
			end
		end
	end

	button:SetScript("OnClick", function(_, btn)
		if btn == "RightButton" then
			LauringUIAccountDB["AutoRecycle"] = not LauringUIAccountDB["AutoRecycle"]
			updateRecycleTip(button)
			button:GetScript("OnEnter")(button)
		else
			if bin:IsShown() then
				clickFunc(1)
			else
				SortRubbish()
				UIFrameFadeIn(bin, .5, 0, 1)
			end
		end
	end)

	CollectRubbish()
end

local function ReskinTracking()
	MiniMapTracking:SetScale(.8)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("BOTTOMRIGHT", Minimap, 2, -4)
	MiniMapTracking:SetFrameLevel(999)
	MiniMapTrackingBackground:Hide()
	MiniMapTrackingButtonBorder:Hide()
	Core.ReskinIcon(MiniMapTrackingIcon)
	MiniMapTrackingIconOverlay:SetAlpha(0)
	local hl = MiniMapTrackingButton:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetAllPoints(MiniMapTrackingIcon)
end

local function SetupLFGMinimapButton()
	if not LFGMinimapFrame then return false end

	LFGMinimapFrame:ClearAllPoints()
	LFGMinimapFrame:SetPoint("RIGHT", Minimap, 5, 0)
	LFGMinimapFrameBorder:Hide()

	return true
end

local function ReskinLFGFrame()
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -5, -5)
	MiniMapBattlefieldFrame:SetFrameLevel(999)
	MiniMapBattlefieldBorder:Hide()
	MiniMapBattlefieldIcon:SetAlpha(0)
	BattlegroundShine:SetTexture(nil)

	local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
	queueIcon:SetPoint("CENTER", MiniMapBattlefieldFrame)
	queueIcon:SetSize(50, 50)
	queueIcon:SetTexture(DB.EyeTexture)
	queueIcon:Hide()
	local anim = queueIcon:CreateAnimationGroup()
	anim:SetLooping("REPEAT")
	anim.rota = anim:CreateAnimation("Rotation")
	anim.rota:SetDuration(2)
	anim.rota:SetDegrees(360)

	hooksecurefunc("BattlefieldFrame_UpdateStatus", function()
		queueIcon:SetShown(MiniMapBattlefieldFrame:IsShown())

		anim:Play()
		for i = 1, MAX_BATTLEFIELD_QUEUES do
			local status = GetBattlefieldStatus(i)
			if status == "confirm" then
				anim:Stop()
				break
			end
		end
	end)

	local lfgFrame = CreateFrame("Frame")
	lfgFrame:RegisterEvent("PLAYER_LOGIN")
	lfgFrame:RegisterEvent("ADDON_LOADED")
	lfgFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

	lfgFrame:SetScript("OnEvent", function(self, event, addon)
		-- ADDON_LOADED: only care about the group finder addon
		if event == "ADDON_LOADED" and addon ~= "Blizzard_GroupFinder_VanillaStyle" then
			return
		end

		-- Try to apply setup
		if not SetupLFGMinimapButton() then
			return
		end

		-- Success: clean up
		self:UnregisterEvent("PLAYER_LOGIN")
		self:UnregisterEvent("ADDON_LOADED")
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	end)
end

local function ReskinInstanceDifficulty()
	local function handleFlag(diff)
		diff:ClearAllPoints()
		diff:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 2, 2)
		diff:SetScale(1)
	end

	if MiniMapInstanceDifficulty then
		handleFlag(MiniMapInstanceDifficulty)
	end

	if GuildInstanceDifficulty then
		handleFlag(GuildInstanceDifficulty)
	end
end

local function ReskinMail()
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -5, 5)
	MiniMapMailIcon:SetTexture(DB.MailTexture)
	MiniMapMailIcon:SetSize(21, 21)
	MiniMapMailIcon:SetVertexColor(1, 1, 0)
end

function module:Reskin()
	ReskinTracking()
	ReskinLFGFrame()
	ReskinInstanceDifficulty()
	ReskinMail()
end

function module:UpdateMinimapScale()
	if not Config.DB["Minimap"]["Enable"] then return end

	local size = Config.DB["Minimap"]["Size"]
	local scale = Config.DB["Minimap"]["Scale"]
	Minimap:SetSize(size, size)
	Minimap:SetScale(scale)
end

function module:OnLogin()
	if not Config.DB["Minimap"]["Enable"] then return end

	Minimap:SetFrameLevel(10)
	Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", UIParent, -5, -5)
	self:UpdateMinimapScale()

	self:HideDefaultFrames()
	--self:ShowCalendar()
	self:HandleTracking()
	self:EasyVolume()
	self:CombatPulse()
	self:WhoPingsMyMap()
	self:RecycleBin()
	self:Reskin()

	if LibDBIcon10_TownsfolkTracker then
		LibDBIcon10_TownsfolkTracker:DisableDrawLayer("OVERLAY")
		LibDBIcon10_TownsfolkTracker:DisableDrawLayer("BACKGROUND")
	end
end
