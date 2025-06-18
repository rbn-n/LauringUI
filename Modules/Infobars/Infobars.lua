local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local Infobars = Core:RegisterModule("Infobars")

Infobars.DataTexts = {}

function Infobars:CreatePanels()
    self:CreateLeftBottomPanel()
    self:CreateRightBottomPanel()
    self:CreateActionBarPanel()
    self:CreateCentralBottomPanel()
end

function Infobars:CreateDataTexts()
    self:PositionBottomPanelDataTexts({
        "Spec", "Guild", "Friends", "Latency", "Fps", "System"
    })

	self:PositionRightPanelDataTexts({
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

function Infobars:PositionBottomPanelDataTexts(names)
	local panel = Infobars.CentralBottomPanel

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
				frame:SetPoint("LEFT", panel, "LEFT", 15, 0)
			else
				local prev = self.DataTexts[names[i - 1]]
				frame:SetPoint("LEFT", prev, "RIGHT", 0, 0)
			end
		else
			print("Missing DataText:", name)
		end

	end
end

function Infobars:PositionRightPanelDataTexts(names)
	local panel = Infobars.RightBottomPanel

	if not panel then
		print("PositionDataTexts: panel is nil!")
		return
	end

	for i, name in ipairs(names) do
		local frame = self.DataTexts[name]
		if frame then

			frame:ClearAllPoints()
			frame:SetParent(panel)
			frame:SetSize(frame.Text:GetWidth(), panel:GetHeight())

			if i == 1 then
				frame:SetPoint("LEFT", panel, "LEFT", 5, 0)
			else
				local prev = self.DataTexts[names[i - 1]]
				frame:SetPoint("LEFT", prev, "RIGHT", 50, 0)
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