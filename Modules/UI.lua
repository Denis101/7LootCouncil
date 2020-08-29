--[[-----------------------------------------------------------------------------
    Lua imports
-------------------------------------------------------------------------------]]

local unpack = unpack
local tinsert = tinsert
local strlen = strlen

--[[-----------------------------------------------------------------------------
    WoW API imports
-------------------------------------------------------------------------------]]

local CreateFrame = CreateFrame

local DressUpItemLink = DressUpItemLink
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
local ChatEdit_InsertLink = ChatEdit_InsertLink

local IsControlKeyDown = IsControlKeyDown
local IsModifiedClick = IsModifiedClick
local IsShiftKeyDown = IsShiftKeyDown

local ShowInspectCursor = ShowInspectCursor
local ResetCursor = ResetCursor
local CursorOnUpdate = CursorOnUpdate

--[[-----------------------------------------------------------------------------
    Ace imports and initialization
    Imports from params:
    - Addon
    - ProfileDB
    - GlobalDB
-------------------------------------------------------------------------------]]
local Addon = unpack(select(2, ...))
local UI = Addon:NewModule("UI", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0", "AceSerializer-3.0")

--[[-----------------------------------------------------------------------------
    Constants
-------------------------------------------------------------------------------]]

local FRAME_WIDTH, FRAME_HEIGHT = 656, 56

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

local LSM = Addon.Libs.LSM

UI.statusBars = {}
UI.statusBarTex = nil
UI.lootRollPos = "TOP"
UI.TexCoords = {0, 1, 0, 1}
UI.PriestColors = { r = 0.99, g = 0.99, b = 0.99, colorStr = 'fffcfcfc' }
UI.RollBars = {}

--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

local function HideTip(frame)
	frame:SetBackdropColor(frame.color.r, frame.color.g, frame.color.b)
	_G.GameTooltip:Hide()
end
local function HideTip2() _G.GameTooltip:Hide(); ResetCursor() end


local function ClickRoll(frame)
    frame.parent:Hide()
end

local function SetTip(frame)
	frame:SetBackdropColor(frame.color.r + .1, frame.color.g + .1, frame.color.b + .1)

	local GameTooltip = _G.GameTooltip
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetText(frame.tiptext)
	GameTooltip:Show()
end

local function SetItemTip(frame)
	if not frame.link then return end
	_G.GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
	_G.GameTooltip:SetHyperlink(frame.link)

	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
end

local function ItemOnUpdate(self)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	CursorOnUpdate(self)
end

local function LootClick(frame)
	if IsControlKeyDown() then DressUpItemLink(frame.link)
	elseif IsShiftKeyDown() then ChatEdit_InsertLink(frame.link) end
end

local function StatusUpdate(frame)
	if not frame.parent.rollID then return end
    --local t = GetLootRollTimeLeft(frame.parent.rollID)
    -- TODO, create a sane loot timer
    local t = 0
	local perc = t / frame.parent.time
	frame.spark:Point("CENTER", frame, "LEFT", perc * frame:GetWidth(), 0)
	frame:SetValue(t)

	if t > 1000000000 then
		frame:GetParent():Hide()
	end
end

local function CreateRollButton(parent, text, color, rolltype, tiptext, ...)
	local f = CreateFrame("Button", nil, parent)
	f:Point(...)
	f:Size(FRAME_HEIGHT * .75)

	f:SetBackdrop({
		bgFile = UI.statusBarTex,
		edgeFile = UI.statusBarTex,
		tile = true,
		tileEdge = true,
		tileSize = 8,
		edgeSize = 1,
	})
	f:SetBackdropBorderColor(color.r, color.g, color.b, .5)
	f:SetBackdropColor(color.r, color.g, color.b, 1)

	f.color = color
	f.rolltype = rolltype
	f.parent = parent
	f.tiptext = tiptext
	f:SetScript("OnEnter", SetTip)
	f:SetScript("OnLeave", HideTip)
	f:SetScript("OnClick", ClickRoll)
	f:SetMotionScriptsWhileDisabled(true)
	local txt = f:CreateFontString(f, "OVERLAY", "GameTooltipText")
	txt:SetFont(Addon.profile.general.fontSettingst.font, Addon.profile.general.fontSettings.size, Addon.profile.general.fontSettings.outline)
	txt:SetText(text)
	txt:Point("CENTER", 0, 0)
	return f, txt
end

--[[-----------------------------------------------------------------------------
    Public
-------------------------------------------------------------------------------]]

function UI:OnLoadUI()
	UI.statusBarTex = Addon.profile.general.unitFrames.barTexture

    do -- setup cropIcon texCoords
		local opt = Addon.global.general.cropIcon
		local modifier = 0.04 * opt
		for i, v in ipairs(UI.TexCoords) do
			if i % 2 == 0 then
				UI.TexCoords[i] = v - modifier
			else
				UI.TexCoords[i] = v + modifier
			end
		end
	end
end

function UI:RegisterStatusBar(statusBar)
	tinsert(UI.statusBars, statusBar)
end

function UI:UpdateStatusBars()
	for _, statusBar in pairs(UI.statusBars) do
		if statusBar and statusBar:IsObjectType('StatusBar') then
			statusBar:SetStatusBarTexture(LSM:Fetch("statusbar", UI.statusBarTex))
		elseif statusBar and statusBar:IsObjectType('Texture') then
			statusBar:SetTexture(LSM:Fetch("statusbar", UI.statusBarTex))
		end
	end
end

function UI:ClassColor(class, usePriestColor)
	if not class then return end

	local color = (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class]) or _G.RAID_CLASS_COLORS[class]
	if type(color) ~= 'table' then return end

	if not color.colorStr then
		color.colorStr = Addon.utils.string.rgb_to_hex(color.r, color.g, color.b, 'ff')
	elseif strlen(color.colorStr) == 6 then
		color.colorStr = 'ff'..color.colorStr
	end

	if (usePriestColor and class == 'PRIEST') and tonumber(color.colorStr, 16) > tonumber(UI.PriestColors.colorStr, 16) then
		return UI.PriestColors
	else
		return color
	end
