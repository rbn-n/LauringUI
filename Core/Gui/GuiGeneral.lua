local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local oUF = ns.oUF
local G = Core:GetModule("GUI")

local function SetupUnitFrames()
    for _, frame in next, oUF.objects do
		if frame.Health and frame.Health.PostUpdate then
			frame.Health:ForceUpdate()
		end
	end
end

local options = {
    {1, "General", "ClassColoredUFs", L["ClassColoredUFs"], nil, SetupUnitFrames, nil, L["ClassColoredUFsTip"]},
}

G.TabList["General"] = options