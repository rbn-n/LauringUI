local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local M = Core:RegisterModule("Mover")

local cr, cg, cb = DB.r, DB.g, DB.b

-- Movable Frame
function Core:CreateMF(parent, saved)
	local frame = parent or self
	frame:SetMovable(true)
	frame:SetUserPlaced(true)
	frame:SetClampedToScreen(true)

	self:EnableMouse(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", function() frame:StartMoving() end)
	self:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing()
		if not saved then return end
		local orig, _, tar, x, y = frame:GetPoint()
		x, y = Core:Round(x), Core:Round(y)
		Config.DB["TempAnchor"][frame:GetName()] = {orig, "UIParent", tar, x, y}
	end)
end

function Core:RestoreMF()
	local name = self:GetName()
	if name and Config.DB["TempAnchor"][name] then
		self:ClearAllPoints()
		self:SetPoint(unpack(Config.DB["TempAnchor"][name]))
	end
end

function Core:UpdateBlizzFrame()
	if InCombatLockdown() then return end
	if self.isRestoring then return end
	self.isRestoring = true
	Core.RestoreMF(self)
	self.isRestoring = nil
end

function Core:RestoreBlizzFrame()
	if IsControlKeyDown() then
		Config.DB["TempAnchor"][self:GetName()] = nil
		UpdateUIPanelPositions(self)
	end
end

function Core:BlizzFrameMover(frame)
	Core.CreateMF(frame, nil, true)
	hooksecurefunc(frame, "SetPoint", Core.UpdateBlizzFrame)
	frame:HookScript("OnMouseUp", Core.RestoreBlizzFrame)
end

-- Frame Mover
local MoverList, MoverFrame = {}, nil
local updater

function Core:Mover(text, value, anchor, width, height)
	local key = "Mover"

	local mover = CreateFrame("Frame", nil, UIParent)
	mover:SetWidth(width or self:GetWidth())
	mover:SetHeight(height or self:GetHeight())
	mover.bg = Core:CreateBackdropFrame(mover)
	mover:Hide()
	mover.text = Core.CreateFS(mover, DB.Font[2], text)
	mover.text:SetWordWrap(true)

	if not Config.DB[key][value] then
		if not anchor then
			print("No anchor for ", text, value)
		end
		mover:SetPoint(unpack(anchor))
	else
		mover:SetPoint(unpack(Config.DB[key][value]))
	end
	mover:EnableMouse(true)
	mover:SetMovable(true)
	mover:SetClampedToScreen(true)
	mover:SetFrameStrata("HIGH")
	mover:RegisterForDrag("LeftButton")
	mover.__key = key
	mover.__value = value
	mover.__anchor = anchor
	mover:SetScript("OnEnter", M.Mover_OnEnter)
	mover:SetScript("OnLeave", M.Mover_OnLeave)
	mover:SetScript("OnDragStart", M.Mover_OnDragStart)
	mover:SetScript("OnDragStop", M.Mover_OnDragStop)
	mover:SetScript("OnMouseUp", M.Mover_OnClick)

    tinsert(MoverList, mover)

	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", mover)

	return mover
end

function M:CalculateMoverPoints(mover, trimX, trimY)
	local screenWidth = Core:Round(UIParent:GetRight())
	local screenHeight = Core:Round(UIParent:GetTop())
	local screenCenter = Core:Round(UIParent:GetCenter(), nil)
	local x, y = mover:GetCenter()

	local LEFT = screenWidth / 3
	local RIGHT = screenWidth * 2 / 3
	local TOP = screenHeight / 2
	local point

	if y >= TOP then
		point = "TOP"
		y = -(screenHeight - mover:GetTop())
	else
		point = "BOTTOM"
		y = mover:GetBottom()
	end

	if x >= RIGHT then
		point = point.."RIGHT"
		x = mover:GetRight() - screenWidth
	elseif x <= LEFT then
		point = point.."LEFT"
		x = mover:GetLeft()
	else
		x = x - screenCenter
	end

	x = x + (trimX or 0)
	y = y + (trimY or 0)
	x, y = Core:Round(x), Core:Round(y)

	return x, y, point
end

