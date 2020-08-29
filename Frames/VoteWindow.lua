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
Addon.VoteWindowOptions = {type = "group", name = "Loot History", args = {}}
Addon.Libs.AceConfig:RegisterOptionsTable(Addon.AddonName .. "VoteWindow", Addon.VoteWindowOptions)
Addon.Libs.AceConfigDialog:SetDefaultSize(Addon.AddonName .. "VoteWindow", Addon:GetConfigDefaultSize())

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

Addon.VoteWindowOptions.childGroups = "tab"

Addon.VoteWindowOptions.args = {
    Header = {
        order = 0,
        type = "header",
        name = "Version" .. format(": %s%s|r", GlobalDB.JuisedBlue.displayText, GlobalDB.general.version),
        width = "full"
    },
}