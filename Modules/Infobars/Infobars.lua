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
	C_Timer.After(0, function()
		local bottomTexts = {
			["Spec"]    = { position = 0.00, align = "LEFT" },
			["Guild"]   = { position = 0.20, align = "LEFT" },
			["Friends"] = { position = 0.35, align = "LEFT" },
			["Latency"] = { position = 0.63, align = "RIGHT" },
			["Fps"]     = { position = 0.78, align = "RIGHT" },
			["System"]  = { position = 1.00, align = "RIGHT" },
		}

		local rightTexts = {
			["Durability"] = { position = 0.00, align = "LEFT" },
			["Bags"]       = { position = 0.30, align = "LEFT" },
			["Gold"]       = { position = 0.80, align = "RIGHT" },
			["Time"]       = { position = 1.00, align = "RIGHT" },
		}

		self:PositionDataTexts(bottomTexts, self.CentralBottomPanel)
		self:PositionDataTexts(rightTexts, self.RightBottomPanel)
	end)
end

function Infobars:RegisterDataText(name, options)
	local panel = options.panel

	local frame = CreateFrame("Button", "LauringUIInfo_"..name, panel)
	frame:SetSize(80, 20) -- Default size, can be overridden in placement

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

function Infobars:PositionDataTexts(dataTexts, panel)
	if not panel then
		print("PositionDataTexts: panel is nil!")
		return
	end

	local panelWidth = panel:GetWidth()

	for name, config in pairs(dataTexts) do
		local frame = self.DataTexts[name]

		if frame and config then
			frame:ClearAllPoints()
			frame:SetParent(panel)
			frame:SetSize(frame.Text:GetStringWidth() + 10, panel:GetHeight())
			frame:SetPoint(config.align, panel, "LEFT", panelWidth * config.position, 0)
		else
			print("Missing DataText or offset for:", name)
		end
	end
end

function Infobars:GetTooltipAnchor(info)
	local _, height = info:GetCenter()
	if height and height > GetScreenHeight() / 2 then
		return "TOP", "BOTTOM", -15
	else
		return "BOTTOM", "TOP", 15
	end
end

function Infobars:StylePanel(panel)
	Core:StyleFrame(panel)
end

function Infobars:OnLogin()
	self:CreatePanels()
	self:CreateDataTexts()
	self:CreateLocation()
	self:CreateExperienceBar()
end
