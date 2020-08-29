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

local GetItemInfo = GetItemInfo

local DressUpItemLink = DressUpItemLink
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
local ChatEdit_InsertLink = ChatEdit_InsertLink

local IsControlKeyDown = IsControlKeyDown
local IsModifiedClick = IsModifiedClick
local IsShiftKeyDown = IsShiftKeyDown

local ShowInspectCursor = ShowInspectCursor
local ResetCursor = ResetCursor
local CursorOnUpdate = CursorOnUpdate

local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS

--[[-----------------------------------------------------------------------------
    Ace imports and initialization
    Imports from params:
    - Addon
    - ProfileDB
    - GlobalDB
-------------------------------------------------------------------------------]]

local Addon = unpack(select(2, ...))


--[[-----------------------------------------------------------------------------
    Constants
-------------------------------------------------------------------------------]]

local FRAME_WIDTH, FRAME_HEIGHT = 656, 56

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

local AceGUI = Addon.Libs.AceGUI
local LSM = Addon.Libs.LSM

local widgetType = "7LC_LootPreview"
local widgetVersion = 1

local widgetProps = {
    statusBarTex = nil,
    lootRollPos = "TOP",
    texCoords = {0, 1, 0, 1},
    priestColors = { r = 0.99, g = 0.99, b = 0.99, colorStr = 'fffcfcfc' },
}

--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

local function HideTip2() _G.GameTooltip:Hide(); ResetCursor() end

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

local function StatusUpdate(frame, elapsed)
	local t = frame:GetValue() - (elapsed * 1000)
	local perc = t / frame.parent.time
	frame.spark:Point("CENTER", frame, "LEFT", perc * frame:GetWidth(), 0)
	frame:SetValue(t)

	if t > 1000000000 then
		frame:GetParent():Hide()
	end
end

local function CreateRollButton(parent, text, color, rolltype, tiptext, ...)
	local btn = CreateFrame("Button", nil, parent)
	btn:Point(...)
	btn:Size(Addon.utils.math.num_round(FRAME_HEIGHT * .75))

	local texture = LSM:Fetch("background", "Solid")
	btn:SetNormalTexture(texture)
	btn:GetNormalTexture():SetColorTexture(color.r, color.g, color.b, 1)
	btn:SetHighlightTexture(texture)
	btn:GetHighlightTexture():SetColorTexture(1, 1, 1, .2)

	btn.color = color
	btn.rolltype = rolltype
	btn.parent = parent
	btn.tiptext = tiptext
	btn:SetMotionScriptsWhileDisabled(true)
	local txt = btn:CreateFontString(btn, "OVERLAY", "GameTooltipText")
	txt:SetFont(Addon.profile.general.fontSettings.font, Addon.profile.general.fontSettings.size, Addon.profile.general.fontSettings.outline)
	txt:SetText(text)
	txt:SetDrawLayer("OVERLAY")
	--txt:SetFrameLevel(btn:GetFrameLevel()+1)
	txt:Point("CENTER", 0, 0)
	return btn, txt
end

local function FeedFrame(frame, options, itemId, time)
	frame.status:SetScript("OnUpdate", function() end)
	frame.time = time

    local name = select(1, GetItemInfo(itemId))
    local link = select(2, GetItemInfo(itemId))
    local quality = select(3, GetItemInfo(itemId))
	local icon = select(10, GetItemInfo(itemId))

	local itemColor = ITEM_QUALITY_COLORS[quality]

	-- TODO, show something useful
	if name == nil or link == nil or quality == nil or quality == nil or itemColor == nil then
		return
	end

    local itemInfo = {
        id = itemId,
        texture = icon,
        name = name,
        quality = quality,
        color = itemColor,
        link = link,
	}

	frame.button.icon:SetTexture(itemInfo.texture)
	frame.button.link = itemInfo.link

    frame.fsloot:SetText(itemInfo.name)
	frame.status:SetStatusBarColor(itemInfo.color.r, itemInfo.color.g, itemInfo.color.b, .7)
	frame.status.bg:SetColorTexture(itemInfo.color.r, itemInfo.color.g, itemInfo.color.b)

	frame.status:SetMinMaxValues(0, time)
	frame.status:SetValue(time)

	if frame.options ~= nil then
		for _,opt in ipairs(frame.options) do
			if opt.btn ~= nil then
				opt.btn:ClearAllPoints()
				opt.btn:SetSize(0, 0)
				opt.btn:Hide()
			end

			if opt.text ~= nil then
				opt.text:ClearAllPoints()
				opt.text:SetSize(0, 0)
				opt.text:Hide()
			end
		end
	end

    frame.options = {}
	local anchorFrame = frame.status
	local offX = -49
	local anchorPoint = "LEFT"
	local relAnchorPoint = "RIGHT"
	for i = 1, table.getn(options) do
		if i > 1 then
			offX = -5
			anchorPoint = "RIGHT"
			relAnchorPoint = "LEFT"
		end

		local opt = options[i]
		local color = opt.color or { r = .8, g = .8, b = .8 }
		local btn, txt = CreateRollButton(frame, opt.displayText, color, opt.key, opt.description or "", anchorPoint, anchorFrame, relAnchorPoint, offX, 0)
		frame.options[i] = { btn = btn, text = txt }
		anchorFrame = btn
	end

	frame.status:SetScript("OnUpdate", StatusUpdate)
	frame:Show()
	_G.AlertFrame:UpdateAnchors()
