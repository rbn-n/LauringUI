local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local QoL = Core:GetModule("QoL")

local ColorPickerFrame, ColorSwatch = _G.ColorPickerFrame, _G.ColorSwatch
local OpacitySliderFrame, ColorPickerFrameHeader = _G.OpacitySliderFrame, _G.ColorPickerFrameHeader

-- Helper to convert hex to RGB component
local function TranslateColor(color)
	if not color then color = "ff" end
	return tonumber(color, 16) / 255
end

-- Local version of the color update function
local function UpdateColor(self)
	local r, g, b = strmatch(self.colorStr or "", "(%x%x)(%x%x)(%x%x)$")
	r, g, b = TranslateColor(r), TranslateColor(g), TranslateColor(b)
	ColorPickerFrame:SetColorRGB(r, g, b)
end

-- Retrieve color safely from input boxes
local function GetBoxColor(box)
	local color = tonumber(box:GetText())
	if not color or color < 0 or color > 255 then color = 255 end
	return color
end

-- Update color from RGB boxes
local function UpdateColorRGB(self)
	local r = GetBoxColor(ColorPickerFrame.__boxR)
	local g = GetBoxColor(ColorPickerFrame.__boxG)
	local b = GetBoxColor(ColorPickerFrame.__boxB)
	self.colorStr = format("%02x%02x%02x", r, g, b)
	UpdateColor(self)
end

-- Update color from hex box
local function UpdateColorString(self)
	self.colorStr = self:GetText()
	UpdateColor(self)
end

-- Helper to create a text input box
local function CreateCodeBox(width, index, text)
	local box = Core.CreateEditBox(ColorPickerFrame, width, 22)
	box:SetMaxLetters(index == 4 and 6 or 3)
	box:SetTextInsets(0, 0, 0, 0)
	box:SetPoint("TOPLEFT", ColorSwatch, "BOTTOMLEFT", 0, -index*24 + 2)
	Core.CreateFS(box, 14, text, "system", "LEFT", -15, 0)

	if index == 4 then
		box:HookScript("OnEnterPressed", UpdateColorString)
	else
		box:HookScript("OnEnterPressed", UpdateColorRGB)
	end

	return box
end

function QoL:EnhancedColorPicker()
	local pickerFrame = ColorPickerFrame

	if pickerFrame._enhancedSetup then return end
	pickerFrame._enhancedSetup = true

	pickerFrame:SetHeight(math.max(pickerFrame:GetHeight(), 250))
	OpacitySliderFrame:SetPoint("TOPLEFT", ColorSwatch, "TOPRIGHT", 50, 0)

	local mover = CreateFrame("Frame", nil, pickerFrame)
	mover:SetAllPoints(ColorPickerFrameHeader)
	Core.CreateMF(mover, pickerFrame) -- make movable via header

	-- Class Color Bar
	local colorBar = CreateFrame("Frame", nil, pickerFrame)
	colorBar:SetSize(1, 22)
	colorBar:SetPoint("BOTTOM", 0, 38)

	local count = 0
	for class, name in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		local value = DB.ClassColors[class]
		if value then
			local button = Core.CreateButton(colorBar, 22, 22, true)
			button.Icon:SetColorTexture(value.r, value.g, value.b)
			button:SetPoint("LEFT", count*22, 0)
			button.colorStr = value.colorStr
			button:SetScript("OnClick", UpdateColor)
			Core.AddTooltip(button, "ANCHOR_TOP", "|c" .. value.colorStr .. name)

			count = count + 1
		end
	end
	colorBar:SetWidth(count * 22)

	-- Input boxes
	pickerFrame.__boxR = CreateCodeBox(45, 1, "|cffff0000R")
	pickerFrame.__boxG = CreateCodeBox(45, 2, "|cff00ff00G")
	pickerFrame.__boxB = CreateCodeBox(45, 3, "|cff0000ffB")
	pickerFrame.__boxH = CreateCodeBox(70, 4, "#")

	-- Sync boxes when color is picked
	pickerFrame:HookScript("OnColorSelect", function(self)
		local r, g, b = self:GetColorRGB()
		r = Core:Round(r * 255)
		g = Core:Round(g * 255)
		b = Core:Round(b * 255)

		self.__boxR:SetText(r)
		self.__boxG:SetText(g)
		self.__boxB:SetText(b)
		self.__boxH:SetText(format("%02x%02x%02x", r, g, b))
	end)
end

QoL:RegisterQoL("EnhancedColorPicker", QoL.EnhancedColorPicker)