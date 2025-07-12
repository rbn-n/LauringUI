local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

local function Menu_OnEnter(self)
		self.bg:SetBackdropBorderColor(DB.r, DB.g, DB.b)
	end

	local function Menu_OnLeave(self)
		Core.SetBorderColor(self.bg)
	end

    local function Menu_OnMouseUp(self)
		self:SetBackdropBorderColor(0, 0, 0)
	end

    local function Menu_OnMouseDown(self)
		self.bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
	end

local function EditBoxClearFocus(frame)
    frame:ClearFocus()
end

local function Button_OnEnter(self)
    if not self:IsEnabled() then return end

    self.__bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
    self.__bg:SetBackdropBorderColor(DB.r, DB.g, DB.b)
end

local function Button_OnLeave(self)
    self.__bg:SetBackdropColor(0, 0, 0, 0)
    Core.SetBorderColor(self.__bg)
end

local blizzRegions = {
    "Left",
    "Middle",
    "Right",
    "Mid",
    "LeftDisabled",
    "MiddleDisabled",
    "RightDisabled",
    "TopLeft",
    "TopRight",
    "BottomLeft",
    "BottomRight",
    "TopMiddle",
    "MiddleLeft",
    "MiddleRight",
    "BottomMiddle",
    "MiddleMiddle",
    "TabSpacer",
    "TabSpacer1",
    "TabSpacer2",
    "_RightSeparator",
    "_LeftSeparator",
    "RightSeparator",
    "LeftSeparator",
    "Cover",
    "Border",
    "Background",
    "TopTex",
    "TopLeftTex",
    "TopRightTex",
    "LeftTex",
    "BottomTex",
    "BottomLeftTex",
    "BottomRightTex",
    "RightTex",
    "MiddleTex",
    "Center",
}

function Core:ReskinButton(noHighlight, override)
    if self.SetNormalTexture and not override then self:SetNormalTexture(0) end
    if self.SetHighlightTexture then self:SetHighlightTexture(0) end
    if self.SetPushedTexture then self:SetPushedTexture(0) end
    if self.SetDisabledTexture then self:SetDisabledTexture("") end

    local buttonName = self.GetName and self:GetName()
    for _, region in pairs(blizzRegions) do
        region = buttonName and _G[buttonName..region] or self[region]
        if region then
            region:SetAlpha(0)
            region:Hide()
        end
    end

    self.__bg = Core.CreateBDFrame(self, 0, true)
    self.__bg:SetFrameLevel(self:GetFrameLevel())
    self.__bg:SetAllPoints()

    if not noHighlight then
        self:HookScript("OnEnter", Button_OnEnter)
        self:HookScript("OnLeave", Button_OnLeave)
    end
end

function Core:CreateEditBox(width, height)
    local editBox = CreateFrame("EditBox", nil, self)
    editBox:SetSize(width, height)
    editBox:SetAutoFocus(false)
    editBox:SetTextInsets(5, 5, 0, 0)
    Core.SetFontSize(editBox, DB.Font[2]+2)
    editBox.bg = Core.CreateBDFrame(editBox, 0, true)
    editBox.bg:SetAllPoints()
    editBox:SetScript("OnEscapePressed", EditBoxClearFocus)
    editBox:SetScript("OnEnterPressed", EditBoxClearFocus)

    editBox.Type = "EditBox"
    return editBox
end

function Core:CreateButton(width, height, text, fontSize)
    local button = CreateFrame("Button", nil, self, "BackdropTemplate")
    button:SetSize(width, height)
    if type(text) == "boolean" then
        Core.PixelIcon(button, fontSize, true)
    else
        Core.ReskinButton(button)
        button.text = Core.CreateFS(button, fontSize or 14, text, true)
    end

    return button
end

