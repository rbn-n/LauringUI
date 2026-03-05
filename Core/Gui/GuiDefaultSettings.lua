local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:RegisterModule("GUI")

G.HeaderTag = "|cff00cc4c"
G.TabList = {
	[L["General"]] = {},
    [L["UnitFrames"]] = {},
    [L["GroupFrames"]] = {},
    [L["Castbars"]] = {},
    [L["Bags"]] = {},
    [L["Chat"]] = {},
    [L["Loot"]] = {},
    [L["Maps"]] = {},
    [L["Nameplates"]] = {},
    [L["Quests"]] = {},
    [L["Tooltips"]] = {},
    [L["Quality of Life"]] = {},
    [L["Profile"]] = {},
}

G.DefaultSettings = {
	BFA = false,
	Mover = {},
	TempAnchor = {},
	Bags = {
		Enable = true,
		IconSize = 34,
		FontSize = 12,
		BagsWidth = 12,
		BankWidth = 14,
		BagsiLvl = true,
		BagSortMode = 1,
		ItemFilter = true,
		CustomItems = {},
		CustomNames = {},
		GatherEmpty = false,
		ShowNewItem = true,
		SplitCount = 1,
		SpecialBagsColor = false,
		iLvlToShow = 1,
		BagsPerRow = 6,
		BankPerRow = 10,
		HideWidgets = true,

		FilterJunk = true,
		FilterAmmo = true,
		FilterConsumable = true,
		FilterEquipment = true,
		FilterLegendary = true,
		FilterCollection = true,
		FilterFavourite = true,
		FilterGoods = false,
		FilterQuest = false,
		FilterEquipSet = false,
		FilterBOE = false,
	},
    Castbars = {
        Enable = true,
        CastingColor = {r=.3, g=.7, b=1},
        NotInterruptColor = {r=1, g=.5, b=.5},
        FocusHeight = 20,
        FocusWidth = 150,
        PlayerHeight = 24,
        PlayerWidth = 400,
        TargetHeight = 20,
        TargetWidth = 250,
        ShowArena = true,
        ShowBoss = false,
        ShowFocus = true,
        ShowPet = true,
        ShowPlayer = true,
        ShowTarget = true,
    },
	Chat = {
		EditBoxFontSize = 15,
		Enable = true,
		Width = 575,
		Height = 250,
		ShowMenu = false,
		UseChatPanels = true,
		UsePredefinedChatConfig = false,
		WhisperColor = true,
		WhisperInvite = true,
		WhisperInviteGuildOnly = true,
		WhisperInviteKeywords = "inv invite",
	},
	General = {
		ClassColoredUFs = true,
	},
	Loot = {
		Enable = true,
		Announce = true,
		AnnounceTitle = true,
		AnnounceRarity = 1,
		Width = 328,
		Height = 28,
		Style = 2,
		Direction = 2,
		ItemLevel = true,
		ItemQuality = true,
	},
	Infobar = {
		FontSize = 17,
		InfoStringLeft = "[guild][friend][ping][fps][zone]",
		InfoStringRight = "[spec][dura][gold][time]",
		MaxAddOns = 12,
	},
	Minimap = {
		Enable = true,
		EnableEasyVolume = true,
		ShowCalendar = true,
		ShowCombatPulse = true,
		ShowRecycleBin = true,
		ShowWhoPings = true,
		Scale = 1.8,
		Size = 140,
	},
	Nameplates = {
		Enable = true,
		AuraFilter = 3,
		AuraSize = 28,
		BlockDBM = true,
		CBTextSize = 14,
		CastTarget = false,
		CastbarGlow = true,
		ClampTarget = true,
		ColorByDot = false,
		ColoredFocus = false,
		ColoredTarget = false,
		CustomColor = {r=0, g=.8, b=.3},
		CustomUnits = {},
		DPSRevertThreat = true,
		DebuffColor = false,
		Desaturate = true,
		DispellMode = 2,
		DotColor = {r=1, g=.5, b=.2},
		DotSpells = {},
		Fadeout = true,
		FadeoutAlpha = 0,
		FocusColor = {r=1, g=.8, b=0},
		FontSize = 14,
		FriendCBTextSize = 14,
		FriendHealthOffset = 5,
		FriendHealthSize = 10,
		FriendNameSize = 10,
		FriendPlate = false,
		FriendPlateCBHeight = 8,
		FriendPlateCBOffset = -1,
		FriendPlateHeight = 8,
		FriendPlateWidth = 190,
		FriendlyCC = false,
		HealthTextOffset = 5,
		HealthTextSize = 16,
		HealthType = 5,
		HostileCC = true,
		InsecureColor = {r=1, g=.25, b=.25},
		Interruptor = true,
		MaxAuras = 5,
		MinAlpha = 1,
		MinScale = 1,
		NameOnlyGuild = false,
		NameOnlyMode = true,
		NameOnlyTextSize = 14,
		NameOnlyTitle = true,
		NameOnlyTitleSize = 12,
		NameTextSize = 14,
		NameType = 5,
		OffTankColor = {r=.2, g=.7, b=.5},
		OffTankThreat = true,
		PlateAuras = true,
		PlateCBHeight = 8,
		PlateCBOffset = -1,
		PlateHeight = 8,
		PlateRange = 41,
		PlateWidth = 190,
		QuestIndicator = true,
		SecureColor = {r=.5, g=.5, b=.1},
		ShowCustomUnits = true,
		SizeRatio = .5,
		TargetColor = {r=0, g=.6, b=1},
		TargetName = false,
		TankMode = true,
		TankRole = false,
		TransColor = {r=1, g=.93, b=.43},
		UnitTargeted = false,
		VerticalSpacing = 1.4,
	},
	QoL = {
		AutoDismount = true,
		DeleteHelper = true,
		ErrorFilter = true,
		LootFaster = true,
		EnableMail = true,
		MailSaver = false,
		MailTarget = "",
		RaidWorldMarksType = 4,
		RaidWorldMarksSize = 25,
		ShowItemLevel = true,
		ShowItemQuality = true,
		TaxiDismount = true,
		ZoomLevel = 3.4,
	},
	Quests = {
		Tracker = true,
	},
	Tooltips = {
		Anchor = 4,
		HideJunkGuild = true,
		HideInCombat = 1,
		HideRealm = true,
		ItemQuality = true,
		Scale = 1,
		SpecLevelByShift = true,
		TargetedBy = true,
	},
	UFs = {
		Enable = true,
		ShowAdditionalPower = true,

		ShowClassPower = false,
		ShowRuneTimer = false,
		ClassPowerWidth = 150,
		ClassPowerHeight = 5,
		ClassPowerxOffset = 12,
		ClassPoweryOffset = -2,

		ArenaWidth = 175,
		ArenaHeight = 30,
		ArenaNameOffset = 0,
		ArenaPowerHeight = 6,
		ArenaPowerOffset = 2,
		HideArenaPower = false,
		ShowArena = true,

        BossWidth = 225,
		BossHeight = 40,
		BossNameOffset = 2,
		BossPowerHeight = 6,
		BossPowerOffset = 2,
		HideBossPower = false,

        FocusHeight = 25,
        FocusWidth = 150,
        FocusNameOffset = 0,
        FocusPowerHeight = 2,
		HideFocusPower = true,
        FocusTargetHeight = 25,
        FocusTargetWidth = 100,
        FocusTargetNameOffset = 0,
        HideFocusTargetPower = true,

        PetHeight = 25,
        PetWidth = 150,
        PetNameOffset = 0,
        PetPowerHeight = 2,
        HidePetName = true,
		HidePetPower = true,

        PlayerHeight = 42,
        PlayerWidth = 272,
        PlayerPowerHeight = 10,
        PlayerPowerOffset = 3,
        PlayerNameOffset= 3,
		HidePlayerPower = true,
        HidePlayerName = false,

		-- Target settings are the same Player settings
		HideTargetPower = false,

		ToTHeight = 25,
        ToTWidth = 125,
        ToTNameOffset = 0,
		HideToTPower = true,

		EnablePartyFrame = true,
		PartyWidth = 150,
		PartyHeight = 75,
		PartyPowerHeight = 2,
		PartyPowerOffset = 1,
		PartyDirection = 3,
		PartySortByRole = true,
		PartySortAscending = false,
		PartySpacing = 5,
		HidePartyTooltip = false,
		HidePartyPower = false,
		ShowParty = true,

		EnablePartyPetFrame = true,
		PartyPetDirection = 1,
        PartyPetHeight = 15,
        PartyPetWidth = 50,
        PartyPetVisability = 1,
		PartyPetPerColumn = 5,
		PartyPetMaxColumn = 1,
		PartyPetPowerHeight = 1,
		HidePartyPetPower = true,

		EnableRaidFrame = true,
		Raid10PowerHeight = 2,
		RaidWidth = 150,
		RaidHeight = 50,
        Raid10Width = 80,
		Raid10Height = 32,
		Raid40Width = 80,
		Raid40Height = 32,
		RaidPowerHeight = 2,
		RaidPowerOffset = 1,
		RaidDirection = 5,
		RaidRows = 1,
		Raid10Rows = 1,
		Raid40Rows = 2,
		RaidSpacing = 3,
		RaidGroups = 5,
		RaidHPMode = 1,
		RaidSortByRole = true,
		RaidSortAscending = false,
		HideRaidPower = true,

		ShowCornerBuffs = true,
		ShowCustomInstanceAuras = true,
		CustomInstanceAuraClickThrough = false,
		CustomInstanceAuraSize = 20,
		CustomInstanceAuraDispellType = 1,
		BuffClickThrough = false,
		BlizzardDebuffClickThrough = false,
		CornerBuffsSize = 20,
		ShowBlizzardDebuff = true,
		BlizzardDebuffSize = 20,

		SmartRaid = true,
		HideRaidTooltip = false,
		TeamIndex = false,
		ShowGroupSolo = false,
		FrequentHealth = false,
		HealthFrequency = .2,
		Desaturate = true,
		RaidTextScale = 1,
		HideTip = false,
		SortByRole = true,
		SortAscending = false,
		AutoBuffs = false,
		ShowRoleMode = 3,

        PlayerFontSize = 15,
        TargetFontSize = 15,
        ToTFontSize = 13,
        PartyFontSize = 15,
        PartyPetFontSize = 12,
        Raid10FontSize = 13,
        RaidFontSize = 13,
        PetFontSize = 13,
        ArenaFontSize = 13,
        BossFontSize = 13,
        FocusFontSize = 13,
        FocusTargetFontSize = 13,

        --[[
            1
            2 currentpercent
            3 currentmax
            4 current
            5 percent
            6 loss
            7 losspercent
        ]]
        PlayerHPTag = 4,
        TargetHPTag = 4,
        ToTHPTag = 5,
        PetHPTag = 5,
        BossHPTag = 5,
        FocusHPTag = 5,
        FocusTargetHPTag = 1,
        ArenaHPTag = 2,
        PartyPetHPTag = 1,

        PlayerMPTag = 4,
        TargetMPTag = 4,
        ToTMPTag = 5,
        PetMPTag = 5,
        BossMPTag = 5,
        FocusMPTag = 5,
        ArenaMPTag = 4,

        ShowAuras = true,
		EnableDebuffHighlight = true,
        PlayerNumBuff = 20,
		PlayerNumDebuff = 20,
		PlayerBuffType = 1,
		PlayerDebuffType = 2,
		PlayerAurasPerRow = 8,
		TargetNumBuff = 20,
		TargetNumDebuff = 20,
		TargetBuffType = 2,
		TargetDebuffType = 2,
		TargetAurasPerRow = 8,
		FocusNumBuff = 20,
		FocusNumDebuff = 20,
		FocusBuffType = 3,
		FocusDebuffType = 2,
		FocusAurasPerRow = 6,
		ToTNumBuff = 6,
		ToTNumDebuff = 6,
		ToTBuffType = 1,
		ToTDebuffType = 1,
		ToTAurasPerRow = 5,
		PetNumBuff = 6,
		PetNumDebuff = 6,
		PetBuffType = 1,
		PetDebuffType = 1,
		PetAurasPerRow = 5,
		BossNumBuff = 6,
		BossNumDebuff = 6,
		BossBuffType = 2,
		BossDebuffType = 3,
		BossBuffPerRow = 6,
		BossDebuffPerRow = 6,
		PlayerAuraDirection = 4,
		PlayerAuraOffset = 17,
		TargetAuraDirection = 1,
		TargetAuraOffset = 3,
		ToTAuraDirection = 1,
		ToTAuraOffset = 10,
		PetAuraDirection = 1,
		PetAuraOffset = 10,
		FocusAuraDirection = 1,
		FocusAuraOffset = 3,
		DebuffsDesaturate = true,
		DebuffColor = false,

		UFTextScale = 1,
    }
}

