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

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

local pp = Addon.utils.display.pixel_perfect

local widgetType = "7LC_TableLabel"
local widgetVersion = 1


--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

local function SetFramePosition(frame, parent, x, y, width, height)
    frame:ClearAllPoints()
    frame:Point("TOPLEFT", parent, "TOPLEFT", x, y)
    frame:SetWidth(pp(width))
    frame:SetHeight(pp(height))
    frame.parent = parent
end

local function SetFrameData(self)
    self.frame.slug = self.heading and self.heading.slug
    self.frame.data = self.value
    self.frame.text:SetText(self.value)
    self.frame:Show()
end

local function SetFrameTexture(frame, disabled)
    -- TODO, make this all configurable
    local texture = LSM:Fetch("background", "Solid")
    frame:SetNormalTexture(texture)
    frame:GetNormalTexture():SetColorTexture(.2, .2, .2, .2)

    if disabled then
        frame:SetHighlightTexture(nil)
    else
        frame:SetHighlightTexture(texture)
        frame:GetHighlightTexture():SetColorTexture(.3, .3, .3, .3)
    end
end

local function CreateMainFrame(name, parent)
    local frame = CreateFrame("Button", name, parent)
    frame:Point("TOPLEFT", parent, "TOPLEFT", 0, 0)
    frame:SetWidth(pp(LABEL_WIDTH))
    frame:SetHeight(pp(LABEL_HEIGHT))

    local txt = frame:CreateFontString(frame, "OVERLAY", "GameTooltipText")
    txt:SetFont(
        Addon.profile.general.fontSettings.font,
        Addon.profile.general.fontSettings.size,
        Addon.profile.general.fontSettings.outline)
    txt:SetDrawLayer("OVERLAY")
    txt:Point("LEFT", pp(5), 0)
    frame.text = txt
    frame:Hide()
    return frame
end

--[[-----------------------------------------------------------------------------
    Methods
-------------------------------------------------------------------------------]]

local methods = {
    ["OnAcquire"] = function(self)
        self:SetDisabled(false)
    end,
    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        SetFrameTexture(self.frame, disabled)
    end,
    ["SetHeading"] = function(self, heading)
        self.heading = heading
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
    ["InsertInto"] = function(self, parent, x, y, width, height)
        SetFramePosition(self, parent, x, y, width, height)
        self:SetParent(parent)
    end,
    ["SetText"] = function(self, value)
        self.value = value
        SetFrameData(self)
    end,
    ["SetLabel"] = function(l) --[[Stub for "input" types]] end,
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