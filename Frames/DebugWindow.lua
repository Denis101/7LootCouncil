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
Addon.DebugWindowOptions = {type = "group", name = "7LC Debug Window", childGroups = "tab", args = {}}
Addon.Libs.AceConfig:RegisterOptionsTable(Addon.AddonName .. "DebugWindow", Addon.DebugWindowOptions)
Addon.Libs.AceConfigDialog:SetDefaultSize(Addon.AddonName .. "DebugWindow", Addon:GetConfigDefaultSize())

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]
Addon.DebugWindowOptions.args = {
    PaginatedList = {
        order = 0,
        type = "group",
        name = "Paginated List",
        childGroups = "tree",
        args = {
            selectGroup = {
                order = 0,
                type = "group",
                name = "Select",
                args = {
                    selectFrame = {
                        order = 0,
                        type = "select",
                        name = "Select",
                        dialogControl = "7LC_PaginatedList",
                        width = "full",
                        values = function()
                            return {}
                        end,
                    },
                },
            },
            multiselectGroup = {
                order = 1,
                type = "group",
                name = "Multiselect",
                args = {
                    multiselectFrame = {
                        order = 0,
                        type = "multiselect",
                        name = "Multiselect",
                        dialogControl = "7LC_PaginatedList",
                        width = "full",
                        values = function()
                            return {}
                        end,
                    },
                },
            },
        },
    },
    SortableTable = {
        order = 1,
        type = "group",
        name = "Sortable Table",
        childGroups = "tab",
        args = {
            table = {
                order = 0,
                type = "select",
                name = "Table",
                width = "full",
                dialogControl = "7LC_SortableTable",
                values = function()
                    return {
                        headings = {
                            {
                                slug = "name", displayText = "Name", widget = "Label", width = 100,
                                desc = function(a,b) return a:upper() > b:upper() end,
                                asc = function(a,b) return a:upper() < b:upper() end,
                            },
                            {
                                slug = "class", displayText = "Class", widget = "Color", width = 100,
                                desc = function(a,b) return a:upper() > b:upper() end,
                                asc = function(a,b) return a:upper() < b:upper() end,
                            },
                            {
                                slug = "note", displayText = "Note", widget = "Label", width = 300,
                                desc = function(a,b) return a:upper() > b:upper() end,
                                asc = function(a,b) return a:upper() < b:upper() end,
                            }
                        },
                        data = {
                            { "Egg", "Priest", "I'm an itiot" },
                            { "Erik", "Warlock", "Rat king prio" },
                            { "Freedom", "Warrior", "Don't worry about it :)" },
                            { "Nayuta", "Rogue", "uwu" },
                            { "Kyr", "Warrior", "Give me golden coins" },
                            { "Mattpriest", "Priest", "hide, hide, hide, hide" },
                            { "Sarcis", "Rogue", "Fucking yellows" },
                            { "Mewn", "Druid", "afk /follow" },
                            { "Wongo", "Mage", "come to my bongo bazaar" },
                            { "Quissy", "Paladin", "guide writer prio" },
                            { "Blodreina", "Paladin", "off-brand frosty" },
                        },
                    }
                end,
            }
        }
    },
}