function Core:ReskinCheckBox(forceSaturation)
    self:SetNormalTexture(0)
    self:SetPushedTexture(0)

    local bg = Core.CreateBDFrame(self, 0, true)
    Core:SetInside(bg, self, 4, 4)
    self.bg = bg

    self:SetHighlightTexture(DB.BackgroundTexture)
    local hl = self:GetHighlightTexture()
    Core:SetInside(hl, bg)
    hl:SetVertexColor(DB.r, DB.g, DB.b, .25)

    local ch = self:GetCheckedTexture()
    ch:SetAtlas("checkmark-minimal")
    ch:SetTexCoord(0, 1, 0, 1)
    ch:SetDesaturated(true)
    ch:SetVertexColor(DB.r, DB.g, DB.b)

    self.forceSaturation = forceSaturation
end

function Core:CreateCheckBox()
    local checkBox = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
    checkBox:SetScript("OnClick", nil) -- reset onclick handler
    Core.ReskinCheckBox(checkBox)

    checkBox.Type = "CheckBox"
    return checkBox
end

function Core:ReskinRadio()
    self:SetNormalTexture(0)
    self:SetHighlightTexture(0)
    self:SetCheckedTexture(DB.bdTex)

    local ch = self:GetCheckedTexture()
    Core:SetInside(ch, self, 4, 4)
    ch:SetVertexColor(DB.r, DB.g, DB.b, .6)

    local bg = Core.CreateBDFrame(self, 0, true)
    Core:SetInside(bg, self, 3, 3)
    self.bg = bg

    self:HookScript("OnEnter", Menu_OnEnter)
    self:HookScript("OnLeave", Menu_OnLeave)
end

-- Color swatch
function Core:ReskinColorSwatch()
    local frameName = self.GetName and self:GetName()
    local swatchBg = frameName and _G[frameName.."SwatchBg"]
    if swatchBg then
        swatchBg:SetColorTexture(0, 0, 0)
        Core:SetInside(swatchBg, nil, 2, 2)
    end

    self:SetNormalTexture(DB.BackgroundTexture)
    Core:SetInside(self:GetNormalTexture(), self, 3, 3)
end

local arrowDegree = {
    ["up"] = 0,
    ["down"] = 180,
    ["left"] = 90,
    ["right"] = -90,
}

function Core:SetupArrow(direction)
    self:SetTexture(DB.ArrowUpTexture)
    self:SetRotation(rad(arrowDegree[direction]))
end

function Core:ReskinArrow(direction)
    self:SetSize(16, 16)
    Core.ReskinButton(self, true)

    self:SetDisabledTexture(DB.BackgroundTexture)
    local dis = self:GetDisabledTexture()
    dis:SetVertexColor(0, 0, 0, .3)
    dis:SetDrawLayer("OVERLAY")
    dis:SetAllPoints()

    local tex = self:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    Core.SetupArrow(tex, direction)
    self.__texture = tex

    self:HookScript("OnEnter", Core.Texture_OnEnter)
    self:HookScript("OnLeave", Core.Texture_OnLeave)
end

-- Handle slider
function Core:ReskinSlider(vertical)
    Core.RemoveBlizzTextures(self)

    local bg = Core.CreateBDFrame(self, 0, true)
    bg:SetPoint("TOPLEFT", 14, -2)
    bg:SetPoint("BOTTOMRIGHT", -15, 3)

    local thumb = self:GetThumbTexture()
    thumb:SetTexture(DB.sparkTex)
    thumb:SetBlendMode("ADD")
    if vertical then thumb:SetRotation(rad(90)) end

    local bar = CreateFrame("StatusBar", nil, bg)
    bar:SetStatusBarTexture(DB.StatusBarTexture)
    bar:SetStatusBarColor(1, .8, 0, .5)
    if vertical then
        bar:SetPoint("BOTTOMLEFT", bg, Config.PixelMultiplexer, Config.PixelMultiplexer)
        bar:SetPoint("BOTTOMRIGHT", bg, -Config.PixelMultiplexer, Config.PixelMultiplexer)
        bar:SetPoint("TOP", thumb, "CENTER")
        bar:SetOrientation("VERTICAL")
    else
        bar:SetPoint("TOPLEFT", bg, Config.PixelMultiplexer, -Config.PixelMultiplexer)
        bar:SetPoint("BOTTOMLEFT", bg, Config.PixelMultiplexer, Config.PixelMultiplexer)
        bar:SetPoint("RIGHT", thumb, "CENTER")
    end
