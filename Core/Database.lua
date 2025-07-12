local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local GetSpecialization = GetSpecialization or C_SpecializationInfo.GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo or C_SpecializationInfo.GetSpecializationInfo

local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_COMMON = LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_COMMON

DB.ScreenWidth, DB.ScreenHeight = GetPhysicalScreenSize()

local Media = "Interface\\AddOns\\LauringUI\\Media\\"
DB.Font = {STANDARD_TEXT_FONT, 15, "OUTLINE"}
DB.StatusBarTexture = Media.."Textures\\Dimglass"
DB.StatusBarTexture2 = Media.."Textures\\Melli"
DB.GlowTexture = Media.."Textures\\glowTex2"
DB.BackgroundTexture = "Interface\\ChatFrame\\ChatFrameBackground"
DB.RecycleBinTexture = "Interface\\HelpFrame\\ReportLagIcon-Loot"
DB.EyeTexture = "Interface\\Minimap\\Raid_Icon"
DB.SparkTexture = "Interface\\CastingBar\\UI-CastingBar-Spark"
DB.DebuffIconBorder = Media.."Textures\\iconborder"
DB.GearTexture = "Interface\\WorldMap\\Gear_64"
DB.ArrowUpTexture = Media.."Textures\\arrow"
DB.ArrowTexture = Media.."Textures\\TargetArrow"
DB.StarTexture = Media.."Textures\\star"
DB.TankTexture = Media.."Textures\\Tank"
DB.HealTexture = Media.."Textures\\Healer"
DB.DpsTexture = Media.."Textures\\DPS"
DB.CloseTexture = Media.."Textures\\close"
DB.SortTexture = Media.."Textures\\SortIcon"
DB.CopyTexture = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up"
DB.MailTexture = "Interface\\Minimap\\Tracking\\Mailbox"
DB.QuestTexture = "adventureguide-microbutton-alert"
DB.ObjectTexture = "Warfronts-BaseMapIcons-Horde-Barracks-Minimap"

DB.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
DB.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t "
DB.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "

DB.MyName = UnitName("player")
DB.MyRealm = GetRealmName()
DB.MyFullName = DB.MyName.."-"..DB.MyRealm
DB.MyName = UnitName("player")
DB.MyRealm = GetRealmName()
DB.MyClass = select(2, UnitClass("player"))
DB.ClassList = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	DB.ClassList[v] = k
end

DB.ClassColors = {}
local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
for class, value in pairs(colors) do
	DB.ClassColors[class] = {}
	DB.ClassColors[class].r = value.r
	DB.ClassColors[class].g = value.g
	DB.ClassColors[class].b = value.b
	DB.ClassColors[class].colorStr = value.colorStr
end
DB.r, DB.g, DB.b = DB.ClassColors[DB.MyClass].r, DB.ClassColors[DB.MyClass].g, DB.ClassColors[DB.MyClass].b
local function Round(x)
	return math.floor(x + 0.5)
end
DB.MyColor = string.format("|cff%02x%02x%02x", Round(DB.r * 255), Round(DB.g * 255), Round(DB.b * 255))
DB.InfoColor = "|cff99ccff" --.6,.8,1
DB.GreyColor = "|cff7b8489"
DB.QualityColors = {}
local qualityColors = BAG_ITEM_QUALITY_COLORS
for index, value in pairs(qualityColors) do
	DB.QualityColors[index] = {r = value.r, g = value.g, b = value.b}
end
DB.QualityColors[-1] = {r = 0, g = 0, b = 0}
DB.QualityColors[LE_ITEM_QUALITY_POOR] = {r = .61, g = .61, b = .61}
DB.QualityColors[LE_ITEM_QUALITY_COMMON] = {r = 0, g = 0, b = 0}

DB.DebuffHighlightColors = {
	MAGIC = {r = 0.2, g = 0.6, b = 1, a = 0.45},
	CURSE = {r = 0.6, g = 0, b = 1, a = 0.45},
	DISEASE = {r = 0.6, g = 0.4, b = 0, a = 0.45},
	POISON = {r = 0, g = 0.6, b = 0, a = 0.45}
}

DB.TexCoord = {.08, .92, .08, .92}

DB.AFKTex = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
DB.DNDTex = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"

ns.DB = DB

-- Deprecated
LE_ITEM_CLASS_CONSUMABLE = LE_ITEM_CLASS_CONSUMABLE or Enum.ItemClass.Consumable
LE_ITEM_CLASS_CONTAINER = LE_ITEM_CLASS_CONTAINER or Enum.ItemClass.Container
LE_ITEM_CLASS_WEAPON = LE_ITEM_CLASS_WEAPON or Enum.ItemClass.Weapon
LE_ITEM_CLASS_GEM = LE_ITEM_CLASS_GEM or Enum.ItemClass.Gem
LE_ITEM_CLASS_ARMOR = LE_ITEM_CLASS_ARMOR or Enum.ItemClass.Armor
LE_ITEM_CLASS_REAGENT = LE_ITEM_CLASS_REAGENT or Enum.ItemClass.Reagent
LE_ITEM_CLASS_PROJECTILE = LE_ITEM_CLASS_PROJECTILE or Enum.ItemClass.Projectile
LE_ITEM_CLASS_TRADEGOODS = LE_ITEM_CLASS_TRADEGOODS or Enum.ItemClass.Tradegoods
LE_ITEM_CLASS_ITEM_ENHANCEMENT = LE_ITEM_CLASS_ITEM_ENHANCEMENT or Enum.ItemClass.ItemEnhancement
LE_ITEM_CLASS_RECIPE = LE_ITEM_CLASS_RECIPE or Enum.ItemClass.Recipe
LE_ITEM_CLASS_QUIVER = LE_ITEM_CLASS_QUIVER or Enum.ItemClass.Quiver
LE_ITEM_CLASS_QUESTITEM = LE_ITEM_CLASS_QUESTITEM or Enum.ItemClass.Questitem
LE_ITEM_CLASS_KEY = LE_ITEM_CLASS_KEY or Enum.ItemClass.Key
LE_ITEM_CLASS_MISCELLANEOUS = LE_ITEM_CLASS_MISCELLANEOUS or Enum.ItemClass.Miscellaneous
LE_ITEM_CLASS_GLYPH = LE_ITEM_CLASS_GLYPH or Enum.ItemClass.Glyph
LE_ITEM_CLASS_BATTLEPET = LE_ITEM_CLASS_BATTLEPET or Enum.ItemClass.Battlepet
LE_ITEM_CLASS_WOW_TOKEN = LE_ITEM_CLASS_WOW_TOKEN or Enum.ItemClass.WoWToken

local function CheckRole()
	local specIndex = GetSpecialization()
	if not specIndex then
		DB.Role = nil
		return
	end

	local _, _, _, _, role = GetSpecializationInfo(specIndex)
	DB.Role = role
end

Core:RegisterEvent("PLAYER_LOGIN", CheckRole)
Core:RegisterEvent("PLAYER_TALENT_UPDATE", CheckRole)
