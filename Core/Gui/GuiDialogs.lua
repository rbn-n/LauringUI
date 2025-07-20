local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

StaticPopupDialogs["RELOAD_LAURINGUI"] = {
	text = L["ReloadUI Required"],
	button1 = APPLY,
	button2 = CLASS_TRIAL_THANKS_DIALOG_CLOSE_BUTTON,
	OnAccept = function()
		ReloadUI()
	end,
}

StaticPopupDialogs["RESET_LAURINGUI"] = {
	text = L["Reset LauringUI Check"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		LauringUIDB = {}
		LauringUIAccountDB = {}
		LauringUICharacterDB = {}
		ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["RESET_LAURINGUI_HELPINFO"] = {
	text = L["Reset LauringUI Helpinfo"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		wipe(LauringUIAccountDB["Help"])
	end,
	whileDead = 1,
}

StaticPopupDialogs["LAURINGUI_RESET_PROFILE"] = {
	text = L["Reset current profile?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		wipe(Config.DB)
		ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["LAURINGUI_APPLY_PROFILE"] = {
	text = L["Apply selected profile?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		LauringUIAccountDB["ProfileIndex"][DB.MyFullName] = G.CurrentProfile
		ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["LAURINGUI_DOWNLOAD_PROFILE"] = {
	text = L["Download selected profile?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		local profileIndex = LauringUIAccountDB["ProfileIndex"][DB.MyFullName]
		if G.CurrentProfile == 1 then
			LauringUICharacterDB[profileIndex-1] = LauringUIDB
		elseif profileIndex == 1 then
			LauringUIDB = LauringUICharacterDB[G.CurrentProfile-1]
		else
			LauringUICharacterDB[profileIndex-1] = LauringUICharacterDB[G.CurrentProfile-1]
		end
		ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["LAURINGUI_UPLOAD_PROFILE"] = {
	text = L["Upload current profile?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		if G.CurrentProfile == 1 then
			LauringUIDB = Config.DB
		else
			LauringUICharacterDB[G.CurrentProfile-1] = Config.DB
		end
	end,
	whileDead = 1,
}

StaticPopupDialogs["LAURINGUI_DELETE_UNIT_PROFILE"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		local name, realm = strsplit("-", self.text.text_arg1)
		if LauringUIAccountDB["TotalGold"][realm] and LauringUIAccountDB["TotalGold"][realm][name] then
			LauringUIAccountDB["TotalGold"][realm][name] = nil
		end
		LauringUIAccountDB["ProfileIndex"][self.text.text_arg1] = nil
	end,
	OnShow = function(self)
		local r, g, b
		local class = self.text.text_arg2
		if class == "NONE" then
			r, g, b = .5, .5, .5
		else
			r, g, b = Core.ClassColor(class)
		end
		self.text:SetText(format(L["Delete unit profile?"], Core.HexRGB(r, g, b), self.text.text_arg1))
	end,
	whileDead = 1,
}

StaticPopupDialogs["RESET_LAURINGUI_DEBUFFS_BLACK"] = {
	text = L["Reset to default list"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		wipe(LauringUIAccountDB["RaidDebuffsBlack"])
		ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["RESET_LAURINGUI_RaidBuffsWhite"] = {
	text = L["Reset to default list"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		wipe(LauringUIAccountDB["CornerSpells"][DB.MyClass])
		ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["RESET_LAURINGUI_BUFFS_WHITE"] = {
	text = L["Reset to default list"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		wipe(LauringUIAccountDB["RaidBuffsWhite"])
		ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["RESET_LAURINGUI_RAIDDEBUFFS"] = {
	text = L["Reset to default list"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		LauringUIAccountDB["RaidDebuffs"] = {}
		ReloadUI()
	end,
	whileDead = 1,
}
