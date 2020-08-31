--[[-----------------------------------------------------------------------------
    Lua imports
-------------------------------------------------------------------------------]]

local unpack = unpack
local strlen = strlen

--[[-----------------------------------------------------------------------------
    WoW API imports
-------------------------------------------------------------------------------]]

local CreateFrame = CreateFrame

--[[-----------------------------------------------------------------------------
    Ace imports and initialization
    Imports from params:
    - Addon
    - ProfileDB
    - GlobalDB
-------------------------------------------------------------------------------]]

local Addon, _, GlobalDB = unpack(select(2, ...))
local AceGUI = Addon.Libs.AceGUI
local LSM = Addon.Libs.LSM

--[[-----------------------------------------------------------------------------
    Constants
-------------------------------------------------------------------------------]]

local DEFAULT_WIDTH = 200
local DEFAULT_HEIGHT = 40

local DEFAULT_ALPHA = .2
local DEFAULT_HIGHLIGHT_ALPHA = .3

local DEFAULT_NORMAL_COLOR = { r = DEFAULT_ALPHA, g = DEFAULT_ALPHA, b = DEFAULT_ALPHA, a = DEFAULT_ALPHA }
local DEFAULT_HIGHLIGHT_COLOR = { r = DEFAULT_HIGHLIGHT_ALPHA, g = DEFAULT_HIGHLIGHT_ALPHA, b = DEFAULT_HIGHLIGHT_ALPHA, a = DEFAULT_HIGHLIGHT_ALPHA }

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

local pp = Addon.utils.display.pixel_perfect

local widgetType = "7LC_TableClass"
local widgetVersion = 1

--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

-- TODO, move this to a non-dumb location, dummy
local function ClassColor(class, usePriestColor)
	if not class then return DEFAULT_NORMAL_COLOR end

	local color = (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class]) or _G.RAID_CLASS_COLORS[class]
	if type(color) ~= 'table' then return DEFAULT_NORMAL_COLOR end

	if not color.colorStr then
		color.colorStr = Addon.utils.string.rgb_to_hex(color.r, color.g, color.b, 'ff')
	elseif strlen(color.colorStr) == 6 then
		color.colorStr = 'ff'..color.colorStr
	end

	if (usePriestColor and class == 'PRIEST') and tonumber(color.colorStr, 16) > tonumber(GlobalDB.PriestColors.colorStr, 16) then
		return GlobalDB.PriestColors
	else
		return color
	end
end

local function CreateText(frame)
    frame.children = {}
    local txt = frame:CreateFontString(frame, "OVERLAY", "GameTooltipText")
    txt:SetPoint("LEFT", pp(5), 0)
    txt:SetFont(
        Addon.profile.general.fontSettings.font,
        Addon.profile.general.fontSettings.size,
        Addon.profile.general.fontSettings.outline)
    txt:SetDrawLayer("OVERLAY")

    frame.text = txt
    table.insert(frame.children, txt)
end

local function SetFrameData(self)
    self.frame.slug = self.heading and self.heading.slug
    self.frame.data = self.value

    if self:GetValue() then
        self.frame.text:SetText(self.value)
    end

    self.frame:Show()
end

local function SetFrameTexture(frame, textureName, normalColor, highlightColor, disabled)
    if frame == nil then
        return
    end

    local texture = LSM:Fetch("background", textureName)
    frame:SetNormalTexture(texture)
    frame:GetNormalTexture():SetColorTexture(
        normalColor.r,
        normalColor.g,
        normalColor.b,
        normalColor.a or DEFAULT_ALPHA)

    if disabled then
        frame:SetHighlightTexture(nil)
    else
        frame:SetHighlightTexture(texture)
        frame:GetHighlightTexture():SetColorTexture(
            highlightColor.r,
            highlightColor.g,
            highlightColor.b,
            highlightColor.a or DEFAULT_HIGHLIGHT_ALPHA)
    end
end

local function CreateMainFrame(name)
    local frame = CreateFrame("Button", name)
    CreateText(frame)
    frame:Hide()
    return frame
end

--[[-----------------------------------------------------------------------------
    Methods
-------------------------------------------------------------------------------]]

local methods = {
    ["OnAcquire"] = function(self)
        self.texture = "Solid"
        self.normalColor = DEFAULT_NORMAL_COLOR
        self.highlightColor = DEFAULT_HIGHLIGHT_COLOR
        self:SetDisabled(false)
        self:SetHeight(DEFAULT_HEIGHT)

        if self:GetValue() then
            self:DoLayout()
            SetFrameTexture(self.frame, self.texture, self.normalColor, self.highlightColor, false)
            SetFrameData(self)
        end
    end,
    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        SetFrameTexture(self.frame, self.texture, self.normalColor, self.highlightColor, disabled)
    end,
    ["SetHeading"] = function(self, heading)
        self.heading = heading
        self:SetWidth(pp(heading.width or DEFAULT_WIDTH))
        SetFrameData(self)
    end,
    ["GetSlug"] = function(self)
        return self.heading and self.heading.slug
    end,
    ["SetValue"] = function(self, value)
        self.value = Addon.utils.string.capitalize(value:lower())
        self.normalColor = ClassColor(value, true)
        SetFrameData(self)
        SetFrameTexture(self.frame, self.texture, self.normalColor, self.highlightColor, self.display)
    end,
    ["GetValue"] = function(self)
        return self.value
    end,
    ["SetText"] = function(self, value)
        self:SetValue(value)
    end,
    ["SetOffset"] = function(self, x, y)
        self.offset = { x = x, y = y }
    end,
    ["DoLayout"] = function(self)
        if not self.offset then
            return
        end

        local x = self.offset.x
        local y = self.offset.y

        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", pp(x), pp(y))
    end,
    ["SetLabel"] = function() --[[Stub for "input" types]] end,
    ["OnEnterPressed"] = function() --[[Stub for "input" types]] end,
}

--[[-----------------------------------------------------------------------------
    Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
    local widget = {
        frame = CreateMainFrame(widgetType),
        type = widgetType,
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)