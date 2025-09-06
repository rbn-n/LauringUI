local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local INFO = Core:RegisterModule("Infobar")

local tinsert, pairs, unpack = table.insert, pairs, unpack
local GOLD_AMOUNT_SYMBOL = format("|cffffd700%s|r", GOLD_AMOUNT_SYMBOL)
local SILVER_AMOUNT_SYMBOL = format("|cffd0d0d0%s|r", SILVER_AMOUNT_SYMBOL)
local COPPER_AMOUNT_SYMBOL = format("|cffc77050%s|r", COPPER_AMOUNT_SYMBOL)

INFO.modules = {}
INFO.leftModules, INFO.rightModules = {}, {}

function INFO:GetMoneyString(money, full)
	if money >= 1e6 and not full then
		return format(" %.0f%s", money / 1e4, GOLD_AMOUNT_SYMBOL)
	else
		if money > 0 then
			local moneyString = ""
			local gold = floor(money / 1e4)
			if gold > 0 then
				moneyString = " "..gold..GOLD_AMOUNT_SYMBOL
			end
			local silver = floor((money - (gold * 1e4)) / 100)
			if silver > 0 then
				moneyString = moneyString.." "..silver..SILVER_AMOUNT_SYMBOL
			end
			local copper = mod(money, 100)
			if copper > 0 then
				moneyString = moneyString.." "..copper..COPPER_AMOUNT_SYMBOL
			end
			return moneyString
		else
			return " 0"..COPPER_AMOUNT_SYMBOL
		end
	end
end

function INFO:RegisterInfobar(name, point)
	local info = CreateFrame("Frame", nil, UIParent)
	info:SetHitRectInsets(0, 0, -10, -10)
	info.text = Core.CreateFS(info, 12)
	info.text:ClearAllPoints()
	-- if C.Infobar.CustomAnchor then
	-- 	info.text:SetPoint(unpack(point))
	-- 	info.isActive = true
	-- end
	info:SetAllPoints(info.text)

	INFO.modules[strlower(name)] = info

	return info
end

function INFO:UpdateInfobarSize()
	for _, info in pairs(INFO.modules) do
		Core.SetFontSize(info.text, Config.DB["Infobar"]["FontSize"])
	end
end

local function info_OnEvent(self, ...)
	if not self.isActive then return end
	self:onEvent(...)
end

function INFO:LoadInfobar(info)
	if info.eventList then
		for _, event in pairs(info.eventList) do
			info:RegisterEvent(event)
		end
		info:SetScript("OnEvent", info_OnEvent)
	end
	if info.onEnter then
		info:SetScript("OnEnter", info.onEnter)
	end
	if info.onLeave then
		info:SetScript("OnLeave", info.onLeave)
	end
	if info.onMouseUp then
		info:SetScript("OnMouseUp", info.onMouseUp)
	end
	if info.onUpdate then
		info:SetScript("OnUpdate", info.onUpdate)
	end
end

function INFO:BackgroundLines()
	local cr, cg, cb = DB.r, DB.g, DB.b

	local parent = UIParent
	local width, height = 575, 20
	local anchors = {
		[1] = {"BOTTOMLEFT", 3, .5, 0, "LeftInfobar"},
		[2] = {"BOTTOMRIGHT", 3, 0, .5, "RightInfobar"},
	}

    for _, v in pairs(anchors) do
		local frame = CreateFrame("Frame", "LauringUI"..v[5], parent)
		frame:SetSize(width, height)
		frame:SetFrameStrata("BACKGROUND")
		Core.Mover(frame, L[v[5]], v[5], {v[1], parent, v[1], 0, v[2]})

        local tex = Core.SetGradient(frame, "H", 0, 0, 0, v[3], v[4], width, height)
        tex:SetPoint("CENTER")
        local bottomLine = Core.SetGradient(frame, "H", cr, cg, cb, v[3], v[4], width, Config.PixelMultiplexer + 1)
        bottomLine:SetPoint("TOP", frame, "BOTTOM")
        local topLine = Core.SetGradient(frame, "H", cr, cg, cb, v[3], v[4], width, Config.PixelMultiplexer + 1)
        topLine:SetPoint("BOTTOM", frame, "TOP")
	end
end

function INFO:Infobar_UpdateValues()
	local modules = INFO.modules

	wipe(INFO.leftModules)
	for name in gmatch(Config.DB["Infobar"]["InfoStringLeft"], "%[(%w+)%]") do
		if modules[name] and not modules[name].isActive then
			modules[name].isActive = true
			tinsert(INFO.leftModules, name) -- left to right
		end
	end

	wipe(INFO.rightModules)
	for name in gmatch(Config.DB["Infobar"]["InfoStringRight"], "%[(%w+)%]") do
		if modules[name] and not modules[name].isActive then
			modules[name].isActive = true
			tinsert(INFO.rightModules, 1, name) -- right to left
		end
	end
end