end

local function UpdateSliderEditBox(self)
    local slider = self.__owner
    local minValue, maxValue = slider:GetMinMaxValues()
    local text = tonumber(self:GetText())
    if not text then return end
    text = min(maxValue, text)
    text = max(minValue, text)
    slider:SetValue(text)
    self:SetText(text)
    self:ClearFocus()
end

local function ResetSliderValue(self)
    local slider = self.__owner
    if slider.__default then
        slider:SetValue(slider.__default)
    end
end

function Core:CreateSlider(name, minValue, maxValue, step, x, y, width)
    local slider = CreateFrame("Slider", nil, self, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetWidth(width or 200)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetHitRectInsets(0, 0, 0, 0)
    Core.ReskinSlider(slider)

    slider.Low:SetText(minValue)
    slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 10, -2)
    slider.High:SetText(maxValue)
    slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -10, -2)
    slider.Text:ClearAllPoints()
    slider.Text:SetPoint("CENTER", 0, 25)
    slider.Text:SetText(name)
    slider.Text:SetTextColor(1, .8, 0)
    slider.value = Core.CreateEditBox(slider, 50, 20)
    slider.value:SetPoint("TOP", slider, "BOTTOM")
    slider.value:SetJustifyH("CENTER")
    slider.value.__owner = slider
    slider.value:SetScript("OnEnterPressed", UpdateSliderEditBox)

    slider.clicker = CreateFrame("Button", nil, slider)
    slider.clicker:SetAllPoints(slider.Text)
    slider.clicker.__owner = slider
    slider.clicker:SetScript("OnDoubleClick", ResetSliderValue)

    return slider
end

local function ReskinStepper(stepper, direction)
    Core.RemoveBlizzTextures(stepper)
    stepper:SetWidth(19)

    local tex = stepper:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    Core.SetupArrow(tex, direction)
    stepper.__texture = tex

    stepper:HookScript("OnEnter", Core.Texture_OnEnter)
    stepper:HookScript("OnLeave", Core.Texture_OnLeave)
end

function Core:ReskinStepperSlider(minimal)
    Core.RemoveBlizzTextures(self)
    ReskinStepper(self.Back, "left")
    ReskinStepper(self.Forward, "right")
    self.Slider:DisableDrawLayer("ARTWORK")

    local thumb = self.Slider.Thumb
    thumb:SetTexture(DB.sparkTex)
    thumb:SetBlendMode("ADD")
    thumb:SetSize(20, 30)

    local bg = Core.CreateBDFrame(self.Slider, 0, true)
    local offset = minimal and 10 or 13
    bg:SetPoint("TOPLEFT", 10, -offset)
    bg:SetPoint("BOTTOMRIGHT", -10, offset)
    local bar = CreateFrame("StatusBar", nil, bg)
    bar:SetStatusBarTexture(DB.StatusBarTexture)
    bar:SetStatusBarColor(1, .8, 0, .5)
    bar:SetPoint("TOPLEFT", bg, Config.PixelMultiplexer, -Config.PixelMultiplexer)
    bar:SetPoint("BOTTOMLEFT", bg, Config.PixelMultiplexer, Config.PixelMultiplexer)
    bar:SetPoint("RIGHT", thumb, "CENTER")
end

local function UpdateCollapseTexture(texture, collapsed)
    if collapsed then
        texture:SetTexCoord(0, .4375, 0, .4375)
    else
        texture:SetTexCoord(.5625, 1, 0, .4375)
    end
end

local function ResetCollapseTexture(self, texture)
    if self.settingTexture then return end
    self.settingTexture = true
    self:SetNormalTexture(0)

    if texture and texture ~= "" then
        if strfind(texture, "Plus") or strfind(texture, "Closed") then
            self.__texture:DoCollapse(true)
        elseif strfind(texture, "Minus") or strfind(texture, "Open") then
            self.__texture:DoCollapse(false)
        end
        self.bg:Show()
    else
        self.bg:Hide()
    end
    self.settingTexture = nil
