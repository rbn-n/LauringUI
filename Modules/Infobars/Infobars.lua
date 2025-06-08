local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local Infobars = Core:RegisterModule("Infobars")

Infobars.DataTexts = {}

local GOLD_AMOUNT_SYMBOL = format("|cffffd700%s|r", GOLD_AMOUNT_SYMBOL)
local SILVER_AMOUNT_SYMBOL = format("|cffd0d0d0%s|r", SILVER_AMOUNT_SYMBOL)
local COPPER_AMOUNT_SYMBOL = format("|cffc77050%s|r", COPPER_AMOUNT_SYMBOL)

function Infobars:CreatePanels()
    self:CreateLeftBottomPanel()
    self:CreateRightBottomPanel()
    self:CreateActionBarPanel()
    self:CreateCentralBottomPanel()
end

function Infobars:CreateDataTexts()
    self:PositionDataTexts(self.CentralBottomPanel, {
        "Spec", "Guild", "Friends", "Latency", "Fps", "System"
    })

	self:PositionDataTexts(self.RightBottomPanel, {
		"Mail", "Durability", "Bags", "Gold", "Time"
	})
end

function Infobars:RegisterDataText(name, options)
	local panel = options.panel

	local frame = CreateFrame("Button", "LauringUIInfo_"..name, panel)
	frame:SetSize(80, 20) -- Default size, adjust later

	if options.onEvent then frame:SetScript("OnEvent", options.onEvent) end
	if options.onMouseUp then frame:SetScript("OnMouseUp", options.onMouseUp) end
	if options.onEnter then frame:SetScript("OnEnter", options.onEnter) end
	if options.onLeave then frame:SetScript("OnLeave", options.onLeave) end
	if options.onUpdate then frame:SetScript("OnUpdate", options.onUpdate) end

	local text = frame:CreateFontString(nil, "OVERLAY")
	text:SetFont(Config.DataText.Font, Config.DataText.Size, Config.DataText.Outline)
	text:SetPoint("CENTER")
	frame.Text = text

	if options.events then
		for _, event in ipairs(options.events) do
			frame:RegisterEvent(event)
		end
	end

	if options.onEvent then
		options.onEvent(frame)
	end

	self.DataTexts[name] = frame

	return frame
end

function Infobars:PositionDataTexts(panel, names)
	if not panel then
		print("PositionDataTexts: panel is nil!")
		return
	end

	local padding = 10
	local total = #names
	local panelWidth = panel:GetWidth()
	local spacing = (panelWidth - padding * 2) / total

	for i, name in ipairs(names) do
		local frame = self.DataTexts[name]
		if frame then

			frame:ClearAllPoints()
			frame:SetParent(panel)
			frame:SetSize(spacing, panel:GetHeight())

			if i == 1 then
				frame:SetPoint("LEFT", panel, "LEFT", padding, 0)
			else
				local prev = self.DataTexts[names[i - 1]]
				frame:SetPoint("LEFT", prev, "RIGHT", 0, 0)
			end
		else
			print("Missing DataText:", name)
		end

	end
end

function Infobars:GetTooltipAnchor(info)
	local _, height = info:GetCenter()
	if height and height > GetScreenHeight()/2 then
		return "TOP", "BOTTOM", -15
	else
		return "BOTTOM", "TOP", 15
	end
end

function Infobars:FormatGold(money, full)
	if money < 0 then
		return " 0"..COPPER_AMOUNT_SYMBOL
	end

    if money >= 1e6 and not full then
        -- Show abbreviated gold, e.g. " 1234g"
        return format(" %.0f%s", money / 1e4, GOLD_AMOUNT_SYMBOL)
	end

	local moneyString = ""
	local gold = floor(money / 1e4)
	if gold > 0 then
		moneyString = " "..gold..GOLD_AMOUNT_SYMBOL
	end

	local silver = floor((money - (gold * 1e4)) / 100)
	if silver > 0 then
		moneyString = moneyString.." "..silver..SILVER_AMOUNT_SYMBOL
	end

	local copper = money % 100
	if copper > 0 then
		moneyString = moneyString.." "..copper..COPPER_AMOUNT_SYMBOL
	end

	return moneyString
end

function Infobars:StylePanel(panel)
	Core:StyleFrame(panel)
end

function Infobars:OnLogin()
	Infobars:CreatePanels()
    Infobars:CreateDataTexts()
	-- TopPanel is created together with Location in DataTexts/Location.lua
	Infobars:CreateLocation()
	Infobars:CreateExperienceBar()
end