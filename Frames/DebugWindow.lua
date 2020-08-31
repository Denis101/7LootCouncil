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

local testData = {
    { "Egg", "PRIEST", "I'm an itiot" },
    { "Erik", "WARLOCK", "Rat king prio" },
    { "Freedom", "WARRIOR", "Don't worry about it :)" },
    { "Nayuta", "ROGUE", "uwu" },
    { "Kyr", "WARRIOR", "Give me golden coins" },
    { "Mattpriest", "PRIEST", "hide, hide, hide, hide" },
    { "Sarcis", "ROGUE", "Fucking yellows" },
    { "Mewn", "DRUID", "afk /follow" },
    { "Wongo", "MAGE", "come to my bongo bazaar" },
    { "Quissy", "PALADIN", "guide writer prio" },
    { "Blodreina", "PALADIN", "off-brand frosty" },
}

local defaultTableFrame = {
    order = 0,
    type = "select",
    name = "SortableTable",
    width = "relative",
    dialogControl = "7LC_SortableTable",
    values = function()
        return {
            headings = {
                { slug = "name", displayText = "Name" },
                { slug = "class", displayText = "Class" },
                { slug = "note", displayText = "Note" },
            },
            data = testData,
        }
    end,
}

local classColorTableFrame = {
    order = 0,
    type = "select",
    name = "SortableTable",
    width = "relative",
    dialogControl = "7LC_SortableTable",
    values = function()
        return {
            headings = {
                {
                    slug = "name", displayText = "Name", widget = "7LC_TableLabel", width = 100,
                    desc = function(a,b) return a:upper() > b:upper() end,
                    asc = function(a,b) return a:upper() < b:upper() end,
                },
                {
                    slug = "class", displayText = "Class", widget = "7LC_TableClass", width = 100,
                    desc = function(a,b) return a:upper() > b:upper() end,
                    asc = function(a,b) return a:upper() < b:upper() end,
                },
                {
                    slug = "note", displayText = "Note", widget = "7LC_TableLabel", width = 300,
                    desc = function(a,b) return a:upper() > b:upper() end,
                    asc = function(a,b) return a:upper() < b:upper() end,
                }
            },
            data = testData,
        }
    end,
}

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
        childGroups = "tree",
        args = {
            defaultTable = {
                order = 0,
                type = "group",
                name = "Default table",
                inline = true,
                args = {
                    table = defaultTableFrame,
                }
            },
            classColorTable = {
                order = 1,
                type = "group",
                name = "Class color table",
                inline = true,
                args = {
                    table = classColorTableFrame,
                }
            },
        },
    },
    TableWidgets = {
        order = 2,
        type = "group",
        name = "Table Widgets",
        childGroups = "tab",
        args = {
            labelGroup = {
                order = 0,
                type = "group",
                name = "TableLabel",
                width = "full",
                inline = true,
                args = {
                    label = {
                        order = 0,
                        type = "input",
                        name = "7LC_TableLabel",
                        width = "full",
                        dialogControl = "7LC_TableLabel",
                        get = function() return "This is a dumb label" end,
                    },
                }
            },
            classGroup = {
                order = 1,
                type = "group",
                name = "TableClass",
                width = "full",
                inline = true,
                args = {
                    druid = {
                        order = 0,
                        type = "input",
                        name = "7LC_TableClass_Druid",
                        width = "full",
                        dialogControl = "7LC_TableClass",
                        get = function() return "DRUID" end,
                    },
                    hunter = {
                        order = 1,
                        type = "input",
                        name = "7LC_TableClass_Hunter",
                        width = "full",
                        dialogControl = "7LC_TableClass",
                        get = function() return "HUNTER" end,
                    },
                    mage = {
                        order = 2,
                        type = "input",
                        name = "7LC_TableClass_Mage",
                        width = "full",
                        dialogControl = "7LC_TableClass",
                        get = function() return "MAGE" end,
                    },
                    paladin = {
                        order = 3,
                        type = "input",
                        name = "7LC_TableClass_Paladin",
                        width = "full",
                        dialogControl = "7LC_TableClass",
                        get = function() return "PALADIN" end,
                    },
                    priest = {
                        order = 4,
                        type = "input",
                        name = "7LC_TableClass_Priest",
                        width = "full",
                        dialogControl = "7LC_TableClass",
                        get = function() return "PRIEST" end,
                    },
                    rogue = {
                        order = 5,
                        type = "input",
                        name = "7LC_TableClass_Rogue",
                        width = "full",
                        dialogControl = "7LC_TableClass",
                        get = function() return "ROGUE" end,
                    },
                    shaman = {
                        order = 6,
                        type = "input",
                        name = "7LC_TableClass_Shaman",
                        width = "full",
                        dialogControl = "7LC_TableClass",
                        get = function() return "SHAMAN" end,
                    },
                    warlock = {
                        order = 7,
                        type = "input",
                        name = "7LC_TableClass_Warlock",
                        width = "full",
                        dialogControl = "7LC_TableClass",
                        get = function() return "WARLOCK" end,
                    },
                    warrior = {
                        order = 8,
                        type = "input",
                        name = "7LC_TableClass_Warrior",
                        width = "full",
                        dialogControl = "7LC_TableClass",
                        get = function() return "WARRIOR" end,
                    },
                },
            },
        }
    }
}