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

local widgetType = "7LC_SortableTable"
local widgetVersion = 1

--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

local function PopulateTable()
end

local function BuildHeading(heading, size, offset)
    
end

local function BuildTable(frame, headings, data)
    local headCount = #headings
    local headingSize = frame.width / headCount

    frame.headings = {}
    for i,v in ipairs(headings) do
        local offset = (i - 1) * headingSize
        local headingFrame = BuildHeading(v, headingSize, offset)
        table.insert(frame.headings, headingFrame)
    end
end

local function CreateMainFrame(name, parent)
    local frame = CreateFrame("Frame", name, parent)
    frame:Size(1, 1)
    frame:CreateBackdrop()
    frame:Show()
    return frame
end

--[[-----------------------------------------------------------------------------
    Methods
-------------------------------------------------------------------------------]]

local methods = {
    ["OnAcquire"] = function(self)
        self:SetDisabled(false)
        self:SetFullWidth(true)
    end,
    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        if disabled then
            -- do things
        else
            -- do other things
        end
    end,
    ["SetMultiselect"] = function(self, value) self.multiselect = value end,
    ["SetValue"] = function(self, value) --[[Stub for "input" types]] end,
    ["GetValue"] = function(self) --[[Stub for "input" types]] end,
    ["SetList"] = function(self, list)
        self.headings = list.headings
        self.data = list.data
        BuildTable(self.frame, self.headings, self.data)
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