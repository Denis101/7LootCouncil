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

local Addon, _, GlobalDB = unpack(select(2, ...))

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

local RoM = Addon:GetModule("RollManager")

--[[-----------------------------------------------------------------------------
    Options
-------------------------------------------------------------------------------]]

local RollOptions = {
    order = 4,
    type = "group",
    name = "Roll Options",
    args = {
        preview = {
            name = "Loot Roll Preview",
            order = 0,
            type = "group",
            inline = true,
            args = {
                lootPreview = {
                    order = 0,
                    type = "select",
                    name = "Loot Preview",
                    dialogControl = "7LC_LootPreview",
                    width = "full",
                    values = function()
                        return {
                            itemId = GlobalDB.PreviewItemIds[math.random(1, table.getn(GlobalDB.PreviewItemIds))],
                            opts = RoM:GetOrderedOptions(true),
                            time = Addon.profile.module.roll.myTimer,
                        }
                    end,
                },
            },
        },
        lootSettings = {
            order = 0,
            name = "Loot Roll Settings",
            type = "group",
            width = "full",
            inline = true,
            args = {
                lootTimer = {
                    order = 0,
                    name = "Loot Timer (seconds)",
                    desc = "Sets how long players will see the loot roll window before being passed to the council for a vote",
                    type = "range",
                    min = 5,
                    max = 120,
                    step = 1,
                    bigStep = 5,
                    get = function() return Addon.profile.module.roll.myTimer end,
                    set = function(_,v) Addon.profile.module.roll.myTimer = v end,
                },
            },
        },
        availableOptions = {
            name = "Available Roll Options",
            order = 1,
            type = "group",
            inline = true,
            args = {},
        },
        addOption = {
            name = "Add Option",
            order = 2,
            type = "group",
            inline = true,
            args = {
                identifier = {
                    order = 0,
                    name = "ID",
                    type = "input",
                    -- TODO VALIDATE
                    get = function() return Addon.profile.module.roll.newOption.id end,
                    set = function(_, v) Addon.profile.module.roll.newOption.id = v end,
                },
                displayText = {
                    order = 1,
                    name = "Display Name",
                    type = "input",
                    width = "full",
                    -- TODO VALIDATE
                    get = function() return Addon.profile.module.roll.newOption.displayText end,
                    set = function(_, v) Addon.profile.module.roll.newOption.displayText = v end,
                },
                color = {
                    name = "Button Color",
                    order = 2,
                    type = "color",
                    width = "full",
                    -- TODO VALIDATE
                    get = function()
                        local c = Addon.profile.module.roll.newOption.color or Addon.profile.general.buttonFrames.color
                        return c.r, c.g, c.b
                    end,
                    set = function(_,r,g,b) Addon.profile.module.roll.newOption.color = { r = r, g = g, b = b } end,
                },
                submit = {
                    order = 3,
                    name = "Add",
                    type = "execute",
                    width = "full",
                    func = function() RoM:Add() end,
                }
            },
        },
    },
}

local rollOptionTemplate = function(k, v)
    return {
        name = k,
        order = v.order,
        type = "group",
        inline = true,
        args = {
            enabled = {
                name = "Enabled",
                order = 0,
                type = "toggle",
                get = function() return v.enabled end,
                set = function(_,val)
                    RoM.Options[k].enabled = val
                    RoM:BuildRollOptions()
                end,
            },
            remove = {
                name = "Remove",
                order = 1,
                type = "execute",
                func = function() RoM:Remove(k) end,
            },
            displayText = {
                name = "Display Name",
                order = 2,
                type = "input",
                width = "full",
                get = function() return v.displayText end,
                set = function(_,val)
                    RoM.Options[k].displayText = val
                    RoM:BuildRollOptions()
                end,
            },
            color = {
                name = "Button Color",
                order = 3,
                type = "color",
                width = "full",
                get = function() return Addon.utils.string.hex_to_rgb(v.color) end,
                set = function(_,r,g,b)
                    RoM.Options[k].color = Addon.utils.string.rgb_to_hex(r,g,b)
                end,
            },
            moveOpts = {
                name = "Change Order",
                order = 4,
                type = "group",
                inline = true,
                args = {
                    moveUp = {
                        name = "Up",
                        order = 0,
                        type = "execute",
                        func = function() RoM:UpdateOrder(k, v.order-1) end,
                    },
                    moveDown = {
                        name = "Down",
                        order = 1,
                        type = "execute",
                        func = function() RoM:UpdateOrder(k, v.order+1) end,
                    },
                    moveToTop = {
                        name = "To Top",
                        order = 2,
                        type = "execute",
                        func = function() RoM:MoveToFront(k) end,
                    },
                    moveToBottom = {
                        name = "To Bottom",
                        order = 3,
                        type = "execute",
                        func = function() RoM:MoveToBack(k) end,
                    },
                },
            },
        },
    }
end

Addon.Frames.AddonSettingsRollOptions = RollOptions

local LoadUI=CreateFrame("Frame")
LoadUI:RegisterEvent("PLAYER_LOGIN")
LoadUI:SetScript("OnEvent", function()
    RoM:SetRollOptionTemplate(rollOptionTemplate)
    RoM:SetOptionsUpdateFunc(function(result)
        Addon.Frames.AddonSettings.args.InnerOptions.args.RollOptions.args.availableOptions.args = result
    end)
    RoM:BuildRollOptions()
end)