end

local function CreateMainFrame(name, parent)
    local container = CreateFrame("Frame", name, parent)
	container:Hide()

    local frame = CreateFrame("Frame", nil, container)
    frame:Point("CENTER", container, "CENTER", 0, 0)
    frame:Size(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetTemplate()
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(10)
    frame.parent = container
	container.lootFrame = frame

	local noteContainer = CreateFrame("Frame", nil, frame)
	noteContainer:Point("CENTER", frame, "BOTTOM", 0, -11)
	noteContainer:Size(FRAME_WIDTH - 2, 20)
	noteContainer:CreateBackdrop()
	container.noteContainer = noteContainer

	local note = AceGUI:Create("EditBox")
	note:SetText("Enter your note here...")
	note:SetMaxLetters(100)
	note:SetRelativeWidth(1)
	note:SetHeight(20)
	note:SetParent(noteContainer)
	noteContainer.note = note

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
    button.icon:SetTexCoord(unpack(widgetProps.texCoords))

    local tfade = frame:CreateTexture(nil, "BORDER")
	tfade:Point("TOPLEFT", frame, "TOPLEFT", 4, 0)
	tfade:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 0)
	tfade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	tfade:SetBlendMode("ADD")
    tfade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .1, .1, .1, 0)

    local status = CreateFrame("StatusBar", nil, frame)
	status:SetInside()
    status:SetFrameLevel(status:GetFrameLevel()-1)
	status:SetStatusBarTexture(LSM:Fetch("statusbar", widgetProps.statusBarTex))
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

	local loot = frame:CreateFontString(nil, "ARTWORK")
	loot:FontTemplate(nil, nil, "OUTLINE")
	loot:Point("LEFT", frame.button, "RIGHT", 10, 1)
	loot:Point("RIGHT", frame, "RIGHT", -5, 0)
	loot:Size(200, 10)
	loot:SetJustifyH("LEFT")
	frame.fsloot = loot

    return container
end

--[[-----------------------------------------------------------------------------
    Methods
-------------------------------------------------------------------------------]]

local methods = {
    ["OnAcquire"] = function(self)
        self:SetDisabled(false)
        self:SetFullWidth(true)
        self:SetHeight(FRAME_HEIGHT + 32)
    end,
    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        if disabled then
            -- do things
        else
            -- do other things
        end
    end,
    ["SetValue"] = function(self, value) --[[Stub for "input" types]] end,
    ["GetValue"] = function(self) --[[Stub for "input" types]] end,
    ["SetList"] = function(self, list)
        FeedFrame(self.frame.lootFrame, list.opts, list.itemId, list.time * 1000)
    end,
    ["SetText"] = function(self, text)
        self.text = text
    end,
    ["SetLabel"] = function(self, label)
        self.label = label
    end,
    ["OnEnterPressed"] = function(self, text) --[[Stub for "input" types]] end,
}

--[[-----------------------------------------------------------------------------
    Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
    widgetProps.statusBarTex = Addon.profile.general.unitFrames.barTexture

    do -- setup cropIcon texCoords
		local opt = Addon.global.general.cropIcon
		local modifier = 0.04 * opt
		for i, v in ipairs(widgetProps.texCoords) do
			if i % 2 == 0 then
				widgetProps.texCoords[i] = v - modifier
			else
				widgetProps.texCoords[i] = v + modifier
			end
		end
	end

    local widget = {
        frame = CreateMainFrame(widgetType, Addon.UIParent),
        type = widgetType,
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)