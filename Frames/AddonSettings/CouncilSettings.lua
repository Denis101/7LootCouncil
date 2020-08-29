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

local CM = Addon:GetModule("CouncilManager")
local RM = Addon:GetModule("RaidManager")

--[[-----------------------------------------------------------------------------
    Options
-------------------------------------------------------------------------------]]

local CouncilSettings = {
    order = 2,
    type = "group",
    name = "Loot Council",
    width = "full",
    childGroups = "tab",
    args = {
        memberSettings = {
            order = 1,
            name = "Council Member Settings",
            type = "group",
            width = "full",
            inline = true,
            args = {
                lockCouncil = {
                    name = "Lock Council",
                    order = 0,
                    type = "toggle",
                    get = function()
                        return Addon.profile.module.council.locked
                    end,
                    set = function(_, value)
                        Addon.profile.module.council.locked = value
                    end,
                },
                members = {
                    name = "Members",
                    order = 1,
                    type = "multiselect",
                    disabled = function() return Addon.profile.module.council.locked end,
                    values = function()
                        local result = {}
                        for k,v in pairs(Addon.profile.module.council.myCouncil) do
                            if v then
                                result[k] = k
                            end
                        end
                        return result
                    end,
                    set = function(_, k)
                        Addon.profile.councilMembers[k] = false
                        CM:UpdateCouncil(Addon.profile.module.council.myCouncil)
                    end,
                },
                addOpts = {
                    name = "Add Members",
                    order = 2,
                    type = "group",
                    inline = true,
                    args = {
                        addByName = {
                            name = "Add By Name",
                            order = 0,
                            type = "input",
                            width = "full",
                            -- TODO VALIDATE
                            set = function(_, value)
                                -- Do sanity checks, make sure player exists
                                Addon.profile.module.council.myCouncil[value] = true
                                CM:UpdateCouncil(Addon.profile.module.council.myCouncil)
                            end,
                        },
                        -- TODO ADD FROM FRIENDS
                        addFromGroup = {
                            name = "Add From Group",
                            order = 1,
                            type = "multiselect",
                            values = function() return RM:GetRaidRosterDisplay() end,
                            get = function(_, k)
                                local n = RM:GetRaidRoster()[k].name
                                return Addon.profile.module.council.myCouncil[n]
                            end,
                            set = function(_, k, v)
                                local n = RM:GetRaidRoster()[k].name
                                Addon.profile.module.council.myCouncil[n] = v
                                CM:UpdateCouncil(Addon.profile.module.council.myCouncil)
                            end
                        },
                        addFromGuild = {
                            name = "Add From Guild",
                            order = 2,
                            type = "group",
                            inline = true,
                            args = {
                                filters = {
                                    name = "Filters",
                                    order = 0,
                                    type = "group",
                                    inline = true,
                                    args = {
                                        filterLevel = {
                                            name = "Level 60 Only",
                                            order = 0,
                                            type = "toggle",
                                        },
                                        filterOfficer = {
                                            name = "Officers Only",
                                            order = 1,
                                            type = "toggle",
                                        },
                                        filterMinRank = {
                                            name = "Minimum Guild Rank",
                                            order = 2,
                                            type = "select",
                                            values = function() return {"Egg", "loves", "dongs"} end,
                                            get = function() return "donglord" end,
                                        },
                                    },
                                },
                                members = {
                                    name = "Members",
                                    order = 1,
                                    type = "multiselect",
                                    values = function() return CM:GetGuildRosterPretty() end,
                                    get = function(_, k)
                                        local n = CM:GetGuildRosterSorted()[k]
                                        return Addon.profile.module.council.myCouncil[n]
                                    end,
                                    set = function(_, k, v)
                                        local n = CM:GetGuildRosterSorted()[k]
                                        Addon.profile.module.council.myCouncil[n] = v
                                        CM:UpdateCouncil(Addon.profile.module.council.myCouncil)
                                    end
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

Addon.Frames.AddonSettingsCouncilSettings = CouncilSettings