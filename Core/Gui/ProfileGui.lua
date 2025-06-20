local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

function G:CreateProfileIcon(bar, index, texture, title, description)
	local button = CreateFrame("Button", nil, bar)
	button:SetSize(32, 32)
	button:SetPoint("RIGHT", -5 - (index-1)*37, 0)
	Core.PixelIcon(button, texture, true)
	button.title = title
	Core.AddTooltip(button, "ANCHOR_RIGHT", description, "info")

	return button
end
function G:Reset_OnClick()
	StaticPopup_Show("LAURINGUI_RESET_PROFILE")
end

function G:Apply_OnClick()
	G.CurrentProfile = self:GetParent().index
	StaticPopup_Show("LAURINGUI_APPLY_PROFILE")
end

function G:Download_OnClick()
	G.CurrentProfile = self:GetParent().index
	StaticPopup_Show("LAURINGUI_DOWNLOAD_PROFILE")
end

function G:Upload_OnClick()
	G.CurrentProfile = self:GetParent().index
	StaticPopup_Show("LAURINGUI_UPLOAD_PROFILE")
end

function G:GetClassFromGoldInfo(name, realm)
	local class = "NONE"
	if LauringUIAccountDB["TotalGold"][realm] and LauringUIAccountDB["TotalGold"][realm][name] then
		class = LauringUIAccountDB["TotalGold"][realm][name][2]
	end
	return class
end

function G:FindProfleUser(icon)
	icon.list = {}
	for fullName, index in pairs(LauringUIAccountDB["ProfileIndex"]) do
		if index == icon.index then
			local name, realm = strsplit("-", fullName)
			if not icon.list[realm] then icon.list[realm] = {} end
			icon.list[realm][Ambiguate(fullName, "none")] = G:GetClassFromGoldInfo(name, realm)
		end
	end
end

function G:Icon_OnEnter()
	if not next(self.list) then return end

	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["SharedCharacters"])
	GameTooltip:AddLine(" ")
	local r, g, b
	for _, value in pairs(self.list) do
		for name, class in pairs(value) do
			if class == "NONE" then
				r, g, b = .5, .5, .5
			else
				r, g, b = Core.ClassColor(class)
			end
			GameTooltip:AddLine(name, r, g, b)
		end
	end
	GameTooltip:Show()
end

function G:Note_OnEscape()
	self:SetText(LauringUIAccountDB["ProfileNames"][self.index])
end

function G:Note_OnEnter()
	local text = self:GetText()
	if text == "" then
		LauringUIAccountDB["ProfileNames"][self.index] = self.__defaultText
		self:SetText(self.__defaultText)
	else
		LauringUIAccountDB["ProfileNames"][self.index] = text
	end
end

function G:CreateProfileBar(parent, index)
	local bar = Core.CreateBDFrame(parent, .25)
	bar:ClearAllPoints()
	bar:SetPoint("TOPLEFT", 10, -10 - 45*(index-1))
	bar:SetSize(570, 40)
	bar.index = index

	local icon = CreateFrame("Frame", nil, bar)
	icon:SetSize(32, 32)
	icon:SetPoint("LEFT", 5, 0)
	if index == 1 then
		Core.PixelIcon(icon, nil, true) -- character
		SetPortraitTexture(icon.Icon, "player")
	else
		Core.PixelIcon(icon, 235423, true) -- share
		icon.Icon:SetTexCoord(.6, .9, .1, .4)
		icon.index = index
		G:FindProfleUser(icon)
		icon:SetScript("OnEnter", G.Icon_OnEnter)
		icon:SetScript("OnLeave", Core.HideTooltip)
	end

	local note = Core.CreateEditBox(bar, 150, 32)
	note:SetPoint("LEFT", icon, "RIGHT", 5, 0)
	note:SetMaxLetters(20)
	if index == 1 then
		note.__defaultText = L["DefaultCharacterProfile"]
	else
		note.__defaultText = L["DefaultSharedProfile"]..(index - 1)
	end
	if not LauringUIAccountDB["ProfileNames"][index] then
		LauringUIAccountDB["ProfileNames"][index] = note.__defaultText
	end
	note:SetText(LauringUIAccountDB["ProfileNames"][index])
	note.index = index
	note:HookScript("OnEnterPressed", G.Note_OnEnter)
	note:HookScript("OnEscapePressed", G.Note_OnEscape)
	note.title = L["ProfileName"]
	Core.AddTooltip(note, "ANCHOR_TOP", L["ProfileNameTip"], "info")

	local reset = G:CreateProfileIcon(bar, 1, "Atlas:transmog-icon-revert", L["ResetProfile"], L["ResetProfileTip"])
	reset:SetScript("OnClick", G.Reset_OnClick)
	bar.reset = reset

	local apply = G:CreateProfileIcon(bar, 2, "Interface\\RAIDFRAME\\ReadyCheck-Ready", L["SelectProfile"], L["SelectProfileTip"])
	apply:SetScript("OnClick", G.Apply_OnClick)
	bar.apply = apply

	local download = G:CreateProfileIcon(bar, 3, "Atlas:streamcinematic-downloadicon", L["DownloadProfile"], L["DownloadProfileTip"])
	download.Icon:SetTexCoord(.25, .75, .25, .75)
	download:SetScript("OnClick", G.Download_OnClick)
	bar.download = download

	local upload = G:CreateProfileIcon(bar, 4, "Atlas:bags-icon-addslots", L["UploadProfile"], L["UploadProfileTip"])
	Core:SetInside(upload.Icon, nil, 6, 6)
	upload:SetScript("OnClick", G.Upload_OnClick)
	bar.upload = upload

	return bar
