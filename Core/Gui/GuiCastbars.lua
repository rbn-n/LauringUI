local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

local function UpdatePlayerCastbar()
    local castbar = _G.oUF_Player and _G.oUF_Player.Castbar
    if castbar then
        local width, height = Config.DB["Castbars"]["PlayerWidth"], Config.DB["Castbars"]["PlayerHeight"]
        castbar:SetSize(width, height)
        castbar.Icon:SetSize(height, height)
        castbar.mover:Show()
        castbar.mover:SetSize(width + height, height)
    end
end

local function UpdateTargetCastbar()
    local castbar = _G.oUF_Target and _G.oUF_Target.Castbar
    if castbar then
        local width, height = Config.DB["Castbars"]["TargetWidth"], Config.DB["Castbars"]["TargetHeight"]
        castbar:SetSize(width, height)
        castbar.Icon:SetSize(height, height)
        castbar.mover:Show()
        castbar.mover:SetSize(width + height, height)
    end
end

local function UpdateFocusCastbar()
    local castbar = _G.oUF_Focus and _G.oUF_Focus.Castbar
    if castbar then
        local width, height = Config.DB["Castbars"]["FocusWidth"], Config.DB["Castbars"]["FocusHeight"]
        castbar:SetSize(width, height)
        castbar.Icon:SetSize(height, height)
        castbar.mover:Show()
        castbar.mover:SetSize(width + height + 5, height + 5)
    end
end

local function UpdatePetCastbar()
    local castbar = _G.oUF_Pet and _G.oUF_Pet.Castbar
    if castbar then
        local width, height = Config.DB["Castbars"]["PetWidth"], Config.DB["Castbars"]["PetHeight"]
        castbar:SetSize(width, height)
        castbar.Icon:SetSize(height, height)
        castbar.mover:Show()
        castbar.mover:SetSize(width + height + 5, height + 5)
    end
end

local options = {
    {1, "Castbars", "Enable", G.HeaderTag..L["UFs Castbar"]},
    {5, "Castbars", "CastingColor", L["PlayerCastingColor"]},
    {5, "Castbars", "NotInterruptColor", L["NotInterruptible Color"], 1},
    {},--blank
    {1, "Castbars", "ShowPlayer", L["Show Player Castbar"]},
    {3, "Castbars", "PlayerWidth", L["Width"].."*", nil, {100, 500, 1}, UpdatePlayerCastbar},
    {3, "Castbars", "PlayerHeight", L["Height"].."*", true, {10, 50, 1}, UpdatePlayerCastbar},
    {},--blank
    {1, "Castbars", "ShowTarget", L["Show Target Castbar"]},
    {3, "Castbars", "TargetWidth", L["Width"].."*", nil, {100, 500, 1}, UpdateTargetCastbar},
    {3, "Castbars", "TargetHeight", L["Height"].."*", true, {10, 50, 1}, UpdateTargetCastbar},
    {},--blank
    {1, "Castbars", "ShowFocus", L["Show Focus Castbar"]},
    {3, "Castbars", "FocusWidth", L["Width"].."*", nil, {100, 500, 1}, UpdateFocusCastbar},
    {3, "Castbars", "FocusHeight", L["Height"].."*", true, {10, 50, 1}, UpdateFocusCastbar},
    {},--blank
    {1, "Castbars", "ShowPet", L["Show Pet Castbar"]},
    {3, "Castbars", "PetWidth", L["Width"].."*", nil, {100, 500, 1}, UpdatePetCastbar},
    {3, "Castbars", "PetHeight", L["Height"].."*", true, {10, 50, 1}, UpdatePetCastbar},
    {},--blank
    {1, "Castbars", "ShowBoss", L["Show Boss Castbar"]},
    {1, "Castbars", "ShowArena", L["Show Arena Castbar"]},
}

G.TabList["Castbars"] = options