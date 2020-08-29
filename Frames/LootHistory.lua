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
Addon.LootHistoryOptions = {type = "group", name = "Loot History", args = {}}
Addon.Libs.AceConfig:RegisterOptionsTable(Addon.AddonName .. "LootHistory", Addon.LootHistoryOptions)
Addon.Libs.AceConfigDialog:SetDefaultSize(Addon.AddonName .. "LootHistory", Addon:GetConfigDefaultSize())

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

Addon.LootHistoryOptions.childGroups = "tab"

Addon.LootHistoryOptions.args = {
    Header = {
        order = 0,
        type = "header",
        name = "Version" .. format(": %s%s|r", GlobalDB.JuisedBlue.displayText, GlobalDB.general.version),
        width = "full"
    },
}