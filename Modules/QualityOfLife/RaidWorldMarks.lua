local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local QoL = Core:GetModule("QoL")

local iconTexture = {
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_6",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_1",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_2",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_5",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
	"Interface\\Buttons\\UI-GroupLoot-Pass-Up",
}

local maxButtons = #iconTexture

local markerTypeToRow = {
	[1] = 3,
	[2] = 9,
	[3] = 1,
	[4] = 3,
}
function QoL:RaidWorldMarks_UpdateGrid()
	local frame = _G["LauringUI_RaidWorldMarkers"]
	if not frame then return end

	local size, margin = Config.DB["QoL"]["RaidWorldMarksSize"], 5
	local showType = Config.DB["QoL"]["RaidWorldMarksType"]
	local perRow = markerTypeToRow[showType]

	for i = 1, maxButtons do
		local button = frame.buttons[i]
		button:SetSize(size, size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPLEFT", frame, margin, -margin)
		elseif mod(i-1, perRow) ==  0 then
			button:SetPoint("TOP", frame.buttons[i-perRow], "BOTTOM", 0, -margin)
		else
			button:SetPoint("LEFT", frame.buttons[i-1], "RIGHT", margin, 0)
		end
	end

	local column = min(maxButtons, perRow)
	local rows = ceil(maxButtons/perRow)
	frame:SetWidth(column*size + (column-1)*margin + 2*margin)
	frame:SetHeight(size*rows + (rows-1)*margin + 2*margin)
	frame:SetShown(showType ~= 4)
end


function QoL.RaidWorldMarks()
    local frame = CreateFrame("Frame", "LauringUI_RaidWorldMarkers", UIParent)
	frame:SetPoint("RIGHT", -100, 0)
	Core.CreateMF(frame, nil, true)
	Core.RestoreMF(frame)
    Core:StyleFrame(frame)
	frame.buttons = {}

	for i = 1, maxButtons do
		local button = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
		button:SetSize(28, 28)
		Core.PixelIcon(button, iconTexture[i], true)
		button.Icon:SetTexture(iconTexture[i])

		if i ~= maxButtons then
			button:RegisterForClicks("AnyDown")
			button:SetAttribute("type", "macro")
			button:SetAttribute("macrotext1", format("/wm %d", i))
			button:SetAttribute("macrotext2", format("/cwm %d", i))
		else
			button:SetScript("OnClick", ClearRaidMarker)
		end
		frame.buttons[i] = button
	end

	QoL:RaidWorldMarks_UpdateGrid()
end

QoL:RegisterQoL("RaidWorldMarks", QoL.RaidWorldMarks)