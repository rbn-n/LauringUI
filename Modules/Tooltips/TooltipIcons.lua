local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local Tooltip = Core:GetModule("Tooltips")

local gsub, unpack, strfind = gsub, unpack, strfind
local GetSpellTexture = GetSpellTexture
local newString = "0:0:64:64:5:59:5:59"

function Tooltip:SetupTooltipIcon(icon)
	local title = icon and _G[self:GetName().."TextLeft1"]
	local titleText = title and title:GetText()
	if titleText then
		title:SetFormattedText("|T%s:20:20:"..newString..":%d|t %s", icon, 20, titleText)
	end

	for i = 2, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		if not line then break end
		local text = line:GetText()
		if text and text ~= " " and not strfind(text, "UI%-CharacterCreate%-Classes") then
			local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:"..newString.."|t")
			if count > 0 then line:SetText(newText) end
		end
	end
end

function Tooltip:HookTooltipCleared()
	self.tipModified = false
end

function Tooltip:HookTooltipSetItem()
	if not self.tipModified then
		local _, link = self:GetItem()
		if link then
			Tooltip.SetupTooltipIcon(self, C_Item.GetItemIconByID(link))
		end

		self.tipModified = true
	end
end

function Tooltip:HookTooltipSetSpell()
	if not self.tipModified then
		local _, id = self:GetSpell()
		if id then
			Tooltip.SetupTooltipIcon(self, GetSpellTexture(id))
		end

		self.tipModified = true
	end
end

function Tooltip:HookTooltipMethod()
	self:HookScript("OnTooltipSetItem", Tooltip.HookTooltipSetItem)
	self:HookScript("OnTooltipSetSpell", Tooltip.HookTooltipSetSpell)
	self:HookScript("OnTooltipCleared", Tooltip.HookTooltipCleared)
end

local function updateBackdropColor(self, r, g, b)
	self:GetParent().bg:SetBackdropBorderColor(r, g, b)
end

local function resetBackdropColor(self)
	self:GetParent().bg:SetBackdropBorderColor(0, 0, 0)
end

function Tooltip:ReskinRewardIcon()
	self.Icon:SetTexCoord(unpack(DB.TexCoord))
	self.bg = Core.CreateBDFrame(self, 0)
	Core:SetOutside(self.bg, self.Icon)

	local iconBorder = self.IconBorder
	iconBorder:SetAlpha(0)
	hooksecurefunc(iconBorder, "SetVertexColor", updateBackdropColor)
	hooksecurefunc(iconBorder, "Hide", resetBackdropColor)
end

function Tooltip:ReskinTooltipIcons()
	Tooltip.HookTooltipMethod(GameTooltip)
	Tooltip.HookTooltipMethod(ItemRefTooltip)

	hooksecurefunc(GameTooltip, "SetUnitAura", function(self)
		Tooltip.SetupTooltipIcon(self)
	end)

	-- Tooltip rewards icon
	Tooltip.ReskinRewardIcon(EmbeddedItemTooltip.ItemTooltip)
end