local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local type, select, unpack = type, select, unpack
local format = string.format

function Core.HexRGB(r, g, b)
    if r then
        if type(r) == "table" then
            if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
        end
        return format("|cff%02x%02x%02x", r*255, g*255, b*255)
    end
end

function Core:ClassColor(class)
    local color = DB.ClassColors[class]
    if not color then return 1, 1, 1 end
    return color.r, color.g, color.b
end

function Core.UnitColor(unit)
    local r, g, b = 1, 1, 1
    if UnitIsPlayer(unit) then
        local class = select(2, UnitClass(unit))
        if class then
            r, g, b = Core.ClassColor(class)
        end
    elseif UnitIsTapDenied(unit) then
        r, g, b = .6, .6, .6
    else
        local reaction = UnitReaction(unit, "player")
        if reaction then
            local color = FACTION_BAR_COLORS[reaction]
            r, g, b = color.r, color.g, color.b
        end
    end
    return r, g, b
end

local function UpdateColorPicker()
		local swatch = ColorPickerFrame.__swatch
		local r, g, b = ColorPickerFrame:GetColorRGB()
		r = Core:Round(r, 2)
		g = Core:Round(g, 2)
		b = Core:Round(b, 2)
		swatch.tex:SetVertexColor(r, g, b)
		swatch.color.r, swatch.color.g, swatch.color.b = r, g, b
	end

	local function CancelColorPicker()
		local swatch = ColorPickerFrame.__swatch
		local r, g, b = ColorPickerFrame:GetPreviousValues()
		swatch.tex:SetVertexColor(r, g, b)
		swatch.color.r, swatch.color.g, swatch.color.b = r, g, b
	end

	local function OpenColorPicker(self)
		local r, g, b = self.color.r, self.color.g, self.color.b
		ColorPickerFrame.__swatch = self
		ColorPickerFrame.swatchFunc = UpdateColorPicker
		ColorPickerFrame.previousValues = {r = r, g = g, b = b}
		ColorPickerFrame.cancelFunc = CancelColorPicker
		ColorPickerFrame:SetColorRGB(r, g, b)
		ColorPickerFrame:Show()
	end

	local function GetSwatchTexColor(tex)
		local r, g, b = tex:GetVertexColor()
		r = Core:Round(r, 2)
		g = Core:Round(g, 2)
		b = Core:Round(b, 2)
		return r, g, b
	end

	local function ResetColorPicker(swatch)
		local defaultColor = swatch.__default
		if defaultColor then
			ColorPickerFrame:SetColorRGB(defaultColor.r, defaultColor.g, defaultColor.b)
		end
	end

	local whiteColor = {r=1, g=1, b=1}
	function Core:CreateColorSwatch(name, color)
		color = color or whiteColor

		local swatch = CreateFrame("Button", nil, self, "BackdropTemplate")
		swatch:SetSize(18, 18)
		Core.CreateBD(swatch, 1)
		if name then
			swatch.text = Core.CreateFS(swatch, 14, name, false, "LEFT", 26, 0)
		end
		local tex = swatch:CreateTexture()
        Core:SetInside(tex)
		tex:SetTexture(DB.bdTex)
		tex:SetVertexColor(color.r, color.g, color.b)
		tex.GetColor = GetSwatchTexColor

		swatch.tex = tex
		swatch.color = color
		swatch:SetScript("OnClick", OpenColorPicker)
		swatch:SetScript("OnDoubleClick", ResetColorPicker)

		return swatch
	end