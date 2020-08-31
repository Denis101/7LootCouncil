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

--[[-----------------------------------------------------------------------------
    Constants
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

local AceGUI = Addon.Libs.AceGUI
local LSM = Addon.Libs.LSM

local widgetType = "7LC_PaginatedList"
local widgetVersion = 1

--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

local function CreateMainFrame(name, parent)
    local frame = CreateFrame("Frame", name, parent)
    frame:SetWidth(100)
    frame:SetHeight(100)
    if frame.CreateBackdrop then
        frame:CreateBackdrop()
    end
    frame:Show()
    return frame
end

--[[-----------------------------------------------------------------------------
    Methods
-------------------------------------------------------------------------------]]

local methods = {
    ["OnAcquire"] = function(self)
        self.multiselect = false
        self:SetDisabled(false)
    end,
    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
    end,
    ["SetText"] = function(self, text)
        self.text = text
    end,
    ["SetLabel"] = function(self, label)
        self.label = label
    end,
    ["SetMultiselect"] = function(self, value) self.multiselect = value end,
    ["SetList"] = function(self, list) --[[Stub for "select" types]] end,
    ["SetValue"] = function(self, value) --[[Stub for "input" types]] end,
    ["GetValue"] = function(self) --[[Stub for "input" types]] end,
    ["OnEnterPressed"] = function(self, text) --[[Stub for "input" types]] end,
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