function INFO:Infobar_UpdateAnchor()
	for _, info in pairs(INFO.modules) do
		info:Hide()
		info.isActive = false
	end

	INFO:Infobar_UpdateValues()

	local previousLeft
	for index, name in pairs(INFO.leftModules) do
		local info = INFO.modules[name]
		info.text:ClearAllPoints()
		if index == 1 then
			info.text:SetPoint("LEFT", _G["LauringUILeftInfobar"], 15, 0)
		else
			info.text:SetPoint("LEFT", previousLeft, "RIGHT", 30, 0)
		end
		previousLeft = info

		info:Show()
		if info.onEvent then info:onEvent("PLAYER_ENTERING_WORLD") end
	end

	local previousRight
	for index, name in pairs(INFO.rightModules) do
		local info = INFO.modules[name]
		info.text:ClearAllPoints()
		if index == 1 then
			info.text:SetPoint("RIGHT", _G["LauringUIRightInfobar"], -15, 0)
		else
			info.text:SetPoint("RIGHT", previousRight, "LEFT", -30, 0)
		end
		previousRight = info

		info:Show()
		if info.onEvent then info:onEvent("PLAYER_ENTERING_WORLD") end
	end
end

function INFO:GetTooltipAnchor(info)
	local _, height = info:GetCenter()
	if height and height > GetScreenHeight()/2 then
		return "TOP", "BOTTOM", -15
	else
		return "BOTTOM", "TOP", 15
	end
end

local function UpdateActionbar(panel, bar)
    if not bar:IsShown() then
        panel:Hide()
        return
    end

    panel:Show()

    local padding = 4
    local width = ((bar:GetWidth() * 30) * 0.95) + padding
    local height = ((bar:GetHeight() * 2) * 0.92) + padding
    panel:SetSize(width, height)

    panel:ClearAllPoints()
    panel:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", -(padding / 2), -(padding / 2))
end

function INFO:StyleActionBar()
    if not C_AddOns.IsAddOnLoaded("Bartender4") then return end

    local bar1 = _G["BT4Button1"]
    if not bar1 then return end

    local panel = CreateFrame("Frame", "LauringUIActionBarPanel", UIParent)
    panel:SetFrameStrata("LOW")

    UpdateActionbar(panel, bar1)

    local cr, cg, cb = DB.r, DB.g, DB.b
    local edgeAlpha = 0.80                      -- tweak this (0..1) to control how strong the edges are
    local lineH = (Config.PixelMultiplexer or 1) + 1

    local w, h = panel:GetSize()
    local half = math.floor(w / 2)
    local otherHalf = w - half

    local leftTex = Core.SetGradient(panel, "H", 0, 0, 0, 0, edgeAlpha, half, h)
    leftTex:SetPoint("LEFT", panel, "LEFT", 0, 0)

    local rightTex = Core.SetGradient(panel, "H", 0, 0, 0, edgeAlpha, 0, otherHalf, h)
    rightTex:SetPoint("RIGHT", panel, "RIGHT", 0, 0)
    local topLeft = Core.SetGradient(panel, "H", cr, cg, cb, 0, edgeAlpha, half, lineH)
    topLeft:SetPoint("BOTTOMLEFT", panel, "TOPLEFT", 0, 0)

    local topRight = Core.SetGradient(panel, "H", cr, cg, cb, edgeAlpha, 0, otherHalf, lineH)
    topRight:SetPoint("BOTTOMRIGHT", panel, "TOPRIGHT", 0, 0)

    local bottomLeft = Core.SetGradient(panel, "H", cr, cg, cb, 0, edgeAlpha, half, lineH)
    bottomLeft:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 0, 0)

    local bottomRight = Core.SetGradient(panel, "H", cr, cg, cb, edgeAlpha, 0, otherHalf, lineH)
    bottomRight:SetPoint("TOPRIGHT", panel, "BOTTOMRIGHT", 0, 0)

    panel:HookScript("OnSizeChanged", function(_, width, height)
        local half = math.floor(width / 2)
        local other = width - half

        leftTex:SetWidth(half);    leftTex:SetHeight(height)
        rightTex:SetWidth(other);  rightTex:SetHeight(height)

        topLeft:SetWidth(half);    topLeft:SetHeight(lineH)
        topRight:SetWidth(other);  topRight:SetHeight(lineH)

        bottomLeft:SetWidth(half);  bottomLeft:SetHeight(lineH)
        bottomRight:SetWidth(other);bottomRight:SetHeight(lineH)
    end)

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("ACTIONBAR_SHOWGRID")
    eventFrame:RegisterEvent("ACTIONBAR_HIDEGRID")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:SetScript("OnEvent", function()
        UpdateActionbar(panel, bar1)
    end)
end

StaticPopupDialogs["CPUUSAGE_WARNING"] = {
	text = L["CPU Usage Warning"],
	button1 = DISABLE,
	button2 = CONTINUE,
	OnAccept = function() SetCVar("scriptProfile", 0) ReloadUI() end,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = false,
}

function INFO:OnLogin()
	for _, info in pairs(INFO.modules) do
		INFO:LoadInfobar(info)
	end

	INFO.loginTime = GetTime()
	INFO:BackgroundLines()
	INFO:UpdateInfobarSize()
	INFO:Infobar_UpdateAnchor()
	INFO:StyleActionBar()

	if GetCVarBool("scriptProfile") then
		StaticPopup_Show("CPUUSAGE_WARNING")
	end
end