end

local function UpdateButtonStatus(button, enable)
	button:EnableMouse(enable)
	button.Icon:SetDesaturated(not enable)
end

function G:UpdateCurrentProfile()
	for index, bar in pairs(G.bars) do
		if index == G.CurrentProfile then
			UpdateButtonStatus(bar.upload, false)
			UpdateButtonStatus(bar.download, false)
			UpdateButtonStatus(bar.apply, false)
			UpdateButtonStatus(bar.reset, true)
			bar:SetBackdropColor(DB.r, DB.g, DB.b, .25)
			bar.apply.bg:SetBackdropBorderColor(1, .8, 0)
		else
			UpdateButtonStatus(bar.upload, true)
			UpdateButtonStatus(bar.download, true)
			UpdateButtonStatus(bar.apply, true)
			UpdateButtonStatus(bar.reset, false)
			bar:SetBackdropColor(0, 0, 0, .25)
			Core.SetBorderColor(bar.apply.bg)
		end
	end
end

function G:Delete_OnEnter()
	local text = self:GetText()
	if not text or text == "" then return end
	local name, realm = strsplit("-", text)
	if not realm then
		realm = DB.MyRealm
		text = name.."-"..realm
		self:SetText(text)
	end

	if LauringUIAccountDB["ProfileIndex"][text] or (LauringUIAccountDB["TotalGold"][realm] and LauringUIAccountDB["TotalGold"][realm][name]) then
		StaticPopup_Show("LAURINGUI_DELETE_UNIT_PROFILE", text, G:GetClassFromGoldInfo(name, realm))
	else
		UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect unit name"])
	end
end

function G:Delete_OnEscape()
	self:SetText("")
end

function G:CreateProfileGUI(parent)
	local reset = Core.CreateButton(parent, 120, 24, L["LauringUI Reset"])
	reset:SetPoint("BOTTOMRIGHT", -10, 10)
	reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_LAURINGUI")
	end)

	local restore = Core.CreateButton(parent, 120, 24, L["Reset Help"])
	restore:SetPoint("BOTTOM", reset, "TOP", 0, 2)
	restore:SetScript("OnClick", function()
		StaticPopup_Show("RESET_LAURINGUI_HELPINFO")
	end)

	local import = Core.CreateButton(parent, 120, 24, L["Import"])
	import:SetPoint("BOTTOMLEFT", 10, 10)
	import:SetScript("OnClick", function()
		parent:GetParent():Hide()
		G:CreateDataFrame()
		G.ProfileDataFrame.Header:SetText(L["Import Header"])
		G.ProfileDataFrame.text:SetText(L["Import"])
		G.ProfileDataFrame.editBox:SetText("")
	end)

	local export = Core.CreateButton(parent, 120, 24, L["Export"])
	export:SetPoint("LEFT", import, "RIGHT", 5, 0)
	export:SetScript("OnClick", function()
		parent:GetParent():Hide()
		G:CreateDataFrame()
		G.ProfileDataFrame.Header:SetText(L["Export Header"])
		G.ProfileDataFrame.text:SetText(OKAY)
		G:ExportGUIData()
	end)

	Core.CreateFS(parent, 14, L["Profile Management"], "system", "TOPLEFT", 10, -10)
	local description = Core.CreateFS(parent, 14, L["Profile Description"], nil, "TOPLEFT", 10, -35)
	description:SetPoint("TOPRIGHT", -10, -30)
	description:SetWordWrap(true)
	description:SetJustifyH("LEFT")

	local delete = Core.CreateEditBox(parent, 245, 24)
	delete:SetPoint("BOTTOMLEFT", import, "TOPLEFT", 0, 2)
	delete:HookScript("OnEnterPressed", G.Delete_OnEnter)
	delete:HookScript("OnEscapePressed", G.Delete_OnEscape)
	delete.title = L["DeleteUnitProfile"]
	Core.AddTooltip(delete, "ANCHOR_TOP", L["DeleteUnitProfileTip"], "info")

	G.CurrentProfile = LauringUIAccountDB["ProfileIndex"][DB.MyFullName]

	local numBars = 3
	local panel = Core.CreateBDFrame(parent, .25)
	panel:ClearAllPoints()
	panel:SetPoint("BOTTOMLEFT", delete, "TOPLEFT", 0, 10)
	panel:SetWidth(parent:GetWidth() - 20)
	panel:SetHeight(15 + numBars * 45)
	panel:SetFrameLevel(11)

	G.bars = {}
	for i = 1, numBars do
		G.bars[i] = G:CreateProfileBar(panel, i)
	end

	G:UpdateCurrentProfile()
