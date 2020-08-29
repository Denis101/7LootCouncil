--[[-----------------------------------------------------------------------------
    Lua imports
-------------------------------------------------------------------------------]]

local unpack = unpack

--[[-----------------------------------------------------------------------------
    WoW API imports
-------------------------------------------------------------------------------]]

local UnitGUID = UnitGUID

--[[-----------------------------------------------------------------------------
    Ace imports and initialization
    Imports from params:
    - Addon
    - ProfileDB
    - GlobalDB
-------------------------------------------------------------------------------]]
local Addon = unpack(select(2, ...))
local RollManager = Addon:NewModule("RollManager", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0", "AceSerializer-3.0")
local RaidManager = Addon:GetModule("RaidManager")

--[[-----------------------------------------------------------------------------
    Constants
-------------------------------------------------------------------------------]]

local COMMS_PREFIX = "7LC-VM"

local DEFAULT_ROLL_OPTIONS = {
    ["mainspec"] = {
        order = 0,
        enabled = true,
        displayText = "MS",
    },
    ["offspec"] = {
        order = 1,
        enabled = true,
        displayText = "OS",
    },
    ["pvp"] = {
        order = 2,
        enabled = true,
        displayText = "PVP",
    },
}

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

RollManager.Options = {}
RollManager.OptionsUpdateFunc = nil
RollManager.RollOptionTemplate = nil

--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
    Public
-------------------------------------------------------------------------------]]

function RollManager:OnInitialize()
    self:RegisterComm(COMMS_PREFIX)

    for k in pairs(DEFAULT_ROLL_OPTIONS) do
        DEFAULT_ROLL_OPTIONS[k].color = Addon.utils.string.rgb_to_hex(
            Addon.profile.general.buttonFrames.color.r,
            Addon.profile.general.buttonFrames.color.g,
            Addon.profile.general.buttonFrames.color.b
        )
    end
end

function RollManager:OnLoadUI()
    self.Options = Addon.profile.module.roll.myOptions
end

function RollManager:SetOptionsUpdateFunc(func)
    self.OptionsUpdateFunc = func
end

function RollManager:SetRollOptionTemplate(template)
    self.RollOptionTemplate = template
end

function RollManager:GetOrderedOptions(useLocal)
    local options = self.Options
    local raidInfo = RaidManager:MyRaidInfo()
    if not useLocal and ((raidInfo.inParty or raidInfo.inGroup) and not raidInfo.isLeader) then
        options = Addon.profile.module.roll.options[RaidManager:GetGroupLeader()]
    end

    if options == nil then
        return {}
    end

    local result = {}
    for k,v in pairs(options) do
        local r,g,b = Addon.utils.string.hex_to_rgb(v.color)
        table.insert(result, {
            key = k,
            order = v.order,
            displayText = v.displayText,
            enabled = v.enabled,
            color = { r = r, g = g, b = b },
        })
    end

    table.sort(result, function (a,b) return a.order > b.order end)
    return result
end

function RollManager:UpdateOrder(key, order)
    if order < 0 then
        return
    end

    local currentOrder = self.Options[key].order
    local moveKey = nil
    local maxOrder = 0
    for k,v in pairs(self.Options) do
        if v.order == order then
            moveKey = k
        end

        if v.order > maxOrder then
            maxOrder = v.order
        end
    end

    if order > maxOrder then
        return
    end

    if moveKey == nil then
        return
    end

    self.Options[moveKey].order = currentOrder
    self.Options[key].order = order
    self:BuildRollOptions()
end

function RollManager:MoveToFront(key)
    local currentOrder = self.Options[key].order
    if currentOrder == 0 then
        return
    end

    for k,v in pairs(self.Options) do
        if v.order < currentOrder then
            self.Options[k].order = v.order + 1
        end
    end

    self.Options[key].order = 1
    self:BuildRollOptions()
end

function RollManager:MoveToBack(key)
    local currentOrder = self.Options[key].order
    local maxOrder = 0
    for _,v in pairs(self.Options) do
        if v.order > maxOrder then
            maxOrder = v.order
        end
    end

    if currentOrder >= maxOrder then
        return
    end

    for k,v in pairs(self.Options) do
        if v.order > currentOrder then
            RollManager.Options[k].order = v.order - 1
        end
    end

    self.Options[key].order = maxOrder
    self:BuildRollOptions()
end

function RollManager:Remove(key)
    local newOptions = {}
    for k,v in pairs(self.Options) do
        if k ~= key then
            newOptions[k] = v
        end
    end

    self.Options = newOptions
    self:BuildRollOptions()
end

function RollManager:Add()
    local maxOrder = 0
    for _,v in pairs(self.Options) do
        if v.order > maxOrder then
            maxOrder = v.order
        end
    end

    local color = Addon.profile.module.roll.newOption.color
    if color == nil or (color.r == nil and color.g == nil and color.b == nil) then
        color = Addon.profile.general.buttonFrames.color
    end

    self.Options[Addon.profile.module.roll.newOption.id] = {
        order = maxOrder + 1,
        enabled = true,
        color = Addon.utils.string.rgb_to_hex(color.r, color.g, color.b),
        displayText = Addon.profile.module.roll.newOption.displayText,
    }

    Addon.profile.module.roll.newOption = {}
    self:BuildRollOptions()
end

function RollManager:BuildRollOptions()
    local result = {}

    if table.getn(self.Options) <= 0 and Addon.profile.module.roll.defaultOptions then
        self.Options = DEFAULT_ROLL_OPTIONS
    end

    if self.RollOptionTemplate ~= nil then
        for k,v in pairs(self.Options) do
            result[k .. "Group"] = self.RollOptionTemplate(k, v)
        end
    end

    if self.OptionsUpdateFunc ~= nil then
        self.OptionsUpdateFunc(result)
    end

    local channel = nil
    if RaidManager:MyRaidInfo().inRaid then channel = "RAID" else channel = "PARTY" end
    self:SendCommMessage(COMMS_PREFIX, self:Serialize({
        sender = UnitGUID("player"),
        payload = self.Options,
    }), channel)

    Addon.profile.module.roll.defaultOptions = false
    Addon.profile.module.roll.myOptions = self.Options
end

--[[-----------------------------------------------------------------------------
    Comms
-------------------------------------------------------------------------------]]

function RollManager:OnCommReceived(prefix, data, channel, source)
    if not source then
        return
    end
    local info = select(2, self:Deserialize(data))
    Addon.profile.module.roll.options[RaidManager:GetGroupLeader()] = info.payload
end

--[[-----------------------------------------------------------------------------
    Events
-------------------------------------------------------------------------------]]
