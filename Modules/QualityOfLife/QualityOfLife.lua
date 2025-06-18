local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local QoL = Core:RegisterModule("QoL")

local QOL_LIST = {}

function QoL:RegisterQoL(name, func)
	if not QOL_LIST[name] then
		QOL_LIST[name] = func
	end
end

function QoL:OnLogin()
    for name, func in next, QOL_LIST do
		if name and type(func) == "function" then
			xpcall(func, geterrorhandler())
		end
	end
end