function M:UpdateTrimFrame()
	if not MoverFrame then return end

	local x, y = M:CalculateMoverPoints(self)
	MoverFrame.__x:SetText(x)
	MoverFrame.__y:SetText(y)
	MoverFrame.__x.__current = x
	MoverFrame.__y.__current = y
	MoverFrame.__trimText:SetText(self.text:GetText())
end

function M:DoTrim(trimX, trimY)
	local mover = updater.__owner
	if mover and MoverFrame then
		local x, y, point = M:CalculateMoverPoints(mover, trimX, trimY)
		MoverFrame.__x:SetText(x)
		MoverFrame.__y:SetText(y)
		MoverFrame.__x.__current = x
		MoverFrame.__y.__current = y
		mover:ClearAllPoints()
		mover:SetPoint(point, UIParent, point, x, y)
		Config.DB[mover.__key][mover.__value] = {point, "UIParent", point, x, y}
	end
end

function M:Mover_OnClick(btn)
	if IsShiftKeyDown() and btn == "RightButton" then
		self:Hide()
	elseif IsControlKeyDown() and btn == "RightButton" then
		self:ClearAllPoints()
		self:SetPoint(unpack(self.__anchor))
		Config.DB[self.__key][self.__value] = nil
	end
	updater.__owner = self
	M.UpdateTrimFrame(self)
end

function M:Mover_OnEnter()
	self.bg:SetBackdropBorderColor(cr, cg, cb)
	self.text:SetTextColor(1, .8, 0)
end

function M:Mover_OnLeave()
	Core.SetBorderColor(self.bg)
	self.text:SetTextColor(1, 1, 1)
end

function M:Mover_OnDragStart()
	self:StartMoving()
	M.UpdateTrimFrame(self)
	updater.__owner = self
	updater:Show()
end

function M:Mover_OnDragStop()
	self:StopMovingOrSizing()
	local orig, _, tar, x, y = self:GetPoint()
	x = Core:Round(x)
	y = Core:Round(y)

	self:ClearAllPoints()
	self:SetPoint(orig, "UIParent", tar, x, y)
	Config.DB[self.__key][self.__value] = {orig, "UIParent", tar, x, y}
	M.UpdateTrimFrame(self)
	updater:Hide()
end

function M:UnlockElements()
	for i = 1, #MoverList do
		local mover = MoverList[i]
		if not mover:IsShown() and not mover.isDisable then
			mover:Show()
		end
	end
	if MoverFrame then MoverFrame:Show() end
end

function M:LockElements()
	for i = 1, #MoverList do
		local mover = MoverList[i]
		mover:Hide()
	end
	if MoverFrame then MoverFrame:Hide() end
	SlashCmdList["TOGGLEGRID"]("1")
end

StaticPopupDialogs["RESET_MOVER"] = {
	text = L["Reset Mover Confirm"],
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		wipe(Config.DB["Mover"])
		ReloadUI()
	end,
}