end

-- Data transfer
local bloodlustFilter = {
	[57723] = true,
	[57724] = true,
	[80354] = true,
	[264689] = true
}

local accountStrValues = {
	["ChatFilterList"] = true,
	["ChatFilterWhiteList"] = true,
	["CustomTex"] = true,
	["IgnoredButtons"] = true,
}

local booleanTable = {
	["CustomUnits"] = true,
	["PowerUnits"] = true,
	["DotSpells"] = true,
}

function G:ExportGUIData()
	local text = "LauringUISettings:"..DB.MyName..":"..DB.MyClass
	for KEY, VALUE in pairs(Config.DB) do
		if type(VALUE) == "table" then
			for key, value in pairs(VALUE) do
				if type(value) == "table" then
					if value.r then
						text = text..";"..KEY..":"..key
						for k, v in pairs(value) do
							text = text..":"..k..":"..v
						end
					elseif key == "ExplosiveCache" then
						text = text..";"..KEY..":"..key..":EMPTYTABLE"
					elseif KEY == "Mover" then
						text = text..";"..KEY..":"..key
						for _, v in ipairs(value) do
							text = text..":"..tostring(v)
						end
					elseif key == "CustomItems" or key == "CustomNames" then
						text = text..";"..KEY..":"..key
						for k, v in pairs(value) do
							text = text..":"..k..":"..v
						end
					elseif booleanTable[key] then
						text = text..";"..KEY..":"..key
						for k, v in pairs(value) do
							text = text..":"..k..":"..tostring(v)
						end
					end
				else
					if Config.DB[KEY][key] ~= G.DefaultSettings[KEY][key] then -- don't export default settings
						text = text..";"..KEY..":"..key..":"..tostring(value)
					end
				end
			end
		end
	end

	for KEY, VALUE in pairs(LauringUIAccountDB) do
		if KEY == "ProfileIndex" or KEY == "ProfileNames" then
			text = text..";ACCOUNT:"..KEY
			for k, v in pairs(VALUE) do
				text = text..":"..k..":"..v
			end
		elseif VALUE == true or VALUE == false or accountStrValues[KEY] then
			text = text..";ACCOUNT:"..KEY..":"..tostring(VALUE)
		end
	end

	G.ProfileDataFrame.editBox:SetText(Core:Encode(text))
	G.ProfileDataFrame.editBox:HighlightText()
end

local function toBoolean(value)
	if value == "true" then
		return true
	elseif value == "false" then
		return false
	end
end

local function ReloadDefaultSettings()
	for i, j in pairs(G.DefaultSettings) do
		if type(j) == "table" then
			if not Config.DB[i] then Config.DB[i] = {} end
			for k, v in pairs(j) do
				Config.DB[i][k] = v
			end
		else
			Config.DB[i] = j
		end
	end
	Config.DB["BFA"] = true -- don't empty data on next loading
end

