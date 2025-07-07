local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if not unit or self.unit ~= unit then return end

	local element = self.DebuffHighlight
	if not element then return end

	local debuffType, color, wasFiltered
	local filterTable = self.DebuffHighlightFilterTable

	for i = 1, 40 do
		local _, _, _, debuffType_i = UnitDebuff(unit, i)
		if not debuffType_i then break end

		local debuffKey = string.upper(debuffType_i)
		if filterTable and filterTable[debuffKey] then
			debuffType = debuffKey
			color = filterTable[debuffKey]
			wasFiltered = false
			break
		end
	end

	if not debuffType and not wasFiltered then
		color = nil
	end

	if element.PostUpdate then
		element.PostUpdate(self, debuffType, nil, wasFiltered, nil, color)
	end
end

local function Path(self, ...)
	return (self.DebuffHighlight.Override or Update)(self, ...)
end

local function Enable(self)
	local element = self.DebuffHighlight
	if element then
		self:RegisterEvent("UNIT_AURA", Path, true)

		if not element.PostUpdate then
			element.PostUpdate = function() end
		end

		return true
	end
end

local function Disable(self)
	if self.DebuffHighlight then
		self:UnregisterEvent("UNIT_AURA", Path)
	end
end

oUF:AddElement("DebuffHighlight", Path, Enable, Disable)