end

--[[
	itemInfo = {
		id,
		textureId,
		name,
		quality,
		color,
		bindType,
		link,
	}
]]
function UI:GetLootRollFrame(itemInfo, rollOptions, time)
	local f = self:RegisterLootRollFrame(rollOptions)
	f.rollID = 1
	f.time = time

	f.button.icon:SetTexture(itemInfo.texture)
	f.button.link = itemInfo.link

	local bop = itemInfo.bindType == 1
	f.fsbind:SetText(bop and "BoP" or "BoE")
	f.fsbind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)

	f.fsloot:SetText(itemInfo.name)
	f.status:SetStatusBarColor(itemInfo.color.r, itemInfo.color.g, itemInfo.color.b, .7)
	f.status.bg:SetColorTexture(itemInfo.color.r, itemInfo.color.g, itemInfo.color.b)

	-- TODO; get sane time values for status bar
	f.status:SetMinMaxValues(0, 30000)
	f.status:SetValue(30000)

	f:Point("CENTER", _G.WorldFrame, "CENTER")
	f:Show()
	_G.AlertFrame:UpdateAnchors()
end

function UI:RegisterLootRollFrame(rollOptions)
	for _,f in ipairs(self.RollBars) do
		if not f.rollID then return f end
	end

	local f = self:CreateLootRollFrame(rollOptions)
	local anchor, anchorInner, x, y
	if self.lootRollPos == "TOP" then
		anchor, anchorInner, x, y = "TOP", "BOTTOM", 0, -4
	else
		anchor, anchorInner, x, y = "BOTTOM", "TOP", 0, 4
	end

	f:Point(anchor, next(self.RollBars) and self.RollBars[#self.RollBars] or _G.AlertFrameHolder, anchorInner, x, y)
	tinsert(self.RollBars, f)
	return f
end

function UI:CreateLootRollFrame(rollOptions)
    local frame = CreateFrame("Frame", nil, Addon.UIParent)
    frame:Size(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetTemplate()
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(10)
	frame:Hide()

    local button = CreateFrame("Button", nil, frame)
    button:Point("RIGHT", frame, "LEFT", 0, 0)
    button:Size(FRAME_HEIGHT)
	button:CreateBackdrop()
    button:SetScript("OnEnter", SetItemTip)
	button:SetScript("OnLeave", HideTip2)
	button:SetScript("OnUpdate", ItemOnUpdate)
	button:SetScript("OnClick", LootClick)
	frame.button = button

    button.icon = button:CreateTexture(nil, "BORDER")
    button.icon:SetAllPoints()
	button.icon:SetTexCoord(unpack(self.TexCoords))

    local tfade = frame:CreateTexture(nil, "BORDER")
	tfade:Point("TOPLEFT", frame, "TOPLEFT", 4, 0)
	tfade:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 0)
	tfade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	tfade:SetBlendMode("ADD")
	tfade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .1, .1, .1, 0)

    local status = CreateFrame("StatusBar", nil, frame)
	status:SetInside()
	status:SetScript("OnUpdate", StatusUpdate)
	status:SetFrameLevel(status:GetFrameLevel()-1)
	status:SetStatusBarTexture(LSM:Fetch("statusbar", UI.statusBarTex))
	self:RegisterStatusBar(status)
	status:SetStatusBarColor(.8, .8, .8, .9)
	status.parent = frame
	frame.status = status

    status.bg = status:CreateTexture(nil, 'BACKGROUND')
	status.bg:SetAlpha(0.1)
	status.bg:SetAllPoints()
	status.bg:SetDrawLayer('BACKGROUND', 2)
	local spark = frame:CreateTexture(nil, "OVERLAY")
	spark:Size(14, FRAME_HEIGHT)
	spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	spark:SetBlendMode("ADD")
	status.spark = spark

	frame.options = {}
	local anchorFrame = frame.status
	local offX = -49
	local anchorPoint = "LEFT"
	local relAnchorPoint = "RIGHT"
	for i = 1, table.getn(rollOptions) do
		if i > 1 then
			offX = -5
			anchorPoint = "RIGHT"
			relAnchorPoint = "LEFT"
		end

		local color = { r = .8, g = .8, b = .8 }

		local opt = rollOptions[i]
		local btn, txt = CreateRollButton(frame, opt.displayText, color, opt.key, opt.description or "", anchorPoint, anchorFrame, relAnchorPoint, offX, 0)
		frame.options[i] = { btn = btn, text = txt }
		anchorFrame = btn
	end

    local bind = frame:CreateFontString()
	bind:Point("LEFT", frame.button, "RIGHT", 10, 1)
	bind:FontTemplate(nil, nil, "OUTLINE")
	frame.fsbind = bind

	local loot = frame:CreateFontString(nil, "ARTWORK")
	loot:FontTemplate(nil, nil, "OUTLINE")
	loot:Point("LEFT", bind, "RIGHT", 0, 0)
	loot:Point("RIGHT", frame, "RIGHT", -5, 0)
	loot:Size(200, 10)
	loot:SetJustifyH("LEFT")
	frame.fsloot = loot

    return frame
end

function UI:ShowDebugFrame()
end

--[[-----------------------------------------------------------------------------
    Comms
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
    Events
-------------------------------------------------------------------------------]]