-- Mover Console
local function CreateConsole()
	if MoverFrame then return end

	MoverFrame = CreateFrame("Frame", nil, UIParent)
	MoverFrame:SetPoint("TOP", 0, -150)
	MoverFrame:SetSize(212, 80)
	Core:StyleFrame(MoverFrame)
	Core.CreateFS(MoverFrame, 15, L["Mover Console"], "system", "TOP", 0, -8)
	local buttons, text = {}, {LOCK, L["Grids"], RESET}
	for i = 1, 3 do
		buttons[i] = Core.CreateButton(MoverFrame, 100, 22, text[i])
		if i == 1 then
			buttons[i]:SetPoint("BOTTOMLEFT", 5, 29)
		elseif i == 3 then
			buttons[i]:SetPoint("BOTTOM", 0, 4)
		else
			buttons[i]:SetPoint("LEFT", buttons[i-1], "RIGHT", 2, 0)
		end
	end

	-- Lock
	buttons[1]:SetScript("OnClick", M.LockElements)
	-- Grids
	buttons[2]:SetScript("OnClick", function()
		SlashCmdList["TOGGLEGRID"]("64")
	end)
	buttons[3]:SetScript("OnClick", function()
		StaticPopup_Show("RESET_MOVER")
	end)

	local header = CreateFrame("Frame", nil, MoverFrame)
	header:SetSize(212, 30)
	header:SetPoint("TOP")
	Core.CreateMF(header, MoverFrame)

	local helpInfo = Core.CreateHelpInfoButton(header, "|nCTRL +"..DB.RightButton..L["Reset anchor"].."|nSHIFT +"..DB.RightButton..L["Hide panel"])
	helpInfo:SetPoint("TOPRIGHT", 2, 5)

	local frame = CreateFrame("Frame", nil, MoverFrame)
	frame:SetSize(212, 73)
	frame:SetPoint("TOP", MoverFrame, "BOTTOM", 0, -3)
	Core:StyleFrame(frame)
	MoverFrame.__trimText = Core.CreateFS(frame, 12, NONE, "system", "BOTTOM", 0, 5)

	local xBox = Core.CreateEditBox(frame, 60, 22)
	xBox:SetPoint("TOPRIGHT", frame, "TOP", -12, -5)
	Core.CreateFS(xBox, 14, "X", "system", "LEFT", -20, 0)
	xBox:SetJustifyH("CENTER")
	xBox.__current = 0
	xBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		text = tonumber(text)
		if text then
			local diff = text - self.__current
			self.__current = text
			M:DoTrim(diff)
		end
	end)
	MoverFrame.__x = xBox

	local yBox = Core.CreateEditBox(frame, 60, 22)
	yBox:SetPoint("TOPRIGHT", frame, "TOP", -12, -29)
	Core.CreateFS(yBox, 14, "Y", "system", "LEFT", -20, 0)
	yBox:SetJustifyH("CENTER")
	yBox.__current = 0
	yBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		text = tonumber(text)
		if text then
			local diff = text - self.__current
			self.__current = text
			M:DoTrim(nil, diff)
		end
	end)
	MoverFrame.__y = yBox

	local arrows = {}
	local arrowIndex = {
		[1] = {degree = 180, offset = -1, x = 28, y = 9},
		[2] = {degree = 0, offset = 1, x = 72, y = 9},
		[3] = {degree = 90, offset = 1, x = 50, y = 20},
		[4] = {degree = -90, offset = -1, x = 50, y = -2},
	}
	local function arrowOnClick(self)
		local modKey = IsModifierKeyDown()
		if self.__index < 3 then
			M:DoTrim(self.__offset * (modKey and 10 or 1))
		else
			M:DoTrim(nil, self.__offset * (modKey and 10 or 1))
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end

	for i = 1, 4 do
		arrows[i] = CreateFrame("Button", nil, frame)
		arrows[i]:SetSize(20, 20)
		Core.PixelIcon(arrows[i], "Interface\\OPTIONSFRAME\\VoiceChat-Play", true)
		local arrowData = arrowIndex[i]
		arrows[i].__index = i
		arrows[i].__offset = arrowData.offset
		arrows[i]:SetScript("OnClick", arrowOnClick)
		arrows[i]:SetPoint("CENTER", arrowData.x, arrowData.y)
		arrows[i].Icon:SetPoint("TOPLEFT", 3, -3)
		arrows[i].Icon:SetPoint("BOTTOMRIGHT", -3, 3)
		arrows[i].Icon:SetRotation(math.rad(arrowData.degree))
	end

	local function showLater(event)
		if event == "PLAYER_REGEN_DISABLED" then
			if MoverFrame:IsShown() then
				M:LockElements()
				Core:RegisterEvent("PLAYER_REGEN_ENABLED", showLater)
			end
		else
			M:UnlockElements()
			Core:UnregisterEvent(event, showLater)
		end
	end
	Core:RegisterEvent("PLAYER_REGEN_DISABLED", showLater)
end

SlashCmdList["LAURINGUI_MOVER"] = function()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT)
		return
	end
	CreateConsole()
	M:UnlockElements()
end
SLASH_LAURINGUI_MOVER1 = "/mm"
SLASH_LAURINGUI_MOVER2 = "/mmm"

function M:OnLogin()
	updater = CreateFrame("Frame")
	updater:Hide()
	updater:SetScript("OnUpdate", function()
		M.UpdateTrimFrame(updater.__owner)
	end)
end