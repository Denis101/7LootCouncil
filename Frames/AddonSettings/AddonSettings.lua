--[[-----------------------------------------------------------------------------
    Lua imports
-------------------------------------------------------------------------------]]

local unpack = unpack
local format = format

--[[-----------------------------------------------------------------------------
    Ace imports and initialization
    Imports from params:
    - Addon
    - ProfileDB
    - GlobalDB
-------------------------------------------------------------------------------]]

local Addon, _, GlobalDB = unpack(select(2, ...))
Addon.Frames.AddonSettings = {
    type = "group",
    name = Addon.AddonName .. " - Version" .. format(": %s%s|r", GlobalDB.JuisedBlue.displayText, GlobalDB.general.version),
    childGroups = "tab",
}

Addon.Libs.AceConfig:RegisterOptionsTable(Addon.AddonName .. "AddonSettings", Addon.Frames.AddonSettings)
Addon.Libs.AceConfigDialog:SetDefaultSize(Addon.AddonName .. "AddonSettings", Addon:GetConfigDefaultSize())

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

Addon.Frames.AddonSettings.args = {
    Main = {
        order = 0,
        type = "group",
        name = "",
        inline = true,
        args = {
            CouncilGroup = Addon.Frames.AddonSettings.CouncilGroup,
        },
    },
    InnerOptions = {
        order = 1,
        type = "group",
        name = "Options",
        childGroups = "tree",
        args = {
            General = Addon.Frames.AddonSettingsGeneral,
            CouncilSettings = Addon.Frames.AddonSettingsCouncilSettings,
            RollOptions = Addon.Frames.AddonSettingsRollOptions,
        }
    },
}