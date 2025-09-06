local _, ns = ...
local Core, Config, L, DB = unpack(ns)

local Quests = Core:RegisterModule("Quests")

local _G = getfenv(0)
local GetNumQuestLogEntries, GetQuestLogTitle  = GetNumQuestLogEntries, GetQuestLogTitle
local GetQuestIndexForWatch = GetQuestIndexForWatch
local QUESTS_DISPLAYED = QUESTS_DISPLAYED or 22
local CodexQuest, QuestLogListScrollFrame = CodexQuest, QuestLogListScrollFrame
local WatchFrame, WatchFrameHeader, WatchFrameCollapseExpandButton = WatchFrame, WatchFrameHeader, WatchFrameCollapseExpandButton
local QuestLogFrame = QuestLogFrame
local IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded

function Quests:ExtQuestLogFrame()
	-- Move ClassicCodex
	if not CodexQuest then return end

    local buttonShow = CodexQuest.buttonShow
    if not buttonShow then return end
    buttonShow:SetWidth(55)
    buttonShow:SetText(DB.InfoColor..SHOW)

    local buttonHide = CodexQuest.buttonHide
    buttonHide:ClearAllPoints()
    buttonHide:SetPoint("LEFT", buttonShow, "RIGHT", 5, 0)
    buttonHide:SetWidth(55)
    buttonHide:SetText(DB.InfoColor..HIDE)

    local buttonReset = CodexQuest.buttonReset
    buttonReset:ClearAllPoints()
    buttonReset:SetPoint("LEFT", buttonHide, "RIGHT", 5, 0)
    buttonReset:SetWidth(55)
    buttonReset:SetText(DB.InfoColor..RESET)
end

function Quests:QuestLogLevel()
	local numEntries = GetNumQuestLogEntries()
	local scrollOffset = HybridScrollFrame_GetOffset(QuestLogListScrollFrame)
	local buttons = QuestLogListScrollFrame.buttons

	local questIndex, questLogTitle, questTitleTag, questNumGroupMates, questNormalText, questCheck
	local questLogTitleText, level, isHeader, isComplete

	for i = 1, QUESTS_DISPLAYED, 1 do
		questLogTitle = buttons[i]
		if not questLogTitle then break end -- precaution for other addons

		questIndex = i + scrollOffset
		questTitleTag = questLogTitle.tag
		questNumGroupMates = questLogTitle.groupMates
		questNormalText = questLogTitle.normalText
		questCheck = questLogTitle.check

		if questIndex <= numEntries then
			questLogTitleText, level, _, isHeader, _, isComplete = GetQuestLogTitle(questIndex)
			if not isHeader then
				questLogTitle:SetText("["..level.."] "..questLogTitleText)
				if isComplete then
					questLogTitle.r = 1
					questLogTitle.g = .5
					questLogTitle.b = 1
					questTitleTag:SetTextColor(1, .5, 1)
				end
			end

			if questNormalText then
				questNormalText:SetWidth(questNormalText:GetWidth() + 30)
				local width = questNormalText:GetStringWidth()
				if width then
					if width <= 210 then
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", width+22, 0)
					else
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", 210, 0)
					end
				end
			end

			if not questNumGroupMates.anchored then
				questNumGroupMates:SetPoint("LEFT")
				questNumGroupMates.anchored = true
			end
		end
	end
end

local function UpdateMinimizeButton(self)
	WatchFrameCollapseExpandButton.__texture:DoCollapse(self.collapsed)
	WatchFrame.header:SetShown(not self.collapsed)
end

local function ReskinMinimizeButton(button)
	Core.ReskinCollapse(button)
	button:GetNormalTexture():SetAlpha(0)
	button:GetPushedTexture():SetAlpha(0)
	button.__texture:DoCollapse(false)
end

local function ReskinQuestIcon(button)
	if not button then return end
	if not button.SetNormalTexture then return end

	if not button.styled then
		button:SetSize(32, 32)
		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		local icon = _G[button:GetName().."IconTexture"]
		if icon then
			button.bg = Core.ReskinIcon(icon, true)
			Core:SetInside(icon)
		end

		button.styled = true
	end

	if button.bg then
		button.bg:SetFrameLevel(0)
	end
end

-- Move and save blizz frames
function Quests:MoveBlizzFrames()
	if not IsAddOnLoaded("RXPGuides") then
		Core:BlizzFrameMover(CharacterFrame)
	end
	Core:BlizzFrameMover(QuestLogFrame)
end

function Quests:OnLogin()
    Quests:MoveBlizzFrames()

	-- Mover for quest tracker
	local frame = CreateFrame("Frame", "LauringQuestMover", UIParent)
	frame:SetSize(240, 50)
	Core.Mover(frame, L["QuestTracker"], "QuestTracker", {"RIGHT", UIParent, "RIGHT", -507, 220})

	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint("TOPRIGHT", frame)
	WatchFrame:SetClampedToScreen(false)
	WatchFrame:SetHeight(GetScreenHeight()*.65)

	hooksecurefunc(WatchFrame, "SetPoint", function(self, _, parent)
		if parent ~= frame then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", frame)
		end
	end)

	hooksecurefunc("WatchFrameItem_UpdateCooldown", function(button)
		ReskinQuestIcon(button)
	end)

	ReskinMinimizeButton(WatchFrameCollapseExpandButton)
	hooksecurefunc("WatchFrame_Collapse", UpdateMinimizeButton)
	hooksecurefunc("WatchFrame_Expand", UpdateMinimizeButton)

	local header = CreateFrame("Frame", nil, WatchFrameHeader)
	header:SetSize(1, 1)
	header:SetPoint("TOPLEFT")
	WatchFrame.header = header

	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, .66, 0, .31)
	bg:SetVertexColor(DB.r, DB.g, DB.b, .8)
	bg:SetPoint("TOPLEFT", -25, 5)
	bg:SetSize(250, 30)

	if not Config.DB["Quests"]["Tracker"] then return end

	Quests:ExtQuestLogFrame()
	hooksecurefunc("QuestLog_Update", Quests.QuestLogLevel)
	hooksecurefunc(QuestLogListScrollFrame, "update", Quests.QuestLogLevel)

	-- Extend the wrap text on WatchFrame, needs review
	hooksecurefunc("WatchFrame_SetLine", function(line)
		if not line.text then return end

		local height = line:GetHeight()
		if height > 28 and height < 34 then
			line:SetHeight(34)
			line.text:SetHeight(34)
		end
	end)

	-- Allow to send quest name
	hooksecurefunc("WatchFrameLinkButtonTemplate_OnClick", function(self)
		if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
			if self.type == "QUEST" then
				local name, _ = GetQuestLogTitle(GetQuestIndexForWatch(self.index))
				if name then
					ChatEdit_InsertLink("["..name.."]")
				end
			end
		end
	end)
end