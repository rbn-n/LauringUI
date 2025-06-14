local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:RegisterModule("GUI")

G.HeaderTag = "|cff00cc4c"
G.TabList = {
    --L["Bags"] = {},
    [L["UnitFrames"]] = {},
    [L["GroupFrames"]] = {},
    [L["Castbars"]] = {},
    [L["Chat"]] = {},
    [L["Maps"]] = {},
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
		ArenaHeight = 12,
        ArenaWidth = 125,
		BossHeight = 12,
        BossWidth = 125,
        FocusHeight = 12,
        FocusWidth = 125,
        PlayerHeight = 30,
        PlayerWidth = 300,
        TargetHeight = 15,
        TargetWidth = 225,
        ShowBoss = false,
        ShowFocus = true,
        ShowPet = true,
        ShowPlayer = true,
        ShowTarget = true,
    },
	Minimap = {
		Enable = true,
		Scale = 1.4,
		Size = 140,
	},
	UFs = {
		Enable = true,

		ArenaWidth = 150,
		ArenaHeight = 22,
		ArenaNameOffset = 0,
		ArenaPowerHeight = 2,
		ArenaPowerOffset = 2,
		HideArenaPower = false,
		ShowArena = true,

        BossWidth = 150,
		BossHeight = 22,
		BossNameOffset = 0,
		BossPowerHeight = 2,
		BossPowerOffset = 2,
		HideBossPower = false,

        FocusHeight = 24,
        FocusWidth = 125,
        FocusNameOffset = 0,
        FocusPowerHeight = 2,
		HideFocusPower = true,
        FocusTargetHeight = 24,
        FocusTargetWidth = 75,
        FocusTargetNameOffset = 0,
        HideFocusTargetPower = true,

        PetHeight = 24,
        PetWidth = 125,
        PetNameOffset = 0,
        PetPowerHeight = 2,
		HidePetPower = true,

        PlayerHeight = 42,
        PlayerWidth = 272,
        PlayerPowerHeight = 10,
        PlayerPowerOffset = 3,
        PlayerNameOffset= 0,
		HidePlayerPower = true,
        HidePlayerName = false,

		-- TargetHeight is used together with PlayerHeight
		HideTargetPower = false,

		ToTHeight = 24,
        ToTWidth = 125,
        ToTNameOffset = 0,
		HideToTPower = true,

		PartyWidth = 200,
		PartyHeight = 75,
		PartyPowerHeight = 2,
		PartyDirection = 3,
		PartySortByRole = true,
		PartySortAscending = false,
		PartySpacing = 5,
		HidePartyTooltip = false,
		HidePartyPower = false,
		ShowParty = true,

		PartyPetDirection = 1,
        PartyPetHeight = 15,
        PartyPetWidth = 50,
        PartyPetVisability = 1,
		PartyPetPerColumn = 5,
		PartyPetMaxColumn = 1,
		PartyPetPowerHeight = 1,
		HidePartyPetPower = true,
		ShowPartyPets = false,

        Raid10Width = 80,
		Raid10Height = 32,
		Raid10PowerHeight = 2,
        RaidWidth = 80,
		RaidHeight = 32,
		RaidPowerHeight = 2,
		RaidDirection = 5,
		RaidRows = 1,
		RaidSpacing = 5,
		HideRaid10Power = true,
		HideRaidPower = true,

		BuffIndicatorScale = 1,
		BuffIndicatorType = 1,

		NumRaidGroups = 8,
		SmartRaid = false,
		HideRaidTooltip = false,
        HideRaid10Tooltip = false,
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
		ShowRoleMode = 1,

        PlayerFontSize = 15,
        TargetFontSize = 15,
        ToTFontSize = 15,
        PartyFontSize = 15,
        PartyPetFontSize = 12,
        Raid10FontSize = 15,
        RaidFontSize = 15,
        PetFontSize = 15,
        ArenaFontSize = 15,
        BossFontSize = 15,
        FocusFontSize = 15,
        FocusTargetFontSize = 15,

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
        ShowInstanceAuras = true,
        DispellType = 1,
        PlayerNumBuff = 20,
		PlayerNumDebuff = 20,
		PlayerBuffType = 1,
		PlayerDebuffType = 1,
		PlayerAurasPerRow = 9,
		TargetNumBuff = 20,
		TargetNumDebuff = 20,
		TargetBuffType = 2,
		TargetDebuffType = 2,
		TargetAurasPerRow = 9,
		FocusNumBuff = 20,
		FocusNumDebuff = 20,
		FocusBuffType = 3,
		FocusDebuffType = 2,
		FocusAurasPerRow = 8,
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
		PlayerAuraDirection = 3,
		PlayerAuraOffset = 10,
		TargetAuraDirection = 1,
		TargetAuraOffset = 10,
		ToTAuraDirection = 1,
		ToTAuraOffset = 10,
		PetAuraDirection = 1,
		PetAuraOffset = 10,
		FocusAuraDirection = 1,
		FocusAuraOffset = 10,
		DebuffsDesaturate = true,
		DebuffColor = false,

		UFTextScale = 1,
    }
}

G.AccountSettings = {
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