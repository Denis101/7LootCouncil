--[[-----------------------------------------------------------------------------
    Lua imports
-------------------------------------------------------------------------------]]

local unpack = unpack

--[[-----------------------------------------------------------------------------
    WoW API imports
-------------------------------------------------------------------------------]]

local UnitGUID, UnitClassBase, UnitName = UnitGUID, UnitClassBase, UnitName
local GetHomePartyInfo, GetRaidRosterInfo, GetClassColor = GetHomePartyInfo, GetRaidRosterInfo, GetClassColor
local UnitInParty, UnitInRaid, IsInRaid, UnitIsGroupLeader = UnitInParty, UnitInRaid, IsInRaid, UnitIsGroupLeader

--[[-----------------------------------------------------------------------------
    Ace imports and initialization
    Imports from params:
    - Addon
    - ProfileDB
    - GlobalDB
-------------------------------------------------------------------------------]]
local Addon = unpack(select(2, ...))
local RaidManager = Addon:NewModule("RaidManager", "AceEvent-3.0", "AceHook-3.0")

--[[-----------------------------------------------------------------------------
    Constants
-------------------------------------------------------------------------------]]

local UNIT_FRAME_BACKDROP = {
    bgFile = AceGUIWidgetLSMlists.background["Solid"],
    edgeFile = nil,
    tile = true, tileSize = 8, edgeSize = 0
}

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

RaidManager.Roster = {}
RaidManager.RosterDisplay = {}
RaidManager.RosterByGUID = {}
RaidManager.Groups = {}
RaidManager.GroupLeader = nil

--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

-- TODO; Add master looter support
local function UpdatePartyRoster()
    local roster, rosterByGuid, group = {}, {}, {}
    local groupLeader = nil

    local myUnitInfo = {
        name = UnitName("player"),
        rank = (UnitIsGroupLeader("player") and 2) or 0,
        group = 1,
        class = UnitClassBase("player"),
        role = nil,
        isML = false,
        guid = UnitGUID("player"),
    }

    if myUnitInfo.rank == 2 then
        groupLeader = myUnitInfo
    end

    table.insert(group, myUnitInfo)
    table.insert(roster, myUnitInfo)
    rosterByGuid[myUnitInfo.guid] = myUnitInfo

    local partyMembers = GetHomePartyInfo()
    if partyMembers == nil then
        return {
            roster = roster,
            rosterByGuid = rosterByGuid,
            groups = { group },
            groupLeader = groupLeader,
        }
    end

    for i = 1, #partyMembers do
        local unitId = "party" .. i
        local rank = (UnitIsGroupLeader(unitId) and 2) or 0
        local unitInfo = {
            name = partyMembers[i],
            rank = rank,
            group = 1,
            class = UnitClassBase(unitId),
            role = nil,
            isML = false,
            guid = UnitGUID(unitId),
        }

        if rank == 2 then
            groupLeader = unitInfo.guid
        end

        table.insert(group, unitInfo)
        table.insert(roster, unitInfo)
        rosterByGuid[unitInfo.guid] = unitInfo
    end

    return {
        roster = roster,
        rosterByGuid = rosterByGuid,
        groups = { group },
        groupLeader = groupLeader,
    }
end

local function UpdateRaidRoster()
    local roster, rosterByGuid, groups = {}, {}, {}
    local groupLeader = nil

    for i = 1, 40 do
        local name, rank, grp, _, _, cls, _, _, _, role, ml = GetRaidRosterInfo(i)
        if name == nil then
            return nil
        end

        local unitInfo = {
            name = name,
            rank = rank,
            group = grp,
            class = cls,
            role = role,
            isML = ml,
            guid = UnitGUID("raid" .. i),
        }

        if rank == 2 then
            groupLeader = unitInfo.guid
        end

        table.insert(roster, unitInfo)
        rosterByGuid[unitInfo.guid] = unitInfo

        if groups[grp] == nil then
            groups[grp] = {}
            groups[grp][1] = unitInfo
        else
            table.insert(groups[grp], unitInfo)
        end
    end

    return {
        roster = roster,
        rosterByGuid = rosterByGuid,
        groups = groups,
        groupLeader = groupLeader,
    }
