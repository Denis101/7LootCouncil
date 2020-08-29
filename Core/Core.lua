--[[-----------------------------------------------------------------------------
    Lua imports
-------------------------------------------------------------------------------]]

local unpack = unpack
local min = min
local tcopy = table.copy
local strupper = strupper

--[[-----------------------------------------------------------------------------
    WoW API imports
-------------------------------------------------------------------------------]]

local hooksecurefunc = hooksecurefunc
local CreateFrame, UnitGUID = CreateFrame, UnitGUID
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT

--[[-----------------------------------------------------------------------------
    Ace imports and initialization
    Imports from params:
    - Addon
    - ProfileDB
    - GlobalDB
-------------------------------------------------------------------------------]]

local Addon, ProfileDB, GlobalDB = unpack(select(2, ...))

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

local ACG = Addon.Libs.AceGUI
local AddonName = Addon.AddonName

Addon.UIParent = CreateFrame("Frame", "7LCParent", _G.UIParent)
Addon.UIParent:SetSize(_G.UIParent:GetSize())
Addon.UIParent:SetPoint("CENTER")
Addon.UIParent:SetFrameLevel(0)

Addon.global = {}
Addon.profile = {}

-- Frames defined in 7LootCouncil/Frames
Addon.Frames = {}

Addon.fontStrings = {}

Addon.initialized = false

--[[-----------------------------------------------------------------------------
    Public
-------------------------------------------------------------------------------]]

--[[
	Lifecycle hook for when the addon is first loaded
]]
function Addon:OnInitialize()
	if not SevenLootCouncilPrivate then
		SevenLootCouncilPrivate = {}
	end

	self.privateDb = SevenLootCouncilPrivate
	self.db = Addon.Libs.AceDB:New("SevenLootCouncil", {
		global = Addon.utils.table.copy(GlobalDB),
		profile = Addon.utils.table.copy(ProfileDB),
	}, true)

	self.profile = self.db.profile
	self.global = self.db.global
	self.initialized = true
end

function Addon:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
end

--[[
	Lifecycle hook for when all UI elements are loaded
]]
function Addon:OnLoadUI()
	Addon.myguid = UnitGUID("player")
	Addon:LoadCommands()
	self.loadedTime = GetTime()
end

function Addon:OnUnloadUI()
	SevenLootCouncilPrivate = SLCPrivate
end

function Addon:OnDisable()
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
end

function Addon:LoadCommands()
	self:RegisterChatCommand("sevenlootcouncil", "TextInput")
	self:RegisterChatCommand("sevenlc", "TextInput")
    self:RegisterChatCommand("slc", "TextInput")
end

function Addon:TextInput(msg)
    local arg1 = self:GetArgs(msg, 2)
	if arg1 and strupper(arg1) == "ROSTER" then
		self:GetModule("RaidManager"):RenderRoster()
	elseif arg1 and strupper(arg1) == "UIDEBUG" then
		self:ToggleOptionsUI("DebugWindow")
	else
		self:ToggleOptionsUI("AddonSettings")
	end
end

function Addon:ToggleOptionsUI(name)
	if InCombatLockdown() then
        self:Print(ERR_NOT_IN_COMBAT)
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	local ACD = self.Libs.AceConfigDialog
	local ConfigOpen = ACD and ACD.OpenFrames and ACD.OpenFrames[AddonName]

	local mode = "Close"
	if ConfigOpen then
		mode = "Close"
	else
		mode = "Open"
	end

	if ACD then
		ACD[mode](ACD, AddonName .. name)
	end

	if mode == "Open" then
		ConfigOpen = ACD and ACD.OpenFrames and ACD.OpenFrames[AddonName]
		if ConfigOpen then
			local frame = ConfigOpen.frame
			if frame and not self.GUIFrame then
				self.GUIFrame = frame
				_G.SevenLCGUIFrame = self.GUIFrame

				self:UpdateConfigSize()
				hooksecurefunc(frame, "StopMovingOrSizing", Addon.ConfigStopMovingOrSizing)
			end
		end
	end
