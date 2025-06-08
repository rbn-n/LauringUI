local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local borders = {
	bgFile =  "Interface\\Buttons\\WHITE8x8",
	edgeFile = "Interface\\Buttons\\WHITE8x8",
	edgeSize = 1,
	tile = false,
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

function Core:StyleFrame(frame)
    Core:CreateBackdrop(frame)
	Core:CreateBorder(frame, 1.1)
	Core:CreateShadow(frame, 5)
end

function Core:CreateBorder(frame, x)
    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetFrameLevel(1)
    border:SetFrameStrata(frame:GetFrameStrata())
    border:SetPoint("TOPLEFT", -x, x)
    border:SetPoint("BOTTOMRIGHT", x, -x)
    border:SetBackdrop(borders)
    border:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
    border:SetBackdropBorderColor(0, 0, 0)
end

function Core:SetBorderColor()
    self:SetBackdropBorderColor(0, 0, 0)
end

function Core:CreateHealthBorder(frame, x)
    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetFrameLevel(1)
    border:SetFrameStrata(frame:GetFrameStrata())
    border:SetPoint("TOPLEFT", -x, x)
    border:SetPoint("BOTTOMRIGHT", x, -x)
    border:SetBackdrop(borders)
    border:SetBackdropColor(1, 0, 0, 0)
    border:SetBackdropBorderColor(0, 0, 0)
end

function Core:CreateBackdrop(frame)
    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetTexture(DB.StatusBarTexture)
    background:SetAllPoints()
    background:SetVertexColor(0.1, 0.1, 0.1, 0)
    frame.__backdrop = background
end

local shadowBackdrop = {
	edgeFile = DB.GlowTexture,
}

function Core:CreateShadow(frame, size)
    if frame.__shadow then return end

    local shadow = CreateFrame("Frame", nil, frame, "BackdropTemplate")

    shadowBackdrop.edgeSize = size or 5

    shadow:SetFrameLevel(1)
    shadow:SetFrameStrata(frame:GetFrameStrata())
    shadow:SetPoint("TOPLEFT", -size, size)
    shadow:SetPoint("BOTTOMRIGHT", size, -size)
    shadow:SetBackdrop(shadowBackdrop)
    shadow:SetBackdropBorderColor(0, 0, 0, .4)

    frame.__shadow = shadow
end

function Core:SetFontSize(size)
    self:SetFont(DB.Font[1], size, DB.Font[3])
end

function Core:CreateFS(size, text, color, anchor, x, y)
    local fs = self:CreateFontString(nil, "OVERLAY")
    Core.SetFontSize(fs, size)
    fs:SetText(text)
    fs:SetWordWrap(false)
    if color and type(color) == "boolean" then
        fs:SetTextColor(DB.r, DB.g, DB.b)
    elseif color == "system" then
        fs:SetTextColor(1, .8, 0)
    end
    if anchor and x and y then
        fs:SetPoint(anchor, x, y)
    else
        fs:SetPoint("CENTER", 1, 0)
    end

    return fs
end

local function CreateBackdrop(parent)
    local bg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    bg:SetAllPoints(parent)
    bg:SetFrameStrata(parent:GetFrameStrata())
    bg:SetFrameLevel(parent:GetFrameLevel() - 1)
    return bg
end

function Core:CreateBackdropFrame(parent)
    local bg = CreateBackdrop(parent)
    self:CreateBorder(bg, 2)
    self:CreateBackdrop(bg)
    self:CreateShadow(bg, 3)
    return bg
end

local function DisablePixelSnap(frame)
    if (frame and not frame:IsForbidden()) and not frame.PixelSnapDisabled then
        if frame.SetSnapToPixelGrid then
            frame:SetSnapToPixelGrid(false)
            frame:SetTexelSnappingBias(0)
        elseif frame.GetStatusBarTexture then
            local texture = frame:GetStatusBarTexture()
            if texture and texture.SetSnapToPixelGrid then
                texture:SetSnapToPixelGrid(false)
                texture:SetTexelSnappingBias(0)
            end
        end

        frame.PixelSnapDisabled = true
    end
end

function Core:SetInside(frame, anchor, xOffset, yOffset, anchor2)
    xOffset = xOffset or Config.PixelMultiplexer
    yOffset = yOffset or Config.PixelMultiplexer
    anchor = anchor or frame:GetParent()

    DisablePixelSnap(frame)
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
    frame:SetPoint("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

function Core:SetOutSide(frame, anchor, xOffset, yOffset, anchor2)
    xOffset = xOffset or Config.PixelMultiplexer
    yOffset = yOffset or Config.PixelMultiplexer
    anchor = anchor or frame:GetParent()

    DisablePixelSnap(frame)
    frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
    frame:SetPoint("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

function Core:CreateSD()
    if self.__shadow then return end

    local frame = self
    if self:IsObjectType("Texture") then frame = self:GetParent() end

    shadowBackdrop.edgeSize = 5
    self.__shadow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    Core:SetOutSide(self.__shadow, self)
    self.__shadow:SetBackdrop(shadowBackdrop)
    self.__shadow:SetBackdropBorderColor(0, 0, 0, .4)
    self.__shadow:SetFrameLevel(1)

    return self.__shadow
end

function Core:CreateGlowFrame(size)
    local frame = CreateFrame("Frame", nil, self)
    frame:SetPoint("CENTER")
    frame:SetSize(size + 8, size + 8)

    return frame
end

local orientationAbbr = {
    ["V"] = "Vertical",
    ["H"] = "Horizontal",
}
function Core:SetGradient(orientation, r, g, b, a1, a2, width, height)
    orientation = orientationAbbr[orientation]
    if not orientation then return end

    local tex = self:CreateTexture(nil, "BACKGROUND")
    tex:SetTexture(DB.BackgroundTexture)
    tex:SetGradient(orientation, CreateColor(r, g, b, a1), CreateColor(r, g, b, a2))
    if width then tex:SetWidth(width) end
    if height then tex:SetHeight(height) end

    return tex
end

function Core:CreateTex()
    if self.__bgTex then return end

    local frame = self
    if self:IsObjectType("Texture") then frame = self:GetParent() end

    local tex = frame:CreateTexture(nil, "BACKGROUND")
    --local tex = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    tex:SetAllPoints(self)
    tex:SetTexture(DB.StatusBarTexture)
    tex:SetHorizTile(true)
    tex:SetVertTile(true)
    tex:SetBlendMode("ADD")
    tex:SetVertexColor(0.1, 0.1, 0.1, 0)

    self.__bgTex = tex
end

-- function Core:CreateBackdrop(frame)
--     local background = frame:CreateTexture(nil, "BACKGROUND")
--     background:SetTexture(DB.StatusBarTexture)
--     background:SetAllPoints()
--     background:SetVertexColor(0.1, 0.1, 0.1, 0)
--     frame.__backdrop = background
-- end

function Core:SetBD(a, x, y, x2, y2)
    local bg = Core.CreateBDFrame(self, a)
    if x then
        bg:SetPoint("TOPLEFT", self, x, y)
        bg:SetPoint("BOTTOMRIGHT", self, x2, y2)
    end
    Core.CreateSD(bg)
    --Core.CreateTex(bg)

    return bg
end

local gradientFrom, gradientTo = CreateColor(0, 0, 0, .5), CreateColor(.3, .3, .3, .3)
function Core:CreateGradient()
    local tex = self:CreateTexture(nil, "BORDER")
    Core:SetInside(tex, self)
    tex:SetTexture(DB.BackgroundTexture)
    tex:SetGradient("Vertical", gradientFrom, gradientTo)

    return tex
end

local defaultBackdrop = {bgFile = DB.BackgroundTexture, edgeFile = DB.BackgroundTexture}
function Core:CreateBD(a)
    defaultBackdrop.edgeSize = Config.PixelMultiplexer
    self:SetBackdrop(defaultBackdrop)
    self:SetBackdropColor(0, 0, 0, a)
    self:SetBackdropBorderColor(0, 0, 0)
end

function Core:CreateBDFrame(a, gradient)
    local frame = self
    if self:IsObjectType("Texture") then frame = self:GetParent() end
    local lvl = frame:GetFrameLevel()

    local bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    Core:SetOutSide(bg, self)
    bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
    Core.CreateBD(bg, a)
    if gradient then
        self.__gradient = Core.CreateGradient(bg)
    end

    return bg
end

local x1, x2, y1, y2 = unpack(DB.TexCoord)
function Core:PixelIcon(texture, highlight)
    self.bg = Core.CreateBDFrame(self)
    self.bg:SetAllPoints()
    self.Icon = self:CreateTexture(nil, "ARTWORK")
    Core:SetInside(self.Icon, self.bg)
    self.Icon:SetTexCoord(x1, x2, y1, y2)
    if texture then
        local atlas = strmatch(texture, "Atlas:(.+)$")
        if atlas then
            self.Icon:SetAtlas(atlas)
        else
            self.Icon:SetTexture(texture)
        end
    end
    if highlight and type(highlight) == "boolean" then
        self:EnableMouse(true)
        self.HL = self:CreateTexture(nil, "HIGHLIGHT")
        self.HL:SetColorTexture(1, 1, 1, .25)
        Core:SetInside(self.HL, self.bg)
    end
end

function Core:ReskinIcon(shadow)
    self:SetTexCoord(x1, x2, y1, y2)
    local bg = Core.CreateBDFrame(self, .25) -- exclude from opacity control
    if shadow then Core.CreateSD(bg) end
    return bg
end

Core.EasyMenu = CreateFrame("Frame", "LauringUI_EasyMenu", UIParent, "UIDropDownMenuTemplate")

function Core:GetRoleTex()
    if self == "TANK" then
        return DB.TankTexture
    elseif self == "DPS" or self == "DAMAGER" then
        return DB.DpsTexture
    elseif self == "HEALER" then
        return DB.HealTexture
    end
end

function Core:ReskinSmallRole(role)
    self:SetTexture(Core.GetRoleTex(role))
    self:SetTexCoord(0, 1, 0, 1)
end

function Core:ReskinRole()
    if self.background then
        self.background:SetTexture("")
    end

    local cover = self.cover or self.Cover
    if cover then cover:SetTexture("") end

    local checkButton = self.checkButton or self.CheckButton or self.CheckBox
    if checkButton then
        checkButton:SetFrameLevel(self:GetFrameLevel() + 2)
        checkButton:SetPoint("BOTTOMLEFT", -2, -2)
        Core.ReskinCheck(checkButton)
    end
end

function Core:CreateHelpInfoButton(tooltip)
    local button = CreateFrame("Button", nil, self)
    button:SetSize(40, 40)
    button.Icon = button:CreateTexture(nil, "ARTWORK")
    button.Icon:SetAllPoints()
    button.Icon:SetTexture(616343)
    button:SetHighlightTexture(616343)
    if tooltip then
        Core.AddTooltip(button, "ANCHOR_BOTTOMLEFT", tooltip, "info", true)
    end

    return button
end

function Core:TogglePanel(frame)
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

local function optOnClick(self)
    PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
    local opt = self.__owner.options
    for i = 1, #opt do
        if self == opt[i] then
            opt[i]:SetBackdropColor(1, .8, 0, .3)
            opt[i].selected = true
        else
            opt[i]:SetBackdropColor(0, 0, 0, .3)
            opt[i].selected = false
        end
    end
    self.__owner.Text:SetText(self.text)
    self:GetParent():Hide()
end

local function optOnEnter(self)
    if self.selected then return end
    self:SetBackdropColor(1, 1, 1, .25)
end

local function optOnLeave(self)
    if self.selected then return end
    self:SetBackdropColor(0, 0, 0)
end

local function buttonOnShow(self)
    self.__list:Hide()
end

local function buttonOnClick(self)
    PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
    Core:TogglePanel(self.__list)
end

function Core:CreateDropDown(width, height, data)
    local dropdown = CreateFrame("Frame", nil, self, "BackdropTemplate")
    dropdown:SetSize(width, height)
    Core.CreateBD(dropdown)
    dropdown:SetBackdropBorderColor(1, 1, 1, .2)
    dropdown.Text = Core.CreateFS(dropdown, 14, "", false, "LEFT", 5, 0)
    dropdown.Text:SetPoint("RIGHT", -5, 0)
    dropdown.options = {}

    local button = CreateFrame("Button", nil, dropdown)
    button:SetPoint("RIGHT", -5, 0)
    Core.ReskinArrow(button, "down")
    button:SetSize(18, 18)
    local list = CreateFrame("Frame", nil, dropdown, "BackdropTemplate")
    list:SetPoint("TOP", dropdown, "BOTTOM", 0, -2)
    RaiseFrameLevel(list)
    Core.CreateBD(list, 1)
    list:SetBackdropBorderColor(1, 1, 1, .2)
    list:Hide()
    button.__list = list
    button:SetScript("OnShow", buttonOnShow)
    button:SetScript("OnClick", buttonOnClick)
    dropdown.button = button

    local opt, index = {}, 0
    for i, j in pairs(data) do
        opt[i] = CreateFrame("Button", nil, list, "BackdropTemplate")
        opt[i]:SetPoint("TOPLEFT", 4, -4 - (i-1)*(height+2))
        opt[i]:SetSize(width - 8, height)
        Core.CreateBD(opt[i])
        local text = Core.CreateFS(opt[i], 14, j, false, "LEFT", 5, 0)
        text:SetPoint("RIGHT", -5, 0)
        opt[i].text = j
        opt[i].index = i
        opt[i].__owner = dropdown
        opt[i]:SetScript("OnClick", optOnClick)
        opt[i]:SetScript("OnEnter", optOnEnter)
        opt[i]:SetScript("OnLeave", optOnLeave)

        dropdown.options[i] = opt[i]
        index = index + 1
    end
    list:SetSize(width, index*(height+2) + 6)

    dropdown.Type = "DropDown"
    return dropdown
end