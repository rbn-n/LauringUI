local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local G = Core:GetModule("GUI")

local function UpdateChatSize()
	Core:GetModule("Chat"):UpdateChatSize()
end

local function ToggleEditBoxAnchor()
	Core:GetModule("Chat"):ToggleEditBoxAnchor()
end

local function UpdateWhisperKeywords()
	Core:GetModule("Chat"):UpdateWhisperKeywords()
end

local options = {
    {1, "Chat", "Enable", G.HeaderTag..L["EnableChat"], nil, nil, nil, L["EnableChatTip"]},
    {3, "Chat", "Width", L["Width"], nil, {250, 750, 1}, UpdateChatSize},
    {3, "Chat", "Height", L["Height"], true, {100, 500, 1}, UpdateChatSize},
    {},--blank
    {4, "ACCOUNT", "TimestampFormat", L["TimestampFormat"].."*", nil, {DISABLE, "03:27 PM", "03:27:32 PM", "15:27", "15:27:32"}},
    {3, "Chat", "EditBoxFontSize", L["EditBoxFontSize"].."*", true, {10, 30, 1}, ToggleEditBoxAnchor},
    {1, "Chat", "WhisperColor", L["Differ WhisperColor"].."*", nil},
    --{1, "Chat", "BottomEditBox", L["BottomEditBox"].."*", true, nil, ToggleEditBoxAnchor},
    {},--blank
    {1, "Chat", "WhisperInvite", G.HeaderTag..L["Whisper Invite"]},
    {1, "Chat", "WhisperInviteGuildOnly", L["Guild Invite Only"].."*"},
    {2, "Chat", "WhisperInviteKeywords", L["Whisper Keyword"].."*", true, nil, UpdateWhisperKeywords, L["WhisperKeywordTip"]},
}

G.TabList["Chat"] = options