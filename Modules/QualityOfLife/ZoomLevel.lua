local _, ns = ...
local Core, Config, L, DB = unpack(ns)
local QoL = Core:GetModule("QoL")

local C_Timer_After = C_Timer.After

function QoL:UpdateZoomLevel()
	SetCVar("cameraDistanceMaxZoomFactor", Config.DB["QoL"]["ZoomLevel"])
end

QoL:RegisterQoL("ZoomLevel", C_Timer_After(0, QoL.UpdateZoomLevel))