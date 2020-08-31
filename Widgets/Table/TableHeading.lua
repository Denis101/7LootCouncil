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

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

local pp = Addon.utils.display.pixel_perfect

local widgetType = "7LC_TableHeading"
local widgetVersion = 1

--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

local function SetFrameData(self)
    self.frame.text:SetText(self.value)
    self.frame:Show()
end

local function CreateMainFrame(name)
    local frame = CreateFrame("Button", name)
    frame.children = {}

    local texture = LSM:Fetch("background", "Solid")
    frame:SetNormalTexture(texture)
    frame:GetNormalTexture():SetColorTexture(.5, .5, .5, .5)

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
        self:SetDisabled(false)
    end,
    ["OnRelease"] = function(self)
        Addon.utils.display.clear_frame(self.frame)
    end,
    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
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
    ["SetOffset"] = function(self, offset)
        self.offset = offset
    end,
    ["DoLayout"] = function(self)
        if not self.offset then
            return
        end

        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", pp(self.offset), 0)
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