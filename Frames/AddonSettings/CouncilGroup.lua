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

local RM = Addon:GetModule("RaidManager")

--[[-----------------------------------------------------------------------------
    Options
-------------------------------------------------------------------------------]]

local CouncilGroup = {
    order = 3,
    type = "group",
    name = "Loot Council (Group)",
    width = "full",
    childGroups = "tab",
    hidden = function() return not RM:ShowGroupCouncil() end,
    args = {
        info = {
            name = "This shows the current loot council for the raid you are in. It is only configured by the current group leader",
            order = 0,
            type = "description",
            width = "full",
        },
        members = {
            name = "Members",
            order = 1,
            type = "multiselect",
            disabled = true,
            hidden = function()
                return Addon.profile.module.council.councils[RM:MyRaidInfo().groupLeader] == nil
            end,
            values = function()
                local result = {}
                local values = Addon.profile.module.council.councils[RM:MyRaidInfo().groupLeader]
                if values == nil then
                    return result
                end
                for k,v in pairs(values) do
                    if v then
                        result[k] = k
                    end
                end
                return result
            end,
        },
    },
}

Addon.Frames.AddonSettingsCouncilGroup = CouncilGroup