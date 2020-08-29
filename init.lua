local type = type
local CreateFrame = CreateFrame

local AceAddon, AceAddonMinor = _G.LibStub("AceAddon-3.0")
local CallbackHandler = _G.LibStub("CallbackHandler-1.0")

local AddonName, Engine = ...

local Addon = AceAddon:NewAddon(AddonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0", "AceComm-3.0")
Addon.callbacks = Addon.callbacks or CallbackHandler:New(Addon)
Addon.AddonName = AddonName

Engine[1] = Addon

Addon.utils = _G.__utils__
_G.SevenLC = Engine

do
    Addon.Libs = {}
	Addon.LibsMinor = {}
	function Addon:AddLib(name, major, minor)
		if not name then return end

		-- in this case: `major` is the lib table and `minor` is the minor version
		if type(major) == "table" and type(minor) == "number" then
			self.Libs[name], self.LibsMinor[name] = major, minor
		else -- in this case: `major` is the lib name and `minor` is the silent switch
			self.Libs[name], self.LibsMinor[name] = _G.LibStub(major, minor)
		end
	end

	Addon:AddLib("AceAddon", AceAddon, AceAddonMinor)
	Addon:AddLib("AceDB", "AceDB-3.0")
	Addon:AddLib("AceDBO", "AceDBOptions-3.0")
	Addon:AddLib("LSM", "LibSharedMedia-3.0")
	Addon:AddLib("RC", "LibRangeCheck-2.0")
	Addon:AddLib("AceGUI", "AceGUI-3.0")
	Addon:AddLib("AceConfig", "AceConfig-3.0")
	Addon:AddLib("AceConfigDialog", "AceConfigDialog-3.0")
    Addon:AddLib("AceConfigRegistry", "AceConfigRegistry-3.0")
end

local LoadUI=CreateFrame("Frame")
LoadUI:RegisterEvent("PLAYER_LOGIN")
LoadUI:RegisterEvent("PLAYER_LOGOUT")
LoadUI:SetScript("OnEvent", function(_,event)
	if event == "PLAYER_LOGIN" then
		if Addon.OnLoadUI ~= nil then
			Addon:OnLoadUI()
		end

		for _,m in Addon:IterateModules() do
			if m.OnLoadUI ~= nil then
				m:OnLoadUI()
			end
		end
	elseif event == "PLAYER_LOGOUT" then
		if Addon.OnUnloadUI ~= nil then
			Addon:OnUnloadUI()
		end

		for _,m in Addon:IterateModules() do
			if m.OnUnloadUI ~= nil then
				m:OnUnloadUI()
			end
		end
	end
end)