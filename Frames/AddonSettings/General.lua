--[[-----------------------------------------------------------------------------
    Lua imports
-------------------------------------------------------------------------------]]

local unpack = unpack

--[[-----------------------------------------------------------------------------
    Ace imports and initialization
    Imports from params:
    - Addon
    - ProfileDB
    - GlobalDB
-------------------------------------------------------------------------------]]

local Addon = unpack(select(2, ...))

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

local LSM = Addon.Libs.LSM
local SettingsHelper = Addon:GetModule("SettingsHelper")

local textOutlines = {
    ["NONE"] = "None",
    ["OUTLINE"] = "Outline",
    ["THICK OUTLINE"] = "Thick Outline",
    ["MONOCHROME"] = "Monochrome"
}

--[[-----------------------------------------------------------------------------
    Options
-------------------------------------------------------------------------------]]

local General = {
    order = 1,
    type = "group",
    name = "General",
    width = "full",
    childGroups = "tab",
    args = {
        appearanceGroup = {
            order = 0,
            type = "group",
            name = "Unit Frame Appearance",
            inline = true,
            get = function(info) return Addon.profile.general.unitFrames[info[#info]] end,
            set = function(info, value) Addon.profile.general.unitFrames[info[#info]] = value end,
            args = {
                barTexture = {
                    order = 0,
                    type = "select",
                    dialogControl = "LSM30_Statusbar",
                    name = "Unit Frame Texture",
                    values = _G.AceGUIWidgetLSMlists.statusbar,
                    get = function(info) return Addon.profile.general.unitFrames[info[#info]] end
                },
            },
        },
        buttonGroup = {
            order = 1,
            type = "group",
            name = "Button Appearance",
            inline = true,
            get = function(info) return Addon.profile.general.buttonFrames[info[#info]] end,
            set = function(info, value) Addon.profile.general.buttonFrames[info[#info]] = value end,
            args = {
                backgroundTexture = {
                    order = 0,
                    type = "select",
                    dialogControl = "LSM30_Background",
                    name = "Button Background Texture",
                    values = _G.AceGUIWidgetLSMlists.background,
                    get = function(info) return Addon.profile.general.buttonFrames[info[#info]] end,
                },
                borderTexture = {
                    order = 1,
                    type = "select",
                    dialogControl = "LSM30_Border",
                    name = "Button Border Texture",
                    values = _G.AceGUIWidgetLSMlists.border,
                    get = function(info) return Addon.profile.general.buttonFrames[info[#info]] end,
                },
                color = {
                    name = "Default Color",
                    order = 2,
                    type = "color",
                    get = function()
                        local c = Addon.profile.general.buttonFrames.color
                        return c.r, c.g, c.b
                    end,
                    set = function(_,r,g,b) Addon.profile.general.buttonFrames.color = { r = r, g = g, b = b } end,
                },
            },
        },
        fontGroup = {
            order = 2,
            type = "group",
            name = "Font",
            inline = true,
            get = function(info) return Addon.profile.general.fontSettings[info[#info]] end,
            set = function(info, value) Addon.profile.general.fontSettings[info[#info]] = value SettingsHelper:UpdateFonts() end,
            args = {
                font = {
                    order = 1,
                    type = "select",
                    dialogControl = "LSM30_Font",
                    name = "Font",
                    values = _G.AceGUIWidgetLSMlists.font
                },
                size = {
                    order = 2,
                    type = "range",
                    min = 8, max = 30, step = 1,
                    name = "Font Size",
                    get = function(info) return tonumber(Addon.profile.general.fontSettings[info[#info]]) end,
                },
                outline = {
                    order = 3,
                    type = "select",
                    name = "Outline Style",
                    values = textOutlines
                },
                fontColor = {
                    name = "Color",
                    type = "color",
                    order = 4,
                    hasAlpha = true,
                    width = 0.5,
                    get = function()
                        local c = Addon.profile.general.fontSettings.color
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        local c = Addon.profile.general.fontSettings.color
                        c.r, c.g, c.b, c.a = r, g, b, a
                        SettingsHelper:UpdateFonts()
                    end
                },
                shadowColor = {
                    name = "Shadow",
                    type = "color",
                    order = 9,
                    hasAlpha = true,
                    width = 0.6,
                    get = function()
                        local c = Addon.profile.general.fontSettings.shadow.Color
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        local c = Addon.profile.general.fontSettings.shadow.Color
                        c.r, c.g, c.b, c.a = r, g, b, a
                        SettingsHelper:UpdateFonts()
                    end
                },
            },
        },
    },
}

Addon.Frames.AddonSettingsGeneral = General