G.AccountSettings = {
	TimestampFormat = 4,
	RaidDebuffs = {},
	TotalGold = {},
	RepairType = 1,
	AutoSell = false,
	GuildSortBy = 1,
	GuildSortOrder = true,
	LockUIScale = false,
	UIScale = .53,
	NumberFormat = 1,
	VersionCheck = true,
	DisableInfobars = false,
	ProfileIndex = {},
	ProfileNames = {},
	SmoothAmount = .25,
	AutoRecycle = false,
	CustomJunkList = {},
	IgnoredButtons = "",
	ShowSlots = false,
	MajorSpells = {},
	NameplateWhite = {},
	NameplateBlack = {},
	CornerSpells = {},
	RaidDebuffsBlack = {},
}


local ignoredTable = {
	["Mover"] = true,
	["TempAnchor"] = true,
}

local function InitialSettings(source, target, fullClean)
	for i, j in pairs(source) do
		if type(j) == "table" then
			if target[i] == nil then target[i] = {} end
			for k, v in pairs(j) do
				if target[i][k] == nil then
					target[i][k] = v
				end
			end
		else
			if target[i] == nil then target[i] = j end
		end
	end

	for i, j in pairs(target) do
		if source[i] == nil then target[i] = nil end
		if fullClean and type(j) == "table" and not ignoredTable[i] then
			for k, v in pairs(j) do
				if source[i] and source[i][k] == nil then
					target[i][k] = nil
				end
			end
		end
	end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, addon)
    if addon ~= "LauringUI" then return end

	if LauringUIAccountDB["NameplateFilter"] then
		if LauringUIAccountDB["NameplateFilter"][1] then
			if not LauringUIAccountDB["NameplateWhite"] then LauringUIAccountDB["NameplateWhite"] = {} end
			for spellID, value in pairs(LauringUIAccountDB["NameplateFilter"][1]) do
				LauringUIAccountDB["NameplateWhite"][spellID] = value
			end
		end
		if LauringUIAccountDB["NameplateFilter"][2] then
			if not LauringUIAccountDB["NameplateBlack"] then LauringUIAccountDB["NameplateBlack"] = {} end
			for spellID, value in pairs(LauringUIAccountDB["NameplateFilter"][2]) do
				LauringUIAccountDB["NameplateBlack"][spellID] = value
			end
		end
	end

    InitialSettings(G.AccountSettings, LauringUIAccountDB)
	if not next(LauringUICharacterDB) then
		for i = 1, 3 do LauringUICharacterDB[i] = {} end
	end

	if not LauringUIAccountDB["ProfileIndex"][DB.MyFullName] then
		LauringUIAccountDB["ProfileIndex"][DB.MyFullName] = 1
	end

	if LauringUIAccountDB["ProfileIndex"][DB.MyFullName] == 1 then
		Config.DB = LauringUIDB
		if not Config.DB["BFA"] then
			wipe(Config.DB)
			Config.DB["BFA"] = true
		end
	else
		Config.DB = LauringUICharacterDB[LauringUIAccountDB["ProfileIndex"][DB.MyFullName] - 1]
	end

    InitialSettings(G.DefaultSettings, Config.DB, true)

	Core:SetupUIScale(true)

	self:UnregisterAllEvents()
end)