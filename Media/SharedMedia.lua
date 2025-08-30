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
    "1", "2", "3", "4", "5",
    "6", "7", "8", "9", "Add",
    "Adds", "AMS", "AOE", "Avoid", "Banner",
    "Beam", "Big Add", "Black", "Bloodlust", "Blue",
    "Bomb", "Break", "Breath", "Buff", "CC",
    "CCd", "Charge", "Clear", "Click", "Dance", "Dance soon",
    "Dark", "Debuff", "Defensive", "Disarmed", "Disoriented", "Dispell",
    "Dodge", "Dodge soon", "Dont Move", "Dot", "Down",
    "Enrage", "Enrage Inc", "Execute", "Fear", "Feared",
    "Fixate", "Frontal", "Gloves", "Green", "Healthstone",
    "Hide", "High Stacks", "Immune", "In", "Inside",
    "Intermission", "Interrupt", "Jump", "Kick", "Kite", "Knockback",
    "Left", "Light", "Link", "LoS", "MC", "Middle",
    "Move", "Next", "Nitro", "Nuke", "On you",
    "Orange", "Orb", "Orbs", "Out", "Outrange",
    "Outside", "Personal", "Phase change", "Pot", "Proc",
    "Purple", "Push", "Racial", "Ready", "Red",
    "Right", "Rooted", "Shield", "Shield soon", "Silenced", "Smash",
    "Smash soon", "Soak", "Spread", "Stack", "Stay",
    "Stomp", "Stop", "Stopcast", "Stunned", "Switch", "Taunt",
    "Throw", "Totem", "Trap", "Trinket", "Turn",
    "Up", "Watch your feet", "Weapon", "White", "Yellow"
}

for _, sound in ipairs(sounds) do
    local name = "Lauring - " .. sound
    local label = "|cff8033b3" .. name .. "|r"
    local file = [[Interface\Addons\LauringUI\Media\Sounds\]] .. name .. ".mp3"
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