end

local function HideCollapseTexture(self)
    self.bg:Hide()
end

function Core:ReskinCollapse(isAtlas)
    self:SetNormalTexture(0)
    self:SetHighlightTexture(0)
    self:SetPushedTexture(0)
    self:SetDisabledTexture("")

    local bg = Core.CreateBDFrame(self, .25, true)
    bg:ClearAllPoints()
    bg:SetSize(13, 13)
    bg:SetPoint("LEFT", self:GetNormalTexture())
    self.bg = bg

    self.__texture = bg:CreateTexture(nil, "OVERLAY")
    self.__texture:SetPoint("CENTER")
    self.__texture:SetSize(7, 7)
    self.__texture:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
    self.__texture.DoCollapse = UpdateCollapseTexture

    self:HookScript("OnEnter", Core.Texture_OnEnter)
    self:HookScript("OnLeave", Core.Texture_OnLeave)
    if isAtlas then
        hooksecurefunc(self, "SetNormalAtlas", ResetCollapseTexture)
    else
        hooksecurefunc(self, "SetNormalTexture", ResetCollapseTexture)
        if self.ClearNormalTexture then
            hooksecurefunc(self, "ClearNormalTexture", HideCollapseTexture)
        end
    end
end

local buttonNames = {"MaximizeButton", "MinimizeButton"}
function Core:ReskinMinMax()
    for _, name in next, buttonNames do
        local button = self[name]
        if button then
            button:SetSize(16, 16)
            button:ClearAllPoints()
            button:SetPoint("CENTER", -3, 0)
            button:SetHitRectInsets(1, 1, 1, 1)
            Core.ReskinButton(button)

            local tex = button:CreateTexture()
            tex:SetAllPoints()
            if name == "MaximizeButton" then
                Core.SetupArrow(tex, "up")
            else
                Core.SetupArrow(tex, "down")
            end
            button.__texture = tex

            button:SetScript("OnEnter", Core.Texture_OnEnter)
            button:SetScript("OnLeave", Core.Texture_OnLeave)
        end
    end
end

function Core:CreateGear(name)
    local button = CreateFrame("Button", name, self)
    button:SetSize(24, 24)
    button.Icon = button:CreateTexture(nil, "ARTWORK")
    button.Icon:SetAllPoints()
    button.Icon:SetTexture(DB.GearTexture)
    button.Icon:SetTexCoord(0, .5, 0, .5)
    button:SetHighlightTexture(DB.GearTexture)
    button:GetHighlightTexture():SetTexCoord(0, .5, 0, .5)

    return button
end

local function CheckUIOption(key, value, newValue)
	if key == "ACCOUNT" then
		if newValue ~= nil then
			LauringUIAccountDB[value] = newValue
		else
			return LauringUIAccountDB[value]
		end
	else
		if newValue ~= nil then
			Config.DB[key][value] = newValue
		else
			return Config.DB[key][value]
		end
	end
end

local function CheckUIReload(name)
	if not strfind(name, "%*") then
		G.NeedUIReload = true
	end
end

local function OnCheckBoxClick(self)
	CheckUIOption(self.__key, self.__value, self:GetChecked())
	CheckUIReload(self.__name)
	if self.__callback then self:__callback() end
end

local function RestoreEditbox(self)
	self:SetText(CheckUIOption(self.__key, self.__value))
end

local function AcceptEditbox(self)
	CheckUIOption(self.__key, self.__value, self:GetText())
	CheckUIReload(self.__name)
	if self.__callback then self:__callback() end
end

local function OnSliderChanged(self, v)
	local current = Core:Round(tonumber(v), 2)
	CheckUIOption(self.__key, self.__value, current)
	CheckUIReload(self.__name)
	self.value:SetText(current)
	if self.__callback then self:__callback() end
end

