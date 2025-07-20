local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
if not LSM then return end

-- Locale flags
local koKR, ruRU, zhCN, zhTW, western = LSM.LOCALE_BIT_koKR, LSM.LOCALE_BIT_ruRU, LSM.LOCALE_BIT_zhCN, LSM.LOCALE_BIT_zhTW, LSM.LOCALE_BIT_western

-- Media types
local MediaType_FONT = LSM.MediaType.FONT
local MediaType_STATUSBAR = LSM.MediaType.STATUSBAR
local MediaType_SOUND = LSM.MediaType.SOUND

-- Fonts
local fonts = {
    { name = "Damias",             path = [[Interface\Addons\LauringUI\Media\Fonts\Damias.ttf]],            locales = ruRU + western },
    { name = "Expressway",         path = [[Interface\Addons\LauringUI\Media\Fonts\Expressway.ttf]],        locales = ruRU + western },
    { name = "Naowh",              path = [[Interface\Addons\LauringUI\Media\Fonts\Naowh.ttf]],             locales = ruRU + western },
    { name = "GothamNarrowUltra",  path = [[Interface\Addons\LauringUI\Media\Fonts\GothamNarrowUltra.ttf]], locales = ruRU + western },
}

for _, font in ipairs(fonts) do
    LSM:Register(MediaType_FONT, font.name, font.path, font.locales)
end

LSM:Register(MediaType_SOUND, "MSBT - Cooldown", [[Interface\Addons\LauringUI\Media\Sounds\MSBT - Cooldown.ogg]])

local sounds = {
    "Lauring - 1", "Lauring - 2", "Lauring - 3", "Lauring - 4", "Lauring - 5",
    "Lauring - 6", "Lauring - 7", "Lauring - 8", "Lauring - 9", "Lauring - Add",
    "Lauring - Adds", "Lauring - AMS", "Lauring - AOE", "Lauring - Avoid", "Lauring - Beam",
    "Lauring - Big Add", "Lauring - Black", "Lauring - Bloodlust", "Lauring - Blue", "Lauring - Bomb",
    "Lauring - Break", "Lauring - Breath", "Lauring - Buff", "Lauring - CC", "Lauring - CCd",
    "Lauring - Charge", "Lauring - Clear", "Lauring - Dance inc", "Lauring - Dance", "Lauring - Dark",
    "Lauring - Debuff", "Lauring - Defensive", "Lauring - Dispell", "Lauring - Dodge inc", "Lauring - Dodge",
    "Lauring - Dont Move", "Lauring - Dot", "Lauring - Down", "Lauring - Enrage Inc", "Lauring - Enrage",
    "Lauring - Execute", "Lauring - Fear", "Lauring - Feared", "Lauring - Fixate", "Lauring - Frontal",
    "Lauring - Gloves", "Lauring - Green", "Lauring - Healthstone", "Lauring - Hide", "Lauring - High Stacks",
    "Lauring - Immune", "Lauring - In", "Lauring - Inside", "Lauring - Intermission", "Lauring - Interrupt",
    "Lauring - Jump", "Lauring - Kick", "Lauring - Kite", "Lauring - Left", "Lauring - Light",
    "Lauring - LoS", "Lauring - MC", "Lauring - Middle", "Lauring - Move", "Lauring - Next",
    "Lauring - Nitro", "Lauring - Nuke", "Lauring - On you", "Lauring - Orange", "Lauring - Orb",
    "Lauring - Orbs", "Lauring - Out", "Lauring - Outrange", "Lauring - Outside", "Lauring - Personal",
    "Lauring - Phase change", "Lauring - Pot", "Lauring - Purple", "Lauring - Push", "Lauring - Racial",
    "Lauring - Ready", "Lauring - Red", "Lauring - Right", "Lauring - Rooted", "Lauring - Shield",
    "Lauring - Silenced", "Lauring - Smash inc", "Lauring - Smash", "Lauring - Soak", "Lauring - Spread",
    "Lauring - Stack", "Lauring - Stay", "Lauring - Stop", "Lauring - Stopcast", "Lauring - Stunned",
    "Lauring - Switch", "Lauring - Taunt", "Lauring - Throw", "Lauring - Trap", "Lauring - Trinket",
    "Lauring - Turn", "Lauring - Up", "Lauring - Watch Feet", "Lauring - White", "Lauring - Yellow"
}

for _, sound in ipairs(sounds) do
    local label = "|cff8033b3" .. sound .. "|r"
    local file = [[Interface\Addons\LauringUI\Media\Sounds\]] .. sound .. ".ogg"
    LSM:Register(MediaType_SOUND, label, file)
end

local statusbars = {
    "Dimglass",
    "Melli",
    "NaowhTarget",
    "NaowhDetails"
}

for _, bar in ipairs(statusbars) do
    local label = "|cff8033b3" .. bar .. "|r"
    local file = [[Interface\Addons\LauringUI\Media\Textures\]] .. bar .. ".tga"
    LSM:Register(MediaType_STATUSBAR, label, file)
end