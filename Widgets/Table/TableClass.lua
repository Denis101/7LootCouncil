--[[-----------------------------------------------------------------------------
    Lua imports
-------------------------------------------------------------------------------]]

local unpack = unpack

--[[-----------------------------------------------------------------------------
    WoW API imports
-------------------------------------------------------------------------------]]

local CreateFrame = CreateFrame
local PlaySound = PlaySound

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

local ROW_HEIGHT = 20

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

local AceGUI = Addon.Libs.AceGUI
local LSM = Addon.Libs.LSM

local pp = Addon.utils.display.pixel_perfect

local widgetType = "7LC_TableClass"
local widgetVersion = 1


--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

local function CreateMainFrame(name, parent)
    local frame = CreateFrame("Frame", name, parent)
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
    end,
    ["SetValue"] = function() --[[Stub for "input" types]] end,
    ["GetValue"] = function() --[[Stub for "input" types]] end,
    ["SetText"] = function(self, text)
        self.text = text
    end,
    ["SetLabel"] = function(self, label)
        self.label = label
    end,
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