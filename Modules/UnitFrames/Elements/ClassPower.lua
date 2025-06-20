local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local UF = Core:GetModule("UnitFrames")

function UF.PostUpdateClassPower(element, cur, max, diff, powerType)
	if not cur or cur == 0 then
		for i = 1, 6 do
			element[i].bg:Hide()
		end
	else
		for i = 1, max do
			element[i].bg:Show()
		end
	end

	if diff then
		for i = 1, max do
			element[i]:SetWidth((element.__owner.ClassPowerBar:GetWidth() - (max - 1) * Config.Margin) / max)
		end
		for i = max + 1, 6 do
			element[i].bg:Hide()
		end
	end

	element.thisColor = cur == max and 1 or 2
	if not element.prevColor or element.prevColor ~= element.thisColor then
		local r, g, b = 1, 0, 0
		if element.thisColor == 2 then
			local color = element.__owner.colors.power[powerType]
			r, g, b = color[1], color[2], color[3]
		end
		for i = 1, #element do
			element[i]:SetStatusBarColor(r, g, b)
		end
		element.prevColor = element.thisColor
	end
end

function UF:OnUpdateRunes(elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)
	self.timer:SetText("")
	if Config.DB["UFs"]["ShowRuneTimer"] then
		local remain = self.runeDuration - duration
		if remain > 0 then
			self.timer:SetText(Core.FormatTime(remain))
		end
	end
end

function UF.PostUpdateRunes(element, runemap)
	for index, runeID in next, runemap do
		local rune = element[index]
		local start, duration, runeReady = GetRuneCooldown(runeID)
		if runeReady then
			rune:SetAlpha(1)
			rune:SetScript("OnUpdate", nil)
			rune.timer:SetText("")
		elseif start then
			rune:SetAlpha(.6)
			rune.runeDuration = duration
			rune:SetScript("OnUpdate", UF.OnUpdateRunes)
		end
	end
end

function UF:CreateEclipseBar(frame)
	if DB.MyClass ~= "DRUID" then return end

	local barWidth, barHeight = Config.DB["UFs"]["ClassPowerWidth"], Config.DB["UFs"]["ClassPowerHeight"]
	local barPoint = {"TOPLEFT", frame, "TOPLEFT", Config.DB["UFs"]["ClassPowerxOffset"], Config.DB["UFs"]["ClassPoweryOffset"]}

	local bar = CreateFrame("StatusBar", nil, frame.Health)
	bar:SetSize(barWidth, barHeight)
	bar:SetPoint(unpack(barPoint))
	bar:SetFrameLevel(frame:GetFrameLevel() + 5)
	bar:SetStatusBarTexture(DB.StatusBarTexture2)
	bar:SetStatusBarColor(.3, .52, .9)
	Core:StyleFrame(bar)
	Core:SmoothBar(bar)

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.StatusBarTexture2)
	bg:SetVertexColor(.8, .82, .6)
	bg.multiplier = .25

	local text = Core.CreateFS(bar, 14)
	text:SetPoint("CENTER", bar, "TOP")
	frame:Tag(text, "[cureclipse]")

	frame.EclipseBar = bar
	frame.EclipseBar.bg = bg
end

function UF:CreateClassPower(frame)
	local barWidth, barHeight = Config.DB["UFs"]["ClassPowerWidth"], Config.DB["UFs"]["ClassPowerHeight"]
	local barPoint = {"TOPLEFT", frame, "TOPLEFT", Config.DB["UFs"]["ClassPowerxOffset"], Config.DB["UFs"]["ClassPoweryOffset"]}

	local isDK = DB.MyClass == "DEATHKNIGHT"
	local bar = CreateFrame("Frame", "$parentClassPowerBar", frame.Health)
	bar:SetSize(barWidth, barHeight)
	bar:SetPoint(unpack(barPoint))

	-- show bg while size changed
	if not isDK then
		bar.bg = Core.SetBD(bar)
		bar.bg:SetFrameLevel(5)
		bar.bg:SetBackdropBorderColor(1, .8, 0)
		bar.bg:Hide()
	end

	local bars = {}
	for i = 1, 6 do
		bars[i] = CreateFrame("StatusBar", nil, bar)
		bars[i]:SetHeight(barHeight)
		bars[i]:SetWidth((barWidth - 5 * Config.Margin) / 6)
		bars[i]:SetStatusBarTexture(DB.StatusBarTexture2)
		bars[i]:SetFrameLevel(frame:GetFrameLevel() + 5)
		Core.SetBD(bars[i], 0)
		if i == 1 then
			bars[i]:SetPoint("BOTTOMLEFT")
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", Config.Margin, 0)
		end

		bars[i].bg = (isDK and bars[i] or bar):CreateTexture(nil, "BACKGROUND")
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(DB.StatusBarTexture2)
		bars[i].bg.multiplier = .25

		if isDK then
			bars[i].timer = Core.CreateFS(bars[i], 13, "")
		end
	end

	if isDK then
		bars.PostUpdate = UF.PostUpdateRunes
		bars.__max = 6
		frame.Runes = bars
	else
		bars.PostUpdate = UF.PostUpdateClassPower
		frame.ClassPower = bars
	end

	frame.ClassPowerBar = bar
end

function UF:ToggleUFClassPower()
	local playerFrame = _G.oUF_Player
	if not playerFrame then return end

	local classPowers = { "ClassPower", "Runes", "EclipseBar" }

	for _, elementName in ipairs(classPowers) do
		local element = playerFrame[elementName]
		if element then
			local isEnabled = playerFrame:IsElementEnabled(elementName)
			if Config.DB["UFs"]["ShowClassPower"] then
				if not isEnabled then
					playerFrame:EnableElement(elementName)
					element:ForceUpdate()
				end
			else
				if isEnabled then
					playerFrame:DisableElement(elementName)
				end
			end
		end
	end
end