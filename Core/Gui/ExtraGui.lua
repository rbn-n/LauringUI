local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

local extraGUIs = {}

function G:ToggleExtraGUI(guiName)
	for name, frame in pairs(extraGUIs) do
		if name == guiName then
			Core:TogglePanel(frame)
		else
			frame:Hide()
		end
	end

	return extraGUIs
end

local function HideExtraGUIs()
	for _, frame in pairs(extraGUIs) do
		frame:Hide()
	end
end

function G:CreateExtraGUI(parent, name, title, bgFrame)
	local frame = CreateFrame("Frame", name, parent)
	frame:SetSize(300, 600)
	frame:SetPoint("TOPLEFT", parent:GetParent(), "TOPRIGHT", 3, 0)
    Core:StyleFrame(frame)

	if title then
		Core.CreateFS(frame, 14, title, "system", "TOPLEFT", 20, -25)
	end

	if bgFrame then
		frame.bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		frame.bg:SetSize(280, 540)
		frame.bg:SetPoint("TOPLEFT", 10, -50)
		Core.CreateBD(frame.bg, .25)
	end

	if not parent.extraGUIHook then
		parent:HookScript("OnHide", HideExtraGUIs)
		parent.extraGUIHook = true
	end
	extraGUIs[name] = frame

	return frame
end

function G:CreateOptionTitle(parent, title, offset)
	Core.CreateFS(parent, 14, title, "system", "TOP", 0, offset)
	local line = Core.SetGradient(parent, "H", 1, 1, 1, .25, .25, 200, Config.PixelMultiplexer)
	line:SetPoint("TOPLEFT", 30, offset-20)
end

local function UpdateDropdownHighlight(self)
	local dd = self.__owner
	for i = 1, #dd.__options do
		local option = dd.options[i]
		if i == Config.DB[dd.__key][dd.__value] then
			option:SetBackdropColor(1, .8, 0, .3)
			option.selected = true
		else
			option:SetBackdropColor(0, 0, 0, .3)
			option.selected = false
		end
	end
end

local function UpdateDropdownState(self)
	local dd = self.__owner
	Config.DB[dd.__key][dd.__value] = self.index
	if dd.__func then dd.__func() end
end

function G:CreateOptionDropdown(parent, title, yOffset, options, tooltip, key, value, default, func)
	local dd = G:CreateDropdown(parent, title, 40, yOffset, options, nil, 180, 28)
	dd.__key = key
	dd.__value = value
	dd.__default = default
	dd.__options = options
	dd.__func = func
	dd.Text:SetText(options[Config.DB[key][value]])

	if tooltip then
		Core.AddTooltip(dd, "ANCHOR_TOP", tooltip, "info", true)
	end

	dd.button.__owner = dd
	dd.button:HookScript("OnClick", UpdateDropdownHighlight)

	for i = 1, #options do
		dd.options[i]:HookScript("OnClick", UpdateDropdownState)
	end
end

local function SliderValueChanged(self, v)
	local current = tonumber(format("%.0f", v))
	self.value:SetText(current)
	Config.DB[self.__key][self.__value] = current
	if self.__update then self.__update() end
end

function G:CreateOptionSlider(parent, title, minV, maxV, defaultV, yOffset, value, func, key)
	local slider = Core.CreateSlider(parent, title, minV, maxV, 1, 30, yOffset)
	if not key then key = "UFs" end
	slider:SetValue(Config.DB[key][value])
	slider.value:SetText(Config.DB[key][value])
	slider.__key = key
	slider.__value = value
	slider.__update = func
	slider.__default = defaultV
	slider:SetScript("OnValueChanged", SliderValueChanged)
end

local function ToggleOptionCheck(self)
	Config.DB[self.__key][self.__value] = self:GetChecked()
	if self.__callback then self:__callback() end
end

function G:CreateOptionCheck(parent, offset, text, key, value, callback, tooltip)
	local box = Core.CreateCheckBox(parent)
	box:SetPoint("TOPLEFT", 10, offset)
	box:SetChecked(Config.DB[key][value])
	box.__key = key
	box.__value = value
	box.__callback = callback
	Core.CreateFS(box, 14, text, nil, "LEFT", 30, 0)
	box:SetScript("OnClick", ToggleOptionCheck)
	if tooltip then
		Core.AddTooltip(box, "ANCHOR_RIGHT", tooltip, "info", true)
	end

	return box
end

function G.ToggleOptionsPanel(option)
	local dd = option.__owner
	for i = 1, #dd.panels do
		dd.panels[i]:SetShown(i == option.index)
	end
end