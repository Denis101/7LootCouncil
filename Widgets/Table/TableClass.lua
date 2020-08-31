--[[-----------------------------------------------------------------------------
    Lua imports
-------------------------------------------------------------------------------]]

local unpack = unpack

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

local Addon = unpack(select(2, ...))
local AceGUI = Addon.Libs.AceGUI
local LSM = Addon.Libs.LSM

--[[-----------------------------------------------------------------------------
    Constants
-------------------------------------------------------------------------------]]

local LABEL_WIDTH = 200
local LABEL_HEIGHT = 40

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

local function SetFrameData(self)
    self.frame.slug = self.heading and self.heading.slug
    self.frame.data = self.value
    self.frame.text:SetText(self.value)
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

local function CreateMainFrame(name, parent, x, y, width, height)
    local xPos = x or 0
    local yPos = y or 0
    local frameWidth = width or LABEL_WIDTH
    local frameHeight = height or LABEL_HEIGHT

    local frame = CreateFrame("Button", name)
    frame.children = {}

    frame:SetFrameStrata(parent:GetFrameStrata())
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", pp(xPos), pp(yPos))
    frame:SetWidth(pp(frameWidth))
    frame:SetHeight(pp(frameHeight))

    local txt = frame:CreateFontString(frame, "OVERLAY", "GameTooltipText")
    txt:SetFont(
        Addon.profile.general.fontSettings.font,
        Addon.profile.general.fontSettings.size,
        Addon.profile.general.fontSettings.outline)
    txt:SetDrawLayer("OVERLAY")
    txt:SetPoint("LEFT", pp(5), 0)
    frame.text = txt
    table.insert(frame.children, txt)
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
    end,
    ["OnRelease"] = function(self)
        Addon.utils.display.clear_frame(self.frame)
    end,
    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        SetFrameTexture(self.frame, self.texture, self.normalColor, self.highlightColor, disabled)
    end,
    ["SetTexture"] = function(self, texture)
        self.texture = texture
        SetFrameTexture(self.frame, texture, self.normalColor, self.highlightColor, self.disabled)
    end,
    ["SetNormalColor"] = function(self, color)
        self.normalColor = color
        SetFrameTexture(self.frame, self.texture, color, self.highlightColor, self.disabled)
    end,
    ["SetHighlightColor"] = function(self, color)
        self.highlightColor = color
        SetFrameTexture(self.frame, self.texture, self.normalColor, color, self.disabled)
    end,
    ["SetHeading"] = function(self, heading)
        self.heading = heading
        self:SetWidth(pp(heading.width or 100))
        self:SetHeight(pp(heading.height or 20))
        SetFrameData(self)
    end,
    ["GetSlug"] = function(self)
        return self.heading and self.heading.slug
    end,
    ["SetValue"] = function(self, value)
        self.value = value
        SetFrameData(self)
    end,
    ["GetValue"] = function(self)
        return self.value
    end,
    ["SetText"] = function(self, value)
        self.value = value
        SetFrameData(self)
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
        frame = CreateMainFrame(widgetType, Addon.UIParent),
        type = widgetType,
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)