local function UpdateDropdownSelection(self)
	local dd = self.__owner
	for i = 1, #dd.__options do
		local option = dd.options[i]
		if i == CheckUIOption(dd.__key, dd.__value) then
			option:SetBackdropColor(1, .8, 0, .3)
			option.selected = true
		else
			option:SetBackdropColor(0, 0, 0, .3)
			option.selected = false
		end
	end
end

local function UpdateDropdownClick(self)
	local dd = self.__owner
	CheckUIOption(dd.__key, dd.__value, self.index)
	CheckUIReload(dd.__name)
	if dd.__callback then dd:__callback() end
end

local function AddTextureToOption(parent, index)
	local tex = parent[index]:CreateTexture()
    Core:SetInside(tex, nil, 4, 4)
	tex:SetTexture(G.TextureList[index].texture)
	tex:SetVertexColor(DB.r, DB.g, DB.b)
end

local function LabelOnEnter(self)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self:GetParent(), "ANCHOR_RIGHT", 0, 3)
	GameTooltip:AddLine(self.text)
	GameTooltip:AddLine(self.tip, .6,.8,1, 1)
	GameTooltip:Show()
end

local function CreateLabel(parent, text, tip)
	local label = Core.CreateFS(parent, 14, text, "system", "CENTER", 0, 25)
	if not tip then return end
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints(label)
	frame.text = text
	frame.tip = tip
	frame:SetScript("OnEnter", LabelOnEnter)
	frame:SetScript("OnLeave", Core.HideTooltip)
end

function G:CreateDropdown(parent, text, x, y, data, tip, width, height)
	local dd = Core.CreateDropDown(parent, width or 90, height or 30, data)
	dd:SetPoint("TOPLEFT", x, y)
	CreateLabel(dd, text, tip)

	return dd
end


