local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local module = Core:GetModule("Infobars")

local floor = math.floor
local GetFramerate = GetFramerate

local function ColorFPS(fps)
    if fps < 15 then
        return "|cffD80909" .. fps .. "|r"
    elseif fps < 30 then
        return "|cffE8DA0F" .. fps .. "|r"
    else
        return "|cff0CD809" .. fps .. "|r"
    end
end

local function UpdateFPS(self)
    local fps = floor(GetFramerate())
    self.Text:SetText(L["FPS"] .. ": " .. ColorFPS(fps))
end

local function OnEvent(self)
    UpdateFPS(self)
end

local function OnUpdate(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer > 1 then
        UpdateFPS(self)
        self.timer = 0
    end
end

module:RegisterDataText("Fps", {
    panel = module.CentralBottomPanel,
    anchor = "LEFT",
    events = { "PLAYER_ENTERING_WORLD" },
    onEvent = OnEvent,
    onUpdate = OnUpdate,
})