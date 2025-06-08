local _, ns = ...
local B, C, L, DB = unpack(ns)

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
DB.IconBorder = Media.."Textures\\iconborder"
DB.GearTexture = "Interface\\WorldMap\\Gear_64"
DB.ArrowUpTexture = Media.."Textures\\arrow"
DB.TankTexture = Media.."Textures\\Tank"
DB.HealTexture = Media.."Textures\\Healer"
DB.DpsTexture = Media.."Textures\\DPS"
DB.CloseTexture = Media.."Textures\\close"

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

DB.TexCoord = {.08, .92, .08, .92}

DB.AFKTex = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
DB.DNDTex = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"

ns.DB = DB