function G:CreateOption(tabName, guiPage)
	local parent, offset = guiPage[tabName].child, 20

    local tabOptions = G.TabList[tabName]

	for _, option in pairs(tabOptions) do
		local optType, key, value, name, horizon, data, callback, tooltip, disabled, isFirstRowSlider = unpack(option)
		-- Checkboxes
		if optType == 1 then
			local cb = Core.CreateCheckBox(parent)
			cb:SetHitRectInsets(-5, -5, -5, -5)
			if horizon then
				cb:SetPoint("TOPLEFT", 330, -offset + 35)
			else
				cb:SetPoint("TOPLEFT", 20, -offset)
				offset = offset + 35
			end
			cb.__key = key
			cb.__value = value
			cb.__name = name
			cb.__callback = callback
			cb.name = Core.CreateFS(cb, 14, name, false, "LEFT", 30, 0)
			cb:SetChecked(CheckUIOption(key, value))
			cb:SetScript("OnClick", OnCheckBoxClick)
			if data and type(data) == "function" then
				local bu = Core.CreateGear(parent)
				bu:SetPoint("LEFT", cb.name, "RIGHT", -2, 1)
				bu:SetScript("OnClick", data)
			end
			if tooltip then
				Core.AddTooltip(cb, "ANCHOR_RIGHT", tooltip, "info", true)
			end
            if disabled then
                if type(disabled) == "table" and disabled.OnHide and not cb:GetChecked() then
                    disabled.OnHide()
                end
                if type(disabled) == "boolean" then
                    cb:Hide()
                end
            end
		-- Editbox
		elseif optType == 2 then
			local eb = Core.CreateEditBox(parent, 200, 28)
			eb:SetMaxLetters(999)
			eb.__key = key
			eb.__value = value
			eb.__name = name
			eb.__callback = callback
			eb.__default = (key == "ACCOUNT" and G.AccountSettings[value]) or G.DefaultSettings[key][value]
			if horizon then
				eb:SetPoint("TOPLEFT", 345, -offset + 45)
			else
				eb:SetPoint("TOPLEFT", 35, -offset - 25)
				offset = offset + 70
			end
			eb:SetText(CheckUIOption(key, value))
			eb:HookScript("OnEscapePressed", RestoreEditbox)
			eb:HookScript("OnEnterPressed", AcceptEditbox)

			Core.CreateFS(eb, 14, name, "system", "CENTER", 0, 25)
			local tip = L["EditBox Tip"]
			if tooltip then tip = tooltip.."|n"..tip end
			Core.AddTooltip(eb, "ANCHOR_RIGHT", tip, "info", true)
		-- Slider
		elseif optType == 3 then
			local min, max, step = unpack(data)
			local x, y
			if horizon then
                local yMult = isFirstRowSlider and 30 or 40
				x, y = 350, -offset + yMult
			else
				x, y = 40, -offset - 30
				offset = offset + 70
			end
			local s = Core.CreateSlider(parent, name, min, max, step, x, y)
			s.__key = key
			s.__value = value
			s.__name = name
			s.__callback = callback
			s.__default = (key == "ACCOUNT" and G.AccountSettings[value]) or G.DefaultSettings[key][value]
			s:SetValue(CheckUIOption(key, value))
			s:SetScript("OnValueChanged", OnSliderChanged)
			s.value:SetText(Core:Round(CheckUIOption(key, value), 2))
			if tooltip then
				Core.AddTooltip(s, "ANCHOR_RIGHT", tooltip, "info", true)
			end
		-- Dropdown
		elseif optType == 4 then
            if value == "TexStyle" then
				for _, v in ipairs(G.TextureList) do
					tinsert(data, v.name)
				end
			end

			local dd = Core.CreateDropDown(parent, 200, 28, data)
			if horizon then
				dd:SetPoint("TOPLEFT", 345, -offset + 45)
			else
				dd:SetPoint("TOPLEFT", 35, -offset - 25)
				offset = offset + 70
			end
			dd.Text:SetText(data[CheckUIOption(key, value)])
			dd.__key = key
			dd.__value = value
			dd.__name = name
			dd.__options = data
			dd.__callback = callback
			dd.button.__owner = dd
			dd.button:HookScript("OnClick", UpdateDropdownSelection)

			for j = 1, #data do
				dd.options[j]:HookScript("OnClick", UpdateDropdownClick)
				if value == "TexStyle" then
					AddTextureToOption(dd.options, j) -- texture preview
				end
			end

			Core.CreateFS(dd, 14, name, "system", "CENTER", 0, 25)
			if tooltip then
				Core.AddTooltip(dd, "ANCHOR_RIGHT", tooltip, "info", true)
			end
		-- Colorswatch
		elseif optType == 5 then
			local swatch = Core.CreateColorSwatch(parent, name, CheckUIOption(key, value))
			local width = 25 + (horizon or 0)*155
			if horizon then
				swatch:SetPoint("TOPLEFT", width, -offset + 30)
			else
				swatch:SetPoint("TOPLEFT", width, -offset - 5)
				offset = offset + 35
			end
			swatch.__default = (key == "ACCOUNT" and G.AccountSettings[value]) or G.DefaultSettings[key][value]
			if disabled then swatch:Hide() end
		-- Blank, no optType
		else
			if not key then
				local line = Core.SetGradient(parent, "H", 1, 1, 1, .25, .25, 560, Config.PixelMultiplexer)
				line:SetPoint("TOPLEFT", 25, -offset - 12)
			end
			offset = offset + 35
		end
	end

	local footer = CreateFrame("Frame", nil, parent)
	footer:SetSize(20, 20)
	footer:SetPoint("TOPLEFT", 25, -offset)
end

local function Thumb_OnEnter(self)
    local thumb = self.thumb or self
    thumb.bg:SetBackdropColor(DB.r, DB.g, DB.b, .75)
end
local function Thumb_OnLeave(self)
    local thumb = self.thumb or self
    if thumb.__isActive then return end
    thumb.bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
end
local function Thumb_OnMouseDown(self)
    local thumb = self.thumb or self
    thumb.__isActive = true
    thumb.bg:SetBackdropColor(DB.r, DB.g, DB.b, .75)
end
local function Thumb_OnMouseUp(self)
    local thumb = self.thumb or self
    thumb.__isActive = nil
    thumb.bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
end