function G:ImportGUIData()
	local profile = G.ProfileDataFrame.editBox:GetText()
	if Core:IsBase64(profile) then profile = Core:Decode(profile) end
	local options = {strsplit(";", profile)}
	local title, version, _, _ = strsplit(":", options[1])
	if title ~= "LauringUISettings" then
		UIErrorsFrame:AddMessage(DB.InfoColor..L["Import data error"])
		return
	end

	-- we don't export default settings, so need to reload it
	ReloadDefaultSettings()

	for i = 2, #options do
		local option = options[i]
		local key, value, arg1 = strsplit(":", option)
		if arg1 == "true" or arg1 == "false" then
			if key == "ACCOUNT" then
				LauringUIAccountDB[value] = toBoolean(arg1)
			else
				Config.DB[key][value] = toBoolean(arg1)
			end
		elseif arg1 == "EMPTYTABLE" then
			Config.DB[key][value] = {}
		elseif strfind(value, "Color") and (arg1 == "r" or arg1 == "g" or arg1 == "b") then
			local colors = {select(3, strsplit(":", option))}
			if Config.DB[key][value] then
				for j = 1, #colors, 2 do
					Config.DB[key][value][colors[j]] = tonumber(colors[j + 1])
				end
			end
		elseif booleanTable[value] then
			local results = {select(3, strsplit(":", option))}
			for j = 1, #results, 2 do
				Config.DB[key][value][tonumber(results[j]) or results[j]] = toBoolean(results[j + 1])
			end
		elseif value == "CustomItems" or value == "CustomNames" then
			local results = {select(3, strsplit(":", option))}
			for j = 1, #results, 2 do
				Config.DB[key][value][tonumber(results[j])] = tonumber(results[j+1]) or results[j+1]
			end
		elseif key == "Mover" then
			local relFrom, parent, relTo, x, y = select(3, strsplit(":", option))
			local valueNumber = tonumber(value) or value
			x = tonumber(x)
			y = tonumber(y)
			Config.DB[key][valueNumber] = {relFrom, parent, relTo, x, y}
		elseif value == "InfoStrLeft" or value == "InfoStrRight" or accountStrValues[value] then
			if key == "ACCOUNT" then
				LauringUIAccountDB[value] = arg1
			else
				Config.DB[key][value] = arg1
			end
		elseif key == "ACCOUNT" then
			if value == "ProfileIndex" then
				local results = {select(3, strsplit(":", option))}
				for j = 1, #results, 2 do
					LauringUIAccountDB[value][results[j]] = tonumber(results[j + 1])
				end
			elseif value == "ProfileNames" then
				local results = {select(3, strsplit(":", option))}
				for j = 1, #results, 2 do
					LauringUIAccountDB[value][tonumber(results[j])] = results[j + 1]
				end
			end
		elseif tonumber(arg1) then
			if value == "StatOrder" then
				Config.DB[key][value] = arg1
			elseif Config.DB[key] then
				Config.DB[key][value] = tonumber(arg1)
			end
		end
	end
	ReloadUI()
end

local function updateTooltip()
	local dataFrame = G.ProfileDataFrame
	local profile = dataFrame.editBox:GetText()
	if Core:IsBase64(profile) then profile = Core:Decode(profile) end
	local option = strsplit(";", profile)
	local title, version, name, class = strsplit(":", option)
	if title == "LauringUISettings" then
		dataFrame.version = version
		dataFrame.name = name
		dataFrame.class = class
	else
		dataFrame.version = nil
	end
end

function G:CreateDataFrame()
	if G.ProfileDataFrame then G.ProfileDataFrame:Show() return end

	local dataFrame = CreateFrame("Frame", nil, UIParent)
	dataFrame:SetPoint("CENTER")
	dataFrame:SetSize(500, 500)
	dataFrame:SetFrameStrata("DIALOG")
	Core.CreateMF(dataFrame)
	--Core.SetBD(dataFrame)
	Core:StyleFrame(dataFrame)
	dataFrame.Header = Core.CreateFS(dataFrame, 16, L["Export Header"], true, "TOP", 0, -5)

	local scrollArea = CreateFrame("ScrollFrame", nil, dataFrame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", 10, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", -28, 40)
	Core.CreateBDFrame(scrollArea, .25)
	Core.ReskinScroll(scrollArea.ScrollBar)

	local editBox = CreateFrame("EditBox", nil, dataFrame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(true)
	editBox:SetFont(DB.Font[1], 14, "")
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetHeight(scrollArea:GetHeight())
	editBox:SetScript("OnEscapePressed", function() dataFrame:Hide() end)
	scrollArea:SetScrollChild(editBox)
	dataFrame.editBox = editBox

	StaticPopupDialogs["LAURINGUI_IMPORT_DATA"] = {
		text = L["Import data warning"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			G:ImportGUIData()
		end,
		whileDead = 1,
	}
	local accept = Core.CreateButton(dataFrame, 100, 20, OKAY)
	accept:SetPoint("BOTTOM", 0, 10)
	accept:SetScript("OnClick", function(self)
		if self.text:GetText() ~= OKAY and dataFrame.editBox:GetText() ~= "" then
			StaticPopup_Show("LAURINGUI_IMPORT_DATA")
		end
		dataFrame:Hide()
	end)
	accept:HookScript("OnEnter", function(self)
		if dataFrame.editBox:GetText() == "" then return end
		updateTooltip()

		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)
		GameTooltip:ClearLines()
		if dataFrame.version then
			GameTooltip:AddLine(L["Data Info"])
			GameTooltip:AddDoubleLine(L["Version"], dataFrame.version, .6,.8,1, 1,1,1)
			GameTooltip:AddDoubleLine(L["Character"], dataFrame.name, .6,.8,1, Core.ClassColor(dataFrame.class))
		else
			GameTooltip:AddLine(L["Data Exception"], 1,0,0)
		end
		GameTooltip:Show()
	end)
	accept:HookScript("OnLeave", Core.HideTooltip)
	dataFrame.text = accept.text

	G.ProfileDataFrame = dataFrame
end