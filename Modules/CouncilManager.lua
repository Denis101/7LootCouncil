--[[-----------------------------------------------------------------------------
    Lua imports
-------------------------------------------------------------------------------]]
local unpack = unpack
local tsort = table.sort
local strmatch = strmatch

--[[-----------------------------------------------------------------------------
    WoW API imports
-------------------------------------------------------------------------------]]

local UnitGUID = UnitGUID
local SetGuildRosterShowOffline, GuildRoster, GetNumGuildMembers, GetGuildRosterInfo = SetGuildRosterShowOffline, GuildRoster, GetNumGuildMembers, GetGuildRosterInfo

--[[-----------------------------------------------------------------------------
    Ace imports and initialization
    Imports from params:
    - Addon
    - ProfileDB
    - GlobalDB
-------------------------------------------------------------------------------]]
local Addon = unpack(select(2, ...))
local CouncilManager = Addon:NewModule("CouncilManager", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0", "AceSerializer-3.0")
local RaidManager = Addon:GetModule("RaidManager")

--[[-----------------------------------------------------------------------------
    Constants
-------------------------------------------------------------------------------]]

local RANK_INDEX_TO_COLOR_CODES = {
    "|cFFFF8000",
    "|cFFA335EE",
    "|cFF0070FF",
    "|cFF1EFF0C",
}

local OTHER_RANKS_COLOR_CODE = "|cFFFFFFFF"

local COMMS_PREFIX = "7LC-CM"

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

CouncilManager.CouncilMembers = {}
CouncilManager.GuildRoster = {}
CouncilManager.GuildRosterSorted = {}
CouncilManager.GuildRosterPretty = {}
CouncilManager.GuildMembers = 0

--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

local function GetNameFromDisplayName(displayName)
    return Addon.utils.string.trim(select(1, strmatch(displayName,"(.-)-(.*)$")))
end

local function UpdateRoster()
    local roster = {}
    local rosterSorted = {}

    CouncilManager.GuildMembers = GetNumGuildMembers()
    for i = 1, CouncilManager.GuildMembers do
        local pname, rankName, rankIndex, level, _, _, _, officerNote, _, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
        local name = strmatch(pname,"(.-)%-(.*)$") or pname

        local unitInfo = {
            name = name,
            rankName = rankName,
            rankIndex = rankIndex,
        }

        roster[name] = unitInfo
        table.insert(rosterSorted, unitInfo.name)
    end

    tsort(rosterSorted, function(a, b)
        return roster[a].rankIndex < roster[b].rankIndex
    end)

    local prettyRoster = {}
    for i = 1, #rosterSorted do
        local unitInfo = roster[rosterSorted[i]]
        local color = RANK_INDEX_TO_COLOR_CODES[unitInfo.rankIndex+1] or OTHER_RANKS_COLOR_CODE
        local prettyName = unitInfo.name .. " - " .. color .. unitInfo.rankName
        table.insert(prettyRoster, prettyName)
    end

    CouncilManager.GuildRoster = roster
    CouncilManager.GuildRosterSorted = rosterSorted
    CouncilManager.GuildRosterPretty = prettyRoster
end

--[[-----------------------------------------------------------------------------
    Public
-------------------------------------------------------------------------------]]

function CouncilManager:OnInitialize()
    self:RegisterComm(COMMS_PREFIX)
    self:RegisterEvent("GUILD_ROSTER_UPDATE")
    SetGuildRosterShowOffline(true)
    GuildRoster()
    UpdateRoster()
end

function CouncilManager:OnDisable()
    self:UnregisterEvent("GUILD_ROSTER_UPDATE")
    SetGuildRosterShowOffline(false)
end

function CouncilManager:UpdateCouncil(councilMembers)
    if councilMembers == nil or table.getn(councilMembers) == 0 then
        return
    end

    CouncilManager.CouncilMembers = councilMembers
    local channel
    if RaidManager:MyRaidInfo().inRaid then channel = "RAID" else channel = "PARTY" end
    self:SendCommMessage(COMMS_PREFIX, self:Serialize({
        sender = UnitGUID("player"),
        payload = councilMembers,
    }), channel)
end

function CouncilManager:GetGuildRosterSorted()
    return CouncilManager.GuildRosterSorted
end

function CouncilManager:GetGuildRosterPretty()
    return CouncilManager.GuildRosterPretty
end

function CouncilManager:GetNameFromDisplayName(displayName)
    return GetNameFromDisplayName(displayName)
end

--[[-----------------------------------------------------------------------------
    Comms
-------------------------------------------------------------------------------]]

function CouncilManager:OnCommReceived(prefix, data, channel, source)
    if not source then
        return
    end
    local info = select(2, self:Deserialize(data))
    Addon.profile.module.council.councils[info.sender] = info.payload
end

--[[-----------------------------------------------------------------------------
    Events
-------------------------------------------------------------------------------]]

function CouncilManager:GUILD_ROSTER_UPDATE()
    UpdateRoster()
    self:UpdateCouncil(Addon.profile.module.council.myCouncil or {})
end