local function updateScrollArrow(arrow)
    if not arrow.__texture then return end

    if arrow:IsEnabled() then
        arrow.__texture:SetVertexColor(1, 1, 1)
    else
        arrow.__texture:SetVertexColor(.5, .5, .5)
    end
end
local function updateTrimScrollArrow(self, atlas)
    local arrow = self.__owner
    if not arrow.__texture then return end

    if atlas == arrow.disabledTexture then
        arrow.__texture:SetVertexColor(.5, .5, .5)
    else
        arrow.__texture:SetVertexColor(1, 1, 1)
    end
end

local function reskinScrollArrow(self, direction, minimal)
    if not self then return end

    if self.Texture then
        self.Texture:SetAlpha(0)
        if self.Overlay then self.Overlay:SetAlpha(0) end
        if minimal then self:SetHeight(17) end
    else
        Core.RemoveBlizzTextures(self)
    end

    local tex = self:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    Core.SetupArrow(tex, direction)
    self.__texture = tex

    self:HookScript("OnEnter", Core.Texture_OnEnter)
    self:HookScript("OnLeave", Core.Texture_OnLeave)

    if self.Texture then
        if minimal then return end
        self.Texture.__owner = self
        hooksecurefunc(self.Texture, "SetAtlas", updateTrimScrollArrow)
        updateTrimScrollArrow(self.Texture, self.Texture:GetAtlas())
    else
        hooksecurefunc(self, "Enable", updateScrollArrow)
        hooksecurefunc(self, "Disable", updateScrollArrow)
    end
	end

function Core:ReskinScroll()
    Core.RemoveBlizzTextures(self:GetParent())
    Core.RemoveBlizzTextures(self)

    local thumb = self:GetThumbTexture()
    if thumb then
        thumb:SetAlpha(0)
        thumb.bg = Core.CreateBDFrame(thumb, .25)
        thumb.bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
        thumb.bg:SetPoint("TOPLEFT", thumb, 4, -1)
        thumb.bg:SetPoint("BOTTOMRIGHT", thumb, -4, 1)
        self.thumb = thumb

        self:HookScript("OnEnter", Thumb_OnEnter)
        self:HookScript("OnLeave", Thumb_OnLeave)
        self:HookScript("OnMouseDown", Thumb_OnMouseDown)
        self:HookScript("OnMouseUp", Thumb_OnMouseUp)
    end

    local up, down = self:GetChildren()
    reskinScrollArrow(up, "up")
    reskinScrollArrow(down, "down")
end

function G:CreateScroll(parent, width, height, text)
	local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
	scroll:SetSize(width, height)
	scroll:SetPoint("BOTTOMLEFT", 10, 10)
	Core.CreateBDFrame(scroll, .25)
	if text then
		Core.CreateFS(scroll, 15, text, false, "TOPLEFT", 5, 20)
	end
	scroll.child = CreateFrame("Frame", nil, scroll)
	scroll.child:SetSize(width, 1)
	scroll:SetScrollChild(scroll.child)
	Core.ReskinScroll(scroll.ScrollBar)

	return scroll
end

function Core:ReskinMenuButton()
    Core.RemoveBlizzTextures(self)
    --self.bg = Core.SetBD(self)
    Core:StyleFrame(self)
    self:SetScript("OnEnter", Menu_OnEnter)
    self:SetScript("OnLeave", Menu_OnLeave)
    self:HookScript("OnMouseUp", Menu_OnMouseUp)
    self:HookScript("OnMouseDown", Menu_OnMouseDown)
end

function G:CreateBarWidgets(parent, texture)
	local icon = CreateFrame("Frame", nil, parent)
	icon:SetSize(22, 22)
	icon:SetPoint("LEFT", 5, 0)
	Core.PixelIcon(icon, texture, true)

	local close = CreateFrame("Button", nil, parent)
	close:SetSize(20, 20)
	close:SetPoint("RIGHT", -5, 0)
	close.Icon = close:CreateTexture(nil, "ARTWORK")
	close.Icon:SetAllPoints()
	close.Icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")
	close:SetHighlightTexture(close.Icon:GetTexture())

	return icon, close
end