end

--Sneak variable slider widget into ElvUI for styling, it it's loaded--
function Addon:styleVarSliderBar(object, ...)
	widget = Addon.hooks[ACG].Create(object, ...)
	if widget and _G.ElvUI and _G.ElvUI[1].modules["Skins"] then
		if widget.type == 'Slider-Variable' then
			local frame = widget.slider
			local editbox = widget.editbox
			local lowtext = widget.lowtext
			local hightext = widget.hightext

			_G.ElvUI[1].modules["Skins"]:HandleSliderFrame(frame)

			editbox:SetTemplate()
			editbox:Height(15)
			editbox:Point('TOP', frame, 'BOTTOM', 0, -1)

			lowtext:Point('TOPLEFT', frame, 'BOTTOMLEFT', 2, -2)
			hightext:Point('TOPRIGHT', frame, 'BOTTOMRIGHT', -2, -2)
		end
	end
	return widget
end


function Addon:HookElvUISkins()
	if _G.ElvUI then
		self:RawHook(ACG, "Create",  "styleVarSliderBar")
	end
end

function Addon:ResetConfigSettings()
	Addon.configSavedPositionTop, Addon.configSavedPositionLeft = nil, nil
	Addon.global.general.AceGUI = Addon.utils.table.copy(GlobalDB.general.AceGUI)
end

function Addon:GetConfigPosition()
	return Addon.configSavedPositionTop, Addon.configSavedPositionLeft
end

function Addon:GetConfigSize()
	if not Addon.initialized then
		return GlobalDB.general.AceGUI.width, GlobalDB.general.AceGUI.height
	else
		return Addon.global.general.AceGUI.width, Addon.global.general.AceGUI.height
	end
end

function Addon:UpdateConfigSize(reset)
	local frame = self.GUIFrame
	if not frame then return end

	local maxWidth, maxHeight = self.UIParent:GetSize()
	frame:SetMinResize(600, 500)
	frame:SetMaxResize(maxWidth-50, maxHeight-50)

	self.Libs.AceConfigDialog:SetDefaultSize(AddonName, self:GetConfigDefaultSize())

	local status = frame.obj and frame.obj.status
	if status then
		if reset then
			self:ResetConfigSettings()

			status.top, status.left = self:GetConfigPosition()
			status.width, status.height = self:GetConfigDefaultSize()

			frame.obj:ApplyStatus()
		else
			local top, left = self:GetConfigPosition()
			if top and left then
				status.top, status.left = top, left

				frame.obj:ApplyStatus()
			end
		end
	end
end

function Addon:GetConfigDefaultSize()
	local width, height = Addon:GetConfigSize()
	local maxWidth, maxHeight = Addon.UIParent:GetSize()
	width, height = min(maxWidth-50, width), min(maxHeight-50, height)
	return width, height
end

function Addon:ConfigStopMovingOrSizing()
	if self.obj and self.obj.status then
		Addon.configSavedPositionTop, Addon.configSavedPositionLeft = Addon.utils.math:num_round(self:GetTop(), 2), Addon.utils.math:num_round(self:GetLeft(), 2)
		Addon.global.general.AceGUI.width, Addon.global.general.AceGUI.height = Addon.utils.math:num_round(self:GetWidth(), 2), Addon.utils.math:num_round(self:GetHeight(), 2)
	end
end

--[[-----------------------------------------------------------------------------
    Events
-------------------------------------------------------------------------------]]

function Addon:PLAYER_REGEN_DISABLED()
	local err
	local ACD = self.Libs.AceConfigDialog
	if ACD and ACD.OpenFrames and ACD.OpenFrames[AddonName] then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		ACD:Close(AddonName)
		err = true
	end

	if err then
		self:Print(ERR_NOT_IN_COMBAT)
	end
end

function Addon:PLAYER_REGEN_ENABLED()
	self:ToggleOptionsUI()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end