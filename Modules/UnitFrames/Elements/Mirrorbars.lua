local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local UF = Core:GetModule("UnitFrames")

local function ReskinTimerBar(bar)
	bar:SetSize(280, 15)
	Core.RemoveBlizzTextures(bar, true)

	local statusbar = _G[bar:GetName().."StatusBar"]
	if statusbar then
		statusbar:SetAllPoints()
		statusbar:SetStatusBarTexture(DB.StatusBarTexture)
	else
		bar:SetStatusBarTexture(DB.StatusBarTexture)
	end

	Core:CreateBorder(bar, 1)
	Core:CreateShadow(bar, 5)
end

function UF:ReskinMirrorBars()
	local previous
	for i = 1, 3 do
		local bar = _G["MirrorTimer"..i]
		ReskinTimerBar(bar)

		if previous then
			bar:SetPoint("TOP", previous, "BOTTOM", 0, -5)
		end
		previous = bar
	end
end