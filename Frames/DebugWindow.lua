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
        childGroups = "select",
        args = {
            table = {
                order = 0,
                type = "multiselect",
                name = "Table",
                dialogControl = "7LC_SortableTable",
                width = "full",
                values = function()
                    return {
                        headings = {
                            { slug = "name", displayText = "Name", widget = "Label", comparator = function(a,b) return a > b end, },
                            { slug = "class", displayText = "Class", widget = "Color", comparator = function(a,b) return a > b end, },
                            { slug = "note", displayText = "Note", widget = "Label", comparator = function(a,b) return a > b end, }
                        },
                        data = {
                            { "Egg", "Priest", "I'm an itiot" },
                            { "Erik", "Warlock", "Rat king prio" },
                            { "Freedom", "Warrior", "Don't worry about it :)" }
                        },
                    }
                end,
            }
        }
    },
}