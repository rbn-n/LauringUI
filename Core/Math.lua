local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local floor = math.floor

local day, hour, minute = 86400, 3600, 60

function Core.Numb(n)
    if LauringUIAccountDB["NumberFormat"] == 1 then
        if n >= 1e12 then
            return format("%.2ft", n / 1e12)
        elseif n >= 1e9 then
            return format("%.2fb", n / 1e9)
        elseif n >= 1e6 then
            return format("%.2fm", n / 1e6)
        elseif n >= 1e3 then
            return format("%.1fk", n / 1e3)
        else
            return format("%.0f", n)
        end
    elseif LauringUIAccountDB["NumberFormat"] == 2 then
        if n >= 1e12 then
            return format("%.2f"..L["NumberCap3"], n / 1e12)
        elseif n >= 1e8 then
            return format("%.2f"..L["NumberCap2"], n / 1e8)
        elseif n >= 1e4 then
            return format("%.1f"..L["NumberCap1"], n / 1e4)
        else
            return format("%.0f", n)
        end
    else
        return format("%.0f", n)
    end
end

function Core:Round(number, idp)
    idp = idp or 0
    local mult = 10 ^ idp
    return floor(number * mult + .5) / mult
end

function Core.FormatTime(s)
    if s >= day then
        return format("%d"..DB.MyColor.."d", s/day + .5), s%day
    elseif s >= hour then
        return format("%d"..DB.MyColor.."h", s/hour + .5), s%hour
    elseif s >= minute then
        return format("%d"..DB.MyColor.."m", s/minute + .5), s%minute
    elseif s > 10 then
        return format("|cffcccc33%d|r", s + .5), s - floor(s)
    elseif s > 3 then
        return format("|cffffff00%d|r", s + .5), s - floor(s)
    else
        return format("|cffff0000%.1f|r", s), s - format("%.1f", s)
    end
end

function Core.FormatTimeRaw(s)
    if s >= day then
        return format("%dd", s/day + .5)
    elseif s >= hour then
        return format("%dh", s/hour + .5)
    elseif s >= minute then
        return format("%dm", s/minute + .5)
    else
        return format("%d", s + .5)
    end
end

function Core:CooldownOnUpdate(elapsed, raw)
    local formatTime = raw and Core.FormatTimeRaw or Core.FormatTime
    self.elapsed = (self.elapsed or 0) + elapsed

    if self.elapsed < .1 then return end

    local timeLeft = self.expiration - GetTime()
    if timeLeft > 0 then
        local text = formatTime(timeLeft)
        self.timer:SetText(text)
    else
        self:SetScript("OnUpdate", nil)
        self.timer:SetText("")
    end
    self.elapsed = 0
end

function Core.SplitList(list, variable, cleanup)
    if cleanup then wipe(list) end
    for word in gmatch(variable, "%S+") do
        word = tonumber(word) or word
        list[word] = true
    end
end