end

local function UpdateRoster()
    local rosterInfo = nil
    if IsInRaid("LE_PARTY_CATEGORY_HOME") then
        rosterInfo = UpdateRaidRoster()
    else
        rosterInfo = UpdatePartyRoster()
    end

    local rosterDisplay = {}
    for i = 1, #rosterInfo.roster do
        local info = rosterInfo.roster[i]
        local rankDisplay = ""
        if info.rank == 2 then
            rankDisplay = " - Leader"
        elseif info.rank == 1 then
            rankDisplay = " - Assist"
        end
        table.insert(rosterDisplay, info.name .. rankDisplay)
    end

    RaidManager.Roster = rosterInfo.roster
    RaidManager.RosterDisplay = rosterDisplay
    RaidManager.RosterByGUID = rosterInfo.rosterByGuid
    RaidManager.Groups = rosterInfo.groups
    RaidManager.GroupLeader = rosterInfo.groupLeader
end

-- local function CreateUnitFrame(unitInfo)
--     local AceGUI = Addon.Libs.AceGUI
--     local grp = AceGUI:Create("SimpleGroup")
--     grp:SetWidth(100)
--     grp:SetCallback("OnClick", function() print(unitInfo.name) end)

--     local playerName = AceGUI:Create("Label")
--     playerName:SetWidth(50)
--     playerName:SetText(unitInfo.name)
--     grp:AddChild(playerName)

--     local playerChoice = AceGUI:Create("Label")
--     playerChoice:SetWidth(25)
--     playerChoice:SetText("MS")
--     grp:AddChild(playerChoice)

--     local voteBtn = AceGUI:Create("Button")
--     voteBtn:SetWidth(25)
--     voteBtn:SetText("x")
--     voteBtn.frame:SetPoint("TOPRIGHT")
--     grp:AddChild(voteBtn)

--     grp.frame:SetBackdrop(UNIT_FRAME_BACKDROP)
--     grp.frame:SetBackdropColor(GetClassColor(unitInfo.class))
--     return grp
-- end

--[[-----------------------------------------------------------------------------
    Public
-------------------------------------------------------------------------------]]

function RaidManager:OnInitialize()
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    UpdateRoster()
end

function RaidManager:OnDisable()
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
end

function RaidManager:RenderRoster()
    local AceGUI = Addon.Libs.AceGUI
    local f = AceGUI:Create("Frame")

    f:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    f:SetLayout("Flow")

    -- for i = 1, table.getn(RaidManager.Roster) do
    --     f:AddChild(CreateUnitFrame(RaidManager.Roster[i]))
    -- end
end

function RaidManager:MyRaidInfo()
    local unitInfo = RaidManager.RosterByGUID[UnitGUID("player")]
    local isLeader = UnitIsGroupLeader("player")

    return {
        isML = unitInfo and unitInfo.isML,
        rank = unitInfo and unitInfo.rank,
        groupNumber = unitInfo and unitInfo.group,
        role = unitInfo and unitInfo.role,
        inParty = UnitInParty("player"),
        inRaid = UnitInRaid("player"),
        isLeader = isLeader,
        groupLeader = (isLeader and UnitGUID("player")) or (RaidManager.GroupLeader and RaidManager.GroupLeader.guid)
    }
end

function RaidManager:GetRaidRoster()
    return RaidManager.Roster
end

function RaidManager:GetRaidRosterDisplay()
    return RaidManager.RosterDisplay
end

function RaidManager:GetGroupLeader()
    return RaidManager.GroupLeader
end

function RaidManager:ShowGroupCouncil()
    local raidInfo = self:MyRaidInfo()
    return (raidInfo.inParty and not raidInfo.isLeader)
end

--[[-----------------------------------------------------------------------------
    Events
-------------------------------------------------------------------------------]]

function RaidManager:GROUP_ROSTER_UPDATE()
	UpdateRoster()
end